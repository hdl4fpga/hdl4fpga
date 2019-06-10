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

	type border        is (left, right, top, bottom);
	type direction     is (horizontal, vertical);
	type gap_vector    is array (direction) of natural;
	type margin_vector is array (border) of natural;

	constant division_length : natural := 32; -- Length in pixels

	type display_layout is record 
		display_width   : natural;            -- Maximun display width
		num_of_segments : natural;	          -- Number of segments to display
		grid_width      : natural;            -- Width of the grid in divisions
		grid_height     : natural;            -- Width of the grid in divisions
		hzaxis_height   : natural;            -- Height of the horizontal axis 
		vtaxis_width    : natural;            -- Width of the vetical axis 
		textbox_width   : natural;            -- Width of the text box
		sgmnt_margin    : margin_vector;      -- Margin
		sgmnt_gap       : gap_vector;         -- Padding
	end record;

	constant sd600  : natural := 0;
	constant hd720  : natural := 1;
	constant hd1080 : natural := 2;
	constant vesa1280x1024: natural := 3;

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
			sgmnt_margin    =>   (others => 0),
			sgmnt_gap       =>   (others => 0)),
		hd720 => (
			display_width   => 1280,
			num_of_segments =>    3,
			grid_width      =>   30,
			grid_height     =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  6*8,
			textbox_width   => 33*8,
			sgmnt_margin    => (others => 0),
			sgmnt_gap       => (others => 0)),
		vesa1280x1024 => (
			display_width   => 1280,
			num_of_segments =>    4,
			grid_width      =>   30,
			grid_height     =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  6*8,
			textbox_width   => 33*8,
			sgmnt_margin    => (others => 0),
			sgmnt_gap       => (others => 0)),
		hd1080 => (
			display_width   => 1920,
			num_of_segments =>    4,
			grid_width      =>   50,
			grid_height     =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  6*8,
			textbox_width   => 33*8,
			sgmnt_margin    => (others => 0),
			sgmnt_gap       => (others => 1)));

	type mode_layout is record
		mode_id   : natural;
		layout_id : natural;
	end record;

	type modelayout_vector is array(natural range <>) of mode_layout;

	constant video_description : modelayout_vector := (
		0 => (mode_id => pclk148_50m1920x1080Rat60, layout_id => hd1080),
		1 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600),
		2 => (mode_id => pclk75_00m1920x1080Rat30,  layout_id => hd1080),
		4 => (mode_id => pclk108_00m1280x1024Cat60, layout_id => vesa1280x1024),
		3 => (mode_id => pclk75_00m1280x768Rat60,   layout_id => hd720));

	constant vtaxis_boxid : natural := 0;
	constant grid_boxid   : natural := 1;
	constant text_boxid   : natural := 2;
	constant hzaxis_boxid : natural := 3;

	function vtaxis_y       (constant layout : display_layout) return natural;
	function vtaxis_x       (constant layout : display_layout) return natural;
	function vtaxis_width   (constant layout : display_layout) return natural;
	function vtaxis_height  (constant layout : display_layout) return natural;

	function sgmnt_margintop    (constant layout : display_layout) return natural; 
	function sgmnt_marginbottom (constant layout : display_layout) return natural; 
	function sgmnt_marginleft   (constant layout : display_layout) return natural; 
	function sgmnt_marginright  (constant layout : display_layout) return natural; 

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

	function sgmnt_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : display_layout)
		return std_logic;
end;

