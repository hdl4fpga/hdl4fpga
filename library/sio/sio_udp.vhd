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

entity sio_udp is
	generic (
		default_ipv4a : std_logic_vector(0 to 32-1) := x"00_00_00_00";
		mymac         : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txen  : out std_logic;

		ipv4acfg_req : in  std_logic;
		myipv4a   : buffer std_logic_vector(0 to 32-1);

		sio_clk   : in  std_logic;
		si_frm    : in  std_logic := '0';
		si_irdy   : in  std_logic := '0';
		si_trdy   : out std_logic := '0';

		so_dv     : out std_logic;
		so_data   : out std_logic_vector);
end;

architecture struct of sio_udp is

	signal txc_rxd  : std_logic_vector(mii_rxd'range);
	signal txc_rxdv : std_logic;

	signal dll_rxdv        : std_logic;
	signal dllhwsa_rx      : std_logic_vector(0 to 48-1);
	signal dllcrc32_rxdv   : std_logic;
	signal dllcrc32_equ    : std_logic;
	signal dllcrc32_rxd    : std_logic_vector(mii_rxd'range);
	signal dllcrc32        : std_logic_vector(0 to 32-1);

	signal ipv4sa_rx       : std_logic_vector(0 to 32-1);
	signal udpsp_rx        : std_logic_vector(0 to 16-1);
	signal udpdp_rxdv      : std_logic;
	signal udppl_rxdv      : std_logic;

	signal mysrv_req       : std_logic;
	signal mysrv_rdy       : std_logic;
	signal mysrv_gnt       : std_logic;
	signal mysrv_hwda      : std_logic_vector(0 to 48-1);
	signal mysrv_ipv4da    : std_logic_vector(0 to 32-1);
	signal mysrv_udpdp     : std_logic_vector(0 to 16-1);
	signal mysrv_udpsp     : std_logic_vector(0 to 16-1);

	signal mysrv_udppltxd  : std_logic_vector(mii_rxd'range);
	signal mysrv_udppllen  : std_logic_vector(0 to 16-1);
	signal mysrv_udppltxen : std_logic;
	signal mysrv_pktcmmt   : std_logic;
	signal mysrv_cmmtena   : std_logic;

	signal dllhwsa_rxdv    : std_logic;
	signal ipv4sa_rxdv     : std_logic;
	signal dhcpipv4a_rxdv  : std_logic;

	constant hwsa_pfix     : std_logic_vector := x"00" & x"07" & x"01" & x"05";
	signal siohwsa_txen    : std_logic;
	signal siohwsa_txd     : std_logic_vector(mii_rxd'range);

	constant ipv4a_pfix    : std_logic_vector := x"00" & x"05" & x"02" & x"03";
	signal sioipv4a_txen   : std_logic;
	signal sioipv4a_txd    : std_logic_vector(mii_rxd'range);

	constant dhcpipv4a_pfix : std_logic_vector := x"00" & x"05" & x"03" & x"03";
	signal dhcpipv4a_txen  : std_logic;
	signal dhcpipv4a_txd   : std_logic_vector(mii_rxd'range);

begin

	mii_ipoe_e : entity hdl4fpga.mii_ipoe
	generic map (
		default_ipv4a => default_ipv4a,
		mymac         => mymac)
	port map (
		mii_rxc       => mii_rxc,
		mii_rxd       => mii_rxd,
		mii_rxdv      => mii_rxdv,

		mii_txc       => mii_txc,
		mii_txd       => mii_txd,
		mii_txen      => mii_txen,

		txc_rxdv      => txc_rxdv,
		txc_rxd       => txc_rxd,

		ipv4sa_rxdv   => ipv4sa_rxdv,
		dllhwsa_rxdv  => dllhwsa_rxdv,
		dhcpipv4a_rxdv=> dhcpipv4a_rxdv,
		tx_req        => mysrv_req,
		tx_rdy        => mysrv_rdy,
		tx_gnt        => mysrv_gnt,
		dll_hwda      => mysrv_hwda,
		ipv4_da       => mysrv_ipv4da,
		dll_rxdv      => dll_rxdv,
		dllhwsa_rx    => dllhwsa_rx,
		dllcrc32_rxdv => dllcrc32_rxdv,
		dllcrc32_rxd  => dllcrc32_rxd,
		dllcrc32_equ  => dllcrc32_equ,

		ipv4sa_rx     => ipv4sa_rx,
		ipv4acfg_req  => ipv4acfg_req,
                                      
		udpdp_rxdv    => udpdp_rxdv,
		udppl_rxdv    => udppl_rxdv,
		udpsp_rx      => udpsp_rx,
		udp_sp        => mysrv_udpsp,
		udp_dp        => mysrv_udpdp,
		udppl_len     => mysrv_udppllen,
		udppl_txen    => mysrv_udppltxen,
		udppl_txd     => mysrv_udppltxd);

	miisio_e : entity hdl4fpga.mii_siosrv
	generic map (
		mysrv_port => std_logic_vector(to_unsigned(57001, 16)))
	port map (
		mii_txc       => mii_txc,
                                      
		dll_rxdv      => dll_rxdv,
		dll_rxd       => txc_rxd,
                                      
		dllhwsa_rx    => dllhwsa_rx,
		dllcrc32_rxdv => dllcrc32_rxdv,
		dllcrc32_equ  => dllcrc32_equ,
                                      
		ipv4sa_rx     => ipv4sa_rx,
                                      
		udppl_rxdv    => udppl_rxdv,
		udpdp_rxdv    => udpdp_rxdv,
		udpsp_rx      => udpsp_rx,
                                      
		tx_rdy        => mysrv_rdy,
		tx_req        => mysrv_req,
		tx_gnt        => mysrv_gnt,
		dll_hwda      => mysrv_hwda,
		ipv4_da       => mysrv_ipv4da,
		udppl_len     => mysrv_udppllen,
		udp_dp        => mysrv_udpdp,
		udp_sp        => mysrv_udpsp,
		pkt_cmmt      => mysrv_pktcmmt,
		cmmt_ena      => mysrv_cmmtena,
		udppl_txen    => mysrv_udppltxen,
		udppl_txd     => mysrv_udppltxd);

	siohwsa_e : entity hdl4fpga.mii_sio
	port map (
		sio_pfix => hwsa_pfix,
		mii_txc  => mii_txc,
		mii_rxdv => dllhwsa_rxdv,
		mii_rxd  => txc_rxd,
		mii_txen => siohwsa_txen,
		mii_txd  => siohwsa_txd);

	sioipv4_e : entity hdl4fpga.mii_sio
	port map (
		sio_pfix => ipv4a_pfix,
		mii_txc  => mii_txc,
		mii_rxdv => ipv4sa_rxdv,
		mii_rxd  => txc_rxd,
		mii_txen => sioipv4a_txen,
		mii_txd  => sioipv4a_txd);

	sioipv4sa_e : entity hdl4fpga.mii_sio
	port map (
		sio_pfix => ipv4a_pfix,
		mii_txc  => mii_txc,
		mii_rxdv => dhcpipv4a_rxdv,
		mii_rxd  => txc_rxd,
		mii_txen => dhcpipv4a_txen,
		mii_txd  => dhcpipv4a_txd);

	buffer_p : block
		constant mem_size : natural := 2048*8;
		signal serdes_frm : std_logic;
		signal ser_data : std_logic_vector(mii_rxd'range);
		signal des_data : std_logic_vector(so_data'range);

		constant addr_length : natural := unsigned_num_bits(mem_size/so_data'length-1);
		subtype addr_range is natural range 1 to addr_length;

		signal wr_ptr    : unsigned(0 to addr_length) := (others => '0');
		signal wr_cntr   : unsigned(0 to addr_length) := (others => '0');
		signal rd_cntr   : unsigned(0 to addr_length) := (others => '0');

		signal src_trdy  : std_logic;
		signal des_irdy  : std_logic;
		signal dst_irdy  : std_logic;
		signal dst_irdy1 : std_logic;

	begin

		serdes_frm <= dhcpipv4a_txen or siohwsa_txen or sioipv4a_txen or udppl_rxdv;
		ser_data   <= wirebus(
			dhcpipv4a_txd & siohwsa_txd & sioipv4a_txd & txc_rxd, siohwsa_txen & sioipv4a_txen & udppl_rxdv);
		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => mii_txc,
			serdes_frm => udppl_rxdv,
			ser_irdy   => '1',
			ser_data   => ser_data,

			des_irdy   => des_irdy,
			des_data   => des_data);

		src_trdy <= setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0));
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if udppl_rxdv='1' then
					if src_trdy='1' then
						if des_irdy='1' then
							wr_cntr <= wr_cntr + 1;
						end if;
					else
					end if;
				elsif mysrv_cmmtena='1' then
					if mysrv_pktcmmt='0' then
						wr_cntr <= wr_ptr;
					else
						wr_ptr  <= wr_cntr;
					end if;
				end if;
			end if;
		end process;

		mem_e : entity hdl4fpga.dpram(def)
		generic map (
			synchronous_rdaddr => false,
			synchronous_rddata => true)
		port map (
			wr_clk  => mii_txc,
			wr_ena  => des_irdy,
			wr_addr => std_logic_vector(wr_cntr(addr_range)),
			wr_data => des_data, 

			rd_clk  => sio_clk,
			rd_addr => std_logic_vector(rd_cntr(addr_range)),
			rd_data => so_data);

		dst_irdy1 <= setif(wr_ptr /= rd_cntr);
		process(sio_clk)
		begin
			if rising_edge(sio_clk) then
				so_dv <= dst_irdy1;
				if dst_irdy1='1' then
					rd_cntr <= rd_cntr + 1;
				end if;
			end if;
		end process;

	end block;

end;
