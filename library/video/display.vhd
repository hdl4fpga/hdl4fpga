-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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
