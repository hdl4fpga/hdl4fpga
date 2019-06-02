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
    
library hdl4fpga;
use hdl4fpga.std.all;

architecture video of testbench is

	signal video_clk    : std_logic := '0';
	signal video_hs     : std_logic;
	signal video_vs     : std_logic;
	signal video_vton   : std_logic;
	signal video_hzon   : std_logic;
	signal video_vtcntr : std_logic_vector(11-1 downto 0) := (others => '0');
	signal video_hzcntr : std_logic_vector(11-1 downto 0) := (others => '0');

	signal box_sidex    : std_logic;
	signal box_sidey    : std_logic;
	signal box_eox      : std_logic;
	signal box_xon      : std_logic;
	signal box_yon      : std_logic;
	signal box_x        : std_logic_vector(11-1 downto 0);
	signal box_y        : std_logic_vector(11-1 downto 0);
	signal box_divx     : std_logic_vector(2-1 downto 0);
	signal box_divy     : std_logic_vector(2-1 downto 0);

 begin
    video_clk <= not video_clk after 12.5 ns;
	video_e : entity hdl4fpga.video_sync
	generic map (
		mode => 1)
	port map (
		video_clk    => video_clk,
		video_hzsync => video_hs,
		video_vtsync => video_vs,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton);

	boxlayout_e : entity hdl4fpga.videobox_layout
	generic map (
		x_edges     => (6*8-1, (6*8)+15*32-1, ((6*8)+15*32)+33*8-1),
		y_edges     => (257-1, (257)+8-1))
	port map (
		video_clk  => video_clk,
		video_xon  => video_hzon,
		video_yon  => video_vton,
		video_x    => video_hzcntr,
		video_y    => video_vtcntr,
		box_xon    => box_xon,
		box_yon    => box_yon,
		box_eox    => box_eox,
		box_xedge  => box_sidex,
		box_yedge  => box_sidey,
		box_xdiv   => box_divx,
		box_ydiv   => box_divy);

	box_e : entity hdl4fpga.video_box
	port map (
		video_clk => video_clk,
		video_xon => box_xon,
		video_yon => box_yon,
		video_eox => box_eox,
		box_xedge => box_sidex,
		box_yedge => box_sidey,
		box_x     => box_x,
		box_y     => box_y);

end;

