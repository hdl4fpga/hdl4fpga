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

	signal video_clk         : std_logic := '0';
	signal video_hs         : std_logic;
	signal video_vs         : std_logic;
	signal video_vton       : std_logic;
	signal video_hzon       : std_logic;
	signal video_hzl        : std_logic;
	signal video_vld        : std_logic;
	signal video_vcntr      : std_logic_vector(11-1 downto 0);
	signal video_hcntr      : std_logic_vector(11-1 downto 0);

	signal win_hzsync         : std_logic;
	signal win_vtsync         : std_logic;
	signal win_posx      : std_logic_vector(11-1 downto 0);
	signal win_posy      : std_logic_vector(11-1 downto 0);
	signal win_divx      : std_logic_vector(2-1 downto 0);
	signal win_divy      : std_logic_vector(1-1 downto 0);

 begin
    video_clk <= not video_clk after 12.5 ns;
	video_e : entity hdl4fpga.video_vga
	generic map (
		mode => 1,
		n    => 11)
	port map (
		clk   => video_clk,
		hsync => video_hs,
		vsync => video_vs,
		hcntr => video_hcntr,
		vcntr => video_vcntr,
		don   => video_hzon,
		frm   => video_vton,
		nhl   => video_hzl);

	layout_e : entity hdl4fpga.win_layout
	generic map (
		x_edges     => (6*8-1, (6*8)+15*32-1, ((6*8)+15*32)+33*8-1),
		y_edges     => (257-1, (257)+8-1))
	port map (
		video_clk   => video_clk,
		video_posx  => video_hcntr,
		video_posy  => video_vcntr,
		video_hzon  => video_hzon,
		video_vton  => video_vton,
		win_hzsync  => win_hzsync,
		win_vtsync  => win_vtsync,
		win_divx    => win_divx,
		win_divy    => win_divy);

end;

