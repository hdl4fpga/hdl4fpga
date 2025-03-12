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
use hdl4fpga.cgafonts.all;
use hdl4fpga.videopkg.all;

entity display is
end;

architecture def of display is

	constant tags : string := (
		"label" & NUL );

	constant attributes : string := (
		"style" & NUL );

	constant idents : string := (
		"foreground" & NUL &
		"background" & NUL &
		"text-align" & NUL &
		"format"     & NUL &
		"width"      & NUL );
	
	subtype ident_ids is positive range 1 to 3;
	constant ident_foreground : ident_ids := 1;
	constant ident_background : ident_ids := 2;
	constant ident_width      : ident_ids := 3;

	function lut_keyword (
		constant stream   : string;
		constant keywords : string)
		return natural is
		variable i : natural;
		variable j : natural;
		variable k : natural;
	begin
		j := keywords'left;
		k := 0;
		loop
			i := stream'left;
			loop
			assert false
			report "(i => " & natural'image(i) & ", " & "j => " & natural'image(j) & ")"
			severity note;
				if i > stream'right then
					if keywords(j)=NUL then
						return k;
					else
						exit;
					end if;
				elsif not isalpha(stream(i)) then
					if keywords(j)=NUL then
						return k;
					else
						exit;
					end if;
				elsif stream(i)=keywords(j) then
					j := j + 1;
				else 
					exit;
				end if;
				i := i + 1;
			end loop;
			while keywords(j)/=NUL loop
				j := j + 1;
			end loop;
			j := j + 1;
			k := k + 1;
			if j > keywords'right then
				return 0;
			end if;
		end loop;
	end;

	-- tag_list          ::=  { tag_element ; } style_element
	-- tag_element       ::= '<' tag_id attribute_list '/' '>'
	-- tag_element       ::= '<' tag_id attribute_list '>' tag_list '<' '/' tag_id '>'
	-- tag_id            ::= identifier
	-- attribute_list    ::= attribute_element { atrribute_element }
	-- attribute_element ::= identifier '=' value

	function parse_tag (
		constant stream : string)
		return boolean is
		type states is (s_lessthan, s_tagid, s_attribute, s_equal, s_value, s_next, s_end);
		variable state  : states;
		variable left   : positive;
		variable right  : natural;
		variable ident_id : ident_ids;
	begin
		left  := stream'left;
		right := stream'left-1;
		while left <= stream'right loop
			if isspace(stream(left)) then
				right := left;
				left  := left + 1;
			else
				case state is
				when s_lessthan =>
					if stream(left)='<' then
						state := s_tagid;
					else
						return false;
					end if;
				when s_tagid =>
					right := isword(stream(left to stream'right));
					if right >= left then
						ident_id := lut_keyword(stream(left to right), tags);
						if ident_id > 0 then
							right := right - left;
							left  := left  + right + 1;
							right := left  - 1 ;
							state := s_attribute;
						else
							return false;
						end if;
					else 
						return false;
					end if;
				when s_attribute =>
					right := isword(stream(left to stream'right));
					if right >= left then
						ident_id := lut_keyword(stream(left to right), attributes);
						if ident_id > 0 then
							right := right - left;
							left  := left  + right + 1;
							right := left  - 1 ;
							state := s_equal;
						else
							return false;
						end if;
					else
						return false;
					end if;
				when s_equal =>
					if stream(left)='=' then
						state := s_value;
					else
						return false;
					end if;
				when s_value =>
					right := isword(stream(left to stream'right));
					if right >= left then
						state := s_end;
					else
						return false;
					end if;
				when s_next =>
					if stream(left)='/' then
						state := s_end;
					else 
						right := isword(stream(left to stream'right));
					end if;
				when s_end =>
				end case;
				right := right - left;
				left  := left  + right + 1;
				right := left  - 1 ;
			end if;
		end loop;
		return false;
	end;

	-- style         ::= { style_element ; } style_element
	-- style_element ::= variable:value
	-- variable      ::= identifier
	-- value         ::= alphanum

	function parse_style (
		constant stream : string)
		return boolean is
		type states is (s_keyword, s_colon, s_value, s_end);
		variable state : states;
		variable left  : positive;
		variable right : natural;
		variable ident_id : ident_ids;
	begin
		left  := stream'left;
		right := stream'left-1;
		while left <= stream'right loop
			if isspace(stream(left)) then
				right := left;
			else
				case state is
				when s_keyword =>
					right := isword(stream(left to stream'right));
					if right >= left then
						ident_id := lut_keyword(stream(left to right), idents);
						if ident_id > 0 then
							state := s_colon;
						else
							return false;
						end if;
					else 
						return false;
					end if;
				when s_colon =>
					if stream(left)=':' then
						right := left;
						state := s_value;
					else
						return false;
					end if;
				when s_value =>
					right := isword(stream(left to stream'right));
					if right >= left then
						-- style(ident_id):= atoi(stream(left to stream'right));
						state := s_end;
					else
						return false;
					end if;
				when s_end =>
				end case;
				right := right - left;
				left  := left  + right + 1;
				right := left  - 1 ;
			end if;
		end loop;
		return false;
	end;

begin
	process
	begin
		assert false
		report CR & "'" & boolean'image(parse_tag("foreground:ground ")) & "'"
		severity note;
		wait;
	end process;
end;