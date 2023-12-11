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

	function get_value (
		constant jso : string;
		constant key : string)
		return string;

end;

package body jso is

	constant debug : boolean := not false;
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

	function get_value (
		constant jso : string;
		constant key : string)
		return string is

		variable key_offset : natural;
		variable key_length : natural;
		variable key_index  : natural;

		variable jso_offset : natural;
		variable jso_length : natural;
		variable jso_index  : natural;

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
					if string(index)=''' then
						index := index + 1;
						exit;
					else
						index := index + 1;
					end if;
				elsif isalnum(string(index)) then
					index := index + 1;
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
			-- report "***** : " & character'image(string(offset));
						key_index := key_index + 1;
					else
						exit;
					end if;
				end loop;
				length := key_index-offset;
			else
				report character'image(string(offset));
			end if;
			-- report "***** : " & natural'image(length);
			-- report "+++++ : " & character'image(string(offset));
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

		procedure next_key (
			constant key    : string;
			variable offset : inout natural;
			variable length : inout natural) is
		begin
			skipws(key, key_index);
			assert debug report integer'image(key_index) severity note;
			assert debug report "-------------------- " & natural'image(key_index) & " : " & character'image(key(key_index)) severity note;
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

		procedure parse_value (
			constant jso : string;
			variable offset : inout natural;
			variable length : inout natural) is

			variable jso_stack : string(1 to jso'length);
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

			variable aphos  : boolean := false;
		begin
			jso_stptr := 0;
			offset := jso_index;
			while jso_index <= jso'right loop
				if not aphos then
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
				end if;
				if jso(jso_index)=''' then
					aphos := not aphos;
				end if;
				jso_index := jso_index + 1;
			end loop;
			length := jso_index-offset;
		end;

		procedure key_value (
			constant key_value    : string;
			variable key_offset   : inout natural;
			variable key_length   : inout natural;
			variable value_offset : inout natural;
			variable value_length : inout natural) is
			variable index        : natural;
		begin
			parse_string(key_value, value_offset, value_length);
			report "KEY VALUE " & key_value;
			index := value_offset + value_length;
			skipws(key_value, index);
			if index <= key_value'right then
				if key_value(index)/=':' then
					key_length := 0;
				else
					key_offset := value_offset;
					key_length := value_length;
					index := index + 1;
					value_offset := index;
					value_length := key_value'right-index+1; 
				end if;
			end if;
		end;
			
		procedure locate_value (
			constant jso : string;
			constant key : string;
			variable offset : inout natural;
			variable length : inout natural) is

			variable index : natural;
			variable key_offset   : natural;
			variable key_length   : natural;
			variable value_offset : natural;
			variable value_length : natural;
		begin
			jso_index := jso'left;
			index  := 0;
			offset := 0;
			length := 0;
			report "-----> jso : '" & jso & ''';
			while jso_index <= jso'right loop
				skipws(jso, jso_index);
				case jso(jso_index) is
				when '['|'{' =>
				jso_index := jso_index + 1;
				when ',' =>
					if index < to_natural(key)+1 then
						index := index + 1;
					end if;
				jso_index := jso_index + 1;
				when ']'|'}' =>
				jso_index := jso_index + 1;
				when others =>
				end case;
				report "jso I " & jso;
				report "jso I " & character'image(jso(jso_index));
				parse_value(jso, offset, length);
				report "jso II " & jso(offset to offset+length-1);
				if to_natural(key) <= index then
				-- elsif key=get_valuekey(jso, offset, length) then
					exit;
				end if;
			end loop;
			-- key_value(jso(offset to offset+length-1), key_offset, key_length, value_offset, value_length);
			key_value(jso(offset to offset+length-1), key_offset, key_length, value_offset, value_length);
			-- report "index " & natural'image(index);
			-- report natural'image(offset) & ':' & natural'image(length);
			-- report '"' & jso(key_offset to key_offset+key_length-1) & '"';
			-- report natural'image(value_offset) & ':' & natural'image(value_length);
			report "-----------> " & jso(key_offset to key_offset+key_length-1) & " ---> '" & jso(value_offset to value_offset+value_length-1) & ''';

		end;
	begin
		key_index  := key'left;
		jso_offset := jso'left;
		jso_length := jso'length;
		for i in 0 to 1 loop
			next_key(key, key_offset, key_length);
			report "key   : '" & key(key_offset to key_offset+key_length-1) & "' " & natural'image(key_offset) & " : " & natural'image(key_length);
			locate_value(jso(jso_offset to jso_offset+jso_length-1), key(key_offset to key_offset+key_length-1), jso_offset, jso_length);
			report "value : '" & jso(jso_offset to jso_offset+jso_length-1) & ''';
		end loop;
		return jso(jso_offset to jso_offset+jso_length-1);
		-- return " ";

	end;
end;