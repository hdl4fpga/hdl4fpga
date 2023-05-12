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

	constant keywords : string := (
		"foreground" & NUL &
		"background" & NUL &
		"text-align" & NUL &
		"format"     & NUL &
		"width"      & NUL );
	
	subtype keyword_id is positive range 1 to 3;
	constant key_foreground : keyword_id := 1;
	constant key_background : keyword_id := 2;
	constant key_width      : keyword_id := 3;

	function isalpha (
		constant char : character)
		return boolean is
	begin
		if    character'pos('a') > character'pos(char) then
			return false;
		elsif character'pos('z') < character'pos(char) then
			return false;
		else 
			return true;
		end if;
	end;

	function isspace (
		constant char : character)
		return boolean is
	begin
		case char is
		when ' ' =>
			return true;
		when others =>
			return false;
		end case;
	end;

	function isword (
		constant stream : string)
		return natural is
	begin
		for i in stream'range loop
			if isalpha(stream(i)) then
				next;
			elsif stream(i)='-' then
				next;
			else
				return i-1;
			end if;
		end loop;
		return stream'right;
	end;

	function iskeyword (
		constant stream : string)
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

	function parse (
		constant style : string)
		return boolean is
		type tokens is (s_keyword, s_equal, s_natural);
		variable left  : positive;
		variable right : natural;
		-- rule1 : keyword:value
		-- rule2 : rule1 { ; rule1}
	begin
		left  := style'left;
		right := style'left-1;
		while right <= style'length loop
			if isspace(style(left)) then
				right := left;
				left  := left + 1;
			else
				right := isword(style(left to style'right));
				if right >= left then
					case keyword(style(left to right)) is
					when key_foreground =>
					when key_background =>
					when key_width      =>
					when others         =>
					end case;
					right := right - left;
					left  := left  + right + 1;
					right := left  - 1 ;
				else
					assert false
					report "syntax error"
					severity failure;
				end if;
			end if;
		end loop;
	end;

begin
	process
	begin
		-- assert false
		-- report CR & boolean'image(keyword("foreground "))
		-- report CR & "'" & match_word(" fore ground ") & "'"
		-- severity note;
		wait;
	end process;
end;