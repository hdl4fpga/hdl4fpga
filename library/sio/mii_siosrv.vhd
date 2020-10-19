--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity mii_siosrv is
	generic (
		mysrv_port    : std_logic_vector(0 to 16-1));
	port (
		mii_txc       : in  std_logic;

		dll_rxdv      : in  std_logic;
		dll_rxd       : in std_logic_vector;

		dllhwsa_rx    : in  std_logic_vector(0 to 48-1);
		dllcrc32_rxdv : in std_logic;
		dllcrc32_equ  : in std_logic;

		ipv4sa_rx     : in  std_logic_vector(0 to 32-1);

		udpdp_rxdv    : in  std_logic;
		udppl_rxdv    : in  std_logic;

		udpsp_rx      : in  std_logic_vector(0 to 16-1);

		tx_req        : out std_logic := '0';
		tx_rdy        : in  std_logic;
		tx_gnt        : in  std_logic;

		dll_hwda      : out std_logic_vector(0 to 48-1) := (others => '-');
		ipv4_da       : out std_logic_vector(0 to 32-1) := (others => '-');
		udppl_len     : out std_logic_vector(0 to 16-1) := (others => '-');
		udp_dp        : out std_logic_vector(0 to 16-1) := (others => '-');
		udp_sp        : out std_logic_vector(0 to 16-1);

		udppl_txen    : out  std_logic;
		udppl_txd     : out  std_logic_vector;
		pkt_cmmt      : out  std_logic;
		cmmt_ena      : out  std_logic;
		tp            : buffer std_logic_vector(1 to 4));

end;

architecture def of mii_siosrv is
	signal myport_rcvd  : std_logic;
	signal mysrv_rcvd   : std_logic;
	signal dllcrc32_eor : std_logic;

	signal rgtr_id      : std_logic_vector(8-1 downto 0);
	signal siosin_frm   : std_logic;
	signal octect_frm   : std_logic;
	signal octect_irdy  : std_logic;
	signal octect_data  : std_logic_vector(8-1 downto 0);
	signal sigsin_frm   : std_logic;
	signal sigrgtr_data : std_logic_vector(8-1 downto 0);
	signal sig_frm      : std_logic;
	signal sig_irdy     : std_logic;
	signal sigrgtr_id   : std_logic_vector(8-1 downto 0);
	signal sigrgtr_dv   : std_logic;
	signal ack_rgtr     : std_logic_vector(8-1 downto 0);
	signal ack_dv   : std_logic;
	signal data : std_logic_vector(0 to 40-1);

begin

	data <= x"00" & x"02" & x"00" & x"00" & ack_rgtr;
	siosin_frm <= udppl_rxdv and myport_rcvd;
	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => mii_txc,
		sin_frm   => udppl_rxdv,
		sin_data  => dll_rxd,
		rgtr_id   => rgtr_id,
		data_frm  => octect_frm,
		data_irdy => octect_irdy,
		rgtr_data => octect_data);

	sigsin_frm <= octect_frm and setif(rgtr_id=x"00");
	sigsin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => mii_txc,
		sin_frm   => sigsin_frm,
		sin_irdy  => octect_irdy,
		sin_data  => octect_data,
		data_frm  => sig_frm,
		data_irdy => sig_irdy,
		rgtr_id   => sigrgtr_id,
		rgtr_dv   => sigrgtr_dv,
		rgtr_data => sigrgtr_data);

	sigseq_e : entity hdl4fpga.sio_rgtr
	generic map (
		rid  => x"00")
	port map (
		rgtr_clk  => mii_txc,
		rgtr_id   => sigrgtr_id,
		rgtr_dv   => sigrgtr_dv,
		rgtr_data => sigrgtr_data,
		data      => ack_rgtr,
		dv        => ack_dv);

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			dllcrc32_eor <= dllcrc32_rxdv;
		end if;
	end process;

	myport_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(mysrv_port,8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => dll_rxdv,
		mii_rxd  => dll_rxd,
		mii_ena  => udpdp_rxdv,
		mii_equ  => myport_rcvd);
	udp_sp <= mysrv_port;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if tx_rdy='0' then
				if myport_rcvd='1' then
					dll_hwda <= dllhwsa_rx;
					ipv4_da  <= ipv4sa_rx;
					udp_dp   <= udpsp_rx;
				end if;
			end if;
		end if;
	end process;

	process (mii_txc)
		variable pkt_rcvd : std_logic;
		variable ack_last : std_logic_vector(ack_rgtr'range);
		variable ack_rcvd : std_logic;
		variable txrdy_edge : std_logic;
	begin
		if rising_edge(mii_txc) then
			if tx_rdy='1' then
				if txrdy_edge='0' then
					tx_req <= '0';
				end if;
			end if;
			txrdy_edge := tx_rdy;

			pkt_cmmt <= '0';
			cmmt_ena <= '0';
			if dllcrc32_rxdv='0' then
				if dllcrc32_eor='1' then
					if dllcrc32_equ='1' then
						if pkt_rcvd='1'  then
							if ack_rcvd='1' then
								tx_req   <= '1';
								pkt_cmmt <= setif(ack_rgtr/=ack_last);
								ack_last := ack_rgtr;
							else
								pkt_cmmt <= '1';
							end if;
							cmmt_ena <= '1';
						end if;
					end if;
					pkt_rcvd := '0';
					ack_rcvd := '0';
				end if;
			end if;

			if ack_dv='1' then
				ack_rcvd := '1';
			end if;

			if dll_rxdv='1'then
				pkt_rcvd := myport_rcvd;
			end if;
		end if;
	end process;

	udppl_len <= std_logic_vector(to_unsigned((data'length+octect_size-1)/octect_size, udppl_len'length));
	myack_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => data,
        mii_txc  => mii_txc,
		mii_txdv => tx_gnt,
        mii_txen => udppl_txen,
        mii_txd  => udppl_txd);

end;
