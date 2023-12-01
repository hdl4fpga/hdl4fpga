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
		variable offset : inout natural;
		variable length : inout natural);
end;

package body jso is

	shared variable index : natural;
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
		constant string : string) is
	begin
		while index <= string'length loop
			if isspace(string(index)) then
				index := index + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure parse_property (
		constant string : string;
		variable offset : inout natural;
		variable length : inout natural) is
	begin
		offset := index;
		length := 0;
		if isalpha(string(index)) then
			while index-offset < string'length loop
				if isalnum(string(index)) then
					index  := index  + 1;
					length := length + 1;
				else
					return;
				end if;
			end loop;
		else
			report character'image(string(offset));
		end if;
	end;

	procedure parse_natural (
		constant string : string;
		variable offset  : inout natural;
		variable right : inout natural) is
	begin
		while offset <= right loop
			if isalnum(string(offset)) then
				offset := offset + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure get_subkey (
		constant key    : string;
		variable offset : inout natural;
		variable length : inout natural) is
	begin
		index := offset;
		while offset < length loop
			case key(offset) is
			when '[' =>
				skipws(key);
				if isalpha(key(index)) then
					parse_property(key, index, length);
				elsif isdigit(key(offset)) then
					parse_natural(key, offset, length);
				else
					assert false report "get_subkey" severity failure;
				end if;
				skipws(key);
				if key(offset) /= ']' then
					assert false report "get_subkey" severity failure;
				end if;
			when '.' =>
				offset := offset + 1;
				skipws(key);
				parse_property(key, offset, length);
				return;
			when others =>
				assert false report "Wrong key format" severity failure;
			end case;
		end loop;
	end;

end;