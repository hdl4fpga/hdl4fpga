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
use hdl4fpga.base.all;

package textboxpkg is

	type style_keys   is (key_width, key_alignment, key_textpalette, key_bgpalette);
	type style_t      is array (style_keys) of integer;
	type style_vector is array (natural range <>) of style_t;

	subtype alignment_t is integer;
	constant left_alignment   : integer := 0;
	constant right_alignment  : integer := 1;
	constant center_alignment : integer := 2;

	function alignment    (constant value : integer) return style_vector; 
	function text_palette (constant value : integer) return style_vector; 
	function bg_palette   (constant value : integer) return style_vector;
	function width        (constant value : integer) return style_vector; 

	function style (
		constant width        : integer := 0;
		constant alignment    : integer := 0;
		constant bg_palette   : integer := -1;
		constant text_palette : integer := -1)
		return style_t;

	function styles (constant values : style_vector) return style_t;

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
		inherit  : natural;
	end record;

	type attr_record is record
		addr : natural;
		attr : integer;
	end record;

	type attr_table is array(natural range <>) of attr_record;

	function alignment (constant value  : tag) return alignment_t; 
	function width     (constant value  : tag) return integer; 

	type tag_vector is array (natural range <>) of tag;

	constant nostyle : style_t := (
		key_width => 0, key_alignment => 0, key_textpalette => -1, key_bgpalette => -1);

	function page (constant children : tag_vector;   constant style : style_t; constant id : string := "") return tag_vector;
	function text (constant content  : string := ""; constant style : style_t := nostyle; constant id : string := "") return tag;
	function div  (constant children : tag_vector;   constant style : style_t := nostyle; constant id : string := "") return tag_vector;


	function render_content (
		constant tags : tag_vector;
		constant size : natural)
		return string;

	function render_tags (
		constant tags : tag_vector)
		return tag_vector;

	function isvalidbyid (
		constant tags : tag_vector;
		constant id   : string)
		return boolean;

	function tagindexbyid (
		constant tags : tag_vector;
		constant id   : string)
		return integer;

	function tagbyid (
		constant tags : tag_vector;
		constant id   : string)
		return tag;

	function memaddr (
		constant tag : tag;
		constant size : natural)
		return std_logic_vector;

	function memaddr (
		constant tag : tag;
		constant size : natural)
		return natural;

	function tagattr_tab(
		constant tags : tag_vector;
		constant attr : style_keys)
		return attr_table;
end;

package body textboxpkg is

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

