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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
--use hdl4fpga.scopeiopkg.all;

package textboxpkg is

	type style_keys   is (key_width, key_alignment, key_textcolor, key_backgroundcolor);
	type style_t      is array (style_keys) of natural;
	type style_vector is array (natural range <>) of style_t;

	subtype alignment_t is natural;
	constant left_alignment   : natural := 0;
	constant right_alignment  : natural := 1;
	constant center_alignment : natural := 2;

	function alignment        (constant value  : natural) return style_vector; 
	function text_color       (constant value  : natural) return style_vector; 
	function background_color (constant value  : natural) return style_vector;
	function width            (constant value  : natural) return style_vector; 

	function style (
		constant alignment        : natural := 0;
		constant background_color : natural := 0;
		constant text_color       : natural := 0;
		constant width            : natural := 0)
		return style_t;

	function styles           (constant values : style_vector) return style_t;

	constant tid_end  : natural := 0;
	constant tid_text : natural := 1;
	constant tid_div  : natural := 2;
	constant tid_page : natural := 3;

	type tag is record 
		tid     : natural;
		style   : style_t;
		id      : string(1 to 16);
		content : string(1 to 16);
	end record;

	type tag_vector is array (natural range <>) of tag;

	constant domain : string := "hola";
	function text (constant content  : string := ""; constant style : style_t; constant id : string := "") return tag_vector;
	function div  (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;
	function page (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;

	function browse (
		constant tags : tag_vector)
		return string;
end;

package body textboxpkg is

	function strfill (
		constant s    : string;
		constant size : natural;
		constant char : character := NUL)
		return string
	is
		variable retval : string(1 to size);
		variable j      : natural;
	begin
		j := 1;
		for i in s'range loop
			retval(j) := s(i);
			j := j + 1;
		end loop;
		while j <= size loop
			retval(j) := char;
			j := j + 1;
		end loop;
		return retval;
	end;

	procedure strcmp (
		variable sucess : inout boolean;
		variable index  : inout natural;
		constant key    : in    string;
		constant domain : in    string)
	is
	begin
		sucess := false;
		for i in key'range loop
			if index < domain'length then
				if key(i)/=domain(index) then
					return;
				else
					index := index + 1;
				end if;
			elsif key(i)=NUL then
				sucess := true;
				return;
			else
				return;
			end if;
		end loop;
		if index < domain'length then
			if domain(index)=NUL then
				sucess := true;
				return;
			else
				return;
			end if;
		else
			sucess := true;
			return;
		end if;
	end;

	function strstr(
		constant key    : string;
		constant domain : string)
		return natural is
		variable sucess : boolean;
		variable index  : natural;
		variable ref    : natural;
	begin
		ref   := 0;
		index := domain'left;
		while index < domain'right loop
			strcmp(sucess, index, key, domain);
			if sucess then
				return ref;
			end if;
			while domain(index) /= NUL loop
				index := index + 1;
			end loop;
			index := index + 1;
		end loop;
	end;

	function strlen (
		constant str : string)
		return natural
	is
		variable retval : natural;
	begin
		retval := 0;
		for i in str'range loop
			if str(i)=NUL then
				return retval;
			end if;
			retval := retval + 1;
		end loop;
		return str'length;
	end;

	function padding_left (
		constant length : natural;
		constant width  : natural;
		constant align  : alignment_t := left_alignment)
		return integer
	is
	begin
		return setif(
			align=right_alignment,   width-length, setif(
			align=center_alignment, (width-length)/2, 0));
	end;

	function padding_right (
		constant length : natural;
		constant width  : natural;
		constant align  : alignment_t := left_alignment)
		return integer is
	begin
		return setif(
			align=left_alignment,    width-length, setif(
			align=center_alignment, (width-length+1)/2, 0));
	end;

	function stralign (
		constant str   : string;
		constant width : natural;
		constant align : alignment_t)
		return string
	is
		constant blank    : character := ' ';
		constant at_left  : integer := padding_left (str 'length, width, align);
		constant at_right : integer := padding_right(str 'length, width, align);
		variable retval   : string(1 to width);
	begin
		for i in 1 to at_left loop
			retval(i) := blank;
		end loop;

		for i in at_left+1 to width-at_right loop
			exit when i > width;
			if i > 0 then
				retval(i) := str (i-at_left+(str 'left-1));
			end if;
		end loop;

		for i in width-at_right+1 to width loop
			retval(i) := blank;
		end loop;

		return retval;
	end;

	function alignment (
		constant value : natural)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_alignment) := value;
		return retval;
	end;

	function background_color (
		constant value : natural)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_backgroundcolor) := value;
		return retval;
	end;

	function text_color (
		constant value : natural)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_textcolor) := value;
		return retval;
	end;

	function width (
		constant value : natural)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_width) := value;
		return retval;
	end;

	function style (
		constant alignment        : natural := 0;
		constant background_color : natural := 0;
		constant text_color       : natural := 0;
		constant width            : natural := 0)
		return style_t
	is
		variable retval : style_t;
	begin
		retval(key_alignment)       := alignment;
		retval(key_backgroundcolor) := background_color;
		retval(key_textcolor)       := text_color;
		retval(key_width)           := width;
		return retval;
	end;

	function styles (
		constant values : style_vector)
		return style_t is
		variable retval : style_t;
	begin
		for i in values'reverse_range loop
			for j in style_t'range loop
				if values(i)(j)/=0 then
					retval(j) := values(i)(j);
				end if;
			end loop;
		end loop;
		return retval;
	end;

	function endtag 
		return tag is
		variable retval : tag;
	begin
		retval.tid := tid_end;
		return retval;
	end;

	function div (
		constant children : tag_vector;
		constant style    : style_t;
		constant id       : string := "")
		return tag_vector is
		variable div : tag;
		variable mesg : line;
	begin
		div.tid   := tid_div;
		div.style := style;
		write (mesg, string'("****** div ======> "));
		write (mesg, div.style(key_width));
		report mesg.all;
		if div.style(key_width)=0 then
			for i in children'range loop
				div.style(key_width) := div.style(key_width) + children(i).style(key_width);
			end loop;
		end if;
		return div & children & endtag;
	end;

	function page (
		constant children : tag_vector;
		constant style    : style_t;
		constant id       : string := "")
		return tag_vector is
		variable page : tag;
		variable tags : tag_vector(children'range);
		variable mesg : line;
	begin
		page.tid   := tid_page;
		page.style := style;
		tags := children;
		write (mesg, string'("****** page ======> "));
		write (mesg, page.style(key_width));
		report mesg.all;
		for i in tags'range loop
			if tags(i).tid = tid_div then
				tags(i).style(key_width) := page.style(key_width);
			end if;
		end loop;
		return page & tags & endtag;
	end;

	function text (
		constant content : string := "";
		constant style   : style_t;
		constant id      : string := "")
		return tag_vector 
	is
		variable mesg : line;
		variable retval : tag_vector(0 to 0);
	begin
		retval(0).tid     := tid_text;
		retval(0).id      := strfill(id, retval(0).id'length);
		retval(0).content := strfill(content, retval(0).content'length);
		retval(0).style   := style;
		retval(0).style(key_width) := setif(style(key_width)=0,content'length, style(key_width));

		write(mesg, string'("====> text =====> "));
		write(mesg, retval(0).style(key_alignment));
		write(mesg, string'(" : "));
		write(mesg, retval(0).style(key_width));
		write(mesg, string'(" : "));
		write(mesg, character'('"'));
		write(mesg, retval(0).content(1 to strlen(content)));
		write(mesg, character'('"'));
		report mesg.all; mesg := null;
		return retval;
	end;

	procedure text_content (
		variable ptr     : inout natural;
		variable content : inout   string;
		constant tags    : in    tag_vector)
	is
		variable mesg : line;
	begin
		content := stralign(
			str   => tags(ptr).content(1 to strlen(tags(ptr).content)), 
			width => tags(ptr).style(key_width),
			align => tags(ptr).style(key_alignment));
		write(mesg, string'("====> text_content =====> "));
		write(mesg, tags(ptr).style(key_alignment));
		write(mesg, string'(" : "));
		write(mesg, strlen(tags(ptr).content));
		write(mesg, string'(" : "));
		write(mesg, tags(ptr).style(key_width));
		write(mesg, string'(" : "));
		write(mesg, character'('"'));
		write(mesg, content);
		write(mesg, character'('"'));
		report mesg.all;
		ptr := ptr + 1;
	end;

	procedure div_content (
		variable ptr     : inout natural;
		variable content : inout   string;
		constant tags    : in    tag_vector)
	is
		variable style  : style_t;
		variable left   : natural;
		variable right  : natural;
		variable mesg : line;
	begin
		style := tags(ptr).style;
		left  := content'left;
		ptr   := ptr + 1;
		while tags(ptr).tid/=tid_end loop
			right := left+tags(ptr).style(key_width)-1;
			text_content (
				ptr     => ptr,
				content => content(left to right),
				tags    => tags);
		write(mesg, string'("====> div_content =====> ******************************** "));
		write(mesg, left);
		write(mesg, string'(" : "));
		write(mesg, right);
		write(mesg, string'(" : "));
		write(mesg, character'('"'));
		write(mesg, content(left to right));
		write(mesg, character'('"'));
		write(mesg, style(key_width));
		report mesg.all; mesg := null;
			left := right + 1;
		end loop;
		content(content'left to content'left+style(key_width)-1) := stralign(
			str   => content(content'left to right), 
			width => style(key_width),
			align => style(key_alignment));
	end;

	procedure page_content (
		variable content  : inout string;
		constant tags     : in  tag_vector)
	is
		variable ptr   : natural;
		variable left  : natural;
		variable right : natural;
		variable mesg : line;
	begin
		ptr  := tags'left;
		left := 1;
		if tags(ptr).tid=tid_page then
			ptr := ptr + 1;
		end if;
		while ptr <= tags'right loop
			right := left + tags(ptr).style(key_width) + left - 1;

			write (mesg, left);
			write (mesg, string'(" : " ));
			write (mesg, right);
			report mesg.all;
			case tags(ptr).tid is
			when tid_div =>
				div_content(
					ptr     => ptr,
					content => content(left to right),
					tags => tags);
				left := right + 1;
			when others =>
			end case;
			ptr  := ptr + 1;
		end loop;
		if left <= content'right then
			content(left) := NUL;
		end if;
	end;

	function browse (
		constant tags : tag_vector)
		return string 
	is
		variable retval : string(1 to 1024);
		variable ptr    : natural;
		variable mesg   : line;
	begin
		
		page_content (
			content => retval,
			tags    => tags);
		write (mesg, strlen(retval));
		report mesg.all;

		return retval;
		
	end;
--	constant layout : tag_vector := 
--		div (
--			style    => styles(background_color(0) & alignment(right_alignment)),
--			children => 
--				text(
--					style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
--					id      => "hzoffset") &
--				text(
--					style   => styles(background_color(0) & width(3) & alignment(center_alignment)),
--					content => ":") &
--				text(
--					style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
--					id      => "hzdiv") &
--				text(
--					style   => styles(background_color(0) & alignment(center_alignment)),
--					content => " ") &
--				text(
--					style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
--					id      => "hzmag") &
--				text(
--					style   => styles(background_color(0) & alignment(center_alignment)),
--					content => "s")) &
--		div (
--			style    => styles(background_color(0) & alignment(right_alignment)),
--			children => 
--				text(
--					style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
--					id      => "tgr_freeze") &
--				text(
--					style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
--					id      => "tgr_edge") &
--				text(
--					style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
--					id      => "tgr_level") &
--				text(
--					style   => styles(background_color(0) & alignment(center_alignment)),
--					content => " ") &
--				text(
--					style   => styles(background_color(0) & width(2) & alignment(right_alignment)),
--					id      => "tgr_div") &
--				text(
--					style   => styles(background_color(0) & alignment(center_alignment)),
--					content => " ") &
--				text(
--					style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
--					id      => "tgr_mag") &
--				text(
--					style   => styles(background_color(0) & alignment(center_alignment)),
--					content => "V"));

end;
