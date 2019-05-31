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
		border          : natural;            -- Border width
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
			border          =>    0,
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
			border          =>    1,
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
			border          =>    1,
			gap             =>    1,
			margin          =>    1));

	type mode_layout is record
		mode_id   : natural;
		layout_id : natural;
	end record;

	type modelayout_vector is array(natural range <>) of mode_layout;

	constant video_description : modelayout_vector := (
		0 => ( mode_id =>  7, layout_id => hd1080),
		1 => ( mode_id =>  1, layout_id => sd600),
		2 => ( mode_id =>  9, layout_id => hd1080),
		3 => ( mode_id => 10, layout_id => hd720));

	function vtaxis_y       (constant layout : display_layout) return natural;
	function vtaxis_x       (constant layout : display_layout) return natural;
	function vtaxis_width   (constant layout : display_layout) return natural;
	function vtaxis_height  (constant layout : display_layout) return natural;

	function sgmnt_margin   (constant layout : display_layout) return natural; 
	function sgmnt_border   (constant layout : display_layout) return natural;
	function sgmnt_gap      (constant layout : display_layout) return natural;
	function sgmnt_height   (constant layout : display_layout) return natural;
	function sgmnt_width    (constant layout : display_layout) return natural;

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

end;

package body scopeiopkg is
	function sgmnt_margin (
		constant layout : display_layout)
		return natural is
	begin
		return layout.margin;
	end;

	function sgmnt_border (
		constant layout : display_layout)
		return natural is
	begin
		return layout.border;
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
		return (layout.grid_height*division_length+1)+sgmnt_gap(layout)+layout.hzaxis_height;
	end;

	function sgmnt_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.vtaxis_width+1+sgmnt_gap(layout)+(layout.grid_width*division_length+1)+1+sgmnt_gap(layout)+layout.textbox_width+2*sgmnt_border(layout);
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
		return sgmnt_border(layout)+0;
	end;

	function vtaxis_y (
		constant layout : display_layout)
		return natural is
	begin
		return sgmnt_border(layout)+0;
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

end;
