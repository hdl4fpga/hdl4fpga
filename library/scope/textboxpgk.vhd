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
		tid      : natural;
		style    : style_t;
		id       : string(1 to 16);
		content  : string(1 to 16);
		mem_ptr  : natural;
	end record;

	type tag_vector is array (natural range <>) of tag;

	function text (constant content  : string := ""; constant style : style_t; constant id : string := "") return tag_vector;
	function div  (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;
	function page (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;

	function browse (
		constant tags : tag_vector;
		constant size : natural)
		return string;

	function strlen (
		constant str : string)
		return natural;

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
		return retval;
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

	procedure offset_memptr(
		constant offset : in    integer;
		variable tags   : inout tag_vector)
	is
		variable level  : natural;
		variable mesg : line;
	begin
		level := 0;
		write(mesg, string'("offset "));
		for i in tags'range loop
			case tags(i).tid is 
			when tid_end =>
				exit when level=0;
				level := level - 1;
			when tid_div =>
				level := level + 1;
			when others =>
			end case;
			write(mesg, string'(" : "));
			write(mesg, tags(i).mem_ptr);
			write(mesg, string'("("));
			write(mesg, offset);
			write(mesg, string'(") -> "));
			tags(i).mem_ptr := tags(i).mem_ptr + offset;
			write(mesg, tags(i).mem_ptr);
		end loop;
		report mesg.all;

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

	function log (
		constant tname   : string;
		constant left    : natural;
		constant right   : natural;
		constant width   : natural;
		constant content : string)
		return line
	is
		variable mesg : line;
	begin
		write(mesg, tname);
		write(mesg, string'(" : left  => "));
		write(mesg, left);
		write(mesg, string'(" : right => "));
		write(mesg, right);
		write(mesg, string'(" : content => "));
		write(mesg, character'('"'));
		if strlen(content)/=0 then
			write(mesg, content(content'left to content'left+strlen(content)-1));
		end if;
		write(mesg, character'('"'));
		write(mesg, string'(" : width => "));
		write(mesg, width);
		return mesg;
	end;

	function div (
		constant children : tag_vector;
		constant style    : style_t;
		constant id       : string := "")
		return tag_vector is
		variable div : tag;
	begin
		div.tid   := tid_div;
		div.style := style;
		return div & children & endtag;
	end;

	function page (
		constant children : tag_vector;
		constant style    : style_t;
		constant id       : string := "")
		return tag_vector is
		variable page : tag;
		variable tags : tag_vector(children'range);
	begin
		page.tid   := tid_page;
		page.style := style;
		tags := children;
		return page & tags & endtag;
	end;

	function text (
		constant content : string := "";
		constant style   : style_t;
		constant id      : string := "")
		return tag_vector 
	is
		variable retval : tag_vector(0 to 0);
		variable mesg : line;
	begin
		retval(0).tid     := tid_text;
		retval(0).id      := strfill(id, retval(0).id'length);
		retval(0).style   := style;
		retval(0).content := strfill(content, retval(0).content'length);

		return retval;
	end;

	procedure text_content (
		variable ctnt_ptr : inout natural;
		variable content  : inout string;
		variable tag_ptr  : inout natural;
		variable tags     : inout tag_vector)
	is
		variable left  : natural;
		variable right : natural;
		variable mesg : line;
	begin
		if tags(tag_ptr).style(key_width)=0 then
			tags(tag_ptr).style(key_width) := strlen(tags(tag_ptr).content); 
		end if;
		tags(tag_ptr).mem_ptr := ctnt_ptr;

		left  := ctnt_ptr;
		right := left+tags(tag_ptr).style(key_width)-1;

		content(left to right) := stralign(
			str   => tags(tag_ptr).content(1 to strlen(tags(tag_ptr).content)), 
			width => tags(tag_ptr).style(key_width),
			align => tags(tag_ptr).style(key_alignment));
		ctnt_ptr := ctnt_ptr + tags(tag_ptr).style(key_width);

		report log(
			tname   => string'("text"),
			left    => left,
			right   => right,
			width   => tags(tag_ptr).style(key_width),
			content => content(content'left to right)).all;
	end;

	procedure div_content (
		variable ctnt_ptr : inout natural;
		variable content  : inout string;
		variable tag_ptr  : inout natural;
		variable tags     : inout tag_vector)
	is
		variable cptr    : natural;
		variable tptr    : natural;
	begin
		cptr    := ctnt_ptr;
		tptr    := tag_ptr;
		tags(tptr).mem_ptr := ctnt_ptr;
		tag_ptr := tag_ptr + 1;

		while tags(tag_ptr).tid/=tid_end loop
			case tags(tag_ptr).tid is
			when tid_text =>
				text_content (
					tag_ptr  => tag_ptr,
					ctnt_ptr => ctnt_ptr,
					content  => content,
					tags     => tags);
			when others =>
			end case;

			tag_ptr := tag_ptr + 1;
		end loop;

		if div.style(key_width)=0 then
			tags(tptr).style(key_width) := ctnt_ptr-cptr;
		end if;

		offset_memptr(
			offset => padding_left (
				length => ctnt_ptr-tags(tptr).mem_ptr,
				width  => tags(tptr).style(key_width),
				align  => tags(tptr).style(key_alignment)),
			tags => tags(tptr to tag_ptr-1));

		content(cptr to cptr+tags(tptr).style(key_width)-1) := stralign(
			str   => content(cptr to ctnt_ptr-1), 
			width => tags(tptr).style(key_width),
			align => tags(tptr).style(key_alignment));

		report log(
			tname   => "div",
			left    => cptr,
			right   => cptr+tags(tptr).style(key_width)-1,
			width   => tags(tptr).style(key_width),
			content => content(cptr to cptr+tags(tptr).style(key_width)-1)).all;

	end;

	procedure page_content (
		variable content  : inout string;
		constant tags     : in  tag_vector)
	is
		variable tag_ptr : natural;
		variable left    : natural;
		variable right   : natural;

		variable vtags  : tag_vector(tags'range);
		variable tptr   : natural;
		variable mesg : line;
	begin
		vtags   := tags;
		tag_ptr := tags'left;
		left    := content'left;
		if vtags(tag_ptr).tid=tid_page then
			tag_ptr := tag_ptr + 1;
		end if;
		while tag_ptr <= vtags'right loop
			tptr  := tag_ptr;
			right := left;

			case vtags(tag_ptr).tid is
			when tid_div =>
				div_content (
					ctnt_ptr => right,
					content  => content,
					tag_ptr  => tag_ptr,
					tags     => vtags);

				offset_memptr(
					offset => padding_left (
						length => right-vtags(tag_ptr).mem_ptr,
						width  => vtags(vtags'left).style(key_width),
						align  => vtags(vtags'left).style(key_alignment)),
					tags => vtags(tptr to tag_ptr));

				content(left to left+vtags(vtags'left).style(key_width)-1) := stralign(
					str   => content(left to right-1), 
					width => vtags(vtags'left).style(key_width),
					align => vtags(vtags'left).style(key_alignment));

			right := left+vtags(vtags'left).style(key_width);
			report log(
				tname   => string'("*************** page"),
				left    => left,
				right   => right,
				width   => vtags(vtags'left).style(key_width),
				content => content(left to right-1)).all;

			when others =>
			end case;

			left    := left+vtags(vtags'left).style(key_width);
			tag_ptr := tag_ptr + 1;
		end loop;
		if right <= content'right then
			content(right) := NUL;
		end if;
	end;

	function browse (
		constant tags : tag_vector;
		constant size : natural)
		return string 
	is
		variable retval  : string(1 to size);
		variable tag_ptr : natural;
	begin
		
		page_content (
			content => retval,
			tags    => tags);
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
