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

	function get_jso (
		constant jso : string)
		return string is

		constant log        : boolean := not true;
		variable key_offset : natural;
		variable key_length : natural;
		variable key_index  : natural;

		variable jso_offset : natural;
		variable jso_length : natural;
		variable jso_index  : natural;
		variable tag_offset : natural;
		variable tag_length : natural;

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
			variable length : out   natural) is
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

		procedure next_tag (
			constant key    : string;
			variable offset : inout natural;
			variable length : inout natural) is
			variable close_char : character;
		begin
			skipws(key, key_index);
			assert log 
				report "next_tag => " & natural'image(key_index) & "->" & ''' & key(key_index) & '''
				severity note;
			while key_index <= key'right loop
				case key(key_index) is
				when '['|'{' =>
					close_char := key(key_index);
					key_index  := key_index + 1;
					skipws(key, key_index);
					if isdigit(key(key_index)) then
						assert log
							 report "next_tag [ is digit"
							 severity note;
						parse_natural(key, offset, length);
					else
						assert log 
							report "next_tag [ is not digit" 
							severity note;
						parse_string(key(key_index to key'right), offset, length);
						assert length/=0 report "next_tag -> invalid key : " & key(key_index to key'right) severity failure;
						key_index := offset+length;
						assert log 
							report "next_tag => " & natural'image(key_index) & "->" & ''' & key(key_index) & '''
							severity note;
					end if;
					skipws(key, key_index);
					case key(key_index) is
					when ']' => 
						assert close_char='['
							report "next_tag : wrong close key " & ''' & close_char & ''' & " " & ''' & key(key_index) & '''
							severity failure;
						key_index := key_index + 1;
					when '}' => 
						assert close_char='{'
							report "next_tag : wrong close key " & ''' & close_char & ''' & " " & ''' & key(key_index) & '''
							severity failure;
						key_index := key_index + 1;
					when others =>
						assert false
							report "next_tag"
							severity failure;
					end case;
					exit;
				when '.' =>
					key_index := key_index + 1;
					skipws(key, key_index);
					parse_string(key(key_index to key'right), offset, length);
					assert length/=0
						report "next_tag -> invalid key : " & key(key_index to key'right)
						severity failure;
					key_index := offset+length;
					exit;
				when others =>
					assert false
						report "Wrong key format"
						severity failure;
				end case;
			end loop;
			skipws(key, key_index);
			assert log
				report "next_tag => key -> " & key(offset to offset+length-1) & ' ' & integer'image(offset) & ':' & integer'image(length)
				severity note;
		end;

		procedure parse_value (
			constant jso    : in    string;
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
			variable list   : boolean := false;
		begin
			jso_stptr := 0;
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

		procedure tag_value (
			constant tag_value    : string;
			variable tag_offset   : inout natural;
			variable tag_length   : inout natural;
			variable value_offset : inout natural;
			variable value_length : inout natural) is
			variable index        : natural;
		begin
			assert log
				report "tag_value => tag_value -> " & '"' & tag_value & '"'
				severity note;
			parse_string(tag_value, value_offset, value_length);
			assert log
				report "tag_value => value_length -> " & natural'image(value_length)
				severity note;
			index := value_offset + value_length;
			skipws(tag_value, index);
			if index <= tag_value'right then
				if value_length=0 then
					assert log
						report "tag_value => no tag"
						severity note;
					tag_length := 0;
					value_offset := index;
					value_length := tag_value'right-index+1; 
				elsif tag_value(index)/=':' then
					tag_length := 0;
				else
					tag_offset := value_offset;
					tag_length := value_length;
					index := index + 1;
					value_offset := index;
					value_length := tag_value'right-index+1; 
				end if;
			end if;
		end;
			
		procedure value_key (
			constant jso          : in string;
			variable value_offset : inout natural;
			variable value_length : inout natural;
			variable key_offset   : inout natural;
			variable key_length   : inout natural) is
		begin
			jso_index := jso'left;
			parse_value(jso, value_offset, value_length);
			skipws(jso, jso_index);
			key_offset := value_offset + value_length;
			key_length := 0;
			if jso_index <= jso'right then
				case jso(jso_index) is
				when '.'|'[' =>
					key_length := jso'right-key_offset+1;
					assert log
						report "value_key => value.key => " & ''' & 
							jso(value_offset to value_offset+value_length-1) & ''' & "->" & ''' &
							jso(key_offset to key_offset+key_length-1) & '''
						severity note;
				when others =>
					assert false
						report "value_key => wrong access key"
						severity failure;
				end case;
			else
				assert log
					report "value_key => value -> " & ''' & jso(value_offset to value_offset+value_length-1) & ''' & "->" & '''
					severity note;
			end if;
		end;

		procedure locate_value (
			constant jso          : in    string;
			constant key          : in    string;
			variable offset       : inout natural;
			variable length       : inout natural) is

			variable index        : natural;
			variable tag_offset   : natural;
			variable tag_length   : natural;
			variable value_offset : natural;
			variable value_length : natural;
		begin
			assert log 
				report "locate_value => key -> " & '"' & key & '"'
				severity note;
			assert log 
				report "locate_value => key(key'left) -> " & ''' & key(key'left) & '''
				severity note;
			jso_index := jso'left;
			index     := 0;
			offset    := 0;
			length    := 0;
			while jso_index <= jso'right loop
				skipws(jso, jso_index);
				case jso(jso_index) is
				when '['|'{' =>
					jso_index := jso_index + 1;
				when ',' =>
					index := index + 1;
					jso_index := jso_index + 1;
				when ']'|'}' =>
					jso_index := jso_index + 1;
				when others =>
				end case;
				parse_value(jso, offset, length);
				if isdigit(key(key'left)) then
					if to_natural(key) <= index then
						assert log 
							report "locate_value => object -> " & jso(offset to offset+length-1)
							severity note;
						tag_value(jso(offset to offset+length-1), tag_offset, tag_length, value_offset, value_length);
						assert log 
							report "locate_value => key:value ->" & jso(tag_offset to tag_offset+tag_length-1) & " : '" & jso(value_offset to value_offset+value_length-1) & '''
							severity note;
						exit;
					end if;
				elsif isalnum(key(key'left)) then
					tag_value(jso(offset to offset+length-1), tag_offset, tag_length, value_offset, value_length);
					if key=jso(tag_offset to tag_offset+tag_length-1) then
						exit;
					end if;
				end if;
			end loop;
			assert log 
				report "locate_value -> " & jso(tag_offset to tag_offset+tag_length-1) & " : '" & jso(value_offset to value_offset+value_length-1) & '''
				severity note;
			offset := value_offset;
			length := value_length;
		end;
	begin
		jso_offset := jso'left;
		jso_length := jso'length;
		value_key(jso, jso_offset, jso_length, key_offset, key_length);
		key_index  := key_offset;
		if key_length/=0 then
			while key_index < key_offset+key_length loop
				next_tag(jso(key_offset to key_offset+key_length-1), tag_offset, tag_length);
				locate_value(jso(jso_offset to jso_offset+jso_length-1), jso(tag_offset to tag_offset+tag_length-1), jso_offset, jso_length);
				assert log
					report "get_jso => key:value -> " & 
						''' & jso(tag_offset to tag_offset+tag_length-1) & ''' & ":" &
						''' & jso(jso_offset to jso_offset+jso_length-1) & '''
					severity note;
			end loop;
		end if;
		return jso(jso_offset to jso_offset+jso_length-1);
	end;
end;