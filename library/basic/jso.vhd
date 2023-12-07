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

	procedure locate_value (
		constant jso : string;
		constant key : string;
		variable offset : inout natural;
		variable length : inout natural);

end;

package body jso is

	constant debug : boolean := not false;
	shared variable key_index : natural;
	shared variable jso_index : natural;
	function isws (
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
		variable index  : inout natural) is
	begin
		while index <= string'right loop
			if isws(string(index)) then
				index := index + 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure parse_string (
		constant string : string;
		variable offset : inout natural;
		variable length :   out natural) is
		variable index  : natural;
		variable aphos  : boolean := false;
	begin
		index  := string'left;
		skipws(string, index);
		offset := index;
		while index <= string'right loop
			if (index-offset)=0 then
				if string(index)=''' then
					aphos := true;
					index := index  + 1;
					next;
				end if;
			end if;
			if aphos then
				index := index  + 1;
				if string(index)=''' then
					return;
				end if;
			elsif isalnum(string(index)) then
				index := index  + 1;
			else
				exit;
			end if;
		end loop;
		length := index-offset;
	end;

	procedure parse_property (
		constant string : string;
		variable offset : inout natural;
		variable length :   out natural) is
	begin
		offset := key_index;
		if isalpha(string(key_index)) then
			while key_index <= string'right loop
				if isalnum(string(key_index)) then
					key_index  := key_index  + 1;
				else
					length := key_index-offset;
					exit;
				end if;
			end loop;
		else
			report character'image(string(offset));
		end if;
	end;

	procedure parse_natural (
		constant string : string;
		variable offset : inout natural;
		variable length :   out natural) is
	begin
		offset := key_index;
		while key_index <= string'right loop
			if isalnum(string(key_index)) then
				key_index := key_index + 1;
			else
				length    := key_index-offset;
				exit;
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

	function to_natural (
		constant value : string;
		constant base  : natural := 10) 
		return natural is
		variable retval : natural;
	begin
		retval := 0;
		for i in value'range loop
			retval := base*retval;
			retval := (character'pos(value(i))-character'pos('0')) + retval;
		end loop;
		assert debug report "---> " & natural'image(retval);
		return retval;
	end;

	procedure parse_value (
		constant jso : string;
		variable offset : inout natural;
		variable length : inout natural) is

		variable jso_stack : string(jso'range);
		variable jso_stptr : natural := 0;
		procedure push (
			constant char : character) is
		begin
			jso_stptr := jso_stptr + 1;
			jso_stack(jso_stptr) := char;
		end;

		procedure pop (
			constant char : character) is
		begin
			jso_stptr := jso_stptr - 1;
		end;

	begin
		jso_stptr := 0;
		offset := jso_index;
		while jso_index <= jso'right loop
			case jso(jso_index) is
			when '['|'{' =>
				push(jso(jso_index));
			when ',' =>
				if jso_stptr=0 then
					exit;
				end if;
			when ']'|'}' =>
				if jso_stptr=0 then
					exit;
				else
					pop(jso(jso_index));
				end if;
			when others =>
			end case;
			jso_index := jso_index + 1;
		end loop;
		length := jso_index-offset+1;
	end;

	function get_key(
		constant data   : string;
		constant offset : natural;
		constant length : natural)
		return string is
		variable key_offset : natural;
		variable key_length : natural;
	begin
		key_offset := offset;
		key_length := 0;
		parse_string(data, key_offset, key_length);
		return data(key_offset to key_offset+key_length-1);
	end;
		
	procedure locate_value (
		constant jso : string;
		constant key : string;
		variable offset : inout natural;
		variable length : inout natural) is

		variable index : natural;
	begin
		jso_index := jso'left;
		index  := 0;
		offset := 0;
		length := 0;
		while jso_index <= jso'right loop
			skipws(jso, jso_index);
			case jso(jso_index) is
			when '['|'{' =>
			when ',' =>
				if index < to_natural(key)+1 then
					index := index + 1;
				end if;
			when ']'|'}' =>
			when others =>
			end case;
			jso_index := jso_index + 1;
			parse_value(jso, offset, length);
			if to_natural(key) <= index then
			-- elsif key=get_valuekey(jso, offset, length) then
				exit;
			end if;
		end loop;
		report "index " & natural'image(index);
		report natural'image(offset) & ':' & natural'image(length);
		report '"' & jso(offset to offset+length-1) & '"';

	end;
end;