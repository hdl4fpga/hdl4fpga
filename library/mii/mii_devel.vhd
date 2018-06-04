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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity mii_debug is
	generic (
		mac       : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		btn       : in  std_logic:= '0';
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_req   : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		video_clk : in  std_logic;
		video_dot : out std_logic;
		video_hs  : out std_logic;
		video_vs  : out std_logic);
	end;

architecture struct of mii_debug is

	signal pre_vld  : std_logic;
	signal bcst_vld : std_logic;
	signal mac_vld  : std_logic;
	signal ip_vld   : std_logic;
	signal arp_vld  : std_logic;
	signal udp_vld  : std_logic;

	signal pkt_vld  : std_logic;
begin

	mii_ipcfg_e : entity hdl4fpga.mii_ipcfg
	generic map (
		mac       => x"00_40_00_01_02_03")
	port map (
		mii_req   => mii_req,

		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,

		mii_txc   => mii_txc,
		mii_txdv  => mii_txdv,
		mii_txd   => mii_txd,

		mii_prev  => pre_vld,
		mii_bcstv => bcst_vld,
		mii_macv  => mac_vld,
		mii_ipv   => ip_vld,
		mii_udpv  => udp_vld);

	pkt_vld <= ip_vld;
	mii_display_e : entity hdl4fpga.mii_display
	port map (
		mii_rxc   => mii_rxc,
		mii_rxdv  => pkt_vld,
		mii_rxd   => mii_rxd,

		video_clk => video_clk,
		video_dot => video_dot,
		video_hs  => video_hs,
		video_vs  => video_vs);

end;
