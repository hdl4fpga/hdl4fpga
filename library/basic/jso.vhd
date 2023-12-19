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

	function get_jso (
		constant jso : string)
		return string;

end;

package body jso is

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
		return retval;
	end;

	procedure get_jso (
		constant jso          : in    string;
		variable jso_offset   : inout natural;
		variable jso_length   : inout natural) is

		constant log          : boolean := not true;
		variable key_offset   : natural;
		variable key_length   : natural;
		variable key_index    : natural;

		variable tag_offset   : natural;
		variable tag_length   : natural;
		variable value_offset : natural;
		variable value_length : natural;

		procedure skipws (
			constant jso       : in    string;
			variable jso_index : inout natural) is
		begin
			while jso_index <= jso'right loop
				if isws(jso(jso_index)) then
					jso_index := jso_index + 1;
				else
					return;
				end if;
			end loop;
		end;

		procedure parse_string (
			constant jso       : in    string;
			variable offset    : inout natural;
			variable length    : out   natural;
			variable jso_index : natural) is
			variable aphos     : boolean := false;
		begin
			jso_index  := jso'left;
			skipws(jso, jso_index);
			offset := jso_index;
			while jso_index <= jso'right loop
				if (jso_index-offset)=0 then
					if jso(jso_index)=''' then
						aphos := true;
						jso_index := jso_index  + 1;
						next;
					end if;
				end if;
				if aphos then
					if jso(jso_index)=''' then
						jso_index := jso_index + 1;
						exit;
					else
						jso_index := jso_index + 1;
					end if;
				elsif isalnum(jso(jso_index)) then
					jso_index := jso_index + 1;
				else
					exit;
				end if;
			end loop;
			length := jso_index-offset;
		end;

		procedure parse_natural (
			constant jso    : in    string;
			variable offset : inout natural;
			variable length :   out natural) is
		begin
			offset := jso'left;
			length := offset;
			while length <= jso'right loop
				if isalnum(jso(length)) then
					length := length + 1;
				else
					length := length-offset;
					exit;
				end if;
			end loop;
		end;

		procedure parse_keytag (
			constant jso       : in    string;
			variable offset    : inout natural;
			variable length    : inout natural;
			variable jso_index : inout natural) is
			variable open_char : character;
		begin
			jso_index := jso'left;
			skipws(jso, jso_index);
			assert log or jso_index > jso'right
				report "parse_keytag => " & natural'image(jso_index) & "->" & ''' & jso(jso_index) & '''
				severity note;
			length := 0;
			while jso_index <= jso'right loop
				case jso(jso_index) is
				when '['|'{' =>
					open_char := jso(jso_index);
					jso_index := jso_index + 1;
					skipws(jso, jso_index);
					if isdigit(jso(jso_index)) then
						assert log
							 report "parse_keytag => [ is digit"
							 severity note;
						parse_natural(jso(jso_index to jso'right), offset, length);
						jso_index := offset + length;
					else
						assert log 
							report "parse_keytag => [ is not digit" 
							severity note;
						parse_string(jso(jso_index to jso'right), offset, length);
						assert length/=0
							report "parse_keytag -> invalid key : " & jso(jso_index to jso'right) 
							severity failure;
						jso_index := offset+length;
						assert log 
							report "parse_keytag => " & natural'image(jso_index) & "->" & ''' & jso(jso_index) & '''
							severity note;
					end if;
					skipws(jso, jso_index);
					case jso(jso_index) is
					when ']' => 
						assert open_char='['
							report "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & jso(jso_index) & '''
							severity failure;
						assert log
							report "parse_keytag => ]"
							severity note;
						jso_index := jso_index + 1;
					when '}' => 
						assert open_char='{'
							report "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & jso(jso_index) & '''
							severity failure;
						assert log
							report "parse_keytag => }"
							severity note;
						jso_index := jso_index + 1;
					when others =>
						assert false
							report "parse_keytag => wrong token -> " & jso(jso_index)
							severity failure;
					end case;
					exit;
				when '.' =>
					jso_index := jso_index + 1;
					skipws(jso, jso_index);
					parse_string(jso(jso_index to jso'right), offset, length);
					assert length/=0
						report "parse_keytag => invalid key : " & jso(jso_index to jso'right)
						severity failure;
					jso_index := offset+length;
					exit;
				when others =>
					length := 0;
					assert log
						report "parse_keytag => null"
						severity note;
				end case;
			end loop;
			skipws(jso, jso_index);
			report "parse_keytag pase => key_index -> " & natural'image(jso_index);
			assert log or jso_index > jso'right
				report "parse_keytag => key -> " & jso(offset to offset+length-1) & ' ' & integer'image(offset) & ':' & integer'image(length)
				severity note;
		end;

		procedure parse_key (
			constant jso    : in string;
			variable offset : inout natural;
			variable length : inout natural) is
			variable key_index  : natural;
			variable tag_offset : natural;
			variable tag_length : natural;
		begin
			key_index := jso'left;
			skipws(jso, key_index);
			offset := key_index;
			loop
				parse_keytag(jso(key_index to jso'right), tag_offset, tag_length, key_index);
				report "parse_key => " & natural'image(length);
				if tag_length=0 then
					length := key_index-offset;
					exit;
				end if;
			end loop;
		end;

		procedure parse_value (
			constant jso    : in    string;
			variable offset : inout natural;
			variable length : inout natural) is

			variable jso_index : natural;
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
			variable list   : boolean := false;
		begin
			jso_stptr := 0;
			jso_index := jso'left;
			skipws(jso, jso_index);
			offset := jso_index;
			while jso_index <= jso'right loop
				if not aphos then
					case jso(jso_index) is
					when '['|'{' =>
						if jso_stptr=0 then 
							if offset=jso_index then
								list := true;
								assert log
									report "parse_value => list"
									severity note;
							end if;
						end if;
						push(jso(jso_index));
					when ',' =>
						if jso_stptr=0 then
							exit;
						end if;
					when ']' =>
						if jso_stptr/=0 then
							assert jso_stack(jso_stptr)='['
								report "parse_value => close key " & jso_stack(jso_stptr) & jso(jso_index)
								severity failure;
							pop(jso(jso_index));
						else
							exit;
						end if;
					when '}' =>
						if jso_stptr/=0 then
							assert jso_stack(jso_stptr)='{'
								report "parse_value => close key " & jso_stack(jso_stptr) & jso(jso_index)
								severity failure;
								exit;
							pop(jso(jso_index));
						else
							exit;
						end if;
					when others =>
					end case;
				end if;
				if jso(jso_index)=''' then
					aphos := not aphos;
				end if;
				jso_index := jso_index + 1;
				if list then
					if jso_stptr=0 then
						exit;
					end if;
				end if;
			end loop;
			length := jso_index-offset;
			assert log
				report "parse_value => value -> " &  jso(offset to offset+length-1)
				severity note;
		end;

		procedure parse_tagvaluekey (
			constant jso          : string;
			variable tag_offset   : inout natural;
			variable tag_length   : inout natural;
			variable value_offset : inout natural;
			variable value_length : inout natural;
			variable key_offset   : inout natural;
			variable key_length   : inout natural) is
			variable jso_index    : natural;
		begin
			assert log
				report "parse_tagvaluekey => jso -> " & '"' & jso & '"'
				severity note;
			jso_index := jso'left;
			parse_string(jso, value_offset, value_length);
			jso_index := value_offset+value_length;
			skipws(jso, jso_index);
			key_offset := value_offset + value_length;
			key_length := 0;
			assert log
				report "parse_tagvaluekey => value_length -> " & natural'image(value_length)
				severity note;
			if jso_index <= jso'right then
				if value_length=0 then
					assert log
						report "parse_tagvaluekey => no tag"
						severity note;
					tag_length := 0;
					value_offset := jso_index;
					value_length := jso'right-jso_index+1; 
					parse_value(jso(value_offset to value_offset+value_length-1), value_offset, value_length);
				elsif jso(jso_index)/=':' then
					report "Pase -> " & jso(jso_index);
					tag_length := 0;
				else
					assert log
						report "parse_tagvaluekey => tag"
						severity note;
					tag_offset := value_offset;
					tag_length := value_length;
					jso_index  := jso_index + 1;
					value_offset := jso_index;
					value_length := jso'right-jso_index+1; 
					skipws(jso, jso_index);
					parse_value(jso(value_offset to value_offset+value_length-1), value_offset, value_length);
				end if;
			end if;
			assert log 
				report "parse_tagvaluekey => tag -> " & '"' & jso(tag_offset to tag_offset+tag_length-1) & '"'
				severity note;
			assert log 
				report "parse_tagvaluekey => value -> " & '"' & jso(value_offset to value_offset+value_length-1) & '"'
				severity note;
			parse_key(jso(value_offset+value_length to jso'right), key_offset, key_length);
			assert log 
				report "parse_tagvaluekey => key -> " & '"' & jso(key_offset to key_offset+key_length-1) & '"'
				severity note;
		end;
			
		procedure locate_value (
			constant jso          : in    string;
			constant tag          : in    string;
			variable offset       : inout natural;
			variable length       : inout natural) is

			variable jso_index    : natural;
			variable tag_offset   : natural;
			variable tag_length   : natural;
			variable key_offset   : natural;
			variable key_length   : natural;
			variable value_offset : natural;
			variable value_length : natural;
			variable position     : natural;
			variable open_char    : character;
		begin
			assert log 
				report "locate_value => tag -> " & '"' & tag & '"'
				severity note;
			offset    := 0;
			length    := 0;
			position  := 0;
			jso_index := jso'left;
			while jso_index <= jso'right loop
				skipws(jso, jso_index);
				case jso(jso_index) is
				when '['|'{' =>
					assert log
						report "locate_value => open"
						severity note;
					open_char := jso(jso_index);
					jso_index := jso_index + 1;
				when ',' =>
					assert log
						report "locate_value => next"
						severity note;
					position  := position + 1;
					jso_index := jso_index + 1;
				when ']' =>
					assert open_char='['
						report "locate_value => wrong close key " & ''' & open_char & ''' & " " & ''' & jso(jso_index) & '''
						severity failure;
					assert log
						report "locate_value => close"
						severity note;
					jso_index := jso_index + 1;
				when '}' =>
					assert open_char='{'
						report "locate_value => wrong close key " & ''' & open_char & ''' & " " & ''' & jso(jso_index) & '''
						severity failure;
					assert log
						report "locate_value => close"
						severity note;
					jso_index := jso_index + 1;
				when others =>
					parse_tagvaluekey(jso(jso_index to offset+length-1), tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
					if isdigit(tag(tag'left)) then
						if to_natural(tag) <= position then
							assert log 
								report "locate_value => tag -> " & jso(tag_offset to tag_offset+tag_length-1)
								severity note;
							exit;
						end if;
					elsif isalnum(tag(tag'left)) then
						if tag=jso(tag_offset to tag_offset+tag_length-1) then
							exit;
						end if;
					end if;
				end case;
			end loop;
			assert log 
				report "locate_value -> " & jso(tag_offset to tag_offset+tag_length-1) & " : '" & jso(value_offset to value_offset+value_length-1) & '''
				severity note;
			offset := tag_offset;
			length := jso_index-tag_offset;
		end;

	begin
		parse_tagvaluekey (jso, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
		return;
		jso_offset := jso'left;
		jso_length := jso'length;
		parse_tagvaluekey(jso, tag_offset, tag_length, jso_offset, jso_length, key_offset, key_length);
		assert log
			report "get_jso => key_length, key -> " & natural'image(key_length) & ", " & '"' & jso(key_offset to key_offset+key_length-1) & '"'
			severity note;
		if key_length/=0 then
			while key_index < key_offset+key_length loop
				parse_keytag(jso(key_offset to key_offset+key_length-1), tag_offset, tag_length, key_index);
				locate_value(jso(jso_offset to jso_offset+jso_length-1), jso(tag_offset to tag_offset+tag_length-1), jso_offset, jso_length);
				assert log
					report "get_jso => key:value -> " & 
						'"' & jso(tag_offset to tag_offset+tag_length-1) & '"' & ":" &
						'"' & jso(jso_offset to jso_offset+jso_length-1) & '"'
					severity note;
				-- get_jso(jso(jso_offset to jso_offset+jso_length-1), jso_offset, jso_length);
			end loop;
		end if;
	end;

	function get_jso (
		constant jso : string)
		return string is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		get_jso (jso, jso_offset, jso_length);
		return jso(jso_offset to jso_offset+jso_length-1);
	end;

end;