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
		si_trdy   : buffer std_logic := '0';
		si_data   : in  std_logic_vector;

		so_dv     : out std_logic;
		so_data   : out std_logic_vector;
		tp : out std_logic_vector(1 to 1));
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

	signal tx_hwda         : std_logic_vector(48-1 downto 0);
	signal tx_ipv4da       : std_logic_vector(32-1 downto 0);
	signal tx_ipport       : std_logic_vector(16-1 downto 0);

	signal usr_txd         : std_logic_vector(mii_txd'range);
	signal usr_req         : std_logic;
	signal usr_gnt         : std_logic;
	signal usr_rdy         : std_logic;
	signal usr_trdy        : std_logic;
	signal usr_txen        : std_logic;

	signal dllhwsa_rxdv    : std_logic;
	signal udpsp_rxdv      : std_logic;
	signal ipv4sa_rxdv     : std_logic;
	signal dhcpipv4a_rxdv  : std_logic;

	constant hwsa_pfix     : std_logic_vector := x"00" & x"07" & x"01" & x"05";
	signal siohwsa_txen    : std_logic;
	signal siohwsa_txd     : std_logic_vector(mii_rxd'range);

	constant ipv4a_pfix    : std_logic_vector := x"00" & x"05" & x"02" & x"03";
	signal sioipv4a_txen   : std_logic;
	signal sioipv4a_txd    : std_logic_vector(mii_rxd'range);

	constant sp_pfix       : std_logic_vector := x"00" & x"03" & x"03" & x"01";
	signal siosp_txen      : std_logic;
	signal siosp_txd       : std_logic_vector(mii_rxd'range);

	constant dhcpipv4a_pfix : std_logic_vector := x"00" & x"05" & x"03" & x"03";
	signal dhcpipv4a_txen  : std_logic;
	signal dhcpipv4a_txd   : std_logic_vector(mii_rxd'range);

	signal tp1 : std_logic_vector(1 to 4);
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

		udpsp_rxdv    => udpsp_rxdv,
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
		udppl_txd     => mysrv_udppltxd,

		usr_req       => usr_req,
		usr_gnt       => usr_gnt,
		usr_rdy       => usr_rdy,
		usr_hwda      => tx_hwda,
		usr_ipv4da    => tx_ipv4da,
		usr_udpdp     => tx_ipport,
		usr_txen      => usr_txen,
		usr_txd       => usr_txd,
		tp => tp1);
	--tp(1) <= tp1(1);

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

	sioipport_e : entity hdl4fpga.mii_sio
	port map (
		sio_pfix => sp_pfix,
		mii_txc  => mii_txc,
		mii_rxdv => udpsp_rxdv,
		mii_rxd  => txc_rxd,
		mii_txen => siosp_txen,
		mii_txd  => siosp_txd);

	buffer_p : block
		constant mem_size : natural := 2048*8;
		signal ser_irdy : std_logic;
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

		ser_irdy <= dhcpipv4a_txen or siohwsa_txen or sioipv4a_txen or siosp_txen or udppl_rxdv;
		ser_data <= wirebus(
			dhcpipv4a_txd  & siohwsa_txd  & sioipv4a_txd  & siosp_txd  & txc_rxd, 
			dhcpipv4a_txen & siohwsa_txen & sioipv4a_txen & siosp_txen & udppl_rxdv);

		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => mii_txc,
			serdes_frm => txc_rxdv,
			ser_irdy   => ser_irdy,
			ser_data   => ser_data,

			des_irdy   => des_irdy,
			des_data   => des_data);

		src_trdy <= setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0));
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if ser_irdy='1' then
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
		tp(1) <= dst_irdy1;
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

	tx_b : block

		signal rgtr_frm     : std_logic;
		signal rgtr_irdy    : std_logic;
		signal rgtr_trdy    : std_logic;
		signal rgtr_idv     : std_logic;
		signal rgtr_id      : std_logic_vector(8-1 downto 0);
		signal rgtr_lv      : std_logic;
		signal rgtr_len     : std_logic_vector(8-1 downto 0);
		signal rgtr_dv      : std_logic;
		signal rgtr_data    : std_logic_vector(32-1 downto 0);
		signal data_frm     : std_logic;
		signal data_irdy    : std_logic;
		signal data_ptr     : std_logic_vector(8-1 downto 0);

		signal sigdata_frm  : std_logic;
		signal sigrgtr_id   : std_logic_vector(8-1 downto 0);
		signal sigrgtr_dv   : std_logic;
		signal sigrgtr_data : std_logic_vector(48-1 downto 0);
		signal des_frm      : std_logic;
		signal des_data     : std_logic_vector(8-1 downto 0);
		signal ser_irdy     : std_logic;
		signal ser_data     : std_logic_vector(mii_rxd'range);


	begin

		siosin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => si_frm,
			sin_irdy  => si_irdy,
			sin_trdy  => si_trdy,
			sin_data  => si_data,
			data_frm  => data_frm,
			data_ptr  => data_ptr,
			data_irdy => data_irdy,
			rgtr_frm  => rgtr_frm,
			rgtr_irdy => rgtr_irdy,
			rgtr_trdy => rgtr_trdy,
			rgtr_idv  => rgtr_idv,
			rgtr_id   => rgtr_id,
			rgtr_lv   => rgtr_lv,
			rgtr_len  => rgtr_len,
			rgtr_dv   => rgtr_dv,
			rgtr_data => rgtr_data);

		sigdata_frm <= data_frm and setif(rgtr_id=x"00"); 
		sig_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => sigdata_frm,
			sin_irdy  => data_irdy,
			sin_data  => rgtr_data(so_data'range),
			rgtr_id   => sigrgtr_id,
			rgtr_dv   => sigrgtr_dv,
			rgtr_data => sigrgtr_data);

		process(sio_clk)
		begin
			if rising_edge(sio_clk) then
				if sigrgtr_dv='1' then
					case sigrgtr_id is
					when x"01" =>
						tx_hwda   <= sigrgtr_data(tx_hwda'range);
					when x"02" => 
						tx_ipv4da <= sigrgtr_data(tx_ipv4da'range);
					when x"03" => 
						tx_ipport <= sigrgtr_data(tx_ipport'range);
					when others =>
					end case;
				end if;
			end if;
		end process;

		des_data <= rgtr_data(des_data'range);
		des_frm  <= rgtr_idv and setif(rgtr_id /= x"00");

		desser_e : entity hdl4fpga.desser
		port map (
			desser_clk => sio_clk,
			des_frm    => des_frm,
			des_irdy   => rgtr_irdy,
			des_trdy   => usr_trdy,
			des_data   => des_data,
			ser_irdy   => ser_irdy, 
			ser_data   => ser_data);

		rgtr_trdy <= setif(des_frm='0', rgtr_frm, usr_gnt and usr_trdy);
		usr_txen  <= ser_irdy and usr_gnt;
		usr_txd   <= ser_data;
		process (des_frm, sio_clk)
		begin
			if rising_edge(sio_clk) then
				if des_frm='1' then
					usr_req <= '1';
				elsif usr_rdy='1' then
					usr_req <= '0';
				end if;
			end if;
		end process;

		
	end block;
--	tp(1) <= si_frm; --usr_req;
end;
