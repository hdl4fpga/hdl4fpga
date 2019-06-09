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
use hdl4fpga.videopkg.all;

package scopeiopkg is

	constant division_length : natural := 32; -- Length in pixels

	type display_layout is record 
		display_width   : natural;            -- Maximun display width
		num_of_segments : natural;	          -- Number of segments to display
		grid_width      : natural;            -- Width of the grid in divisions
		grid_height     : natural;            -- Width of the grid in divisions
		hzaxis_height   : natural;            -- Height of the horizontal axis 
		vtaxis_width    : natural;            -- Width of the vetical axis 
		textbox_width   : natural;            -- Width of the text box
		gap             : natural;            -- Padding
		margin          : natural;            -- Margin
	end record;

	constant sd600  : natural := 0;
	constant hd720  : natural := 1;
	constant hd1080 : natural := 2;

	type displaylayout_vector is array (natural range <>) of display_layout;

	constant displaylayout_table : displaylayout_vector := (
		sd600 => (            
			display_width   =>  800,
			num_of_segments =>    2,
			grid_width      =>   15,
			grid_height     =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  6*8,
			textbox_width   => 33*8,
			gap             =>    0,
			margin          =>    0),
		hd720 => (
			display_width   => 1280,
			num_of_segments =>    4,
			grid_width      =>   30,
			grid_height     =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  6*8,
			textbox_width   => 33*8,
			gap             =>    0,
			margin          =>    1),
		hd1080 => (
			display_width   => 1920,
			num_of_segments =>    4,
			grid_width      =>   50,
			grid_height     =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  6*8,
			textbox_width   => 33*8,
			gap             =>    1,
			margin          =>    1));

	type mode_layout is record
		mode_id   : natural;
		layout_id : natural;
	end record;

	type modelayout_vector is array(natural range <>) of mode_layout;

	constant video_description : modelayout_vector := (
		0 => (mode_id => pclk148_50m1920x1080Rat60, layout_id => hd1080),
		1 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600),
		2 => (mode_id => pclk75_00m1920x1080Rat30,  layout_id => hd1080),
		3 => (mode_id => pclk75_00m1280x768Rat60,   layout_id => hd720));

	constant vtaxis_boxid : natural := 0;
	constant hzaxis_boxid : natural := 1;
	constant grid_boxid   : natural := 2;
	constant text_boxid   : natural := 3;

	function vtaxis_y       (constant layout : display_layout) return natural;
	function vtaxis_x       (constant layout : display_layout) return natural;
	function vtaxis_width   (constant layout : display_layout) return natural;
	function vtaxis_height  (constant layout : display_layout) return natural;

	function sgmnt_margin   (constant layout : display_layout) return natural; 
	function sgmnt_gap      (constant layout : display_layout) return natural;
	function sgmnt_width    (constant layout : display_layout) return natural;
	function sgmnt_height   (constant layout : display_layout) return natural;
	function sgmnt_xedges   (constant layout : display_layout) return natural_vector;
	function sgmnt_yedges   (constant layout : display_layout) return natural_vector;

	function grid_x         (constant layout : display_layout) return natural;
	function grid_y         (constant layout : display_layout) return natural;
	function grid_width     (constant layout : display_layout) return natural;
	function grid_height    (constant layout : display_layout) return natural;

	function textbox_x      (constant layout : display_layout) return natural;
	function textbox_y      (constant layout : display_layout) return natural;
	function textbox_width  (constant layout : display_layout) return natural;
	function textbox_height (constant layout : display_layout) return natural;

	function hzaxis_x       (constant layout : display_layout) return natural;
	function hzaxis_y       (constant layout : display_layout) return natural;
	function hzaxis_width   (constant layout : display_layout) return natural;
	function hzaxis_height  (constant layout : display_layout) return natural;

	function main_width  (constant layout : display_layout) return natural;
	function main_yedges (constant layout : display_layout) return natural_vector;

	function box_on (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : display_layout)
		return std_logic;
end;

