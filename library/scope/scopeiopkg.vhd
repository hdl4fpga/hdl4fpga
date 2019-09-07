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
	constant label_hzdiv    : i18n_labelids := 0;
	constant label_hzoffset : i18n_labelids := 1;
	constant label_trigger  : i18n_labelids := 2;
	constant label_vtdiv    : i18n_labelids := 3;
	constant label_vtoffset : i18n_labelids := 4;

	constant i18n_text : string := 
		"Hz div"     & NUL & 
		"Hz offset"  & NUL & 
		"Trigger"    & NUL & 
		"Vt div"     & NUL & 
		"Vt offset"  & NUL & 
		NUL &
		"Escala hz"  & NUL &
		"Retardo"    & NUL &
		"Disparo"    & NUL & 
		"Escala vt"  & NUL & 
		"Nivel vt"   & NUL & 
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

	type alignment is (
		left_alignment, 
		right_alignment, 
		center_alignment);

	function text_align (
		constant data  : string;
		constant width : natural;
		constant align : alignment := left_alignment;
		constant value : character := ' ')
		return string;

	type style_t is record
		width : natural;
		align : alignment;
		-- private
		addr  : natural;
	end record;

	constant no_style : style_t := (width => 0, align => left_alignment, addr => 0);
	type style_vector is array (natural range <>) of style_t;

	type tag_id is (tagid_end, tagid_row, tagid_label, tagid_var);
	type tag is record 
		tagid   : tag_id;
		style   : style_t;
		ref     : natural;
	end record;
	type tag_vector is array (natural range <>) of tag;

	constant var_triggerid  : natural := 1;
	constant var_hzdivid    : natural := 0;
	constant var_hzoffsetid : natural := 0;
	constant var_vtdivid    : natural := 2;
	constant var_vtoffsetid : natural := 3;

	constant analogtime_rowstyle   : style_t := (width => 0,  align => right_alignment, addr => 0);
	constant analogtime_fieldstyle : style_t := (width => 11, align => right_alignment, addr => 0);

	constant analogtime_layout : tag_vector := (
		(tagid_row, style => analogtime_rowstyle, ref => 0),
			(tagid_var,   style => analogtime_fieldstyle,  ref => var_triggerid),
			(tagid_label, style => analogtime_fieldstyle,  ref => label_trigger),
		(tagid_end, style => no_style, ref => 0),
		(tagid_row, style => analogtime_rowstyle, ref => 0),
			(tagid_var,  style => analogtime_fieldstyle,  ref => var_hzoffsetid),
			(tagid_var,  style => analogtime_fieldstyle,  ref => var_hzdivid),
		(tagid_end, style => no_style, ref => 0),
		(tagid_row, style => analogtime_rowstyle, ref => 0),
			(tagid_label, style => analogtime_fieldstyle, ref => label_hzoffset),
			(tagid_label, style => analogtime_fieldstyle, ref => label_hzdiv),
		(tagid_end, style => no_style, ref => 0),
		(tagid_row, style => analogtime_rowstyle, ref => 0),
			(tagid_label, style => analogtime_fieldstyle, ref => label_vtoffset),
			(tagid_label, style => analogtime_fieldstyle, ref => label_vtdiv),
		(tagid_end, style => no_style, ref => 0));

	function text_content (
		constant tag_layout  : tag_vector;
		constant text_width  : natural;
		constant text_height : natural;
		constant lang        : i18n_langs)
		return std_logic_vector;

	function text_addr (
		constant ref_id      : std_logic_vector;
		constant tag_layout  : tag_vector;
		constant text_width  : natural;
		constant text_height : natural)
		return std_logic_vector;

	function text_setaddr (
		constant tag_layout  : tag_vector;
		constant text_width  : natural;
		constant text_height : natural)
		return tag_vector;

	function text_analoginputs (
		constant inputs      : natural;
		constant tag_layout  : tag_vector)
		return tag_vector;

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

	function text_atleft (
		constant length : natural;
		constant width  : natural;
		constant align  : alignment := left_alignment)
		return integer is
	begin
		return setif(
			align=right_alignment,   width-length, setif(
			align=center_alignment, (width-length)/2, 0));
	end;

	function text_atright (
		constant length : natural;
		constant width  : natural;
		constant align  : alignment := left_alignment)
		return integer is
	begin
		return setif(
			align=left_alignment,    width-length, setif(
			align=center_alignment, (width-length+1)/2, 0));
	end;

	function text_align (
		constant data  : string;
		constant width  : natural;
		constant align : alignment := left_alignment;
		constant value : character := ' ')
		return string is
		variable retval   : string(1 to width);
		constant at_left  : integer := text_atleft(data'length, width, align);
		constant at_right : integer := text_atright(data'length, width, align);
	begin
		assert data'length <= width
			report "string shorter than width"
			severity failure;

		for i in 1 to at_left loop
			retval(i) := value;
		end loop;

		for i in at_left+1 to width-at_right loop
			exit when i > width;
			if i > 0 then
				retval(i) := data(i-at_left+(data'left-1));
			end if;
		end loop;

		for i in width-at_right+1 to width loop
			retval(i) := value;
		end loop;

		return retval;
	end;

	function text_label (
		constant text_tag : tag;
		constant lang     : i18n_langs)
		return string is
	begin
		return text_align(
			i18n_label(lang, text_tag.ref), 
			text_tag.style.width, 
			text_tag.style.align);
	end;

	procedure tagrow_setaddr (
		variable tag_index   : inout natural;
		variable tag_layout  : inout tag_vector) is
		variable text_length : positive;
		variable text_addr   : natural;
		variable text_left   : positive;
		variable at_left     : natural;
		variable index       : natural;
	begin
		index     := tag_index;
		text_addr := tag_layout(tag_index).style.addr;
		text_left := 1;
		tag_index := tag_index + 1;
		while tag_index < tag_layout'length loop
			text_length := text_left+tag_layout(tag_index).style.width-1;
			tag_layout(tag_index).style.addr := text_addr;
			text_addr   := text_addr  + tag_layout(tag_index).style.width;
			case tag_layout(tag_index).tagid is
			when tagid_end  =>
				exit;
			when others =>
			end case;
			text_left := text_length + 1;
			tag_index := tag_index   + 1;
		end loop;
		at_left := text_atleft(text_length, tag_layout(index).style.width, tag_layout(index).style.align);
		while index < tag_layout'length loop
			tag_layout(index).style.addr := tag_layout(index).style.addr + at_left;
			case tag_layout(index).tagid is
			when tagid_end  =>
				exit;
			when others =>
			end case;
			index := index + 1;
		end loop;
	end;

	procedure tagrow_content (
		variable tag_index   : inout natural;
		variable text_line   : inout string;
		constant tag_layout  : tag_vector;
		constant lang        : i18n_langs) is
		constant row_tag     : tag     := tag_layout(tag_layout'left);
		constant text_width  : natural := row_tag.style.width;
		constant text_alignment : alignment := row_tag.style.align;
		variable text_left   : positive;
		variable text_right  : positive;
	begin
		text_left := 1;
		tag_index := tag_index + 1;
		while tag_index < tag_layout'length loop
			text_right := text_left+tag_layout(tag_index).style.width-1;
			case tag_layout(tag_index).tagid is
			when tagid_end  =>
				for i in text_left to text_right loop
					text_line(i) := '#';
				end loop;
				exit;
			when tagid_label =>
				text_line(text_left to text_right) := text_label(tag_layout(tag_index), lang);
			when tagid_var =>
				for i in text_left to text_right loop
					text_line(i) := '$';
				end loop;
			when tagid_row =>
				for i in text_left to text_right loop
					text_line(i) := '@';
				end loop;
			end case;
			text_left := text_right + 1;
			tag_index := tag_index  + 1;
		end loop;

		text_line := text_align(
			text_line(1 to text_right),
			text_width, 
			text_alignment);
	end;

	function text_content (
		constant tag_layout  : tag_vector;
		constant text_width  : natural;
		constant text_height : natural;
		constant lang        : i18n_langs)
		return std_logic_vector is
		type line_vector is array (natural range <>) of string(1 to text_width);
		variable text_data   : line_vector(1 to text_height);
		variable lineno      : natural;
		variable tag_index   : natural;
		variable layout      : tag_vector(tag_layout'range) := tag_layout;
		variable retval      : unsigned(0 to ascii'length*text_width*text_height-1);
	begin
		lineno    := 1;
		tag_index := 0;
		while tag_index < layout'length loop
			case layout(tag_index).tagid is
			when tagid_row =>
				if layout(tag_index).style.width = 0 then
					layout(tag_index).style.width := text_width;
				end if;
				tagrow_content(tag_index, text_data(lineno), layout, lang);
			when others =>
				text_data(lineno) := (others => 'b');
			end case;
			lineno    := lineno    + 1;
			tag_index := tag_index + 1;
		end loop;
		retval := (others => '0');
		for i in text_data'range loop
			retval(0 to text_width*ascii'length-1) := unsigned(to_ascii(text_data(i)));
			retval := retval rol (text_width*ascii'length);
		end loop;
		return std_logic_vector(retval);
	end;
		
	function text_analoginputs (
		constant inputs      : natural;
		constant tag_layout  : tag_vector)
		return tag_vector is
		variable layout      : tag_vector(0 to tag_layout'length+4*inputs);
	begin
		layout(0 to tag_layout'length-1) := tag_layout;
		for i in 0 to inputs-1 loop
			layout(tag_layout'length+4*i+0) := (tagid_row, style => analogtime_rowstyle,   ref => 0);
			layout(tag_layout'length+4*i+1) := (tagid_var, style => analogtime_fieldstyle, ref => 2*i+var_vtoffsetid);
			layout(tag_layout'length+4*i+2) := (tagid_var, style => analogtime_fieldstyle, ref => 2*i+var_vtdivid);
			layout(tag_layout'length+4*i+3) := (tagid_end, style => no_style,              ref => 0);
		end loop;
		return layout;
	end;

	function text_setaddr (
		constant tag_layout  : tag_vector;
		constant text_width  : natural;
		constant text_height : natural)
		return tag_vector is
		variable retval      : tag_vector(tag_layout'range);
		variable tag_addr    : natural;
		variable tag_index   : natural;
		variable layout      : tag_vector(tag_layout'range) := tag_layout;
	begin
		tag_addr  := 0;
		tag_index := tag_layout'left;
		while tag_index < layout'length loop
			layout(tag_index).style.addr := tag_addr;
			case layout(tag_index).tagid is
			when tagid_row =>
				if layout(tag_index).style.width = 0 then
					layout(tag_index).style.width := text_width;
				end if;
				tag_addr := tag_addr  + layout(tag_index).style.width;
				tagrow_setaddr(tag_index, layout);
			when others =>
			end case;
			tag_index := tag_index + 1;
		end loop;
		return layout;
	end;

	function text_addr (
		constant ref_id      : std_logic_vector;
		constant tag_layout  : tag_vector;
		constant text_width  : natural;
		constant text_height : natural)
		return std_logic_vector is
		constant text_size : natural := text_width*text_height;
		constant addr_size : natural := unsigned_num_bits(text_size-1);
		variable layout    : tag_vector(tag_layout'range);
	begin
		layout := text_setaddr (tag_layout, text_width, text_height);
		for i in layout'range loop
			case layout(i).tagid is
			when tagid_var =>
				if unsigned(ref_id)=to_unsigned(layout(i).ref, ref_id'length) then
					return '1' & std_logic_vector(to_unsigned(layout(i).style.addr, addr_size));
				end if;
			when others =>
			end case;
		end loop;
		return '0' & (0 to addr_size-1 => '-');
	end;
		
end;
