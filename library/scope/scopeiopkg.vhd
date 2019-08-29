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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;

package scopeiopkg is

	subtype i18n_langs is natural range 0 to 2-1;
	constant lang_EN : i18n_langs := 0;
	constant lang_ES : i18n_langs := 1;

	subtype i18n_labelids is natural range 0 to 5-1;
	type i18nlabelid_vector is array (natural range <>) of i18n_labelids;
	constant lbel_horizontal : i18n_labelids := 0;
	constant lbel_vertical   : i18n_labelids := 1;
	constant lbel_level      : i18n_labelids := 2;
	constant lbel_scale      : i18n_labelids := 3;
	constant lbel_trigger    : i18n_labelids := 4;

	constant i18n_text : string := 
		"Horizontal" & NUL & 
		"Vertical"   & NUL & 
		"Level"      & NUL & 
		"Scale"      & NUL & 
		"Trigger"      & NUL & 
		NUL &
		"Horizontal" & NUL &
		"Vertical"   & NUL &
		"Nivel"      & NUL & 
		"Escala"     & NUL & 
		"Disparo"    & NUL & 
		NUL;

	constant max_inputs    : natural := 64;
	constant axisy_backscale : natural := 0;
	constant axisx_backscale : natural := 1;
	constant max_pixelsize : natural := 24;

	type border        is (left, right, top, bottom);
	type rotate        is (ccw0, ccw90, ccw270);
	type direction     is (horizontal, vertical);
	type gap_vector    is array (direction) of natural;
	type margin_vector is array (border)    of natural;

	constant textfont_width  : natural :=  8;
	constant textfont_height : natural := 16;

	type style is record 
		gap    : gap_vector;
		margin : margin_vector;
	end record;

	type display_layout is record 
		display_width    : natural;            -- Display's width
		display_height   : natural;            -- Display's height
		num_of_segments  : natural;	           -- Number of segments to display
		division_size    : natural;            -- Length in pixels
		grid_width       : natural;            -- Width of the grid in divisions
		grid_height      : natural;            -- Width of the grid in divisions
		axis_fontsize    : natural;            -- Axis font size
		hzaxis_height    : natural;            -- Height of the horizontal axis 
		vtaxis_width     : natural;            -- Width of the vetical axis 
		vttick_rotate    : rotate;             -- Vertical label rotating
		textbox_width    : natural;            -- Width of the text box
		main_margin      : margin_vector;      -- Main Margin
		main_gap         : gap_vector;         -- Main Padding
		sgmnt_margin     : margin_vector;      -- Segment Margin
		sgmnt_gap        : gap_vector;         -- Segment Padding
	end record;

	constant sd600            : natural := 0;
	constant hd720            : natural := 1;
	constant hd1080           : natural := 2;
	constant vesa1280x1024    : natural := 3;
	constant sd600x16         : natural := 4;
	constant sd600x16fs       : natural := 5;
	constant oled96x64        : natural := 6;
	constant oled96x64ongrid  : natural := 11;
	constant lcd800x480       : natural := 7;
	constant lcd800x480ongrid : natural := 10;
	constant lcd1024x600      : natural := 8;
	constant vesa640x480      : natural := 9;

	type displaylayout_vector is array (natural range <>) of display_layout;

	constant displaylayout_table : displaylayout_vector := (
		sd600 => (            
			display_width   =>  800,
			display_height  =>  600,
			num_of_segments =>    2,
			division_size   =>   32,
			grid_width      => 15*32+1,
			grid_height     =>  8*32+1,
			axis_fontsize   =>    8,
			hzaxis_height   =>    8,
			vtaxis_width    =>  1*8,
			vttick_rotate   => ccw90,
			textbox_width   => 33*8,
			main_margin     => (left => 3, top => 23, others => 0),
			main_gap        => (vertical => 16, others => 0),
			sgmnt_margin    => (top => 2, bottom => 2, others => 1),
			sgmnt_gap       => (horizontal => 1, others => 0)),
		sd600x16 => (            
			display_width    =>  96,
			display_height   =>  64,
			num_of_segments  =>   1,
			division_size    =>   8,
			grid_width       => 12*8,
			grid_height      =>  8*8,
			axis_fontsize    =>    8,
			hzaxis_height    =>    0,
			vtaxis_width     =>    0,
			vttick_rotate    => ccw90,
			textbox_width    => 0,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		sd600x16fs => (
			display_width    =>  800,
			display_height   =>  600,
			num_of_segments  =>    4,
			division_size    =>   16,
			grid_width       => 46*16,
			grid_height      =>  8*16,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
			textbox_width    =>  0,
			main_margin      => (others => 0),
			main_gap         => (others => 4),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		oled96x64 => (
			display_width    =>   96,
			display_height   =>   64,
			num_of_segments  =>    1,
			division_size    =>    8,
			grid_width       => 11*8+1,
			grid_height      =>  7*8+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    7,
			vtaxis_width     =>    7,
			vttick_rotate    => ccw90,
			textbox_width    =>    0, -- no textbox
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		oled96x64ongrid => (
			display_width    =>   96,
			display_height   =>   64,
			num_of_segments  =>    1,
			division_size    =>   16,
			grid_width       => 6*16,
			grid_height      => 4*16,
			axis_fontsize    =>    8,
			hzaxis_height    =>    0,
			vtaxis_width     =>    0,
			vttick_rotate    => ccw90,
			textbox_width    =>    0, -- no textbox
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		vesa640x480 => (
			display_width    =>  640,
			display_height   =>  480,
			num_of_segments  =>    3,
			division_size    =>   16,
			grid_width       => 36*16+1,
			grid_height      =>  9*16+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
			textbox_width    =>    0,
			main_margin      => (others => 0),
			main_gap         => (others => 4),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		lcd800x480 => (
			display_width    =>  800,
			display_height   =>  480,
			num_of_segments  =>    3,
			division_size    =>   16,
			grid_width       => 46*16+1,
			grid_height      =>  9*16+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
			textbox_width    =>    0,
			main_margin      => (others => 0),
			main_gap         => (others => 4),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		lcd800x480ongrid => (
			display_width    =>  800,
			display_height   =>  480,
			num_of_segments  =>    3,
			division_size    =>   32,
			grid_width       =>   32*25,
			grid_height      =>   32*5,
			axis_fontsize    =>    8,
			hzaxis_height    =>    0,
			vtaxis_width     =>    0,
			vttick_rotate    => ccw0,
			textbox_width    =>    0,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		lcd1024x600 => (
			display_width    => 1024,
			display_height   =>  600,
			num_of_segments  =>    1,
			division_size    =>   32,
			grid_width       => 30*32+1,
			grid_height      => 18*32+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
			textbox_width    =>    0,
			main_margin      => (others => 0),
			main_gap         => (others => 4),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		hd720 => (
			display_width    => 1280,
			display_height   =>  720,
			num_of_segments  =>    3,
			division_size    =>   32,
			grid_width       => 30*32+1,
			grid_height      =>  8*32+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
			textbox_width    => 33*8,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		vesa1280x1024 => (
			display_width    => 1280,
			display_height   =>  720,
			num_of_segments  =>    4,
			division_size    =>   32,
			grid_width       => 30*32+1,
			grid_height      =>  8*32+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
			textbox_width    => 33*8,
			main_margin      => (others => 0),
			main_gap         => (others => 0),
			sgmnt_margin     => (others => 0),
			sgmnt_gap        => (others => 0)),
		hd1080 => (
			display_width    => 1920,
			display_height   => 1080,
			num_of_segments  =>    4,
			division_size    =>   32,
			grid_width       => 50*32+1,
			grid_height      =>  8*32+1,
			axis_fontsize    =>    8,
			hzaxis_height    =>    8,
			vtaxis_width     =>  6*8,
			vttick_rotate    => ccw0,
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
		5 => (mode_id => pclk38_25m800x600Cat60,    layout_id => sd600x16fs),
		6 => (mode_id => pclk23_75m640x480Cat60,    layout_id => vesa640x480),
		7 => (mode_id => pclk38_25m96x64Rat60,      layout_id => oled96x64ongrid),
		8 => (mode_id => pclk30_00m800x480Rat60,    layout_id => lcd800x480),
		9 => (mode_id => pclk50_00m1024x600Rat60,   layout_id => lcd1024x600),
	   10 => (mode_id => pclk38_25m800x600Cat60,    layout_id => lcd800x480ongrid));

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
	function vtaxis_tickrotate (constant layout : display_layout) return rotate;

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
	function main_height (constant layout : display_layout) return natural;
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

	constant pltid_gridfg    : natural :=  0;
	constant pltid_gridbg    : natural :=  6;
	constant pltid_vtfg      : natural :=  1;
	constant pltid_vtbg      : natural :=  2;
	constant pltid_hzfg      : natural :=  3;
	constant pltid_hzbg      : natural :=  4;
	constant pltid_textfg    : natural :=  9;
	constant pltid_textbg    : natural :=  5;
	constant pltid_sgmntbg   : natural :=  7;
	constant pltid_scopeiobg : natural :=  8;

	constant pltid_order : natural_vector := (
		0 => pltid_vtfg,
		1 => pltid_hzfg,
		2 => pltid_textfg,      
		3 => pltid_gridfg,
		4 => pltid_vtbg,
		5 => pltid_hzbg,
		6 => pltid_textbg,      
		7 => pltid_gridbg,
		8 => pltid_sgmntbg,
		9 => pltid_scopeiobg);

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

	constant paletteid_maxsize    : natural := unsigned_num_bits(max_inputs+pltid_order'length-1);
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

	component scopeio_tds
		generic (
			inputs           : natural;
			time_factors     : natural_vector;
			storageword_size : natural);
		port (
			rgtr_clk         : in  std_logic;
			rgtr_dv          : in  std_logic;
			rgtr_id          : in  std_logic_vector(8-1 downto 0);
			rgtr_data        : in  std_logic_vector;

			input_clk        : in  std_logic;
			input_dv         : in  std_logic;
			input_data       : in  std_logic_vector;
			time_dv          : in  std_logic;
			time_scale       : in  std_logic_vector;
			time_offset      : in  std_logic_vector;
			trigger_chanid   : buffer std_logic_vector;
			trigger_level    : buffer std_logic_vector;
			video_clk        : in  std_logic;
			video_vton       : in  std_logic;
			video_frm        : in  std_logic;
			video_addr       : in  std_logic_vector;
			video_dv         : out std_logic;
			video_data       : out std_logic_vector);
	end component;

	function scale_1245 (
		constant val   : signed;
		constant scale : std_logic_vector)
		return signed;
		
	function i18n_label (
		constant i18n_lang  : i18n_langs;
		constant i18n_label : i18n_labelids)
		return string;

	function text_field (
		constant field  : unsigned;
		constant layout : display_layout)
		return unsigned;

	function text_mask (
		constant lang   : i18n_langs;
		constant layout : display_layout)
		return std_logic_vector;
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
		retval(pos(margin_start)+n*(pos(gap)+1)) := retval(n*(pos(gap+1))) + sides(0);
		for i in 0 to sides'length-2 loop
			if sides(i)/=0 then
				retval(pos(margin_start)+n*(pos(gap)+1)+1) := retval(pos(margin_start)+n*(pos(gap)+1)) + gap;
				n := n + 1;
			end if;
			retval(pos(margin_start)+n*(pos(gap)+1)) := retval(pos(margin_start)+(n-1)*(pos(gap)+1)+1) + sides(i+1);
		end loop;
		if sides(sides'right)/=0 then
			retval(pos(margin_start)+pos(margin_end)+n*(pos(gap)+1)) := retval(pos(margin_start)+n*(pos(gap)+1)) + margin_end;
		else
			n := n - 1;
		end if;

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
		return layout.grid_width;
	end;

	function grid_height (
		constant layout : display_layout)
		return natural is
	begin
		return layout.grid_height;
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

	function vtaxis_tickrotate (
		constant layout : display_layout)
		return rotate is
	begin
		return layout.vttick_rotate;
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
		return layout.grid_height;
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
			sides        => (
				vtaxis_boxid => vtaxis_width(layout), 
				grid_boxid   => grid_width(layout), 
				text_boxid   => textbox_width(layout)),
			margin_start => layout.sgmnt_margin(left),
			margin_end   => layout.sgmnt_margin(right),
			gap          => layout.sgmnt_gap(horizontal)));
	end;

	function sgmnt_yedges(
		constant layout : display_layout)
		return natural_vector is
	begin

		return to_edges(boxes_sides(
			sides        => (
				0 => grid_height(layout),
				1 => hzaxis_height(layout)),
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
		constant x_sides  : natural_vector := (
			vtaxis_boxid => vtaxis_width(layout),
			grid_boxid   => grid_width(layout),
			text_boxid   => textbox_width(layout),
			hzaxis_boxid => grid_width(layout));

		constant y_sides  : natural_vector := (
			vtaxis_boxid => vtaxis_height(layout),
			grid_boxid   => grid_height(layout),
			text_boxid   => textbox_height(layout),
			hzaxis_boxid => hzaxis_height(layout));

		variable retval   : std_logic;
		variable x_margin : natural;
		variable y_margin : natural;
		variable x_gap    : natural;
		variable y_gap    : natural;

		function lookup (
			constant id    : natural;
			constant sides : natural_vector)
			return natural is
			variable div   : natural;
		begin
			div := 0;
			for i in 0 to id-1  loop
				if sides(i) /= 0 then
					div := div + 1;
				end if;
			end loop;
			return div;
		end;
	begin

		retval   := '0';
		x_margin := pos(layout.sgmnt_margin(left));
		y_margin := pos(layout.sgmnt_margin(top));
		x_gap    := pos(layout.sgmnt_gap(horizontal));
		y_gap    := pos(layout.sgmnt_gap(vertical));

		case box_id is
		when vtaxis_boxid | grid_boxid | text_boxid =>                 
			if x_sides(box_id)/=0 then
				retval := setif(unsigned(y_div)=(0*(y_gap+1)+y_margin) and unsigned(x_div)=(lookup(box_id, x_sides)*(x_gap+1)+x_margin));
			end if;
		when hzaxis_boxid =>               
			if y_sides(hzaxis_boxid)/=0 then
				retval := setif(unsigned(y_div)=(1*(y_gap+1)+y_margin) and unsigned(x_div)=(lookup(grid_boxid, x_sides)*(x_gap+1)+x_margin));
			end if;
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

	function main_height (
		constant layout : display_layout)
		return natural is
	begin
		return layout.display_height;
	end;

	function main_xedges(
		constant layout : display_layout)
		return natural_vector is
		constant sides : natural_vector := boxes_sides(
			sides        => (0 => sgmnt_width(layout)),
			margin_start => layout.main_margin(left),
			margin_end   => layout.main_margin(right),
			gap          => layout.main_gap(horizontal));

	begin
		assert sides(sides'right)<=main_width(layout)
		report "Boxes' Width sum up cannot be greater than Display's Width"
		severity FAILURE;
		return to_edges(sides);
	end;

	function main_yedges(
		constant layout : display_layout)
		return natural_vector is
		constant sides : natural_vector := boxes_sides(
			sides        => (0 to layout.num_of_segments-1 => sgmnt_height(layout)),
			margin_start => layout.main_margin(top),
			margin_end   => layout.main_margin(bottom),
			gap          => layout.main_gap(vertical));
	begin
		assert sides(sides'right)<=main_height(layout)
		report "Boxes' Height sum up cannot be greater than Display's Height"
		severity FAILURE;
		return to_edges(sides);
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

	function scale_1245 (
		constant val   : signed;
		constant scale : std_logic_vector)
		return signed is
		variable sel  : std_logic_vector(scale'length-1 downto 0);
		variable by1  : signed(val'range);
		variable by2  : signed(val'range);
		variable by4  : signed(val'range);
		variable rval : signed(val'range);
	begin
		by1 := shift_left(val, 0);
		by2 := shift_left(val, 1);
		by4 := shift_left(val, 2);
		sel := scale;
		case sel(2-1 downto 0) is
		when "00" =>
			rval := by1;
		when "01" =>
			rval := by2;
		when "10" =>
			rval := by4;
		when "11" =>
			rval := by4 + by1;
		when others =>
			rval := (others => '-');
		end case;
		return rval;
	end;
		
	function i18n_label (
		constant i18n_lang  : i18n_langs;
		constant i18n_label : i18n_labelids)
		return string is
		variable lbel : i18n_labelids;
		variable pos0 : natural;
		variable pos1 : natural;
		variable n    : natural;
	begin
		n := 1;
		lang_l : for lang in i18n_langs loop
			lbel := 0;
			while i18n_text(n) /= NUL loop
				pos0 := n;
				while i18n_text(n) /= NUL loop
					n := n + 1;
				end loop;
				pos1 := n - 1;
				n    := n + 1;
				exit lang_l when lbel = i18n_label and lang = i18n_lang;
				if i18n_text(n) /= NUL then
					lbel := lbel + 1;
				end if;
			end loop;
			n := n + 1;
		end loop;
		return i18n_text(pos0 to pos1);
	end;

	function text_field (
		constant field  : unsigned;
		constant layout : display_layout)
		return unsigned is
		constant text_cols  : natural := textbox_width(layout)/textfont_width;
		constant text_rows  : natural := textbox_height(layout)/textfont_height;
		constant text_size  : natural := text_rows*text_cols;
		variable retval     : unsigned(0 to ascii'length*text_size-1);
		constant line_size  : natural := text_cols*ascii'length;
		variable text_addr  : unsigned(0 to unsigned_num_bits(text_size-1)-1);

	begin
		case to_integer(field) is
		when 0 => 
			text_addr := to_unsigned(12, text_addr'length);
		when 1 => 
			text_addr := to_unsigned(text_cols+12, text_addr'length);
		when others =>
			text_addr := resize(mul(field-2, 16)+(8+2*text_cols), text_addr'length);
		end case;
		return text_addr;
	end;
		
	function text_mask (
		constant lang   : i18n_langs;
		constant layout : display_layout)
		return std_logic_vector is
		constant text_cols   : natural := textbox_width(layout)/textfont_width;
		constant text_rows   : natural := textbox_height(layout)/textfont_height;
		constant text_size   : natural := text_rows*text_cols;
		variable retval      : unsigned(0 to ascii'length*text_size-1);

		constant label_maxsize : natural := 12;
		variable ascii_buffer  : std_logic_vector(0 to ascii'length*label_maxsize-1);
		constant labelids : i18nlabelid_vector := (
			0 => lbel_horizontal,
			1 => lbel_trigger,
			2 => lbel_level,
			3 => lbel_scale);

	begin
		for i in 0 to 2-1 loop
			ascii_buffer := fill(to_ascii(i18n_label(lang, labelids(i))), ascii_buffer'length, true);
			retval(0 to ascii_buffer'length-1) := unsigned(ascii_buffer);
			retval := retval rol (text_cols*ascii'length);
		end loop;
		for i in 0 to (labelids'length-2)/2-1 loop
			ascii_buffer := fill(to_ascii(i18n_label(lang, labelids(2*(i+1)+0))), ascii_buffer'length, true);
			retval(0 to ascii_buffer'length-1) := unsigned(ascii_buffer);
			retval := retval rol ((text_cols/2)*ascii'length);
			ascii_buffer := fill(to_ascii(i18n_label(lang, labelids(2*(i+1)+1))), ascii_buffer'length, true);
			retval(0 to ascii_buffer'length-1) := unsigned(ascii_buffer);
			retval := retval rol ((text_cols-text_cols/2)*ascii'length);
		end loop;
		retval := retval ror ((2+(labelids'length-2)/2)*(text_cols*ascii'length));
		return std_logic_vector(retval);
	end;
		
end;
