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
	procedure set_index(
		constant value : natural);

	procedure next_key (
		constant key    : string;
		variable offset : inout natural;
		variable length : inout natural);
end;

package body jso is

	constant debug : boolean := not false;
	shared variable key_index : natural;
	shared variable js0_index : natural;
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
		variable index  : natural) is
	begin
		while index <= string'right loop
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
		offset := key_index;
		length := 0;
		if isalpha(string(key_index)) then
			while key_index <= string'right loop
				if isalnum(string(key_index)) then
					key_index  := key_index  + 1;
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
		variable offset : inout natural;
		variable length : inout natural) is
	begin
		offset := key_index;
		length := 0;
		while key_index <= string'right loop
			if isalnum(string(key_index)) then
				key_index  := key_index + 1;
				length := length + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure set_index (
		constant value : natural) is
	begin
		key_index := value;
	end;

	procedure next_key (
		constant key    : string;
		variable offset : inout natural;
		variable length : inout natural) is
	begin
		skipws(key, key_index);
		assert debug report integer'image(key_index) severity note;
		assert debug report "-------------------- " & character'image(key(key_index)) severity note;
		while key_index <= key'right loop
			case key(key_index) is
			when '[' =>
				key_index := key_index + 1;
				skipws(key, key_index);
				if isalpha(key(key_index)) then
					parse_property(key, offset, length);
				elsif isdigit(key(key_index)) then
					parse_natural(key, offset, length);
				else
					assert false report "next_key" severity failure;
				end if;
				skipws(key, key_index);
				if key(key_index)=']' then
					key_index := key_index + 1;
				else
					assert false report "next_key" severity failure;
				end if;
				exit;
			when '.' =>
				key_index := key_index + 1;
				skipws(key, key_index);
				parse_property(key, offset, length);
				exit;
			when others =>
				assert false report "Wrong key format" severity failure;
			end case;
		end loop;
		skipws(key, key_index);
		assert debug 
		report "=====> " & 
			integer'image(key_index) & ":" & integer'image(offset) & ':' & integer'image(length);
	end;

	procedure get_arrayvalue (
		constant jso : string;
		constant key : string;
		variable offset : inout natural;
		variable length : inout natura) is
		variable index  : natural;
	begin
		index := 0;
		while jso_index <= jso'right loop
			if index < key then
				skipws(jso, jso_index);
				case jso(jso_index) is
				when ',' =>
					if obj_pointer=0 then
						index := index + 1;
					else 
						jso_index := jso_index + 1;
					end if;
				when '[' =>
					jso_index := jso_index + 1;
				when '{' =>
					jso_index := jso_index + 1;
				when others =>
					jso_index := jso_index + 1;
				end case;
			else
			end if;
		end loop;
		
	end;
			-- case jso(jso_index) is
	procedure get_value (
		constant jso : string;
		constant key : string;
		variable offset : inout natural;
		variable length : inout natura) is
		variable obj_level   : string(jso'range);
		variable obj_pointer : positive := jso'left;
	begin
		skipws(jso, jso_index);
		while jso_index <= jso'right loop
			if key=natural then

			end if;
		end loop;
		
	end;
			-- case jso(jso_index) is
			-- when '['|'{' =>
				-- obj_level(obj_pointer) := jso(jso_index);
			-- when others =>
				-- assert false report "Wrong jso format" severity failure;
			-- end case;
			-- end case;
end;