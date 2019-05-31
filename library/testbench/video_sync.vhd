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
use hdl4fpga.scopeiopkg.all;

entity testbench is
end;

architecture video of testbench is
	constant layout : display_layout := displaylayout_table(video_description(1).layout_id);

				constant grid_id    : natural := 0;
				constant vtaxis_id  : natural := 1;
				constant hzaxis_id  : natural := 2;
				constant textbox_id : natural := 3;

	constant sgmnt_x : natural_vector := (grid_id => grid_x(layout),      vtaxis_id => vtaxis_x(layout),      hzaxis_id => hzaxis_x(layout),      textbox_id => textbox_x(layout));
	constant sgmnt_y : natural_vector := (grid_id => grid_y(layout),      vtaxis_id => vtaxis_y(layout),      hzaxis_id => hzaxis_y(layout),      textbox_id => textbox_y(layout));
	constant sgmnt_w : natural_vector := (grid_id => grid_width(layout),  vtaxis_id => vtaxis_width(layout),  hzaxis_id => hzaxis_width(layout),  textbox_id => textbox_width(layout));
	constant sgmnt_h : natural_vector := (grid_id => grid_height(layout), vtaxis_id => vtaxis_height(layout), hzaxis_id => hzaxis_height(layout), textbox_id => textbox_height(layout));

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
	signal win_hzon : std_logic_vector(0 to 4-1);
	signal win_vton : std_logic_vector(0 to 4-1);
	signal win_x      : std_logic_vector(11-1 downto 0);
	signal win_y      : std_logic_vector(11-1 downto 0);

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
		x           => sgmnt_x,
		y           => sgmnt_y,
		width       => sgmnt_w,
		height      => sgmnt_h)
	port map (
		video_clk   => video_clk,
		video_x     => video_hcntr,
		video_y     => video_vcntr,
		video_hzon  => video_hzon,
		video_vton  => video_vton,
		win_hzsync  => win_hzsync,
		win_vtsync  => win_vtsync,
		win_hzon    => win_hzon,
		win_vton    => win_vton);


	win_e : entity hdl4fpga.win
	port map (
		video_clk => video_clk,
		video_hzl => video_hzl,
		winx_ini  => win_hzsync,
		winy_ini  => win_vtsync,
		win_x     => win_x,
		win_y     => win_y);


end;
