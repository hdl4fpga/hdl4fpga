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
		my_mac        : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_txc   : in  std_logic;
		txc_rxdv  : buffer std_logic;
		mii_col   : in  std_logic := '0';
		mii_crs   : in  std_logic := '0';
		mii_txd   : buffer std_logic_vector;
		mii_txen  : buffer std_logic;

		ipv4acfg_req : in  std_logic;
		myipv4a   : buffer std_logic_vector(0 to 32-1);

		sio_clk   : in  std_logic;
		si_frm    : in  std_logic := '0';
		si_irdy   : in  std_logic := '0';
		si_trdy   : out std_logic;
		si_data   : in  std_logic_vector;

		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector;

		tp        : out std_logic_vector(1 to 32));

	constant phyo_idle : std_logic := '1';

	constant my_port : std_logic_vector(0 to 16-1) := std_logic_vector(to_unsigned(57001, 16));
end;

architecture struct of sio_udp is

	signal txc_rxd  : std_logic_vector(mii_rxd'range);

	signal dll_rxdv        : std_logic;
	signal dllhwsa_rx      : std_logic_vector(0 to 48-1);
	signal dllfcs_vld      : std_logic;
	signal dllcrc32        : std_logic_vector(0 to 32-1);

	signal ipv4sa_rx       : std_logic_vector(0 to 32-1);
	signal udpsp_rx        : std_logic_vector(0 to 16-1);
	signal udpdp_rxdv      : std_logic;
	signal udppl_rxdv      : std_logic;

	signal flow_req      : std_logic;
	signal flow_gnt      : std_logic;

	signal flow_hwdatx     : std_logic_vector(48-1 downto 0);
	signal flow_ipv4datx   : std_logic_vector(32-1 downto 0);
	signal flow_udpdptx    : std_logic_vector(16-1 downto 0);
	signal flow_udpsptx    : std_logic_vector(16-1 downto 0);
	signal flow_udplentx   : std_logic_vector(16-1 downto 0);

	signal udppl_txen      : std_logic;
	signal udppl_txd       : std_logic_vector(mii_rxd'range);

	signal tx_ack          : std_logic_vector(8-1 downto 0);

	signal usr_gnt         : std_logic;
	signal usr_rdy         : std_logic;

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

	signal buffer_data     : std_logic_vector(txc_rxd'range);
	signal buffer_irdy     : std_logic;

	signal flow_frm        : std_logic;
	signal flow_irdy       : std_logic;
	signal flow_trdy       : std_logic;
	signal flow_data       : std_logic_vector(txc_rxd'range);

	signal myport_rcvd     : std_logic;
	signal flowfcs_vld     : std_logic;

begin

	mii_ipoe_e : entity hdl4fpga.mii_ipoe
	generic map (
		default_ipv4a  => default_ipv4a,
		my_mac         => my_mac)
	port map (
		mii_rxc        => mii_rxc,
		mii_rxd        => mii_rxd,
		mii_rxdv       => mii_rxdv,

		mii_txc        => mii_txc,
		mii_col        => mii_col,
		mii_crs        => mii_crs,
		mii_txd        => mii_txd,
		mii_txen       => mii_txen,

		txc_rxdv       => txc_rxdv,
		txc_rxd        => txc_rxd,

		udpsp_rxdv     => udpsp_rxdv,
		ipv4sa_rxdv    => ipv4sa_rxdv,
		dllhwsa_rxdv   => dllhwsa_rxdv,
		dhcpipv4a_rxdv => dhcpipv4a_rxdv,

		tx_req         => flow_req,
		tx_gnt         => flow_gnt,

		dll_rxdv       => dll_rxdv,
		dllhwsa_rx     => dllhwsa_rx,
		dllfcs_vld     => dllfcs_vld,

		ipv4sa_rx      => ipv4sa_rx,
		ipv4acfg_req   => ipv4acfg_req,
                                       
		udpdp_rxdv     => udpdp_rxdv,
		udppl_rxdv     => udppl_rxdv,
		udpsp_rx       => udpsp_rx,

		dll_hwda       => flow_hwdatx,
		ipv4_da        => flow_ipv4datx,
		udpsp_tx       => flow_udpsptx,
		udpdp_tx       => flow_udpdptx,
		udppl_txlen    => flow_udplentx,

		udppl_txen     => udppl_txen,
		udppl_txd      => udppl_txd,
		tp => tp);

	rx_b : block
	begin
		myport_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(my_port,8))
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => dll_rxdv,
			mii_rxd  => txc_rxd,
			mii_ena  => udpdp_rxdv,
			mii_equ  => myport_rcvd);

		siohwsa_e : entity hdl4fpga.sio_mii
		port map (
			sio_pfix => hwsa_pfix,
			mii_txc  => mii_txc,
			mii_rxdv => dllhwsa_rxdv,
			mii_rxd  => txc_rxd,
			mii_txen => siohwsa_txen,
			mii_txd  => siohwsa_txd);

		sioipv4_e : entity hdl4fpga.sio_mii
		port map (
			sio_pfix => ipv4a_pfix,
			mii_txc  => mii_txc,
			mii_rxdv => ipv4sa_rxdv,
			mii_rxd  => txc_rxd,
			mii_txen => sioipv4a_txen,
			mii_txd  => sioipv4a_txd);

		sioipv4sa_e : entity hdl4fpga.sio_mii
		port map (
			sio_pfix => ipv4a_pfix,
			mii_txc  => mii_txc,
			mii_rxdv => dhcpipv4a_rxdv,
			mii_rxd  => txc_rxd,
			mii_txen => dhcpipv4a_txen,
			mii_txd  => dhcpipv4a_txd);

		sioipport_e : entity hdl4fpga.sio_mii
		port map (
			sio_pfix => sp_pfix,
			mii_txc  => mii_txc,
			mii_rxdv => udpsp_rxdv,
			mii_rxd  => txc_rxd,
			mii_txen => siosp_txen,
			mii_txd  => siosp_txd);

		buffer_irdy <= dhcpipv4a_txen or siohwsa_txen or sioipv4a_txen or siosp_txen or (udppl_rxdv and myport_rcvd);
		buffer_data <= wirebus(
			dhcpipv4a_txd  & siohwsa_txd  & sioipv4a_txd  & siosp_txd  & txc_rxd, 
			dhcpipv4a_txen & siohwsa_txen & sioipv4a_txen & siosp_txen & (udppl_rxdv and myport_rcvd));

		flowfcs_vld <= dllfcs_vld and myport_rcvd;

	end block;

	flow_e : entity hdl4fpga.sio_flow
	port map (
		phyi_clk    => mii_txc,
		phyi_frm    => txc_rxdv,
		phyi_fcsvld => flowfcs_vld,

		buffer_frm  => txc_rxdv,
		buffer_irdy => buffer_irdy,
		buffer_data => buffer_data,

		so_clk      => sio_clk,
		so_frm      => so_frm,
		so_irdy     => so_irdy,
		so_trdy     => so_trdy,
		so_data     => so_data,

		si_clk      => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_trdy     => si_trdy,
		si_data     => si_data,

		phyo_clk    => mii_txc,
		phyo_frm    => flow_frm,
		phyo_irdy   => flow_irdy,
		phyo_trdy   => flow_trdy,
		phyo_data   => flow_data);

	tx_b : block

		signal rgtr_trdy    : std_logic;
		signal rgtr_idv     : std_logic;
		signal rgtr_id      : std_logic_vector(8-1 downto 0);
		signal rgtr_frm     : std_logic;
		signal rgtr_data    : std_logic_vector(txc_rxd'range);
		signal data_frm     : std_logic;
		signal data_irdy    : std_logic;
		signal sout_irdy    : std_logic;

		signal sigdata_frm  : std_logic;
		signal sigrgtr_id   : std_logic_vector(8-1 downto 0);
		signal sigrgtr_dv   : std_logic;
		signal sigrgtr_data : std_logic_vector(0 to 48-1);
		alias  sig_data     : std_logic_vector(sigrgtr_data'reverse_range) is sigrgtr_data;

		signal lat_frm  : std_logic;
		constant xxx : natural := rgtr_id'length/flow_data'length;
		constant xxx1 : natural := rgtr_data'length;
	begin

		siosin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => flow_frm,
			sin_irdy  => flow_irdy,
			sin_trdy  => flow_trdy,
			sin_data  => flow_data,
			data_frm  => data_frm,
			data_irdy => data_irdy,
			sout_irdy => sout_irdy,
			rgtr_frm  => rgtr_frm,
			rgtr_idv  => rgtr_idv,
			rgtr_trdy => rgtr_trdy,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		sig_b : block
		begin

			sigdata_frm <= data_frm and setif(rgtr_id=x"00"); 
			sig_e : entity hdl4fpga.sio_sin
			port map (
				sin_clk   => sio_clk,
				sin_frm   => sigdata_frm,
				sin_irdy  => sout_irdy,
				sin_data  => rgtr_data,
				rgtr_id   => sigrgtr_id,
				rgtr_dv   => sigrgtr_dv,
				rgtr_data => sigrgtr_data);

			flow_udpsptx <= my_port; 
			process(sio_clk)
			begin
				if rising_edge(sio_clk) then
					if sigrgtr_dv='1' then
						case sigrgtr_id is
						when x"01" =>
							flow_hwdatx   <= reverse(sig_data(flow_hwdatx'range),8);
						when x"02" =>
							flow_ipv4datx <= reverse(sig_data(flow_ipv4datx'range),8);
						when x"03" =>
							flow_udpdptx  <= reverse(sig_data(flow_udpdptx'range),8);
						when x"04" =>
							flow_udplentx <= reverse(sig_data(flow_udplentx'range),8);
						when others =>
						end case;
					end if;
				end if;
			end process;
		end block;

		latfrm_e : entity hdl4fpga.align 
		generic map (
			n => 1,
			d => (0 to 0 => xxx-1))
		port map (
			clk => sio_clk,
			di(0)  => rgtr_frm,
			do(0)  => lat_frm);

		rgtr_trdy <= setif((to_bitvector(rgtr_id)=x"00" and to_bit(rgtr_frm)='1') or to_bit(flow_gnt)='1');
		latdat_e : entity hdl4fpga.align 
		generic map (
			n => xxx1,
			d => (0 to xxx1-1 => xxx-1+1))
		port map (
			clk => sio_clk,
			ena => rgtr_trdy,
			di  => rgtr_data,
			do  => udppl_txd);

		process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if to_bitvector(rgtr_id)=x"00" then
					flow_req   <= '0';
					udppl_txen <= '0';
				elsif lat_frm='1' then
					flow_req   <= '1';
					udppl_txen <= flow_gnt;
				else
					flow_req   <= '0';
					udppl_txen <= '0';
				end if;
			end if;
		end process;

	end block;
		
--	tp(1) <= txc_rxdv;
--	tp(2) <= '1';
--	tp(3 to 3+udppl_txd'length-1) <= txc_rxd;

end;
