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
	function get(
		constant jso : string;
		constant key : string)
		return string;
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

	function to_integer (
		constant char : character)
		return integer is
	begin
		return character'pos(char)-character'pos('0');
	end;

	type slice is record
		offset : natural;
		length : natural;
	end record;

	procedure stripws (
		constant string : string;
		variable offset : inout natural) is
	begin
		while isspace(string(offset)) loop
			offset := offset + 1;
		end loop;
	end;

	procedure parse_natural (
		constant key    : in    string;
		variable offset : in    natural;
		variable length : inout natural) is
	begin
		length := 0;
		while offset+length <= key'right loop
			if isdigit(key(offset+length)) then
				length := length + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure get_subkey (
		constant key    : in    string;
		constant offset : in    natural;
		variable length : inout natural) is
	begin
		length := 0;
		case key(offset + length) is
		when '[' =>
			length := length + 1;
			-- stripws ;
			if isalpha(key(offset + length)) then
			elsif isdigit(key(offset + length)) then
			end if;
			-- parse_natural;
			-- stripws ;
			if key(offset + length) /= ']' then
				assert false
				report "error"
				severity FAILURE;
			end if;
			length := length + 1;
		when '.' =>
			-- stripws ;
			-- parse_string;
		when others =>
			assert false
			report "w"
			severity failure;
		end case;
	end;

	function get_value (
		constant jso : string;
		constant key : string)
		return string is
	begin


	end;

	function get(
		constant jso : string;
		constant key : string)
		return string is

		variable key_offset : natural;
		variable key_length : natural;

	begin
		stripws (key, key_offset);
		get_subkey (key, key_offset, key_length);
		stripws (jso, jso_offset);
		get_value (subkey, jso);

	end;
end;
