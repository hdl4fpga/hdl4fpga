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

	function resolve (
		constant jso : string)
		return string;

	function resolve (
		constant jso : string)
		return natural;

	function resolve (
		constant jso : string)
		return boolean;

	subtype jso is string;

	function "**" (
		constant jso : jso;
		constant key : string)
		return natural;

	function "**" (
		constant jso : jso;
		constant key : string)
		return boolean;

	function "**" (
		constant obj : jso;
		constant key : string)
		return jso;
end;

package body jso is

	constant log_parsestring      : natural := 2**0;
	constant log_parsenatural     : natural := 2**1;
	constant log_parsekeytag      : natural := 2**2;
	constant log_parsekey         : natural := 2**3;
	constant log_parsevalue       : natural := 2**4;
	constant log_parsetagvaluekey : natural := 2**5;
	constant log_locatevalue      : natural := 2**6;
	constant log_resolve          : natural := 2**7;
	constant log                  : natural := 0; --log_parsetagvaluekey; -- + log_resolve + log_locatevalue    + log_parsevalue ;

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
		if char='_' then
			return true;
		elsif character'pos('A') <= character'pos(char) and character'pos(char) <= character'pos('Z') then
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
		constant base  : natural) 
		return natural is
		variable retval : natural;
	begin
		retval := 0;
		for i in value'range loop
			if value(i)/='_' then
				retval := base*retval;
				if character'pos(value(i)) >= character'pos('0') and (character'pos(value(i))-character'pos('0')) <= (base-1) mod 10 then
					retval := (character'pos(value(i))-character'pos('0')) + retval;
				elsif character'pos(value(i)) >= character'pos('a') and (character'pos(value(i))-character'pos('a')) < (base-10) then
					retval := (character'pos(value(i))-character'pos('a')) + 10 + retval;
				elsif character'pos(value(i)) >= character'pos('A') and (character'pos(value(i))-character'pos('A')) < (base-10) then
					retval := (character'pos(value(i))-character'pos('A')) + 10 + retval;
				else
					assert false
						report "Wrong number " & character'image(value(i)) & " " & natural'image(base)
						severity failure;
				end if;
			end if;
		end loop;
		return retval;
	end;

	function to_natural (
		constant value : string)
		return natural is
		variable retval : natural;
	begin
		if value'length > 1 then
			if value(value'left)='0' then
				case value(value'left+1) is
				when 'x'|'X' =>
					return to_natural(value(value'left+2 to value'right), 16);
				when 'b'|'B' =>
					return to_natural(value(value'left+2 to value'right), 2);
				when others =>
					return to_natural(value(value'left+2 to value'right), 10);
				end case;
			else
				return to_natural(value, 10);
			end if;
		else
			return to_natural(value, 10);
		end if;
	end;

	function to_real(
		constant value : string) 
		return real is
		variable idx  : natural;
		variable sign : real;
		variable mant : real;
		variable exp  : integer;
	begin
		idx := value'left;
		if value(idx) = '-' then
			sign := -1.0;
			idx  := idx + 1;
		else
			sign := 1.0;
			if value(idx) = '+' then
				idx := idx + 1;
			end if;
		end if;

		mant := 0.0;
		exp  := 0;
		while idx < value'right loop
			if value(idx)='.' then
				idx := idx + 1;
				exit;
			end if;
			mant := 10.0*mant + real(character'pos(value(idx))-character'pos('0'));
			idx  := idx + 1;
		end loop;

		while idx < value'right loop
			if value(idx)='e' then
				idx := idx + 1;
				exit;
			end if;
			mant := 10.0*mant + real(character'pos(value(idx))-character'pos('0'));
			exp  := exp - 1;
			idx  := idx + 1;
		end loop;

		exp := 0;
		while idx < value'right loop
			exp := 10*exp + (character'pos(value(idx))-character'pos('0'));
			idx := idx + 1;
		end loop;

		return 0.0;
	end;
	
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
		variable jso_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable aphos     : boolean := false;
	begin
		skipws(jso, jso_index);
		offset := jso_index;
		while jso_index <= jso'right loop
			if (jso_index-offset)=0 then
				if jso(jso_index)=''' then
					aphos     := true;
					jso_index := jso_index  + 1;
					offset    := jso_index;
					next;
				end if;
			end if;
			if aphos then
				if jso(jso_index)=''' then
					length    := jso_index-offset;
					jso_index := jso_index + 1;
					assert (log/log_parsestring) mod 2=0
						report "parse_string => " & '"' & jso(offset to offset+length-1) & '"'
						severity note;
					return;
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
		assert (log/log_parsestring) mod 2=0
			report "parse_string => " & '"' & jso(offset to offset+length-1) & '"'
			severity note;
	end;

	procedure parse_natural (
		constant jso       : in    string;
		variable jso_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
	begin
		skipws(jso, jso_index);
		offset := jso_index;
		while jso_index <= jso'right loop
			if isalnum(jso(jso_index)) then
				jso_index := jso_index + 1;
			else
				exit;
			end if;
		end loop;
		length := jso_index-offset;
		assert (log/log_parsenatural) mod 2=0
			report "parse_string => " & '"' & jso(offset to offset+length-1) & '"'
			severity note;
	end;

	procedure parse_keytag (
		constant jso       : in    string;
		variable jso_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable open_char : character;
	begin
		skipws(jso, jso_index);
		assert ((log/log_parsekeytag) mod 2=0)
			report "parse_keytag => jso_index -> " & natural'image(jso_index)
			severity note;
		-- assert ((log/log_parsekeytag) mod 2=0) or jso_index > jso'right
			-- report "parse_keytag => jso_index -> " & natural'image(jso_index) & " -> " & ''' & jso(jso_index) & '''
			-- severity note;
		length := 0;
		while jso_index <= jso'right loop
			case jso(jso_index) is
			when '['|'{' =>
				open_char := jso(jso_index);
				jso_index := jso_index + 1;
				parse_natural(jso, jso_index, offset, length);
				assert ((log/log_parsekeytag) mod 2=0) or length=0 
					 report "parse_keytag => [ is position"
					 severity note;
				assert ((log/log_parsekeytag) mod 2=0) or length/=0 
					report "parse_keytag  => [ is string" 
					severity note;
				if length=0 then
					parse_string(jso, jso_index, offset, length);
				end if;
				assert length/=0
					report "parse_keytag -> invalid key : " & jso(jso_index to jso'right) 
					severity failure;
				assert ((log/log_parsekeytag) mod 2=0)
					report "parse_keytag => " & natural'image(jso_index) & "->" & ''' & jso(jso_index) & '''
					severity note;
				skipws(jso, jso_index);
				case jso(jso_index) is
				when ']' => 
					assert open_char='['
						report "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & jso(jso_index) & '''
						severity failure;
					assert ((log/log_parsekeytag) mod 2=0)
						report "parse_keytag => ]"
						severity note;
					jso_index := jso_index + 1;
				when '}' => 
					assert open_char='{'
						report "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & jso(jso_index) & '''
						severity failure;
					assert ((log/log_parsekeytag) mod 2=0)
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
				parse_string(jso, jso_index, offset, length);
				assert length/=0
					report "parse_keytag => invalid key : " & jso(jso_index to jso'right)
					severity failure;
				jso_index := offset+length;
				exit;
			when others =>
				length := 0;
				assert ((log/log_parsekeytag) mod 2=0)
					report "parse_keytag => null"
					severity note;
				exit;
			end case;
		end loop;
		assert ((log/log_parsekeytag) mod 2=0) or jso_index > jso'right
			report "parse_keytag => key -> " & jso(offset to offset+length-1) & ' ' & integer'image(offset) & ':' & integer'image(length)
			severity note;
	end;

	procedure parse_key (
		constant jso        : in string;
		variable jso_index  : inout natural;
		variable offset     : inout natural;
		variable length     : inout natural) is
		variable tag_offset : natural;
		variable tag_length : natural;
	begin
		skipws(jso, jso_index);
		offset := jso_index;
		loop
			parse_keytag(jso, jso_index, tag_offset, tag_length);
			assert ((log/log_parsekey) mod 2=0)
				report "parse_key => " & natural'image(length)
				severity note;
			if tag_length=0 then
				length := jso_index-offset;
				exit;
			end if;
		end loop;
	end;

	procedure parse_value (
		constant jso       : in    string;
		variable jso_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable jso_stack : string(1 to 32);
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
		skipws(jso, jso_index);
		offset := jso_index;
		while jso_index <= jso'right loop
			if not aphos then
				case jso(jso_index) is
				when '['|'{' =>
					if jso_stptr=0 then 
						if offset=jso_index then
							list := true;
							assert ((log/log_parsevalue) mod 2=0)
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
		assert ((log/log_parsevalue) mod 2=0)
			report "parse_value => value -> " &  jso(offset to offset+length-1)
			severity note;
	end;

	procedure parse_tagvaluekey (
		constant jso          : string;
		variable jso_index    : inout natural;
		variable tag_offset   : inout natural;
		variable tag_length   : inout natural;
		variable value_offset : inout natural;
		variable value_length : inout natural;
		variable key_offset   : inout natural;
		variable key_length   : inout natural) is
	begin
		assert ((log/log_parsetagvaluekey) mod 2=0)
			report "parse_tagvaluekey => jso -> " & '"' & jso(jso_index to jso'right) & '"'
			severity note;
		parse_string(jso, jso_index, value_offset, value_length);
		tag_offset := value_offset;
		tag_length := 0;
		skipws(jso, jso_index);
		if jso_index <= jso'right then
			if value_length=0 then
				tag_length   := 0;
				value_offset := jso_index;
				value_length := jso'right-jso_index+1; 
				parse_value(jso, jso_index, value_offset, value_length);
				-- assert ((log/log_parsetagvaluekey) mod 2=0)
					-- report
						-- "parse_tagvaluekey => no tag" & LF &
						-- "parse_tagvaluekey => value          -> " & '"' & jso(value_offset to value_offset+value_length-1) & '"' & LF &
						-- "parse_tagvaluekey => jso(jso_index) -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					-- severity note;
			elsif jso(jso_index)/=':' then
				assert ((log/log_parsetagvaluekey) mod 2=0)
					report
						"parse_tagvaluekey => tag token not found" & LF &
						"parse_tagvaluekey => value     -> " & '"' & jso(value_offset to value_offset+value_length-1) & '"' & LF &
						"parse_tagvaluekey => jso_index -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					severity note;
				tag_length   := 0;
				tag_offset   := value_offset;
			else
				tag_offset   := value_offset;
				tag_length   := value_length;
				jso_index    := jso_index + 1;
				value_offset := jso_index;
				value_length := jso'right-jso_index+1; 
				skipws(jso, jso_index);
				parse_value(jso, jso_index, value_offset, value_length);
				assert ((log/log_parsetagvaluekey) mod 2=0)
					report LF &
						"parse_tagvaluekey => tag       -> " & '"' & jso(tag_offset to tag_offset+tag_length-1) & '"' & LF &
						"parse_tagvaluekey => value     -> " & '"' & jso(value_offset to value_offset+value_length-1) & '"' 
					severity note;
				assert ((log/log_parsetagvaluekey) mod 2=0) or jso_index <= jso'right
					report LF &
						"parse_tagvaluekey => jso_index passed end of the jso -> " & natural'image(jso_index)
					severity note;
				-- assert ((log/log_parsetagvaluekey) mod 2=0) or jso_index > jso'right
					-- report LF &
						-- "parse_tagvaluekey => jso(jso_index) -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					-- severity note;
			end if;
		else
			assert ((log/log_parsetagvaluekey) mod 2=0)
				report LF &
					"parse_tagvaluekey => string value -> " & '"' & jso(value_offset to value_offset+value_length-1) & '"' & LF &
					"parse_tagvaluekey => jso_index passed end of the jso -> " & natural'image(jso_index)
				severity note;
		end if;
		parse_key(jso, jso_index, key_offset, key_length);
		assert ((log/log_parsetagvaluekey) mod 2=0)
			report LF &
				"parse_tagvaluekey => key       -> " & '"' & jso(key_offset to key_offset+key_length-1) & '"' & LF &
				"parse_tagvaluekey => jso_index -> " & natural'image(jso_index)
			severity note;
	end;
		
	procedure locate_value (
		constant jso          : in    string;
		variable jso_index    : inout natural;
		constant tag          : in    string;
		variable offset       : inout natural;
		variable length       : inout natural) is

		variable tag_offset   : natural;
		variable tag_length   : natural;
		variable key_offset   : natural;
		variable key_length   : natural;
		variable value_offset : natural;
		variable value_length : natural;
		variable position     : natural;
		variable open_char    : character;
		variable valid        : boolean;
	begin
		assert ((log/log_locatevalue) mod 2=0)
			report LF &
				"locaye_value => vvvvvvvvvvvvvvvvvvvv" & LF &
				"locate_value => jso       -> " & natural'image(jso_index) & ':' & natural'image(jso'right) & " " & '"' & jso(jso_index to jso'right) & '"'
			severity note;
		parse_tagvaluekey(jso, jso_index, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
		jso_index := value_offset;
		offset    := tag_offset;
		length    := 0;
		position  := 0;
		while jso_index <= jso'right loop
			assert ((log/log_locatevalue) mod 2=0)
				report LF &
					"locale_value.loop => jso(jso_index) -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
				severity note;
			skipws(jso, jso_index);
			case jso(jso_index) is
			when '['|'{' =>
				assert ((log/log_locatevalue) mod 2=0)
					report LF &
						"locate_value => start -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					severity note;
				open_char := jso(jso_index);
				jso_index := jso_index + 1;
			when ',' =>
				assert ((log/log_locatevalue) mod 2=0)
					report LF & 
						"locate_value => next position -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					severity note;
				position  := position + 1;
				jso_index := jso_index + 1;
			when ']' =>
				assert open_char='['
					report LF & 
						"locate_value => wrong close key at " & natural'image(jso_index) & " open with  " & ''' & open_char & ''' & " close by " & character'image(jso(jso_index))
					severity failure;
				assert ((log/log_locatevalue) mod 2=0)
					report LF & 
						"locate_value => close -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					severity note;
				jso_index := jso_index + 1;
			when '}' =>
				assert open_char='{'
					report LF & 
						"locate_value => wrong close key " & ''' & open_char & ''' & " "  & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					severity failure;
				assert ((log/log_locatevalue) mod 2=0)
					report LF & 
						"locate_value => close -> " & natural'image(jso_index) & ':' & character'image(jso(jso_index))
					severity note;
				jso_index := jso_index + 1;
			when others =>
			end case;
			parse_tagvaluekey(jso, jso_index, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
			assert ((log/log_locatevalue) mod 2=0)
				report LF & 
					"locate_value => jso -> " & natural'image(value_offset) & ':' & natural'image(value_offset+value_length-1) & " " & '"' & jso(value_offset to value_offset+value_length-1) & '"'
				severity note;
			if isdigit(tag(tag'left)) then
				if to_natural(tag) <= position then
					assert ((log/log_locatevalue) mod 2=0)
						report LF & 
						"locate_value => tag -> " & natural'image(tag_offset) & ':' & natural'image(tag_offset+tag_length-1) & jso(tag_offset to tag_offset+tag_length-1)
						severity note;
					offset := tag_offset;
					length := jso_index-offset;
					exit;
				end if;
			elsif isalnum(tag(tag'left)) then
				if tag=jso(tag_offset to tag_offset+tag_length-1) then
					offset := tag_offset;
					length := jso_index-offset;
					exit;
				end if;
			end if;
			-- assert ((log/log_locatevalue) mod 2=0)
				-- report LF & 
					-- "locale_value => jso_index end loop-> " & natural'image(jso_index) & " '" &jso(jso_index) & "'"
				-- severity note;
		end loop;
		assert ((log/log_locatevalue) mod 2=0)
			report LF & 
				"locate_value => tag   -> " & natural'image(tag_offset)   & ':' & natural'image(tag_offset+tag_length-1) & '"' & jso(tag_offset   to tag_offset+tag_length-1) & '"' & LF & 
				"locate_value -> value -> " & natural'image(value_offset) & ':' & natural'image(jso_index-1)             & '"' & jso(value_offset to jso_index-1) & '"'
			severity note;
		assert ((log/log_locatevalue) mod 2=0)
			report LF & 
				"locate_value => ^^^^^^^^^^^^^^^^^^^^"
			severity note;
	end;

	procedure resolve (
		constant jso           : in    string;
		variable value_offset  : inout natural;
		variable value_length  : inout natural) is

		variable jso_index     : natural;
		variable key_offset    : natural;
		variable key_length    : natural;
		variable keytag_offset : natural;
		variable keytag_length : natural;
		variable keytag_index  : natural;

		variable jso_offset    : natural;
		variable jso_length    : natural;
		variable tag_offset    : natural;
		variable tag_length    : natural;

	begin
		jso_index := jso'left;
		parse_tagvaluekey (jso, jso_index, tag_offset, tag_length, value_offset, value_length, keytag_offset, keytag_length);
		assert ((log/log_resolve) mod 2=0) 
			report "resolve => keytag -> " & natural'image(keytag_offset) & ":" & natural'image(keytag_length) & ":" & '"' & jso(keytag_offset to keytag_offset+keytag_length-1) & '"' & LF &
			       "resolve => value  -> " & natural'image(value_offset)  & ":" & natural'image(value_length)  & ":" & '"' & jso(value_offset  to value_offset+value_length-1)   & '"' & LF
			severity note;
		if keytag_length/=0 then
			keytag_index := keytag_offset;
			loop
				parse_keytag(jso, keytag_index, tag_offset, tag_length);
				if tag_length=0 then
					exit;
				end if;
				assert ((log/log_resolve) mod 2=0)
					report "resolve => tag         -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ":" & '"' & jso(tag_offset to tag_offset+tag_length-1) & LF &
					       "resolve => jso_index   -> " & natural'image(jso_index)
					severity note;
				locate_value(jso, value_offset, jso(tag_offset to tag_offset+tag_length-1), jso_offset, jso_length);
				assert jso_length/=0
					report "resolve => invalid key -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ":" & '"' & jso(tag_offset to tag_offset+tag_length-1)
					severity failure;
				assert ((log/log_resolve) mod 2=0)
					report "resolve => key         -> " & '"' & natural'image(tag_offset) & ":" & natural'image(tag_length) & jso(tag_offset to tag_offset+tag_length-1) & '"' & LF &
					       "resolve => value       -> " & '"' & natural'image(jso_offset) & ":" & natural'image(jso_length) & jso(jso_offset to jso_offset+jso_length-1) & '"'
					severity note;
				value_offset := jso_offset;
				resolve(jso(jso_offset to jso_offset+jso_length-1), jso_offset, jso_length);
			end loop;
		else
			jso_offset := jso'left;
			jso_length := jso'length;
		end if;
		jso_index := jso_offset;
		parse_tagvaluekey (jso(jso_offset to jso_offset+jso_length-1), jso_index, tag_offset, tag_length, value_offset, value_length, keytag_offset, keytag_length);
	end;

	function resolve (
		constant jso : string)
		return string is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		resolve (jso, jso_offset, jso_length);
		return jso(jso_offset to jso_offset+jso_length-1);
	end;

	function resolve (
		constant jso : string)
		return natural is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		resolve (jso, jso_offset, jso_length);
		return to_natural(jso(jso_offset to jso_offset+jso_length-1));
	end;

	function resolve (
		constant jso : string)
		return boolean is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		resolve (jso, jso_offset, jso_length);
		if jso(jso_offset to jso_offset+jso_length-1)="true" then
			return true;
		else
			return false;
		end if;
	end;

	function "**" (
		constant jso : jso;
		constant key : string)
		return natural is
	begin
		return resolve(string(jso) & key);
	end;

	function "**" (
		constant jso : jso;
		constant key : string)
		return boolean is
	begin
		return resolve(string(jso) & key);
	end;

	function "**" (
		constant obj : jso;
		constant key : string)
		return jso is
	begin
		return resolve(string(obj) & key);
	end;

end;