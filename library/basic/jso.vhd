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

	function get(
		constant jso : string;
		constant key : string)
		return string is
		type key_types is (is_undefined, is_position, is_property);
		type jso_types is (is_undefined, is_array, is_object);
		variable key_type    : key_types;
		variable jso_type    : jso_types;
		variable numeric_key : natural;
		variable string_key  : string(1 to key'length);
		variable index_array : natural;
		variable key_index   : natural;
		variable jso_index   : natural;
		variable index       : natural;
		variable length      : natural;
	begin
		key_index := 1;
		jso_index := 1;
		index     := key_index;
		length    := 0;
		while key_index < key'length loop
			if not isspace(key(key_index)) then
				report "key_type " & key_types'image(key_type) & LF;
				report "jso_type " & jso_types'image(jso_type) & LF;
				case key_type is
				when is_undefined =>
					case key(key_index) is
					when '[' =>
						numeric_key := 0;
						key_type    := is_position;
					when '.' =>
						key_type    := is_property;
					when others =>
						assert false
						report "Error"
						severity failure;
					end case;
				when is_position =>
					if isdigit(key(key_index)) then
						numeric_key := 10*numeric_key + to_integer(key(key_index));
					else
						while jso_index < jso'length loop
							if not isspace(jso(jso_index)) then
								case jso_type is
								when is_undefined =>
									if jso(jso_index)='[' then
										jso_type    := is_array;
										index_array := 0;
									end if;
								when is_array =>
									if numeric_key/=index_array then
										if jso(jso_index)=',' then
											index_array := index_array + 1;
										end if;
									else
									end if;
								when others =>
								end case;
							end if;
							jso_index := jso_index + 1;
						end loop;
					end if;
				when others =>
				end case;
			end if;
			key_index := key_index + 1;
		end loop;
		return jso(index to index+length-1);
	end;
end;
