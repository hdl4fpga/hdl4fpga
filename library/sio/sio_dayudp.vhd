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

entity sio_dayudp is
	generic (
		default_ipv4a : std_logic_vector(0 to 32-1) := x"00_00_00_00";
		my_mac        : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		ipv4acfg_req  : in  std_logic := '-';

		phy_rx_dv   : in  std_logic;
		phy_rx_d    : in  std_logic_vector;

		phy_txc     : in  std_logic;
		txc_rxdv    : out std_logic;
		phy_col     : in  std_logic := '0';
		phy_crs     : in  std_logic := '0';
		phy_rxc     : in  std_logic;
		phy_tx_en   : out std_logic;
		phy_tx_d    : out std_logic_vector;
	
		sio_clk     : in  std_logic;
		sio_addr    : in  std_logic := '0';

		si_frm      : in  std_logic := '0';
		si_irdy     : in  std_logic := '0';
		si_trdy     : out std_logic := '0';
		si_data     : in  std_logic_vector;

		so_frm      : out std_logic;
		so_irdy     : out std_logic;
		so_trdy     : in  std_logic;
		so_data     : out std_logic_vector;
		tp : out std_logic_vector(1 to 4));
	
end;

architecture beh of sio_dayudp is

	signal siudp_frm  : std_logic;
	signal siudp_irdy : std_logic;
	signal siudp_trdy : std_logic;
	signal soudp_frm  : std_logic;
	signal soudp_irdy : std_logic;
	signal soudp_trdy : std_logic;
	signal soudp_data : std_logic_vector(so_data'range);

begin

	siudp_frm  <= '0' when sio_addr/='0' else si_frm;
	siudp_irdy <= '0' when sio_addr/='0' else si_irdy;
	soudp_trdy <= '0' when sio_addr/='0' else so_trdy;

	sioudpp_e : entity hdl4fpga.sio_udp
	generic map (
		default_ipv4a => default_ipv4a,
		my_mac        => my_mac)
	port map (
		mii_rxc     => phy_rxc,
		mii_rxdv    => phy_rx_dv,
		mii_rxd     => phy_rx_d,

		mii_col     => phy_col,
		mii_crs     => phy_crs,
		mii_txc     => phy_txc,
		txc_rxdv    => txc_rxdv,
		mii_txen    => phy_tx_en,
		mii_txd     => phy_tx_d,

		ipv4acfg_req => ipv4acfg_req,
		sio_clk     => sio_clk,
		si_frm      => siudp_frm,
		si_irdy     => siudp_irdy,
		si_trdy     => siudp_trdy,
		si_data     => si_data,
		so_frm      => soudp_frm,
		so_irdy     => soudp_irdy,
		so_trdy     => soudp_trdy,
		so_data     => soudp_data,
		tp => tp);

	si_trdy <= so_trdy when sio_addr/='0' else siudp_trdy;
	so_frm  <= si_frm  when sio_addr/='0' else soudp_frm; 
	so_irdy <= si_irdy when sio_addr/='0' else soudp_irdy;
	so_data <= si_data when sio_addr/='0' else soudp_data;

end;
