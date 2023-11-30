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


package jso is
	procedure get_subkey (
		constant key    : string;
		variable left  : inout natural;
		variable right : inout natural);
end;

package body jso is

	function isspace (
		constant char : character;
		constant wspc : string := (' ', HT, LF, CR, FF))
		return boolean is
	begin
		for i in wspc'range loop
			if wspc(i)=char then
				return true;
			end if;
		end loop;
		return false;
	end;

	function isdigit (
		constant char  : character;
		constant digit : string := "0123456789")
		return boolean is
	begin
		for i in digit'range loop
			if digit(i)=char then
				return true;
			end if;
		end loop;
		return false;
	end;

	function isalpha (
		constant char : character)
		return boolean is
	begin
		if    character'pos('A') <= character'pos(char) and character'pos(char) <= character'pos('Z') then
			return true;
		elsif character'pos('a') <= character'pos(char) and character'pos(char) <= character'pos('z') then
			return true;
		else
			return false;
		end if;
	end;

	function isalnum (
		constant char : character)
		return boolean is
	begin
		if isdigit(char) then
			return true;
		elsif isalpha(char) then
			return true;
		else
			return false;
		end if;
	end;

	function to_integer (
		constant char : character)
		return integer is
	begin
		return character'pos(char)-character'pos('0');
	end;

	procedure skipws (
		constant string : string;
		variable left  : inout natural;
		variable right : inout natural) is
	begin
		while left <= right loop
			if isspace(string(left)) then
				left := left + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure parse_property (
		constant string : string;
		variable left  : inout natural;
		variable right : inout natural) is
		variable index : natural;
	begin
		index := left;
		if isalpha(string(index)) then
			while index <= right loop
				if isalnum(string(index)) then
					index := index + 1;
				else
					right := index - 1;
					return;
				end if;
			end loop;
		else
			report character'image(string(left));
		end if;
	end;

	procedure parse_natural (
		constant string : string;
		variable left  : inout natural;
		variable right : inout natural) is
	begin
		while left <= right loop
			if isalnum(string(left)) then
				left := left + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure get_subkey (
		constant key   : string;
		variable left  : inout natural;
		variable right : inout natural) is
	begin
		while left <= right loop
			case key(left) is
			when '[' =>
				skipws(key, left, right);
				if isalpha(key(left)) then
					parse_property(key, left, right);
				elsif isdigit(key(left)) then
					parse_natural(key, left, right);
				else
					assert false report "get_subkey" severity failure;
				end if;
				skipws(key, left, right);
				if key(left) /= ']' then
					assert false report "get_subkey" severity failure;
				end if;
			when '.' =>
				left := left + 1;
				skipws(key, left, right);
				parse_property(key, left, right);
				return;
			when others =>
				assert false report "Wrong key format" severity failure;
			end case;
		end loop;
	end;

end;