package body scopeiopkg is

	function pos(
		constant val : natural)
		return natural is
	begin
		if val > 0 then
			return 1;
		end if;
		return 0;
	end;

	function boxes_sides(
		constant sides        : natural_vector;
		constant margin_start : natural := 0;
		constant margin_end   : natural := 0;
		constant gap          : natural := 0)
		return natural_vector is

		variable retval : natural_vector(0 to sides'length+(sides'length-1)*gap+pos(margin_start)+pos(margin_end)-1);
		variable n      : natural;

	begin

		n := 0;
		retval(n*(pos(gap)+1)) := margin_start;
		retval(pos(margin_start)+n*(pos(gap)+1)) := retval(n*(pos(gap+1))) + sides(n);
		while n < sides'length-1 loop
			retval(pos(margin_start)+n*(pos(gap)+1)+1) := retval(pos(margin_start)+n*(pos(gap)+1)) + gap;
			n := n + 1;
			retval(pos(margin_start)+n*(pos(gap)+1))   := retval(pos(margin_start)+(n-1)*(pos(gap)+1)+1) + sides(n);
		end loop;
		retval(pos(margin_start)+pos(margin_end)+n*(pos(gap)+1)) := retval(pos(margin_start)+n*(pos(gap)+1)) + margin_end;

		return retval(0 to n+n*pos(gap)+pos(margin_start)+pos(margin_end));
	end;

	function sgmnt_margintop (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(top);
	end;

	function sgmnt_marginbottom (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(bottom);
	end;

	function sgmnt_marginleft (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(left);
	end;

	function sgmnt_marginright (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(right);
	end;

	function sgmnt_horizontalgap (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_gap(horizontal);
	end;

	function sgmnt_height (
		constant layout : display_layout)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + layout.sgmnt_margin(top);
		retval := retval + grid_height(layout);
		retval := retval + layout.sgmnt_gap(vertical);
		retval := retval + layout.hzaxis_height;
		retval := retval + layout.sgmnt_margin(bottom);
		return retval;
	end;

	function sgmnt_width (
		constant layout : display_layout)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + layout.sgmnt_margin(left);
		retval := retval + layout.vtaxis_width;
		retval := retval + layout.sgmnt_gap(horizontal);
		retval := retval + grid_width(layout);
		retval := retval + layout.sgmnt_gap(horizontal);
		retval := retval + layout.textbox_width;
		retval := retval + layout.sgmnt_margin(right);
		return retval;
	end;

	function sgmnt_xedges(
		constant layout : display_layout)
		return natural_vector is

	begin

		return to_edges(boxes_sides(
			sides        => (vtaxis_width(layout), grid_width(layout), textbox_width(layout)),
			margin_start => layout.sgmnt_margin(left),
			margin_end   => layout.sgmnt_margin(right),
			gap          => layout.sgmnt_gap(horizontal)));
	end;

	function sgmnt_yedges(
		constant layout : display_layout)
		return natural_vector is
	begin

		return to_edges(boxes_sides(
			sides        => (grid_height(layout), hzaxis_height(layout)),
			margin_start => layout.sgmnt_margin(top),
			margin_end   => layout.sgmnt_margin(bottom),
			gap          => layout.sgmnt_gap(vertical)));
	end;

	function grid_x (
		constant layout : display_layout)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + vtaxis_x(layout);
		retval := retval + vtaxis_width(layout);
		retval := retval + layout.sgmnt_gap(horizontal);
		return retval;
	end;

	function grid_y (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(top);
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
		return layout.sgmnt_margin(left);
	end;

	function vtaxis_y (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(top);
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
		variable retval : natural := 0;
	begin
		retval := retval + grid_x(layout);
		retval := retval + grid_width(layout);
		retval := retval + layout.sgmnt_gap(horizontal);
		return retval;
	end;

	function textbox_y (
		constant layout : display_layout)
		return natural is
	begin
		return layout.sgmnt_margin(top);
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
		variable retval : natural := 0;
	begin
		retval := retval + grid_y(layout);
		retval := retval + grid_height(layout);
		retval := retval + layout.sgmnt_gap(vertical);
		return retval;
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

	function sgmnt_boxon (
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

		x_margin := pos(layout.sgmnt_margin(left));
		y_margin := pos(layout.sgmnt_margin(top));
		x_gap    := pos(layout.sgmnt_gap(horizontal));
		y_gap    := pos(layout.sgmnt_gap(vertical));

		case box_id is
		when vtaxis_boxid | grid_boxid | text_boxid =>                 
			retval := setif(unsigned(y_div)=0*(y_gap+1)+y_margin and unsigned(x_div)=box_id*(x_gap+1)+x_margin);
		when hzaxis_boxid   =>               
			retval := setif(unsigned(y_div)=1*(y_gap+1)+y_margin and unsigned(x_div)=grid_boxid*(x_gap+1)+x_margin);
		when others =>
			retval := '0';
		end case;
		return retval;
	end;
end;
