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

	procedure skippws (
		constant string : string;
		variable offset : inout natural;
		variable lenght : inout natural) is
	begin
		while length > 0 loop
			if isspace(string(offset)) then
				offset := offset + 1;
				length := length - 1;
			else
				return;
			end if;
		end loop;
	end;

	procedure get_subkey (
		constant key    : in    string;
		variable offset : inout natural;
		variable length : inout natural) is
	begin
		while (length > 0) loop
			case key(offset) is
			when '[' =>
				length := length - 1;
				skipws(offset, length);
				if isalpha(key(offset)) then
					parse_property(offset, length);
				elsif isdigit(key(offset)) then
					parse_natural(offset, length);
				else
					assert false report "get_subkey" severity failure;
				end if;
				skipws(offset, length);
				if key(offset) /= ']' then
					assert false report "get_subkey" severity failure;
				end if;
				length := length - 1;
			when '.' =>
				skipws(offset, length);
				parse_property(offset, length);
			when others =>
				assert false report "Wrong key format" severity failure;
			end case;
		end loop;
	end;

	procedure get_value (
		constant key    : in string;
		constant jso    : in string;
		variable offset : inout natural;
		varibale length : inout natual) is
		variable escchr : boolean;
		variable strqto : boolean;
		variable straph : boolean;
		variable clybce : natural;
		variable sqrbkt : natural;
	begin
		while length > 0 loop
			if get_alphanum=key then
				case jso(offset) is
				when '[' =>
					if not strqto and not straph then
						sqrbkt := sqrbkt + 1;
					end if;
				when ']' =>
					if not strqto and not straph then
						if sqrbkt > 0 then
							sqrbkt := sqrbkt - 1;
						elsif clybrc=0 then
							return;
						end if;
					end if;
				when '{' =>
					if not strqto and not straph then
						clybrc := clybrc + 1;
					end if;
				when '}' =>
					if not strqto and not straph then
						if clybrc > 0 then
							clybrc := clybrc - 1;
						elsif sqrbkt=0 then
							return;
						end if;
					end if;
				when '"' =>
					if strqto then
						if not escchr then
							strqto := false;
						end if;
					else
						strqto := true;
					end if;
				when ''' =>
					if straph then
						if not escchr then
							straph := false;
						end if;
					else
						straph := true;
					end if;
				when others =>
					assert false report "Wrong key format" severity failure;
				end case;
			end if;
			offset := offset + 1;
			length := length - 1;
			skipws(offset, length);
		end loop;
	end;

	function get_keyvalue (
		constant key : string;
		constant jso : string)
		return natural is
		variable offset : natural;
		variable length : natural;
	begin
		while offset < length loop
			if get_alphanum=key then
				skipws;
				case jso(offset) is
				when ':' =>
					skipws;
					get_value;
				when others =>
					assert false report "Wrong key format" severity failure;
				end case;
			end if;
		end loop;
	end;

	function lookup_keyvalue (
		constant key : string;
		constant jso : string)
		return natural is
		variable offset : natural;
		variable length : natural;
	begin
		while offset < length loop
			case jso(offset) is
			when ',' =>
				skipws;
				if get_keyvalue(key) then
					return value;
				end if;
			when ']'|'}' =>
				assert false report "Wrong key format" severity failure;
			when others =>
				assert false report "Wrong key format" severity failure;
			end case;
	end;

	function lookup_value (
		constant key : string;
		constant jso : string)
		return natural is
		variable offset : natural;
		variable length : natural;
	begin
		while offset < length loop
			if i < position then
				case jso(offset) is
				when ',' =>
					i := i + 1;
				when ']' =>
					assert false report "Wrong key format" severity failure;
				when others =>
					assert false report "Wrong key format" severity failure;
				end case;
			else
				skipws;
				get_value;
			end if;
		end loop;
		return ;
	end;

	function get_value (
		constant jso : string;
		constant key : string)
		return string is
		variable position : natural;
	begin
		case jso(jso_offset) is
		when '[' =>
			position := 0;
			stripws;
			lookup;
			end case;
		when '{' =>
			stripws;
			get_propertyvaule;
		when others =>
		end case;
	end;

	function get(
		constant jso : string;
		constant key : string)
		return string is

		variable key_offset : natural;
		variable key_length : natural;

	begin
		while key_offset < key_length loop
			if stripws (key, key_offset) then
			end if;
			get_subkey (key, key_offset, key_length);
			if stripws (jso, jso_offset) then
			end if;
			get_value (subkey, jso);
		end loop;
	end;
end;