--	function log (
--		constant tname   : string;
--		constant left    : integer;
--		constant right   : integer;
--		constant width   : integer;
--		constant content : string)
--		return line
--	is
--		variable mesg : line;
--	begin
--		write(mesg, '[' & tname & ']');
--		write(mesg, string'(" : left  => "));
--		write(mesg, left);
--		write(mesg, string'(" : right => "));
--		write(mesg, right);
--		write(mesg, string'(" : content => "));
--		write(mesg, character'('"'));
--		if strlen(content)/=0 then
--			write(mesg, content(content'left to content'left+strlen(content)-1));
--		end if;
--		write(mesg, character'('"'));
--		write(mesg, string'(" : width => "));
--		write(mesg, width);
--		return mesg;
--	end;

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
--				report "end " & itoa(tags(i).mem_ptr);
				exit when level=0;
				level := level - 1;
			when tid_div =>
--				report "start " & itoa(tags(i).mem_ptr);
				level := level + 1;
			when others =>
--				report "start " & itoa(tags(i).mem_ptr);
			end case;
		end loop;
--		report mesg.all;

	end;

	function alignment (
		constant value : integer)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_width)       := 0;
		retval(0)(key_alignment)   := value;
		retval(0)(key_textpalette) := -1;
		retval(0)(key_bgpalette)   := -1;
		return retval;
	end;

	function bg_palette (
		constant value : integer)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_width)       := 0;
		retval(0)(key_alignment)   := 0;
		retval(0)(key_textpalette) := -1;
		retval(0)(key_bgpalette)   := value;
		return retval;
	end;

	function text_palette (
		constant value : integer)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_width)       := 0;
		retval(0)(key_alignment)   := 0;
		retval(0)(key_textpalette) := value;
		retval(0)(key_bgpalette)   := -1;
		return retval;
	end;

	function width (
		constant value : integer)
		return style_vector is
		variable retval : style_vector(0 to 0);
	begin
		retval(0)(key_width)       := value;
		retval(0)(key_alignment)   := 0;
		retval(0)(key_textpalette) := -1;
		retval(0)(key_bgpalette)   := -1;
		return retval;
	end;

	function width (
		constant value : tag)
		return integer is
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
		constant width        : integer := 0;
		constant alignment    : integer := 0;
		constant bg_palette   : integer := -1;
		constant text_palette : integer := -1)
		return style_t
	is
		variable retval : style_t;
	begin
		retval(key_alignment)   := alignment;
		retval(key_bgpalette)   := bg_palette;
		retval(key_textpalette) := text_palette;
		retval(key_width)       := width;
		return retval;
	end;

	function styles (
		constant values : style_vector)
		return style_t is
		variable retval : style_t;
	begin
		for i in values'range loop
			for j in style_t'range loop
				case j is
				when key_textpalette | key_bgpalette =>
					if values(i)(j) >= 0 then
						retval(j) := values(i)(j);
					elsif retval(j) < 0 then	
						retval(j) := -1;
					end if;
				when key_width | key_alignment =>
					if values(i)(j) > 0 then
						retval(j) := values(i)(j);
					elsif retval(j) < 0 then	
						retval(j) := 0;
					end if;
				end case;
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
		constant style    : style_t := nostyle;
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
		constant style   : style_t := nostyle;
		constant id      : string := "")
		return tag is
		variable retval : tag_vector(0 to 0);
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
		variable tags     : inout tag_vector) is
		variable left    : natural;
		variable right   : natural;
		variable str     : string(1 to tags(0).content'length); -- Xilinx
		variable width   : natural;                             -- messes up
		variable align   : natural;                             -- Workaround
	begin
		if tags(tag_ptr).style(key_width)=0 then
			tags(tag_ptr).style(key_width) := strlen(tags(tag_ptr).content); 
		end if;
		tags(tag_ptr).mem_ptr := ctnt_ptr - 1;

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
		variable tags     : inout tag_vector) is
		variable cptr    : natural;
		variable tptr    : natural;
		variable width   : natural;                   -- Xilinx messes
		variable align   : natural;                   -- Workaround
	begin
		cptr    := ctnt_ptr;
		tptr    := tag_ptr;
		tags(tptr).mem_ptr := ctnt_ptr - 1;
		tag_ptr := tag_ptr + 1;

		loop
			case tags(tag_ptr).tid is
			when tid_text =>
				tags(tag_ptr).inherit := tptr;
				process_text (
					tag_ptr  => tag_ptr,
					ctnt_ptr => ctnt_ptr,
					content  => content,
					tags     => tags);
			when tid_end =>
				tags(tag_ptr).mem_ptr := ctnt_ptr - 1;
				tags(tag_ptr).inherit := tptr;
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

