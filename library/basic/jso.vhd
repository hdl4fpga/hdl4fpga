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
		constant key : string;
		constant jso : string)
		return string;
end;

package body jso is

	function isspace (
		constant char : character)
		return boolean is
	begin
		return true;
	end;

	function isdigit (
		constant char : character)
		return boolean is
	begin
		return true;
	end;

	function isalpha (
		constant char : character)
		return boolean is
	begin
		return true;
	end;

	function to_integer (
		constant char : character)
		return integer is
	begin
		return character'pos(char)-character'pos('0');
	end;

	function get(
		constant key : string;
		constant jso : string)
		return string is
		type key_types is (is_undefined, is_position, is_property);
		variable key_type    : key_types;
		type jso_types is (is_undefined, is_array, is_object);
		variable jso_type : jso_types;
		variable numeric_key : natural;
		variable string_key  : string(1 to key'length);
		variable index_array : natural;
		variable i           : natural;
		variable j           : natural;
	begin
		i := 0;
		j := 0;
		while i < key'length loop
			if not isspace(key(i)) then
				case key_type is
				when is_undefined =>
					if key(i)='[' then
					elsif isdigit(key(i)) then
						numeric_key := to_integer(key(i));
						key_type    := is_position;
					elsif isalpha(key(i)) then
						key_type    := is_property;
					else
						assert false
						report "Error"
						severity failure;
					end if;
				when is_position =>
					if isdigit(key(i)) then
						numeric_key := 10*numeric_key + to_integer(key(i));
					else
						while j < jso'length loop
							if not isspace(jso(j)) then
								case jso_type is
								when is_undefined =>
									if jso(j)='[' then
										jso_type    := is_array;
										index_array := 0;
									end if;
								when is_array =>
									if numeric_key/=index_array then
										if jso(j)=',' then
											index_array := index_array + 1;
										end if;
									else
									end if;
								when others =>
								end case;
							end if;
							j := j + 1;
						end loop;
					end if;
				when others =>
				end case;
			end if;
			i := i + 1;
		end loop;
		return "hola";
	end;
end;
