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
		padding         : natural;            -- Padding
		margin          : natural;            -- Margin
	end record;

	type layout_vector is array (natural range <>) of display_layout;

	constant vlayout_tab : vlayout_vector := (
		--      display_width | num_of_seg | grid_width | grid_height | hzaxis_height | vtaxis_width | textbox_width | border | padding | margin
		0 => (        800,           2,        15,          8,          8,       6*8,         33*8,       1,        0,       1),
		1 => (       1280,           4,        30,          8,          8,       6*8,         33*8,       1,        0,       1),
		2 => (       1920,           4,        50,          8,          8,       6*8,         33*8,       1,        0,       1));

	type mode_layout record is
		mode_id   : natural;
		layout_id : natural;
	end record;

	type mode_layout is array(natural range <>) mode_layout;
	constant video_layout

	constant vlayout : display_layout := vlayout_tab(vlayout_id);

	function vt_y      (constant layout : display_layout) return natural;
	function vt_x      (constant layout : display_layout) return natural;
	function vtaxis_width  (constant layout : display_layout) return natural;
	function vt_height (constant layout : display_layout) return natural;

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

	function sgmnt_padding (
		constant layout : display_layout)
		return natural is
	begin
		return layout.padding;
	end;

	function sgmnt_height (
		constant layout : display_layout;
		constant gu : natural := division_length)
		return natural is
	begin
		return ((layout.grid_height*gu+1)+1+sgmnt_padding(layout)+layout.hzaxis_height)+sgmnt_border(layout);
	end;

	function sgmnt_width (
		constant layout : display_layout;
		constant gu : natural := division_length)
		return natural is
	begin
		return layout.vtaxis_width+1+sgmnt_padding(layout)+(layout.grid_width*gu+1)+1+sgmnt_padding(layout)+layout.textbox_width+2*sgmnt_border(layout);
	end;

	function grid_x (
		constant layout : display_layout;
		constant gu : natural := division_length)
		return natural is
	begin
		return vt_x(layout)+vtaxis_width(layout)+1+sgmnt_padding(layout);
	end;

	function grid_y (
		constant layout : display_layout)
		return natural is
	begin
		return vt_y(layout);
	end;

	function grid_width (
		constant layout : display_layout;
		constant gu : natural := division_length)
		return natural is
	begin
		return layout.grid_width*gu+1;
	end;

	function grid_height (
		constant layout : display_layout;
		constant gu : natural := division_length)
		return natural is
	begin
		return layout.grid_height*gu+1;
	end;

	function vt_x (
		constant layout : display_layout)
		return natural is
	begin
		return sgmnt_border(layout)+0;
	end;

	function vt_y (
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

	function vt_height (
		constant layout : display_layout)
		return natural is
	begin
		return grid_height(layout);
	end;

	function text_x (
		constant layout : display_layout)
		return natural is
	begin
		return grid_x(layout)+grid_width(layout)+1+sgmnt_padding(layout);
	end;

	function text_y (
		constant layout : display_layout)
		return natural is
	begin
		return vt_y(layout);
	end;

	function textbox_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.textbox_width;
	end;

	function text_height (
		constant layout : display_layout;
		constant gu : natural := division_length)
		return natural is
	begin
		return layout.grid_height*gu;
	end;

	function hz_x (
		constant layout : display_layout)
		return natural is
	begin
		return grid_x(layout);
	end;

	function hz_y (
		constant layout : display_layout)
		return natural is
	begin
		return grid_y(layout)+grid_height(layout)+1+sgmnt_padding(layout);
	end;

	function hz_width (
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