--		report "div";
		offset_memptr(
			offset => padding_left (
			length => ctnt_ptr-tags(tptr).mem_ptr - 1,
				width  => tags(tptr).style(key_width),
				align  => tags(tptr).style(key_alignment)),
			tags => tags(tptr+1 to tag_ptr));

		ctnt_ptr := tags(tag_ptr).mem_ptr + 1;
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
		variable tags     : inout tag_vector) is
		variable tag_ptr : natural;
		variable left    : natural;
		variable right   : natural;

		variable vtags   : tag_vector(0 to tags'length-1):= tags;
		variable tptr    : natural;
		variable length  : natural;                   -- Xilinx's mess
		variable width   : natural;                   -- 
		variable align   : natural;                   -- Workaround
	begin
		tag_ptr := vtags'left;
		left    := content'left;
		if vtags(tag_ptr).tid=tid_page then
			vtags(tag_ptr).inherit := vtags'left;
			tag_ptr := tag_ptr + 1;
		end if;
		while tag_ptr <= vtags'right loop
			tptr  := tag_ptr;
			right := left;

			case vtags(tag_ptr).tid is
			when tid_div =>
				vtags(tag_ptr).inherit := vtags'left;
				process_div (
					ctnt_ptr => right,
					content  => content,
					tag_ptr  => tag_ptr,
					tags     => vtags);

				length := vtags(tptr).style(key_width);            -- Xilinx's mess
				width  := vtags(0).style(key_width);               --
				align  := vtags(0).style(key_alignment);           -- Workaround

				offset_memptr(
					offset => padding_left (
						length => length,
						width  => width,
						align  => align),
					tags => vtags(tptr to tag_ptr));

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

			when tid_end =>
				vtags(tag_ptr).mem_ptr := right - 1;
				vtags(tag_ptr).inherit := vtags'left;
--				report "@@@@ " & itoa(tag_ptr) &  " @@ " & itoa(vtags'right) &  " @@@ " & itoa(vtags(tag_ptr).mem_ptr);
				exit;
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
		return string is
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
		return tag_vector is
		variable content : string(1 to 0);
		variable vtags   : tag_vector(tags'range);
		 
	begin
		
		vtags := tags;
		process_page (
			content => content,
			tags    => vtags);
		return vtags;
		
	end;

	function isvalidbyid (
		constant tags : tag_vector;
		constant id   : string)
		return boolean is
	begin
		for i in tags'range loop
			if strcmp(tags(i).id,id) then
				return true;
			end if;
		end loop;
		return false;
	end;

	function tagindexbyid (
		constant tags : tag_vector;
		constant id   : string)
		return integer is
	begin
		for i in tags'range loop
			if strcmp(tags(i).id,id) then
				return i;
			end if;
		end loop;

		assert false
		report "Invalid tag : " & id & " " & natural'image(tags'length)
		severity FAILURE;
	end;

	function tagbyid (
		constant tags : tag_vector;
		constant id   : string)
		return tag is
	begin
		return tags(tagindexbyid(tags, id));
	end;

	function memaddr (
		constant tag  : tag;
		constant size : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(tag.mem_ptr, size));
	end;

	function memaddr (
		constant tag  : tag;
		constant size : natural)
		return natural is
	begin
		return tag.mem_ptr;
	end;

	function tagattr_tab(
		constant tags : tag_vector;
		constant attr : style_keys)
		return attr_table is
		function get_attr (
			constant tags : tag_vector;
			constant tag  : natural;
			constant attr : style_keys)
			return integer is
			variable inherit : natural;
		begin
			case attr is
			when key_textpalette | key_bgpalette =>
				inherit := tag;
				while inherit /= tags'left loop
--					report "get attr : " & itoa(tag);
					if tags(inherit).style(attr) >= 0 then
--						report "return -> " & itoa(inherit) & " : " & itoa(tags(inherit).style(attr));
						return tags(inherit).style(attr);
					else
--						report "----> " & itoa(tags(inherit).style(attr));
					end if;
					inherit := tags(inherit).inherit;
				end loop;
--				report "return -> " & itoa(inherit) & " : " & itoa(tags(inherit).style(attr));
				return tags(inherit).style(attr);
			when key_width | key_alignment =>
				return tags(tag).style(attr);
			end case;

		end;

		variable tab_length   : natural;
		variable current_attr : natural;
		variable inherit      : natural;
		variable retval       : attr_table(0 to tags'length-1);

	begin
		current_attr  := tags'left;
		tab_length    := 1;
		retval(0).attr := tags(current_attr).style(attr);
--		report "@@@@@ -> " & itoa(tags(tags'right).mem_ptr);
		for i in tags'range loop
			if tags(i).tid = tid_end then
				inherit := tags(tags(i).inherit).inherit;
				if get_attr(tags, inherit, attr) /= get_attr(tags, current_attr, attr) then
					-- report "** " & itoa(i) &  " *** -> " & itoa(tags(i).mem_ptr) & " ==> " & itoa(get_attr(tags, inherit, attr));
					retval(tab_length).addr := tags(i).mem_ptr;
					retval(tab_length).attr := get_attr(tags, inherit, attr);
					tab_length := tab_length + 1;
				end if;
				current_attr := tags(tags(i).inherit).inherit; --tags(i).inherit;
			else
				if get_attr(tags, i, attr) /= get_attr(tags, current_attr, attr) then
					-- report "++ " & itoa(i) &  " +++ -> " & itoa(tags(i).mem_ptr) & " ==> " & itoa(get_attr(tags, i, attr));
					retval(tab_length).addr := tags(i).mem_ptr;
					retval(tab_length).attr := get_attr(tags, i, attr);
					tab_length := tab_length + 1;
				end if;
				current_attr := i;
			end if;
		end loop;
		return retval(0 to tab_length-1);
	end;
end;
