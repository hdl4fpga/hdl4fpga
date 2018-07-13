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

entity scopeio_debug is
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

architecture struct of scopeio_debug is

	signal txc  : std_logic;
	signal txdv : std_logic;
	signal txd  : std_logic_vector(mii_txd'range);

	signal d_rxc  : std_logic;
	signal d_rxdv : std_logic;
	signal d_rxd  : std_logic_vector(mii_txd'range);
	signal udpdport_vld : std_logic_vector(0 to 0);

	constant cga_addr : natural := 0;
	constant cga_data : natural := 1;

	constant scopeio_rgtrmap : natural_vector(0 to 2-1) := (
		cga_addr => 14,
		cga_data => 8);
	subtype rgtr_cgaaddr is natural range 14-1 downto  0;
	subtype rgtr_cgadata is natural range 22-1 downto 14;
	signal scopeio_rgtr : std_logic_vector(14+8-1 downto 0);

	signal mem_data : std_logic_vector(0 to 16-1);
	signal data_len : std_logic_vector(0 to 16-1);
begin

	txc <= mii_txc;
	mii_txdv <= txdv;
	mii_txd  <= txd;

	mii_ipcfg_e : entity hdl4fpga.mii_ipcfg
	generic map (
		mac       => x"00_40_00_01_02_03")
	port map (
		mii_req   => mii_req,

		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,
		udpdport_dat => x"0000",
		udpdport_vld => udpdport_vld,

		mii_txc   => mii_txc,
		mii_txdv  => txdv,
		mii_txd   => txd);

	scopeio_sin_e : entity hdl4fpga.scopeio_sin
	generic map (
		rgtr_map => scopeio_rgtrmap)
	port map (
		sin_clk  => mii_rxc,
		sin_dv   => udpdport_vld(0),
		sin_data => mii_rxd,
		rgtr     => scopeio_rgtr,
		mem_data => mem_data,
		data_len => data_len);

	cga_display_e : entity hdl4fpga.cga_display
	port map (
		cga_clk  => mii_rxc,
		cga_addr => scopeio_rgtr(rgtr_cgaaddr),
		cga_data => scopeio_rgtr(rgtr_cgadata),

		video_clk => video_clk,
		video_dot => video_dot,
		video_hs  => video_hs,
		video_vs  => video_vs);

end;
