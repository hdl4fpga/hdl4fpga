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

use std.textio;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.jso.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.textboxpkg.all;

package scopeiopkg is

	constant femto : real := 1.0e-15;
	constant pico  : real := 1.0e-12;
	constant nano  : real := 1.0e-9;
	constant micro : real := 1.0e-6;
	constant milli : real := 1.0e-3;

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

	constant axisy_backscale : natural := 0;
	constant axisx_backscale : natural := 1;
	constant max_pixelsize : natural := 24;

	constant textfont_width  : natural :=  8;
	constant textfont_height : natural := 16;

	-- type display_layout is record 
		-- display_width    : natural;            -- Display's width
		-- display_height   : natural;            -- Display's height
		-- num_of_segments  : natural;	           -- Number of segments to display
		-- division_size    : natural;            -- Length in pixels
		-- grid_width       : natural;            -- Width of the grid in divisions
		-- grid_height      : natural;            -- Width of the grid in divisions
		-- axis_fontsize    : natural;            -- Axis font size
		-- textbox_fontwidth : natural;            -- Textbox fontsize
		-- hzaxis_height    : natural;            -- Height of the horizontal axis 
		-- hzaxis_within    : boolean;            -- Horizontal axis within grid
		-- vtaxis_width     : natural;            -- Width of the vetical axis 
		-- vtaxis_within    : boolean;            -- Vertical axis within grid
		-- vttick_rotate    : rotate;             -- Vertical label rotating
		-- textbox_width    : natural;            -- Width of the text box
		-- textbox_within   : boolean;            -- Textbox within grid
		-- main_margin      : margin_vector;      -- Main Margin
		-- main_gap         : gap_vector;         -- Main Padding
		-- sgmnt_margin     : margin_vector;      -- Segment Margin
		-- sgmnt_gap        : gap_vector;         -- Segment Padding
	-- end record;
-- 
	-- type displaylayout_ids is (
		-- sd480,
		-- sd600,
		-- hd720,
		-- hd1080);
-- 
	-- type displaylayout_vector is array (displaylayout_ids) of display_layout;
