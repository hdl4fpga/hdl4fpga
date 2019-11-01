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

	function alignment (constant value  : tag) return alignment_t; 
	function width     (constant value  : tag) return natural; 

	type tag_vector is array (natural range <>) of tag;

	function text (constant content  : string := ""; constant style : style_t; constant id : string := "") return tag;
	function div  (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;
	function page (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;

	function render_content (
		constant tags : tag_vector;
		constant size : natural)
		return string;

	function render_tags (
		constant tags : tag_vector)
		return tag_vector;

	function validbyid (
		constant tags : tag_vector;
		constant id   : string)
		return std_logic;

	function tagbyid (
		constant tags : tag_vector;
		constant id   : string)
		return tag;

	function memaddr (
		constant tag : tag;
		constant size : natural)
		return std_logic_vector;

	function strlen (
		constant str : string)
		return natural;

	function strcmp (
		constant str1 : in string;
		constant str2 : in string)
		return boolean;

	function itoa (
		constant arg : integer)
		return string;

	function btoa (
		constant arg : std_logic_vector)
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

	function strcmp (
		constant str1 : in string;
		constant str2 : in string)
		return boolean
	is
		alias astr1 : string(1 to str1'length) is str1;
		alias astr2 : string(1 to str2'length) is str2;
	begin
		for i in astr1'range loop
			if astr2'right < i then
				if astr1(i)=NUL then
					return true;
				else
					return false;
				end if;
			elsif astr1(i)/=astr2(i) then
				return false;
			end if;
		end loop;
		if astr2'length=astr1'length then
			return true;
		elsif astr2(astr1'right+1)=NUL then
			return true;
		else
			return false;
		end if;
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

	function strrev (
		constant arg : string)
		return string
	is
		variable retval : string(1 to arg'length);
	begin
		retval := arg;
		for i in 1 to retval'length/2 loop
			swap(retval(i), retval(retval'length+1-i));
		end loop;
		return retval;
	end;

	function itoa (
		constant arg : integer)
		return string 
	is
		constant asciitab : string(1 to 10) := "0123456789";
		variable rval   : string(1 to 256);
		variable value    : natural;
	begin
		value  := abs(arg);
		rval := (others => NUL);
		for i in rval'range loop
			rval(i) := asciitab((value mod 10)+1);
			value     := value / 10;
			exit when value=0;
		end loop;
		return strrev(rval(1 to strlen(rval)));
	end;

	function btoa (
		constant arg : std_logic_vector)
		return string
	is
	begin
		return itoa(to_integer(unsigned(arg)));
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

	function log (
		constant tname   : string;
		constant left    : integer;
		constant right   : integer;
		constant width   : integer;
		constant content : string)
		return line
	is
		variable mesg : line;
	begin
		write(mesg, '[' & tname & ']');
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

	function stralign (
		constant str   : string;
		constant width : natural;
		constant align : alignment_t)
		return string
	is
		constant blank    : character := ' ';
		constant at_left  : integer := padding_left (strlen(str), width, align);
		constant at_right : integer := padding_right(strlen(str), width, align);
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
--		variable mesg : line;
	begin
		level := 0;
--		write(mesg, string'("offset "));
		for i in tags'range loop
--			write(mesg, string'(" : "));
--			write(mesg, tags(i).id(1 to strlen(tags(i).id)));
--			write(mesg, string'(" : "));
--			write(mesg, tags(i).mem_ptr);
--			write(mesg, string'("("));
--			write(mesg, offset);
--			write(mesg, string'(") -> "));
			tags(i).mem_ptr := tags(i).mem_ptr + offset;
--			write(mesg, tags(i).mem_ptr);
			case tags(i).tid is 
			when tid_end =>
				exit when level=0;
				level := level - 1;
			when tid_div =>
				level := level + 1;
			when others =>
			end case;
		end loop;
--		report mesg.all;

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

	function width (
		constant value : tag)
		return natural is
	begin
		return value.style(key_width);
	end;

	function alignment (
		constant value : tag)
		return alignment_t is
	begin
		return value.style(key_alignment);
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
		variable div    : tag;
		variable retval : tag_vector(0 to children'length+2-1);
	begin
		div.tid   := tid_div;
		div.style := style;
		div.id    := strfill(id, div.id'length);
		retval(0) := div;
		retval(1 to children'length) := children;
		retval(retval'right) := endtag;
		return retval;
	end;

	function page (
		constant children : tag_vector;
		constant style    : style_t;
		constant id       : string := "")
		return tag_vector is
		variable page   : tag;
		variable retval : tag_vector(0 to children'length+2-1);
	begin
		page.tid   := tid_page;
		page.style := style;
		page.id    := strfill(id, page.id'length);
		retval(0)  := page;
		retval(1 to children'length) := children;
		retval(retval'right) := endtag;
		return retval;
	end;

	function text (
		constant content : string := "";
		constant style   : style_t;
		constant id      : string := "")
		return tag 
	is
		variable retval : tag_vector(0 to 0);
		variable mesg : line;
	begin
		retval(0).tid     := tid_text;
		retval(0).id      := strfill(id, retval(0).id'length);
		retval(0).style   := style;
		retval(0).content := strfill(content, retval(0).content'length);

		return retval(0);
	end;

	procedure process_text (
		variable ctnt_ptr : inout natural;
		variable content  : inout string;
		variable tag_ptr  : inout natural;
		variable tags     : inout tag_vector)
	is
		variable left    : natural;
		variable right   : natural;
		variable str     : string(1 to tags(0).content'length); -- Xilinx
		variable width   : natural;                             -- messes up
		variable align   : natural;                             -- Workaround
		variable mesg    : line;
	begin
		if tags(tag_ptr).style(key_width)=0 then
			tags(tag_ptr).style(key_width) := strlen(tags(tag_ptr).content); 
		end if;
		tags(tag_ptr).mem_ptr := ctnt_ptr;

		left  := ctnt_ptr;
		right := left+tags(tag_ptr).style(key_width)-1;

		if content'length > 1 then
			str   := tags(tag_ptr).content;               -- Xilinx 
			width := tags(tag_ptr).style(key_width);      -- messes up
			align := tags(tag_ptr).style(key_alignment);  -- Workaround
			content(left to right) := stralign(
				str   => str,
				width => width,
				align => align);
		end if;
		ctnt_ptr := ctnt_ptr + tags(tag_ptr).style(key_width);

--		if content'length > 1 then
--			report log(
--				tname   => string'("text"),
--				left    => left,
--				right   => right,
--				width   => width,
--				content => content(content'left to right)).all;
--		end if;

--		write (mesg, tags(tag_ptr).mem_ptr);
--		report mesg.all;

	end;

	procedure process_div (
		variable ctnt_ptr : inout natural;
		variable content  : inout string;
		variable tag_ptr  : inout natural;
		variable tags     : inout tag_vector)
	is
		variable cptr    : natural;
		variable tptr    : natural;
		variable width   : natural;                   -- Xilinx messes
		variable align   : natural;                   -- Workaround
	begin
		cptr    := ctnt_ptr;
		tptr    := tag_ptr;
		tags(tptr).mem_ptr := ctnt_ptr;
		tag_ptr := tag_ptr + 1;

		loop
			case tags(tag_ptr).tid is
			when tid_text =>
				process_text (
					tag_ptr  => tag_ptr,
					ctnt_ptr => ctnt_ptr,
					content  => content,
					tags     => tags);
			when tid_end =>
				tags(tag_ptr).mem_ptr := ctnt_ptr;
				exit;
			when others =>
			end case;

			tag_ptr := tag_ptr + 1;
		end loop;

		if tags(tptr).style(key_width)=0 then
			tags(tptr).style(key_width) := ctnt_ptr-cptr;
		end if;

		if content'length > 1 then
			width := tags(tptr).style(key_width);      -- Xilinx's mess
			align := tags(tptr).style(key_alignment);  -- Workaround
			content(cptr to cptr+tags(tptr).style(key_width)-1) := stralign(
				str   => content(cptr to ctnt_ptr-1), 
				width => width,
				align => align);
		end if;

		offset_memptr(
			offset => padding_left (
				length => ctnt_ptr-tags(tptr).mem_ptr,
				width  => tags(tptr).style(key_width),
				align  => tags(tptr).style(key_alignment)),
			tags => tags(tptr+1 to tag_ptr));

		ctnt_ptr := tags(tag_ptr).mem_ptr;
--		if content'length > 1 then
--			report log(
--				tname   => "div",
--				left    => cptr,
--				right   => cptr+tags(tptr).style(key_width)-1,
--				width   => tags(tptr).style(key_width),
--				content => content(cptr to cptr+tags(tptr).style(key_width)-1)).all;
--		end if;

	end;

	procedure process_page (
		variable content  : inout string;
		variable tags     : inout tag_vector)
	is
		variable tag_ptr : natural;
		variable left    : natural;
		variable right   : natural;

		variable vtags  : tag_vector(0 to tags'length-1):= tags;
		variable tptr   : natural;
		variable length  : natural;                   -- Xilinx's mess
		variable width   : natural;                   -- 
		variable align   : natural;                   -- Workaround
	begin
		tag_ptr := vtags'left;
		left    := content'left;
		if vtags(tag_ptr).tid=tid_page then
			tag_ptr := tag_ptr + 1;
		end if;
		while tag_ptr <= vtags'right loop
			tptr  := tag_ptr;
			right := left;

			case vtags(tag_ptr).tid is
			when tid_div =>
				process_div (
					ctnt_ptr => right,
					content  => content,
					tag_ptr  => tag_ptr,
					tags     => vtags);

				length := vtags(tptr).style(key_width);            -- Xilinx's mess
				width  := vtags(vtags'left).style(key_width);      --
				align  := vtags(vtags'left).style(key_alignment);  -- Workaround
				offset_memptr(
					offset => padding_left (
						length => length,
						width  => width,
						align  => align),
					tags => vtags(tptr to tag_ptr-1));

				if content'length > 1 then
					content(left to left+vtags(vtags'left).style(key_width)-1) := stralign(
						str   => content(left to right-1), 
						width => vtags(vtags'left).style(key_width),
						align => vtags(vtags'left).style(key_alignment));
				end if;

			right := left+vtags(vtags'left).style(key_width);
--			if content'length > 1 then
--				report log(
--					tname   => string'("page"),
--					left    => left,
--					right   => right,
--					width   => vtags(vtags'left).style(key_width),
--					content => content(left to right-1)).all;
--			end if;

			when others =>
			end case;

			left    := left+vtags(vtags'left).style(key_width);
			tag_ptr := tag_ptr + 1;
		end loop;
		if right <= content'right then
			content(right) := NUL;
		end if;
		tags := vtags;
	end;

	function render_content (
		constant tags : tag_vector;
		constant size : natural)
		return string 
	is
		variable retval  : string(1 to size);
		variable tag_ptr : natural;
		variable vtags   : tag_vector(0 to tags'length-1);
	begin
		
		vtags := tags;
		process_page (
			content => retval,
			tags    => vtags);
		return retval;
		
	end;

	function render_tags (
		constant tags : tag_vector)
		return tag_vector 
	is
		variable content : string(1 to 0);
		variable vtags   : tag_vector(tags'range);
		 
	begin
		
		vtags := tags;
		process_page (
			content => content,
			tags    => vtags);
		return vtags;
		
	end;

	function validbyid (
		constant tags : tag_vector;
		constant id   : string)
		return std_logic
	is
	begin
		for i in tags'range loop
			if strcmp(tags(i).id,id) then
				return '1';
			end if;
		end loop;
		return '0';
	end;

	function tagbyid (
		constant tags : tag_vector;
		constant id   : string)
		return tag
	is
	begin
		for i in tags'range loop
			if strcmp(tags(i).id,id) then
				return tags(i);
			end if;
			assert false
			report "Invalid tag : " & itoa(i) & " " & '"' & tags(i).id & '"'
			severity warning;
		end loop;
		assert false
			report "Invalid tag : " & id & " " & itoa(tags'length)
			severity FAILURE;
		return tags(0);
	end;

	function memaddr (
		constant tag  : tag;
		constant size : natural)
		return std_logic_vector
	is
	begin
		return std_logic_vector(to_unsigned(tag.mem_ptr-1, size));
	end;

end;
