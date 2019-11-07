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
use hdl4fpga.cgafont.all;

library unisim;
use unisim.vcomponents.all;

architecture mii_debug of arty is
	signal sys_clk        : std_logic;
	signal mii_req        : std_logic;
	signal vga_dot      : std_logic;
	signal vga_vs       : std_logic;
	signal vga_hs       : std_logic;
	signal vga_clk      : std_logic;

	signal rxc  : std_logic;
	signal rxd  : std_logic_vector(eth_rxd'range);
	signal rxdv : std_logic;

	signal txc  : std_logic;
	signal txd  : std_logic_vector(eth_txd'range);
	signal txdv : std_logic;

	type display_param is record
		dcm_mul    : natural;
		dcm_div    : natural;
	end record;

	type layout_mode is (
		mode600p, 
		mode1080p,
		mode600px16,
		mode480p);

	type displayparam_vector is array (layout_mode) of display_param;
	constant video_params : displayparam_vector := (
		mode600p    => (dcm_mul =>  2, dcm_div => 1),
		mode1080p   => (dcm_mul => 15, dcm_div => 2),
		mode480p    => (dcm_mul =>  3, dcm_div => 2),
		mode600px16 => (dcm_mul =>  5, dcm_div => 4));

	constant video_mode : layout_mode := mode600p;

begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => video_params(video_mode).dcm_mul,
		dfs_div => video_params(video_mode).dcm_div)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	mii_debug_e : entity hdl4fpga.mii_debug
	port map (
		mii_req   => mii_req,
		mii_rxc   => mii_rxc,
		mii_rxd   => mii_rxd,
		mii_rxdv  => mii_rxdv,
--		mii_rxc   => mii_txc,
--		mii_rxd   => mii_txd,
--		mii_rxdv  => mii_txdv,
		mii_txc   => mii_txc,
		mii_txd   => mii_txd,
		mii_txdv  => mii_txdv,

		video_clk => vga_clk, 
		video_dot => vga_dot,
		video_hs  => vga_hsync,
		video_vs  => vga_vsync);
	
	clk_videodac <= vga_clk;
	hsync <= vga_hsync;
	vsync <= vga_vsync;
	red   <= (others => vga_dot);
	green <= (others => vga_dot);
	blue  <= (others => vga_dot);

	process (txc)
	begin
		if rising_edge(txc) then
			if btn(0)='1' then
				mii_req <= '0';
			else
				mii_req <= '1';
			end if;
		end if;
	end process;
	led7 <= not mii_req;

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';
end;