package body scopeiopkg is

	function sgmnt_margin (
		constant layout : display_layout)
		return natural is
	begin
		return layout.margin;
	end;

	function sgmnt_gap (
		constant layout : display_layout)
		return natural is
	begin
		return layout.gap;
	end;

	function sgmnt_height (
		constant layout : display_layout)
		return natural is
	begin
		return grid_height(layout)+hzaxis_height(layout);
	end;

	function sgmnt_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.vtaxis_width+1+sgmnt_gap(layout)+(layout.grid_width*division_length+1)+1+sgmnt_gap(layout)+layout.textbox_width+2*sgmnt_margin(layout);
	end;

	function sgmnt_xedges(
		constant layout : display_layout)
		return natural_vector is

		variable retval : natural_vector(0 to 3-1);
	begin

		retval(0) := vtaxis_width(layout);
		retval(1) := retval(0) + grid_width(layout);
		retval(2) := retval(1) + textbox_width(layout);
		return to_edges(retval);
	end;

	function sgmnt_yedges(
		constant layout : display_layout)
		return natural_vector is

		variable retval : natural_vector(0 to 2-1);
	begin

		retval(0) := grid_height(layout);
		retval(1) := retval(0) + hzaxis_height(layout);
		return to_edges(retval);
	end;

	function grid_x (
		constant layout : display_layout)
		return natural is
	begin
		return vtaxis_x(layout)+vtaxis_width(layout)+sgmnt_gap(layout);
	end;

	function grid_y (
		constant layout : display_layout)
		return natural is
	begin
		return vtaxis_y(layout);
	end;

	function grid_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.grid_width*division_length+1;
	end;

	function grid_height (
		constant layout : display_layout)
		return natural is
	begin
		return layout.grid_height*division_length+1;
	end;

	function vtaxis_x (
		constant layout : display_layout)
		return natural is
	begin
		return sgmnt_margin(layout)+0;
	end;

	function vtaxis_y (
		constant layout : display_layout)
		return natural is
	begin
		return sgmnt_margin(layout)+0;
	end;

	function vtaxis_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.vtaxis_width;
	end;

	function vtaxis_height (
		constant layout : display_layout)
		return natural is
	begin
		return grid_height(layout);
	end;

	function textbox_x (
		constant layout : display_layout)
		return natural is
	begin
		return grid_x(layout)+grid_width(layout)+1+sgmnt_gap(layout);
	end;

	function textbox_y (
		constant layout : display_layout)
		return natural is
	begin
		return vtaxis_y(layout);
	end;

	function textbox_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.textbox_width;
	end;

	function textbox_height (
		constant layout : display_layout)
		return natural is
	begin
		return layout.grid_height*division_length;
	end;

	function hzaxis_x (
		constant layout : display_layout)
		return natural is
	begin
		return grid_x(layout);
	end;

	function hzaxis_y (
		constant layout : display_layout)
		return natural is
	begin
		return grid_y(layout)+grid_height(layout)+1+sgmnt_gap(layout);
	end;

	function hzaxis_width (
		constant layout : display_layout)
		return natural is
	begin
		return grid_width(layout);
	end;

	function hzaxis_height (
		constant layout : display_layout)
		return natural is
	begin
		return 8;
	end;

	function main_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.display_width;
	end;

	function main_yedges(
		constant layout : display_layout)
		return natural_vector is

		variable retval : natural_vector(0 to layout.num_of_segments-1);
	begin

		retval(0) := sgmnt_height(layout);
		for i in 1 to  layout.num_of_segments-1 loop
			retval(i) := retval(i-1) + sgmnt_height(layout);
		end loop;
		return to_edges(retval);
	end;

	function box_on (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : display_layout)
		return std_logic is
		variable retval : std_logic;
		variable x_margin : natural;
		variable y_margin : natural;
		variable x_gap   : natural;
		variable y_gap   : natural;
	begin

		x_margin := 0;
		x_gap    := 0;
		if layout.margin /= 0 then
			x_gap := 1;
		end if;

		y_margin := 0;
		y_gap    := 0;
		if layout.margin /= 0 then
			y_gap := 1;
		end if;

		case box_id is
		when vtaxis_boxid => 
			retval := setif(unsigned(y_div)=0*(y_gap+1)+y_margin and unsigned(x_div)=0*(x_gap+1)+x_margin);
		when grid_boxid   =>                 
			retval := setif(unsigned(y_div)=0*(y_gap+1)+y_margin and unsigned(x_div)=1*(x_gap+1)+x_margin);
		when text_boxid   =>                 
			retval := setif(unsigned(y_div)=0*(y_gap+1)+y_margin and unsigned(x_div)=2*(x_gap+1)+x_margin);
		when hzaxis_boxid   =>               
			retval := setif(unsigned(y_div)=1*(y_gap+1)+y_margin and unsigned(x_div)=1*(x_gap+1)+x_margin);
		when others =>
			retval := '0';
		end case;
		return retval;
	end;
end;