-- 
	-- constant displaylayout_tab : displaylayout_vector := (
		-- sd480 => (            
			-- display_width     =>  640,
			-- display_height    =>  480,
			-- num_of_segments   =>    1,
			-- division_size     =>   32,
			-- grid_width        => 19*32+1,
			-- grid_height       => 14*32+1,
			-- axis_fontsize     =>    8,
			-- textbox_fontwidth =>    8,
			-- hzaxis_height     =>    8,
			-- hzaxis_within     => false,
			-- vtaxis_width      =>  1*8,
			-- vtaxis_within     => false,
			-- vttick_rotate     => ccw90,
			-- textbox_width     => 32*8,
			-- textbox_within    => true,
			-- main_margin       => (left       => 12, top    => 12, others => 0),
			-- main_gap          => (vertical   => 0, others => 0),
			-- sgmnt_margin      => (top        => 0, bottom => 0, others => 0),
			-- sgmnt_gap         => (horizontal => 0, others => 0)),
		-- sd600 => (            
			-- display_width   =>  800,
			-- display_height  =>  600,
			-- num_of_segments =>    2,
			-- division_size   =>   32,
			-- grid_width      => 16*32+1,
			-- grid_height     =>  6*32+1,
			-- axis_fontsize   =>    8,
			-- textbox_fontwidth =>  8,
			-- hzaxis_height   =>  8,
			-- hzaxis_within   => false,
			-- vtaxis_width    =>  1*8,
			-- vtaxis_within   => false,
			-- vttick_rotate   => ccw90,
			-- textbox_width   => 32*8,
			-- textbox_within  => false,
			-- main_margin     => (left => 3, top => 23, others => 0),
			-- main_gap        => (vertical => 16, others => 0),
			-- sgmnt_margin    => (top => 1, bottom => 1, others => 0),
			-- sgmnt_gap       => (horizontal => 1, others => 0)),
		-- hd720 => (
			-- display_width    => 1280,
			-- display_height   =>  720,
			-- num_of_segments  =>    3,
			-- division_size    =>   32,
			-- grid_width       => 31*32+1,
			-- grid_height      =>  6*32+1,
			-- axis_fontsize    =>    8,
			-- textbox_fontwidth=>    8,
			-- hzaxis_height    =>    8,
			-- hzaxis_within    => false,
			-- vtaxis_width     =>  6*8,
			-- vttick_rotate    => ccw0,
			-- textbox_width    => 32*6+1,
			-- vtaxis_within    => false,
			-- textbox_within   => false,
			-- main_margin     => (left => 3, top => 23, others => 0),
			-- main_gap        => (vertical => 16, others => 0),
			-- sgmnt_margin    => (top => 1, bottom => 1, left => 1, right => 1),
			-- sgmnt_gap       => (horizontal => 1, others => 0)),
		-- hd1080 => (
			-- display_width    => 1920,
			-- display_height   => 1080,
			-- num_of_segments  =>    4,
			-- division_size    =>   32,
			-- grid_width       => 50*32+1,
			-- grid_height      =>  8*32+1,
			-- axis_fontsize    =>    8,
			-- textbox_fontwidth   =>  8,
			-- hzaxis_height    =>    8,
			-- hzaxis_within   =>  false,
			-- vtaxis_width     =>  6*8,
			-- vttick_rotate    => ccw0,
			-- vtaxis_within   =>  false,
			-- textbox_width    => 33*8,
			-- textbox_within   => false,
			-- main_margin      => (top => 5, left => 1, others => 0),
			-- main_gap         => (others => 1),
			-- sgmnt_margin     => (others => 1),
			-- sgmnt_gap        => (horizontal => 1, others => 0)));

	constant vtaxis_boxid : natural := 0;
	constant grid_boxid   : natural := 1;
	constant text_boxid   : natural := 2;
	constant hzaxis_boxid : natural := 3;

	function axis_fontsize     (constant layout : string) return natural;

	function hzaxis_x          (constant layout : string) return natural;
	function hzaxis_y          (constant layout : string) return natural;
	function hzaxis_width      (constant layout : string) return natural;
	function hzaxis_height     (constant layout : string) return natural;

	function vtaxis_y          (constant layout : string) return natural;
	function vtaxis_x          (constant layout : string) return natural;
	function vtaxis_width      (constant layout : string) return natural;
	function vtaxis_height     (constant layout : string) return natural;
	function vtaxis_tickrotate (constant layout : string) return string;

	function grid_x            (constant layout : string) return natural;
	function grid_y            (constant layout : string) return natural;
	function grid_width        (constant layout : string) return natural;
	function grid_height       (constant layout : string) return natural;
	function grid_unit         (constant layout : string) return natural;

	function textbox_x         (constant layout : string) return natural;
	function textbox_y         (constant layout : string) return natural;
	function textbox_width     (constant layout : string) return natural;
	function textbox_height    (constant layout : string) return natural;

	function sgmnt_width       (constant layout : string) return natural;
	function sgmnt_height      (constant layout : string) return natural;
	function sgmnt_xedges      (constant layout : string) return natural_vector;
	function sgmnt_yedges      (constant layout : string) return natural_vector;

	function sgmnt_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : string)
		return std_logic;

	function main_width  (constant layout : string) return natural;
	function main_height (constant layout : string) return natural;
	function main_xedges (constant layout : string) return natural_vector;
	function main_yedges (constant layout : string) return natural_vector;

	function main_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : string)
		return std_logic;

	constant rid_ipaddr   : std_logic_vector := x"1f";
	constant rid_hzaxis   : std_logic_vector := x"10";
	constant rid_palette  : std_logic_vector := x"11";
	constant rid_trigger  : std_logic_vector := x"12";
	constant rid_gain     : std_logic_vector := x"13";
	constant rid_vtaxis   : std_logic_vector := x"14";
	constant rid_pointer  : std_logic_vector := x"15";
	constant rid_dmaaddr  : std_logic_vector := x"16";
	constant rid_dmalen   : std_logic_vector := x"17";
	constant rid_dmadata  : std_logic_vector := x"18";

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

	constant max_inputs     : natural := 32-pltid_order'length;
	constant maxinputs_bits : natural := unsigned_num_bits(max_inputs-1);
	constant chanid_maxsize : natural := unsigned_num_bits(max_inputs-1);

	function bitfield (
		constant bf_rgtr   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector;

	constant ip4num1_id : natural := 3;
	constant ip4num2_id : natural := 2;
	constant ip4num3_id : natural := 1;
	constant ip4num4_id : natural := 0;

	constant ip4addr_bf : natural_vector := (
		ip4num1_id => 8,
		ip4num2_id => 8,
		ip4num3_id => 8,
		ip4num4_id => 8);

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

	constant paletteopacityena_id : natural := 0;
	constant palettecolorena_id   : natural := 1;
	constant paletteopacity_id    : natural := 2;
	constant paletteid_id         : natural := 3;
	constant palettecolor_id      : natural := 4;

	constant palette_bf : natural_vector := (
		paletteopacityena_id => 1, 
		palettecolorena_id   => 1, 
		paletteopacity_id    => 1, 
		paletteid_id         => paletteid_maxsize, 
		palettecolor_id      => palettecolor_maxsize);

	constant trigger_freeze_id  : natural := 0;
	constant trigger_slope_id   : natural := 1;
	constant trigger_oneshot_id : natural := 2;
	constant trigger_level_id   : natural := 3;
	constant trigger_chanid_id  : natural := 4;

	constant triggerlevel_maxsize : natural := 9;
	constant trigger_bf : natural_vector := (
		trigger_freeze_id  => 1,
		trigger_slope_id   => 1,
		trigger_oneshot_id => 1,
		trigger_level_id   => triggerlevel_maxsize,
		trigger_chanid_id  => chanid_maxsize);

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

	type sio_float is record
		frac  : natural;
		exp   : integer;
		point : natural;
		multp : natural;
	end record;

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
			trigger_freeze   : buffer std_logic;
			video_clk        : in  std_logic;
			video_vton       : in  std_logic;
			video_frm        : in  std_logic;
			video_addr       : in  std_logic_vector;
			video_dv         : out std_logic;
			video_data       : out std_logic_vector);
	end component;

	function to_siofloat (
		constant unit : real)
		return sio_float;

	type siofloat_vector is array(natural range <>) of sio_float;

	function get_float1245 (
		constant unit : real)
		return siofloat_vector;

	function get_precs(
		constant floats : siofloat_vector)
		return natural_vector;

	function get_units(
		constant floats : siofloat_vector)
		return integer_vector;

	function scale_1245 (
		constant val   : signed;
		constant scale : std_logic_vector)
		return signed;
		
	function scale_1245 (
		constant val   : unsigned;
		constant scale : std_logic_vector)
		return unsigned;
		
	constant var_hzdivid      : natural := 0;
	constant var_hzunitid     : natural := 1;
	constant var_hzoffsetid   : natural := 2;
	constant var_tgrlevelid   : natural := 3;
	constant var_tgrfreezeid  : natural := 4;
	constant var_tgrunitid    : natural := 5;
	constant var_tgredgeid    : natural := 6;
	constant var_vtunitid     : natural := 7;
	constant var_vtoffsetid   : natural := 8;

	constant ip4_children : tag_vector := (         -- Xilinx's ISE Workaround
		text(                                       
			content => "IP : "),
		text(                                                                               -- 
			style   => styles(
				width(3) & alignment(right_alignment)),
			content => "*",
			id      => "ip4.num1"),
		text(
			content => "."),
		text(
			style   => styles(
				width(3) & alignment(right_alignment)),
			content => "*",
			id      => "ip4.num2"),
		text(
			content => "."),
		text(
			style   => styles(
				width(3) & alignment(right_alignment)),
			content => "*",
			id      => "ip4.num3"),
		text(
			content => "."),
		text(
			style   => styles(
				width(3) & alignment(right_alignment)),
			content => "*",
			id      => "ip4.num4"));

	constant ip4_tags : tag_vector := div (                                                 -- Xilinx's ISE Workaround
		style    => styles(alignment(right_alignment)),
		children => ip4_children);

	constant hz_children : tag_vector := (                                                  -- Xilinx's ISE Workaround
		text(                                                                               
			style   => styles(
				width(8) & alignment(right_alignment)),
			content => "NaN",
			id      => "hz.offset"),
		text(
			style   => styles(
				width(3) & alignment(center_alignment)),
			content => ":"),
		text(
			style   => styles(
				width(6) & alignment(right_alignment)),
			content => "NaN",
			id      => "hz.div"),
		text(
			content => " "),
		text(
			content => "*",
			id      => "hz.mag"),
		text(
			content => "s"));

	constant hz_tags : tag_vector := div (  -- Xilinx's ISE Workaround
		style    => styles(bg_palette(pltid_textbg) & alignment(right_alignment)),
		children => hz_children);                                                           

	constant tgr_children : tag_vector := ( -- Xilinx's ISE Workaround
		text( 
			style   => styles(
				width(1) & alignment(right_alignment)),
			id      => "tgr.freeze"),
		text(
			style   => styles(
				width(1) & alignment(right_alignment)),
			id      => "tgr.edge"),
		text(
			style   => styles(
				width(7) & alignment(right_alignment)),
			content => "NaN",
			id      => "tgr.level"),
		text(
			style   => styles(
				width(3) & alignment(center_alignment)),
			content => ":"),
		text(
			style   => styles(
				width(6) & alignment(right_alignment)),
			content => "",
			id      => "tgr.div"),
		text(
			content => " "),
		text(
			style   => styles(
				width(1)),
			content => "*",
			id      => "tgr.mag"),
		text(
			content => "V"));

	constant tgr_tags : tag_vector := div (                                                 -- Xilinx's ISE Workaround
		id       => "tgr",
		style    => styles(text_palette(pltid_order'length) & bg_palette(pltid_textbg) & alignment(right_alignment)),
		children => tgr_children);
		
	constant vt0_children : tag_vector := (													-- Xilinx's ISE Workaround
		text(
			style   => styles(alignment(left_alignment)),
			id      => "vt(0).text"),
		text(
			style   => styles(alignment(right_alignment) & width(7)),
			content => "NaN",
			id      => "vt(0).offset"),
		text(
			style   => styles(width(3) & alignment(center_alignment)),
			content => ":"),
		text(
			style   => styles(width(6) & alignment(right_alignment)),
			content => "NaN",
			id      => "vt(0).div" ),
		text(
			style   => styles(alignment(center_alignment)),
			content => " "),
		text(
			style   => styles(alignment(right_alignment)),
			content => "*",
			id      => "vt(0).mag"),
		text(
			style   => styles(alignment(center_alignment)),
			content => "V"));

	constant vt0_tags : tag_vector := div(                                                  -- Xilinx's ISE Workaround
		id       => "vt(0)",
		style    => styles(
			text_palette(pltid_order'length) & bg_palette(pltid_textbg) & alignment(right_alignment)),
		children => vt0_children);                                                         

	function analogreadings (
		constant style       : style_t;
		constant inputs      : natural;
		constant input_names : tag_vector)
		return tag_vector;

	constant notext : tag := text;

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

		variable edge   : natural;
		variable index  : natural;
		variable edges  : natural_vector(0 to sides'length+(sides'length-1)*gap+pos(margin_end)-1);
		variable retval : natural_vector(0 to sides'length+(sides'length-1)*gap+pos(margin_start)+pos(margin_end)-1);
	begin

		index := 0;
		edge  := margin_start;
		for i in sides'range loop
			if sides(i)/=0 then
				if index > 0 then
					if gap/=0 then
						edges(index) := gap + edge;
						edge  := edges(index);
						index := index + 1;
					end if;
				end if;
				edges(index) := sides(i) + edge;
				edge  := edges(index);
				index := index + 1;
			end if;
		end loop;
		if margin_end > 0 then
			edges(index) := margin_end + edge;
			index := index + 1;
		end if;
		if margin_start > 0 then
			retval(0) := margin_start;
			retval(1 to index) := edges(0 to index-1);
			index := index + 1;
		else
			retval(0 to index-1) := edges(0 to index-1);
		end if;

		return retval(0 to index-1);
	end;

	function grid_x (
		constant layout : string)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + vtaxis_x(layout);
		if not (jso(layout)**".axis.vertical.inside") then
			retval := retval + vtaxis_width(layout);
			retval := retval + jso(layout)**".segment.horizontal";
		end if;
		return retval;
	end;

	function grid_y (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".segment.top";
	end;

	function grid_width (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".grid.width";
	end;

	function grid_height (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".grid.height";
	end;

	function grid_unit (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".grid.unit";
	end;

	function axis_fontsize (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".axis.fontsize";
	end;

	function vtaxis_x (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".segment.left";
	end;

	function vtaxis_y (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".segment.top";
	end;

	function vtaxis_width (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".axis.vertical.width";
	end;

	function vtaxis_height (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".grid.height";
	end;

	function vtaxis_tickrotate (
		constant layout : string)
		return string is
	begin
		return jso(layout)**".axis.vertical.rotate";
	end;

	function textbox_x (
		constant layout : string)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + grid_x(layout);
		if not (jso(layout)**".textbox.inside") then
			retval := retval + jso(layout)**".grid.width";
			retval := retval + jso(layout)**".segment.horizontal";
		else
			if 2**unsigned_num_bits(jso(layout)**".textbox.width"-1)=jso(layout)**".textbox.width" then
				if jso(layout)**".textbox.font_width"*(grid_width(layout)/jso(layout)**".textbox.font_width") mod jso(layout)**"textbox.width"=0 then
					retval := retval + jso(layout)**".grid.width"-jso(layout)**".textbox.width"-jso(layout)**".grid.width" mod jso(layout)**".textbox.font_width";
				else
					retval := retval + grid_width(layout)-textbox_width(layout);
				end if;
			else
				retval := retval + grid_width(layout)-textbox_width(layout);
			end if;
		end if;
		return retval;
	end;

	function textbox_y (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".segment.top";
	end;

	function textbox_width (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".textbox.width";
	end;

	function textbox_height (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".grid.height";
	end;

	function hzaxis_x (
		constant layout : string)
		return natural is
	begin
		return grid_x(layout);
	end;

	function hzaxis_y (
		constant layout : string)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + grid_y(layout);
		if not (jso(layout)**".axis.horizontal.inside")=false then
			retval := retval + jso(layout)**".grid.height";
			retval := retval + jso(layout)**".segment.vertical";
		else
			retval := retval + grid_height(layout)-jso(layout)**".axis.horizontal.height";
		end if;
		return retval;
	end;

	function hzaxis_width (
		constant layout : string)
		return natural is
	begin
		return grid_width(layout);
	end;

	function hzaxis_height (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".axis.horizontal.height";
	end;

	function sgmnt_height (
		constant layout : string)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + jso(layout)**".segment.top";
		retval := retval + jso(layout)**".grid.height";
		if not (jso(layout)**".axis.horizontal.inside") then
			retval := retval + jso(layout)**".axis.horizontal.height";
			retval := retval + jso(layout)**".segment.vertical";
		end if;
		retval := retval + jso(layout)**".segment.bottom";
		return retval;
	end;

	function sgmnt_width (
		constant layout : string)
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + jso(layout)**".segment.left";
		if not (jso(layout)**".axis.vertical.inside") then
			retval := retval + jso(layout)**".axis.vertical.width";
			retval := retval + jso(layout)**".segment.horizontal";
		end if;
		retval := retval + grid_width(layout);
		if not (jso(layout)**".textbox.inside") then
			retval := retval + jso(layout)**".textbox.width";
			retval := retval + jso(layout)**".segment.horizontal";
		end if;
		retval := retval + jso(layout)**".segment.right";
		return retval;
	end;

	function sgmnt_xedges(
		constant layout : string)
		return natural_vector is

	begin

		return to_edges(boxes_sides(
			sides        => (
				vtaxis_boxid => setif(not (jso(layout)**".axis.vertical.inside"), vtaxis_width(layout)), 
				grid_boxid   => grid_width(layout), 
				text_boxid   => setif(not (jso(layout)**".textbox.inside"), textbox_width(layout))),
			margin_start => jso(layout)**".segment.left",
			margin_end   => jso(layout)**".segment.right",
			gap          => jso(layout)**".segment.horizontal"));
	end;

	function sgmnt_yedges(
		constant layout : string)
		return natural_vector is
	begin

		return to_edges(boxes_sides(
			sides        => (
				0 => grid_height(layout),
				1 => setif(not (jso(layout)**".axis.horizontal.inside"), hzaxis_height(layout))),
			margin_start => jso(layout)**".segment.top",
			margin_end   => jso(layout)**".segment.bottom",
			gap          => jso(layout)**".segment.vertical"));
	end;

	function sgmnt_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector;
		constant layout : string)
		return std_logic is
		constant x_sides  : natural_vector := (
			vtaxis_boxid => setif(not (jso(layout)**".axis.vertical.inside"), vtaxis_width(layout)),
			grid_boxid   => grid_width(layout),
			text_boxid   => setif(not (jso(layout)**".textbox.inside"), textbox_width(layout)),
			hzaxis_boxid => setif(not (jso(layout)**".axis.horizontal.inside"),  hzaxis_width(layout)));

		constant y_sides  : natural_vector := (
			vtaxis_boxid => setif(not (jso(layout)**".axis.vertical.inside"), vtaxis_height(layout)),
			grid_boxid   => grid_height(layout),
			text_boxid   => setif(not (jso(layout)**".textbox.inside"), textbox_height(layout)),
			hzaxis_boxid => setif(not (jso(layout)**".axis.horizontal.inside"), hzaxis_height(layout)));

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
		x_margin := pos(jso(layout)**".segment.left");
		y_margin := pos(jso(layout)**".segment.top");
		x_gap    := pos(jso(layout)**".segment.horizontal");
		y_gap    := pos(jso(layout)**".segment.vertical)");

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
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".display.width";
	end;

	function main_height (
		constant layout : string)
		return natural is
	begin
		return jso(layout)**".display.height";
	end;

	function main_xedges(
		constant layout : string)
		return natural_vector is
		constant sides : natural_vector := boxes_sides(
			sides        => (0 => sgmnt_width(layout)),
			margin_start => jso(layout)**".main.left",
			margin_end   => jso(layout)**".main.right",
			gap          => jso(layout)**".main.horizontal");

	begin
		assert sides(sides'right)<=main_width(layout)
		report "Boxes' Width sum up cannot be greater than Display's Width"
		severity FAILURE;
		return to_edges(sides);
	end;

	function main_yedges(
		constant layout : string)
		return natural_vector is
		constant sides : natural_vector := boxes_sides(
			-- sides        => (0 to natural'(jso(layout)**".num_of_segments")-1 => sgmnt_height(layout)),
			sides        => (0 to resolve(layout&".num_of_segments")-1 => sgmnt_height(layout)),
			margin_start => jso(layout)**".main.top",
			margin_end   => jso(layout)**".main.bottom",
			gap          => jso(layout)**".main.vertical");
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
		constant layout   : string)
		return std_logic is
		variable x_margin : natural;
		variable y_margin : natural;
		variable x_gap    : natural;
		variable y_gap    : natural;
	begin

		x_margin := pos(jso(layout)**".main.left");
		y_margin := pos(jso(layout)**".main.top");
		x_gap    := pos(jso(layout)**".main.horizontal");
		y_gap    := pos(jso(layout)**".main.vertical");

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

	function to_siofloat (
		constant unit : real)
		return sio_float is
		variable frac : real;
		variable exp   : integer;
		variable point : natural;
		variable multp : natural;
		variable mult  : real;
	begin
		assert unit >= 1.0  
			report "Invalid unit value"
			severity failure;

		mult  := 1.0;
		point := 0;
		while unit >= mult loop
			mult  := mult * 1.0e1;
			point := point + 1;
		end loop;
		mult  := mult / 1.0e1;
		point := point - 1;
		frac  := unit / mult;

		exp := 0;
		for i in 0 to 3-1 loop
			exit when floor(frac)=(frac);

			assert i /= 4
			report "Invalid unit value"
			severity failure;

			frac := frac * 2.0;
			exp  := exp - 1;
		end loop;

		return sio_float'(frac => natural(frac), exp => exp, point => point mod 3, multp => point / 3);
	end;

	function get_float1245 (
		constant unit : real)
		return siofloat_vector is
		constant mult : natural_vector (0 to 4-1) := (1, 2, 4, 5);
		variable rval : siofloat_vector(0 to 4-1);
	begin
		for i in 0 to 4-1 loop
			rval(i) := to_siofloat(unit*real(mult(i)));
		end loop;
		return rval;
	end;

	function get_precs(
		constant floats : siofloat_vector)
		return natural_vector is
		variable rval : natural_vector(0 to 16-1);
	begin
		for i in floats'range loop
			case floats(i).point is
			when 0 =>
				rval(i) := 2;
			when 1 =>
				rval(i) := 1;
			when others =>
				rval(i) := 3;
			end case;
		end loop;
		for i in 4 to 16-1 loop
			rval(i) := ((rval(i-4) + 1) mod 3) + 1;
		end loop;
		return rval;
	end;

	function get_units(
		constant floats : siofloat_vector)
		return integer_vector is
		variable rval : integer_vector(0 to 16-1);
	begin
		for i in floats'range loop
			case floats(i).point is
			when 0 =>
				rval(i) := 0;
			when 1 =>
				rval(i) := 1;
			when others =>
				rval(i) := -1;
			end case;
		end loop;
		for i in 4 to 16-1 loop
			rval(i) := ((rval(i-4) + 2) mod 3) - 1;
		end loop;
		return rval;
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
		
	function scale_1245 (
		constant val   : unsigned;
		constant scale : std_logic_vector)
		return unsigned is
		variable sel  : std_logic_vector(scale'length-1 downto 0);
		variable by1  : unsigned(val'range);
		variable by2  : unsigned(val'range);
		variable by4  : unsigned(val'range);
		variable rval : unsigned(val'range);
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
			rval := (others => '1');
		end case;
		return rval;
	end;
		
	function analogreadings (
		constant style    : style_t;
		constant inputs   : natural;
		constant input_names : tag_vector)
		return tag_vector
	is
		variable vt_tag   : tag_vector(vt0_tags'range);
		variable vt_tags  : tag_vector(0 to inputs*vt0_tags'length-1);
		variable children : tag_vector(0 to ip4_tags'length+hz_tags'length+tgr_tags'length+inputs*vt0_tags'length-1);
		variable base     : natural;
	begin
		vt_tag := vt0_tags;
		if input_names'length > 0 then 
			if isvalidbyid(input_names, "vt(0).text") then
				vt_tag(tagindexbyid(vt_tag,"vt(0).text")).content := input_names(tagindexbyid(input_names,"vt(0).text")).content;
			end if;
		end if;

		vt_tags(0 to vt0_tags'length-1) := vt_tag;
		for i in 1 to inputs-1 loop
			vt_tag := vt0_tags;
			if input_names'length > 0 then 
				if isvalidbyid(input_names, "vt(" & integer'image(i) & ").text") then
					vt_tag(tagindexbyid(vt_tag, "vt(0).text")).content := input_names(tagindexbyid(input_names, "vt(" & itoa(i) & ").text")).content;
        			vt_tag(tagindexbyid(vt_tag, "vt(0)")).style(key_textpalette) := i+pltid_order'length;
        			vt_tag(tagindexbyid(vt_tag, "vt(0)")).id        := strfill("vt(" & itoa(i) & ")", 16);
        			vt_tag(tagindexbyid(vt_tag, "vt(0).text")).id   := strfill("vt(" & itoa(i) & ").text", 16);
        			vt_tag(tagindexbyid(vt_tag, "vt(0).offset")).id := strfill("vt(" & itoa(i) & ").offset", 16);
        			vt_tag(tagindexbyid(vt_tag, "vt(0).div")).id    := strfill("vt(" & itoa(i) & ").div", 16);
        			vt_tag(tagindexbyid(vt_tag, "vt(0).mag")).id    := strfill("vt(" & itoa(i) & ").mag", 16);
				else
					report input_names(i).id & " is not valid tag" 
					severity FAILURE;
				end if;
			end if;

			-- for i in vt_tag'range loop
				-- report CR & LF & integer'image(i) & " ---> " & vt_tag(i).id
				-- severity warning;
			-- end loop;

			vt_tags(i*vt_tag'length to (i+1)*vt_tag'length-1) := vt_tag;
		end loop;

		base := 0;
		children(base to base+ip4_tags'length-1) := ip4_tags;

		base := base + ip4_tags'length;
		children(base to base+hz_tags'length-1)  := hz_tags;

		base := base + hz_tags'length;
		children(base to base+tgr_tags'length-1) := tgr_tags;
		children(tagindexbyid(children, "tgr")).style(key_textpalette) := inputs+pltid_order'length;

		base := base + tgr_tags'length;
		children(base to base+vt_tags'length-1)  := vt_tags;

		return page(
			style    => style,
			children => children);
	end;

end;
