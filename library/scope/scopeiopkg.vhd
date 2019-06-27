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

	constant max_inputs      : natural := 64;
	constant axisy_backscale : natural := 0;
	constant axisx_backscale : natural := 1;

	type border        is (left, right, top, bottom);
	type heading       is (up, down);
	type direction     is (horizontal, vertical);
	type gap_vector    is array (direction) of natural;
	type margin_vector is array (border)    of natural;

	type style is record 
		gap    : gap_vector;
		margin : margin_vector;
	end record;

	type display_layout is record 
		display_width    : natural;            -- Maximun display width
		num_of_segments  : natural;	          -- Number of segments to display
		division_size    : natural;            -- Length in pixels
		grid_width       : natural;            -- Width of the grid in divisions
		grid_height      : natural;            -- Width of the grid in divisions
		axis_fontsize    : natural;            -- Axis font size
		hzaxis_height    : natural;            -- Height of the horizontal axis 
		vtaxis_width     : natural;            -- Width of the vetical axis 
		vttick_direction : direction;          -- Vertical label direction
		vttick_heading   : heading;            -- Vertical label heading
		textbox_width    : natural;            -- Width of the text box
		main_margin      : margin_vector;      -- Main Margin
		main_gap         : gap_vector;         -- Main Padding
		sgmnt_margin     : margin_vector;      -- Segment Margin
		sgmnt_gap        : gap_vector;         -- Segment Padding
	end record;

	constant sd600  : natural := 0;
	constant hd720  : natural := 1;
	constant hd1080 : natural := 2;
	constant vesa1280x1024: natural := 3;
	constant sd600x16 : natural := 4;
	constant sd600x16fs : natural := 5;
	constant sd600x16oled : natural := 6;

	type displaylayout_vector is array (natural range <>) of display_layout;

	constant displaylayout_table : displaylayout_vector := (
		sd600 => (            
			display_width    =>  800,
			num_of_segments  =>    2,
			division_size    =>   32,
			grid_width       =>   15,
			grid_height      =>    8,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  1*8,
			vttick_direction => vertical,
			vttick_heading   => up,
			textbox_width    => 33*8,
			main_margin      => (left => 3, top => 23, others => 0),
			main_gap         => (vertical => 16, others => 0),
			sgmnt_margin     => (top => 2, bottom => 2, others => 1),
			sgmnt_gap        => (horizontal => 1, others => 0)),
		sd600x16 => (            
			display_width    =>  800,
			num_of_segments  =>    1,
			division_size    =>    8,
			grid_width       =>   11,
			grid_height      =>    7,
			axis_fontsize    =>    4,
			hzaxis_height    =>    4,
			vtaxis_width     =>  1*4,
			vttick_direction => vertical,
			vttick_heading   => down,
			textbox_width    => 33*8,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		sd600x16fs => (
			display_width    =>  800,
			num_of_segments  =>    4,
			division_size    =>   16,
			grid_width       =>   30,
			grid_height      =>    8,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_direction => horizontal,
			vttick_heading   => up,
			textbox_width    => 33*8,
			main_margin      => (top => 5, left => 1, others => 0),
			main_gap         => (vertical => 8, others => 0),
			sgmnt_margin     => (top => 2, bottom => 2, others => 1),
			sgmnt_gap        => (horizontal => 1, others => 0)),
		sd600x16oled => (
			display_width    =>  800,
			num_of_segments  =>    1,
			division_size    =>   16,
			grid_width       =>    5,
			grid_height      =>    4,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  1*8,
			vttick_direction => horizontal,
			vttick_heading   => up,
			textbox_width    =>    1,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		hd720 => (
			display_width    => 1280,
			num_of_segments  =>    3,
			division_size    =>   32,
			grid_width       =>   30,
			grid_height      =>    8,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_direction => horizontal,
			vttick_heading   => up,
			textbox_width    => 33*8,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		vesa1280x1024 => (
			display_width    => 1280,
			num_of_segments  =>    4,
			division_size    =>   32,
			grid_width       =>   30,
			grid_height      =>    8,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_direction => horizontal,
			vttick_heading   => up,
			textbox_width    => 33*8,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		hd1080 => (
			display_width    => 1920,
			num_of_segments  =>    4,
			division_size    =>   32,
			grid_width       =>   50,
			grid_height      =>    8,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_direction => horizontal,
			vttick_heading   => up,
			textbox_width    => 33*8,
			main_margin      => (top => 5, left => 1, others => 0),
			main_gap         => (others => 1),
			sgmnt_margin     => (others => 1),
			sgmnt_gap        => (horizontal => 1, others => 0)));

	type mode_layout is record
		mode_id   : natural;
		layout_id : natural;
	end record;

	type modelayout_vector is array(natural range <>) of mode_layout;

	constant video_description : modelayout_vector := (
		0 => (mode_id => pclk148_50m1920x1080Rat60, layout_id => hd1080),
		1 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600),
		2 => (mode_id => pclk75_00m1920x1080Rat30,  layout_id => hd1080),
		3 => (mode_id => pclk75_00m1280x768Rat60,   layout_id => hd720),
		4 => (mode_id => pclk108_00m1280x1024Cat60, layout_id => vesa1280x1024),
		5 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600x16),
		6 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600x16fs),
		7 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600x16oled));

	constant vtaxis_boxid : natural := 0;
	constant grid_boxid   : natural := 1;
	constant text_boxid   : natural := 2;
	constant hzaxis_boxid : natural := 3;

	function axis_fontsize     (constant layout : display_layout) return natural;

	function hzaxis_x          (constant layout : display_layout) return natural;
	function hzaxis_y          (constant layout : display_layout) return natural;
	function hzaxis_width      (constant layout : display_layout) return natural;
	function hzaxis_height     (constant layout : display_layout) return natural;

	function vtaxis_y          (constant layout : display_layout) return natural;
	function vtaxis_x          (constant layout : display_layout) return natural;
	function vtaxis_width      (constant layout : display_layout) return natural;
	function vtaxis_height     (constant layout : display_layout) return natural;
	function vtaxis_tickdirection (constant layout : display_layout) return direction;
	function vtaxis_tickheading   (constant layout : display_layout) return heading;

	function grid_x            (constant layout : display_layout) return natural;
	function grid_y            (constant layout : display_layout) return natural;
	function grid_width        (constant layout : display_layout) return natural;
	function grid_height       (constant layout : display_layout) return natural;
	function grid_divisionsize (constant layout : display_layout) return natural;

	function textbox_x         (constant layout : display_layout) return natural;
	function textbox_y         (constant layout : display_layout) return natural;
	function textbox_width     (constant layout : display_layout) return natural;
	function textbox_height    (constant layout : display_layout) return natural;

	function sgmnt_width       (constant layout : display_layout) return natural;
	function sgmnt_height      (constant layout : display_layout) return natural;
	function sgmnt_xedges      (constant layout : display_layout) return natural_vector;
	function sgmnt_yedges      (constant layout : display_layout) return natural_vector;

	function sgmnt_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : display_layout)
		return std_logic;

	function main_width  (constant layout : display_layout) return natural;
	function main_xedges (constant layout : display_layout) return natural_vector;
	function main_yedges (constant layout : display_layout) return natural_vector;

	function main_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : display_layout)
		return std_logic;

	constant rid_hzaxis   : std_logic_vector := x"10";
	constant rid_palette  : std_logic_vector := x"11";
	constant rid_trigger  : std_logic_vector := x"12";
	constant rid_gain     : std_logic_vector := x"13";
	constant rid_vtaxis   : std_logic_vector := x"14";
	constant rid_pointer  : std_logic_vector := x"15";

	constant chanid_maxsize  : natural := unsigned_num_bits(max_inputs-1);

	function bitfield (
		constant bf_rgtr   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector;

	constant vtoffset_maxsize : natural := 13;
	constant vtoffset_id : natural := 0;
	constant vtchanid_id : natural := 1;
	constant vtoffset_bf : natural_vector := (
		vtoffset_id => vtoffset_maxsize, 
		vtchanid_id => chanid_maxsize);

	constant hzoffset_maxsize : natural := 16;
	constant hzscale_maxsize  : natural :=  4;

	constant hzoffset_id : natural := 0;
	constant hzscale_id  : natural := 1;
	constant hzoffset_bf : natural_vector := (
		hzoffset_id => hzoffset_maxsize, 
		hzscale_id  => hzscale_maxsize);

	constant paletteid_maxsize    : natural := unsigned_num_bits(max_inputs+9-1);
	constant palettecolor_maxsize : natural := 24;
	constant paletteid_id         : natural := 0;
	constant palettecolor_id      : natural := 1;

	constant palette_bf : natural_vector := (
		paletteid_id    => paletteid_maxsize, 
		palettecolor_id => palettecolor_maxsize);

	constant trigger_ena_id    : natural := 0;
	constant trigger_edge_id   : natural := 1;
	constant trigger_level_id  : natural := 2;
	constant trigger_chanid_id : natural := 3;

	constant triggerlevel_maxsize : natural := 9;
	constant trigger_bf : natural_vector := (
		trigger_ena_id    => 1,
		trigger_edge_id   => 1,
		trigger_level_id  => triggerlevel_maxsize,
		trigger_chanid_id => chanid_maxsize);

	constant gainid_maxsize : natural := 4;

	constant gainid_id      : natural := 0;
	constant gainchanid_id  : natural := 1;
	constant gain_bf : natural_vector := (
		gainid_id     => gainid_maxsize,
		gainchanid_id => chanid_maxsize);

	constant pointerx_maxsize : natural := 11;
	constant pointery_maxsize : natural := 11;
	constant pointerx_id      : natural := 0;
	constant pointery_id      : natural := 1;

	constant pointer_bf : natural_vector := (
		pointery_id => pointery_maxsize, 
		pointerx_id => pointerx_maxsize);

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
--		for i in 0 to sides'length-2 loop
		while n < sides'length-1 loop
--			if sides(n+1)/=0 then
				retval(pos(margin_start)+n*(pos(gap)+1)+1) := retval(pos(margin_start)+n*(pos(gap)+1)) + gap;
				n := n + 1;
				retval(pos(margin_start)+n*(pos(gap)+1))   := retval(pos(margin_start)+(n-1)*(pos(gap)+1)+1) + sides(n);
--			end if;
		end loop;
		retval(pos(margin_start)+pos(margin_end)+n*(pos(gap)+1)) := retval(pos(margin_start)+n*(pos(gap)+1)) + margin_end;

		return retval(0 to n+n*pos(gap)+pos(margin_start)+pos(margin_end));
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
		return layout.grid_width*layout.division_size+1;
	end;

	function grid_height (
		constant layout : display_layout)
		return natural is
	begin
		return layout.grid_height*layout.division_size+1;
	end;

	function grid_divisionsize (
		constant layout : display_layout)
		return natural is
	begin
		return layout.division_size;
	end;

	function axis_fontsize (
		constant layout : display_layout)
		return natural is
	begin
		return layout.axis_fontsize;
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

	function vtaxis_tickdirection (
		constant layout : display_layout)
		return direction is
	begin
		return layout.vttick_direction;
	end;

	function vtaxis_tickheading (
		constant layout : display_layout)
		return heading is
	begin
		return layout.vttick_heading;
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
		return layout.grid_height*layout.division_size;
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
		return layout.hzaxis_height;
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

	function main_width (
		constant layout : display_layout)
		return natural is
	begin
		return layout.display_width;
	end;

	function main_xedges(
		constant layout : display_layout)
		return natural_vector is

	begin
		return to_edges(boxes_sides(
			sides        => (0 => sgmnt_width(layout)),
			margin_start => layout.main_margin(left),
			margin_end   => layout.main_margin(right),
			gap          => layout.main_gap(horizontal)));
	end;

	function main_yedges(
		constant layout : display_layout)
		return natural_vector is
	begin
		return to_edges(boxes_sides(
			sides        => (0 to layout.num_of_segments-1 => sgmnt_height(layout)),
			margin_start => layout.main_margin(top),
			margin_end   => layout.main_margin(bottom),
			gap          => layout.main_gap(vertical)));
	end;

	function main_boxon (
		constant box_id   : natural;
		constant x_div    : std_logic_vector;
		constant y_div    : std_logic_vector;
		constant layout   : display_layout)
		return std_logic is
		variable x_margin : natural;
		variable y_margin : natural;
		variable x_gap    : natural;
		variable y_gap    : natural;
	begin

		x_margin := pos(layout.main_margin(left));
		y_margin := pos(layout.main_margin(top));
		x_gap    := pos(layout.main_gap(horizontal));
		y_gap    := pos(layout.main_gap(vertical));

		return setif(unsigned(y_div)=box_id*(y_gap+1)+y_margin and unsigned(x_div)=0*(x_gap+1)+x_margin);
	end;

	function bitfield (
		constant bf_rgtr   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector is
		variable retval : unsigned(bf_rgtr'length-1 downto 0);
		variable dscptr : natural_vector(0 to bf_dscptr'length-1);
	begin
		dscptr := bf_dscptr;
		retval := unsigned(bf_rgtr);
		if bf_rgtr'left > bf_rgtr'right then
			for i in bf_dscptr'range loop
				if i=bf_id then
					return std_logic_vector(retval(bf_dscptr(i)-1 downto 0));
				end if;
				retval := retval ror bf_dscptr(i);
			end loop;
		else
			for i in bf_dscptr'range loop
				retval := retval rol bf_dscptr(i);
				if i=bf_id then
					return std_logic_vector(retval(bf_dscptr(i)-1 downto 0));
				end if;
			end loop;
		end if;
		return (0 to 0 => '-');
	end;

end;
