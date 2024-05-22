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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

package hdo is

	function compact (
		constant hdo : string)
		return string;

	procedure resolve (
		constant hdo           : in    string;
		variable value_offset  : inout natural;
		variable value_length  : inout natural);

	function resolve (
		constant hdo : string)
		return string;

	function resolve (
		constant hdo : string)
		return integer;

	function resolve (
		constant hdo : string)
		return boolean;

	-- function to_integervector (
		-- constant object : string)
		-- return integer_vector;

	subtype hdo is string;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return boolean;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return natural;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return real;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return std_logic_vector;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return character;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return hdo;

	function escaped (
		constant obj : string)
		return string;

end;

package body hdo is

	constant log_parsestring      : natural := 2**0;
	constant log_parsenatural     : natural := 2**1;
	constant log_parsekeytag      : natural := 2**2;
	constant log_parsekey         : natural := 2**3;
	constant log_parsevalue       : natural := 2**4;
	constant log_parsetagvaluekey : natural := 2**5;
	constant log_locatevalue      : natural := 2**6;
	constant log_resolve          : natural := 2**7;
	constant log                  : natural := 0; --log_parsetagvaluekey + log_resolve; -- + log_locatevalue    + log_parsevalue ;

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
		if character'pos('A') <= character'pos(char) and character'pos(char) <= character'pos('Z') then
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
		case char is
		when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
			return character'pos(char)-character'pos('0');
		when 'A'|'B'|'C'|'D'|'E'|'F' =>
			return character'pos(char)-character'pos('A')+10;
		when 'a'|'b'|'c'|'d'|'e'|'f' =>
			return character'pos(char)-character'pos('A')+10;
		when others =>
			assert false --|
			report "wrong digit " & character'image(char) --|
			severity failure; --|
		end case;
	end;

	function to_natural (
		constant value : string;
		constant base  : natural) 
		return integer is
		variable sign   : integer;
		variable retval : integer;
	begin
		retval := 0;
		sign   := 1;
		for i in value'range loop
			if value(i)/='_' then
				retval := base*retval;
				if character'pos(value(i)) >= character'pos('0') and (character'pos(value(i))-character'pos('0')) <= (base-1) mod 10 then
					retval := (character'pos(value(i))-character'pos('0')) + retval;
				elsif character'pos(value(i)) >= character'pos('a') and (character'pos(value(i))-character'pos('a')) < (base-10) then
					retval := (character'pos(value(i))-character'pos('a')) + 10 + retval;
				elsif character'pos(value(i)) >= character'pos('A') and (character'pos(value(i))-character'pos('A')) < (base-10) then
					retval := (character'pos(value(i))-character'pos('A')) + 10 + retval;
				elsif i=value'left then
					if value(i)='-' then
						sign := -1;
					else
						assert false --|
						report "Wrong number " & character'image(value(i)) & " " & natural'image(base)  & " @ " & value--|
						severity failure; --|
					end if;
				else
					assert false --|
					report "Wrong number " & character'image(value(i)) & " " & natural'image(base) --|
					severity failure; --|
				end if;
			end if;
		end loop;
		return sign*retval;
	end;

	function to_stdlogicvector (
		constant value : string)
		return std_logic_vector is

		function to_bin(
			constant value    : string;
			constant log2base : natural)
			return std_logic_vector is
			variable j        : natural;
			variable retval   : std_logic_vector(0 to log2base*value'length-1);
		begin
			j := value'left;
			for i in retval'range loop
				while value(j)='_' loop
					j := j + 1;
					if j > value'right then
						return retval(0 to i-1);
					end if;
				end loop;
				if (to_integer(value(j))/2**((log2base-1)-i mod log2base)) mod 2=0 then
					retval(i) := '0';
				else
					retval(i) := '1';
				end if;
				if i mod log2base = log2base-1 then
					j := j + 1;
				end if;
				if j > value'right then
					return retval(0 to i);
				end if;
			end loop;
			return retval;
		end;

	begin
		if value'length > 1 then
			if value(value'left)='0' then
				case value(value'left+1) is
				when 'x'|'X' =>
					return to_bin(value(value'left+2 to value'right), 4);
				when 'b'|'B' =>
					return to_bin(value(value'left+2 to value'right), 1);
				when others =>
					return to_bin(value(value'left+1 to value'right), 1);
				end case;
			else
				return to_bin(value, 1);
			end if;
		else
			assert false --|
			report "value'range is nul" --|
			severity failure; --|
		end if;
	end;

	function to_natural (
		constant value : string)
		return integer is
		variable retval : integer;
	begin
		if value'length > 1 then
			if value(value'left)='0' then
				case value(value'left+1) is
				when 'x'|'X' =>
					return to_natural(value(value'left+2 to value'right), 16);
				when 'b'|'B' =>
					return to_natural(value(value'left+2 to value'right), 2);
				when others =>
					return to_natural(value(value'left+1 to value'right), 10);
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
		variable sign : character;
		variable mant : real;
		variable exp  : integer;
	begin
		idx := value'left;
		case value(idx) is
		when '+'|'-' =>
			sign := value(idx);
			idx  := idx + 1;
		when others =>
			sign := '+';
		end case;

		mant := 0.0;
		while idx <= value'right loop
			if value(idx)='.' then
				idx := idx + 1;
				exit;
			end if;
			mant := 10.0*mant + real(character'pos(value(idx))-character'pos('0'));
			idx  := idx + 1;
		end loop;

		exp := 0;
		while idx <= value'right loop
			if value(idx)='e' then
				idx := idx + 1;
				exit;
			end if;
			if not isdigit(value(idx)) then --| Xilinx ISE 14.7 warning complain
				report "wrong character to_real" --|
				severity failure; --|
			end if; --|
			mant := 10.0*mant + real(character'pos(value(idx))-character'pos('0'));
			exp  := exp + 1;
			idx  := idx + 1;
		end loop;
		while exp > 0 loop
			mant := mant / 10.0;
			exp  := exp - 1;
		end loop;

		if sign='-' then
			mant := -mant;
		end if;

		if idx > value'right then
			return mant;
		end if;

		case value(idx) is
		when '+'|'-' =>
			sign := value(idx);
			idx  := idx + 1;
		when others =>
			sign := '+';
		end case;

		exp := 0;
		while idx <= value'right loop
			exp := 10*exp + (character'pos(value(idx))-character'pos('0'));
			idx := idx + 1;
		end loop;
		if sign='-' then
			exp := -exp;
		end if;

		return mant*10.0**exp;
	end;
	
	function skipws (
		constant hdo       : in string;
		constant hdo_index : in natural)
		return positive is
		variable retval : natural;
	begin
		for i in hdo_index to hdo'right loop
			if not isws(hdo(i)) then
				return i;
			end if;
		end loop;
		return hdo'right+1;
	end;

	procedure skipws (
		constant hdo       : in    string;
		variable hdo_index : inout natural) is
	begin
		for i in hdo'range loop
			if i >= hdo_index then 
				if not isws(hdo(i)) then
					exit;
				end if;
				hdo_index := hdo_index + 1;
			end if;
		end loop;
	end;

	procedure parse_string (
		constant hdo       : in    string;
		variable hdo_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable aphos     : boolean := false;
		variable bkslh     : boolean := false;
	begin
		skipws(hdo, hdo_index);
		offset := hdo_index;
		while hdo_index <= hdo'right loop
			if hdo(hdo_index)='\' then
				bkslh := true;
				hdo_index := hdo_index  + 1;
				next;
			elsif (hdo_index-offset)=0 then
				if hdo(hdo_index)=''' then
					aphos     := true;
					hdo_index := hdo_index  + 1;
					offset    := hdo_index;
					next;
				end if;
			end if;
			if not bkslh then
				if aphos then
					if hdo(hdo_index)=''' then
						length    := hdo_index-offset;
						hdo_index := hdo_index + 1;
						assert (log/log_parsestring) mod 2=0 --|note
							report "parse_string => " & '"' & hdo(offset to offset+length-1) & '"' --|note
							severity note; --|note
						return;
					else
						hdo_index := hdo_index + 1;
					end if;
				elsif isalnum(hdo(hdo_index)) then
					hdo_index := hdo_index + 1;
				else
					case hdo(hdo_index) is
					when '-'|'_' =>
						hdo_index := hdo_index + 1;
					when others =>
						exit;
					end case;
				end if;
			else
				hdo_index := hdo_index + 1;
				bkslh := false;
			end if;
		end loop;
		length := hdo_index-offset;
		assert (log/log_parsestring) mod 2=0 --|note
			report "parse_string => " & '"' & hdo(offset to offset+length-1) & '"' --|note
			severity note; --|note
	end;

	procedure parse_natural (
		constant hdo       : in    string;
		variable hdo_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
	begin
		skipws(hdo, hdo_index);
		offset := hdo_index;
		while hdo_index <= hdo'right loop
			if isalnum(hdo(hdo_index)) then
				hdo_index := hdo_index + 1;
			else
				exit;
			end if;
		end loop;
		length := hdo_index-offset;
		assert (log/log_parsenatural) mod 2=0 --|note
			report "parse_string => " & '"' & hdo(offset to offset+length-1) & '"' --|note
			severity note; --|note
	end;

	procedure parse_keytag (
		constant hdo       : in    string;
		variable hdo_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable open_char : character;
	begin
		skipws(hdo, hdo_index);
		assert ((log/log_parsekeytag) mod 2=0) --|note
			report "parse_keytag => hdo_index -> " & natural'image(hdo_index) --|note
			severity note; --|note
		assert ((log/log_parsekeytag) mod 2=0) or hdo_index > hdo'right --|note
			report "parse_keytag => hdo_index -> " & natural'image(hdo_index) & " -> " & ''' & hdo(hdo_index) & ''' --|note
			severity note; --|note
		length := 0;
		while hdo_index <= hdo'right loop
			case hdo(hdo_index) is
			when '['|'{' =>
				open_char := hdo(hdo_index);
				hdo_index := hdo_index + 1;
				parse_natural(hdo, hdo_index, offset, length);
				assert ((log/log_parsekeytag) mod 2=0) or length=0   --|note
				report "parse_keytag => [ is position" --|note
				severity note; --|note
				assert ((log/log_parsekeytag) mod 2=0) or length/=0  --|note
				report "parse_keytag  => [ is string"  --|note
				severity note; --|note
				if length=0 then
					parse_string(hdo, hdo_index, offset, length);
				end if;
				if length=0 then --| Xilinx ISE 14.7 warning complain
					assert false
					report "parse_keytag -> invalid key : " & hdo(hdo_index to hdo'right)  --|
					severity failure; --|
				end if; --|
				assert ((log/log_parsekeytag) mod 2=0) --|note
				report "parse_keytag => " & natural'image(hdo_index) & "->" & ''' & hdo(hdo_index) & ''' --|note
				severity note; --|note
				skipws(hdo, hdo_index);
				case hdo(hdo_index) is
				when ']' => 
					if open_char/='[' then --| Xilinx ISE 14.7 warning complain
						assert false
						report "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & hdo(hdo_index) & ''' --|
						severity failure; --|
					end if; --|
					assert ((log/log_parsekeytag) mod 2=0) --|note
					report "parse_keytag => ]" --|note
					severity note; --|note
					hdo_index := hdo_index + 1;
				when '}' => 
					if open_char/='{' then --| Xilinx ISE 14.7 warning complain
						assert false
						report "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & hdo(hdo_index) & ''' --|
						severity failure; --|
					end if; --|
					assert ((log/log_parsekeytag) mod 2=0) --|note
					report "parse_keytag => }" --|note
					severity note; --|note
					hdo_index := hdo_index + 1;
				when others =>
					assert false --|
					report "parse_keytag => wrong token -> " & hdo(hdo_index) & " @ " & hdo --|
					severity failure; --|
				end case;
				exit;
			when '.' =>
				hdo_index := hdo_index + 1;
				skipws(hdo, hdo_index);
				parse_string(hdo, hdo_index, offset, length);
				if length=0 then --| Xilinx ISE 14.7 warning complain
					assert false
					report "parse_keytag => invalid key : " & hdo(hdo_index to hdo'right) --|
					severity failure; --|
				end if; --|
				hdo_index := offset+length;
				exit;
			when others =>
				length := 0;
				assert ((log/log_parsekeytag) mod 2=0) --|note
					report "parse_keytag => null" --|note
					severity note; --|note
				exit;
			end case;
		end loop;
		assert ((log/log_parsekeytag) mod 2=0) or hdo_index > hdo'right --|note
			report "parse_keytag => key -> " & hdo(offset to offset+length-1) & ' ' & integer'image(offset) & ':' & integer'image(length) --|note
			severity note; --|note
	end;

	procedure parse_key (
		constant hdo        : in string;
		variable hdo_index  : inout natural;
		variable offset     : inout natural;
		variable length     : inout natural) is
		variable tag_offset : natural;
		variable tag_length : natural;
	begin
		skipws(hdo, hdo_index);
		offset := hdo_index;
		assert ((log/log_parsekey) mod 2=0) --|note
			report "parse_key => " & hdo(hdo_index to hdo'right) --|note
			severity note; --|note
		loop
			parse_keytag(hdo, hdo_index, tag_offset, tag_length);
			assert ((log/log_parsekey) mod 2=0) --|note
				report "parse_key => tag -> " & '"' & hdo(tag_offset to tag_offset+tag_length-1) & '"' --|note
				severity note; --|note
			if tag_length=0 then
				length := hdo_index-offset;
				exit;
			end if;
		end loop;
		assert ((log/log_parsekey) mod 2=0) --|note
			report "parse_key => " & '"' & hdo(offset to offset+length-1) & '"' --|note
			severity note; --|note
	end;

	procedure parse_value (
		constant hdo       : in    string;
		variable hdo_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable hdo_stack : string(1 to 32);
		variable hdo_stptr : positive := hdo_stack'left;
		procedure push (
			variable hdo_stptr : inout positive;
			constant char : in character) is
		begin
			hdo_stack(hdo_stptr) := char;
			hdo_stptr := hdo_stptr + 1;
		end;

		procedure pop (
			variable hdo_stptr : inout positive) is
		begin
			hdo_stptr := hdo_stptr - 1;
		end;

		variable aphos  : boolean := false;
		variable bkslh  : boolean := false;
		variable list   : boolean := false;
	begin
		skipws(hdo, hdo_index);
		offset := hdo_index;
		for i in offset to hdo'right loop
			if not aphos and not bkslh then
				case hdo(hdo_index) is
				when '['|'{' =>
					if hdo_stptr=hdo_stack'left then 
						if offset=hdo_index then
							list := true;
							assert ((log/log_parsevalue) mod 2=0) --|note
								report "parse_value => list" --|note
								severity note; --|note
						end if;
					end if;
					push(hdo_stptr, hdo(hdo_index));
				when ',' =>
					if hdo_stptr=hdo_stack'left then
						exit;
					end if;
				when ']' =>
					if hdo_stptr/=hdo_stack'left then
						if hdo_stack(hdo_stptr-1)/='[' then --| Xilinx ISE 14.7 warning complain
							assert false --|
							report "parse_value => close key " & hdo_stack(hdo_stptr-1) & hdo(hdo_index) --|
							severity failure; --|
						end if; --|
						pop(hdo_stptr);
					else
						exit;
					end if;
				when '}' =>
					if hdo_stptr/=hdo_stack'left then
						if hdo_stack(hdo_stptr-1)/='{' then --| Xilinx ISE 14.7 warning complain
							assert false --|
							report "parse_value => close key " & hdo_stack(hdo_stptr-1) & hdo(hdo_index) --|
							severity failure; --|
						end if; --|
						pop(hdo_stptr);
					else
						exit;
					end if;
				when others =>
				end case;
			end if;
			if not bkslh then
				if hdo(hdo_index)='\' then
					bkslh := true;
				elsif hdo(hdo_index)=''' then
					aphos := not aphos;
				end if;
			else
				bkslh := false;
			end if;
			hdo_index := hdo_index + 1;
			if list then
				if hdo_stptr=hdo_stack'left then
					exit;
				end if;
			end if;
		end loop;
		length := hdo_index-offset;
		assert ((log/log_parsevalue) mod 2=0) --|note
			report "parse_value => value -> " &  hdo(offset to offset+length-1) --|note
			severity note; --|note
	end;

	procedure parse_tagvaluekey (
		constant hdo          : string; -- Xilinx ISE bug left and right are not sent according slice
		constant hdo_left     : natural; -- Xilinx ISE bug. left and right are not sent according slice
		constant hdo_right    : natural; -- Xilinx ISE bug. left and right are not sent according slice
		variable hdo_index    : inout natural;
		variable tag_offset   : inout natural;
		variable tag_length   : inout natural;
		variable value_offset : inout natural;
		variable value_length : inout natural;
		variable key_offset   : inout natural;
		variable key_length   : inout natural) is
	begin
		assert ((log/log_parsetagvaluekey) mod 2=0) --|note
			report "parse_tagvaluekey => hdo -> " & '"' & hdo(hdo_index to hdo_right) & '"' --|note
			severity note; --|note
		parse_string(hdo, hdo_index, value_offset, value_length);
		skipws(hdo, hdo_index);
		tag_offset := value_offset;
		tag_length := 0;
		skipws(hdo, hdo_index);
		if hdo_index <= hdo_right then
			if value_length=0 then
				tag_length   := 0;
				value_offset := hdo_index;
				value_length := hdo_right-hdo_index+1; 
				parse_value(hdo, hdo_index, value_offset, value_length);
				assert ((log/log_parsetagvaluekey) mod 2=0) --|note
					report --|note
						"parse_tagvaluekey => no tag" & LF & --|note
						"parse_tagvaluekey => value          -> " & '"' & hdo(value_offset to value_offset+value_length-1) & '"' & LF & --|note
						"parse_tagvaluekey => hdo(hdo_index) -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
					severity note; --|note
			elsif hdo(hdo_index)/=':' then
				assert ((log/log_parsetagvaluekey) mod 2=0) --|note
					report --|note
						"parse_tagvaluekey => tag token not found" & LF & --|note
						"parse_tagvaluekey => value     -> " & '"' & hdo(value_offset to value_offset+value_length-1) & '"' & LF & --|note
						"parse_tagvaluekey => hdo_index -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
					severity note; --|note
				tag_length   := 0;
				tag_offset   := value_offset;
			else
				tag_offset   := value_offset;
				tag_length   := value_length;
				hdo_index    := hdo_index + 1;
				value_offset := hdo_index;
				value_length := hdo_right-hdo_index+1; 
				skipws(hdo, hdo_index);
				parse_value(hdo, hdo_index, value_offset, value_length);
				assert ((log/log_parsetagvaluekey) mod 2=0) --|note
					report LF & --|note
						"parse_tagvaluekey => tag       -> " & '"' & hdo(tag_offset to tag_offset+tag_length-1) & '"' & LF & --|note
						"parse_tagvaluekey => value     -> " & '"' & hdo(value_offset to value_offset+value_length-1) & '"'  --|note
					severity note; --|note
				assert ((log/log_parsetagvaluekey) mod 2=0) or hdo_index <= hdo_right --|note
					report LF & --|note
						"parse_tagvaluekey => hdo_index passed end of the hdo -> " & natural'image(hdo_index) --|note
					severity note; --|note
				assert ((log/log_parsetagvaluekey) mod 2=0) or hdo_index > hdo_right --|note
					report LF & --|note
						"parse_tagvaluekey => hdo(hdo_index) -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
					severity note; --|note
			end if;
		else
			assert ((log/log_parsetagvaluekey) mod 2=0) --|note
				report LF & --|note
					"parse_tagvaluekey => string value -> " & '"' & hdo(value_offset to value_offset+value_length-1) & '"' & LF & --|note
					"parse_tagvaluekey => hdo_index passed end of the hdo -> " & natural'image(hdo_index) --|note
				severity note; --|note
		end if;
		skipws(hdo, hdo_index);
		parse_key(hdo, hdo_index, key_offset, key_length);
		assert ((log/log_parsetagvaluekey) mod 2=0) --|note
			report LF & --|note
				"parse_tagvaluekey => key       -> " & '"' & hdo(key_offset to key_offset+key_length-1) & '"' & LF & --|note
				"parse_tagvaluekey => hdo_index -> " & natural'image(hdo_index) --|note
			severity note; --|note
	end;
		
	procedure locate_value (
		constant hdo          : in    string;
		variable hdo_index    : inout natural;
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
		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF & --|note
				"locaye_value => vvvvvvvvvvvvvvvvvvvv" & LF & --|note
				"locate_value => hdo       -> " & natural'image(hdo_index) & ':' & natural'image(hdo'right) & " " & '"' & hdo(hdo_index to hdo'right) & '"' --|note
			severity note; --|note
		parse_tagvaluekey(hdo, hdo'left, hdo'right, hdo_index, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
		hdo_index := value_offset;
		offset    := tag_offset;
		length    := 0;
		position  := 0;
		while hdo_index <= hdo'right loop
			assert ((log/log_locatevalue) mod 2=0) --|note
				report LF & --|note
					"locale_value.loop => hdo(hdo_index) -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
				severity note; --|note
			skipws(hdo, hdo_index);
			case hdo(hdo_index) is
			when '['|'{' =>
				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF & --|note
						"locate_value => start -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
					severity note; --|note
				open_char := hdo(hdo_index);
				hdo_index := hdo_index + 1;
			when ',' =>
				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF &  --|note
						"locate_value => next position -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
					severity note; --|note
				position  := position + 1;
				hdo_index := hdo_index + 1;
			when ']' =>
				if open_char/='[' then --| Xilinx ISE 14.7 warning complain
					assert false --|
					report LF &  --|
						"locate_value => wrong close key at " & natural'image(hdo_index) & " open with  " & ''' & open_char & ''' & " close by " & character'image(hdo(hdo_index)) --|
					severity failure; --|
				end if; --|
				assert ((log/log_locatevalue) mod 2=0) --|note
				report LF &  --|note
					"locate_value => close -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
				severity note; --|note
				hdo_index := hdo_index + 1;
			when '}' =>
				if open_char/='{' then --| Xilinx ISE 14.7 warning complain
					assert false --|
					report LF &  --|
						"locate_value => wrong close key " & ''' & open_char & ''' & " "  & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|
					severity failure; --|
				end if; --|
				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF &  --|note
						"locate_value => close -> " & natural'image(hdo_index) & ':' & character'image(hdo(hdo_index)) --|note
					severity note; --|note
				hdo_index := hdo_index + 1;
			when others =>
			end case;
			parse_tagvaluekey(hdo, hdo'left, hdo'right, hdo_index, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
			assert ((log/log_locatevalue) mod 2=0) --|note
				report LF &  --|note
					"locate_value => hdo -> " & natural'image(value_offset) & ':' & natural'image(value_offset+value_length-1) & " " & '"' & hdo(value_offset to value_offset+value_length-1) & '"' --|note
				severity note; --|note
			if isdigit(tag(tag'left)) then
				if to_natural(tag) <= position then
					assert ((log/log_locatevalue) mod 2=0) --|note
						report LF &  --|note
						"locate_value => tag -> " & natural'image(tag_offset) & ':' & natural'image(tag_offset+tag_length-1) & hdo(tag_offset to tag_offset+tag_length-1) --|note
						severity note; --|note
					offset := tag_offset;
					length := hdo_index-offset;
					exit;
				end if;
			elsif isalnum(tag(tag'left)) then
				if tag_length/=0 then
					if tag=hdo(tag_offset to tag_offset+tag_length-1) then
						offset := tag_offset;
						length := hdo_index-offset;
						exit;
					end if;
				end if;
			end if;
			assert ((log/log_locatevalue) mod 2=0) --|note
				report LF &  --|note
					"locale_value => hdo_index end loop-> " & natural'image(hdo_index) & " '" &hdo(hdo_index) & "'" --|note
				severity note; --|note
		end loop;
		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF &  --|note
				"locate_value => tag   -> " & natural'image(tag_offset)   & ':' & natural'image(tag_offset+tag_length-1) & '"' & hdo(tag_offset   to tag_offset+tag_length-1) & '"' & LF &  --|note
				"locate_value -> value -> " & natural'image(value_offset) & ':' & natural'image(hdo_index-1)             & '"' & hdo(value_offset to hdo_index-1) & '"' --|note
			severity note; --|note
		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF &  --|note
				"locate_value => ^^^^^^^^^^^^^^^^^^^^" --|note
			severity note; --|note
	end;

	function compact (
		constant hdo : string)
		return string is
		variable retval : string(1 to hdo'length);
		variable escape : boolean;
		variable bkslh  : boolean;
		variable j      : positive;
	begin
		bkslh  := false;
		escape := false;
		j      := retval'left;
		for i in hdo'range loop
			if bkslh then
				retval(j) := hdo(i);
				j := j + 1;
			elsif escape then
				retval(j) := hdo(i);
				j := j + 1;
			elsif not isws(hdo(i)) then
				retval(j) := hdo(i);
				j := j + 1;
			end if;
			if bkslh then
				bkslh := false;
			elsif hdo(i)='\' then
				bkslh := true;
			elsif hdo(i)=''' or hdo(i)='"' then
				escape := not escape;
			end if;
		end loop;
		return retval(1 to j-1);
	end;

	procedure resolve (
		constant hdo           : in    string;
		variable value_offset  : inout natural;
		variable value_length  : inout natural) is

		variable hdo_index     : natural;
		variable key_offset    : natural;
		variable key_length    : natural;
		variable keytag_offset : natural;
		variable keytag_length : natural;
		variable keytag_index  : natural;

		variable hdo_offset    : natural;
		variable hdo_length    : natural;
		variable tag_offset    : natural;
		variable tag_length    : natural;

	begin
		hdo_index := hdo'left;
		parse_tagvaluekey (hdo, hdo'left, hdo'right, hdo_index, tag_offset, tag_length, value_offset, value_length, keytag_offset, keytag_length);
		assert ((log/log_resolve) mod 2=0)  --|note
			report "resolve => keytag -> " & natural'image(keytag_offset) & ":" & natural'image(keytag_length) & ":" & '"' & hdo(keytag_offset to keytag_offset+keytag_length-1) & '"' & LF & --|note
			       "resolve => value  -> " & natural'image(value_offset)  & ":" & natural'image(value_length)  & ":" & '"' & hdo(value_offset  to value_offset+value_length-1)   & '"' & LF --|note
			severity note; --|note
		if keytag_length/=0 then
			keytag_index := keytag_offset;
			loop
				parse_keytag(hdo, keytag_index, tag_offset, tag_length);
				if tag_length=0 then
					exit;
				end if;
				assert ((log/log_resolve) mod 2=0) --|note
					report "resolve => tag         -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ":" & '"' & hdo(tag_offset to tag_offset+tag_length-1) & LF & --|note
					       "resolve => hdo_index   -> " & natural'image(hdo_index) --|note
					severity note; --|note
				locate_value(hdo, value_offset, hdo(tag_offset to tag_offset+tag_length-1), hdo_offset, hdo_length);
				if hdo_length=0 then --| Xilinx ISE 14.7 warning complain
					assert false --|
					report "resolve => invalid key -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ":" & '"' & hdo(tag_offset to tag_offset+tag_length-1) & '"' & LF & --|
					hdo --|
					severity failure; --|
				end if; --|
				assert ((log/log_resolve) mod 2=0) --|note
				report LF & --|note
					"resolve => key         -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ' ' & '"' & hdo(tag_offset to tag_offset+tag_length-1) & '"' & LF & --|note
				    "resolve => value       -> " & natural'image(hdo_offset) & ":" & natural'image(hdo_length) & ' ' & '"' & hdo(hdo_offset to hdo_offset+hdo_length-1) & '"' --|note
				severity note; --|note
				value_offset := hdo_offset;
				-- resolve(hdo(hdo_offset to hdo_offset+hdo_length-1), hdo_offset, hdo_length);
			end loop;
		else
			hdo_offset := hdo'left;
			hdo_length := hdo'length;
		end if;
		hdo_index := hdo_offset;
		parse_tagvaluekey (hdo, hdo_offset, hdo_offset+hdo_length-1, hdo_index, tag_offset, tag_length, value_offset, value_length, keytag_offset, keytag_length);
		assert ((log/log_resolve) mod 2=0) --|note
			report LF & --|note
				"resolve => tag   -> " & natural'image(tag_offset)   & ":" & natural'image(tag_length)   & ' ' & '"' & hdo(tag_offset   to tag_offset+tag_length-1)     & '"' & LF & --|note
				"resolve => value -> " & natural'image(value_offset) & ":" & natural'image(value_length) & ' ' & '"' & hdo(value_offset to value_offset+value_length-1) & '"' & LF & --|note
				"resolve => key   -> " & natural'image(key_offset)   & ":" & natural'image(key_length)   & ' ' & '"' & hdo(key_offset   to key_offset+key_length-1)     & '"' & LF --|note
			severity note; --|note
	end;

	function resolve (
		constant hdo : string)
		return string is
		variable hdo_offset : natural;
		variable hdo_length : natural;
	begin
		resolve (hdo, hdo_offset, hdo_length);
		return hdo(hdo_offset to hdo_offset+hdo_length-1);
	end;

	function resolve (
		constant hdo : string)
		return boolean is
		variable hdo_offset : natural;
		variable hdo_length : natural;
	begin
		resolve (hdo, hdo_offset, hdo_length);
		if hdo(hdo_offset to hdo_offset+hdo_length-1)="true" then
			return true;
		else
			return false;
		end if;
	end;

	function resolve (
		constant hdo : string)
		return integer is
		variable hdo_offset : natural;
		variable hdo_length : natural;
	begin
		resolve (hdo, hdo_offset, hdo_length);
		return to_natural(hdo(hdo_offset to hdo_offset+hdo_length-1));
	end;

	function resolve (
		constant hdo : string)
		return real is
		variable hdo_offset : natural;
		variable hdo_length : natural;
	begin
		resolve (hdo, hdo_offset, hdo_length);
		return to_real(hdo(hdo_offset to hdo_offset+hdo_length-1));
	end;

	function resolve (
		constant hdo : string)
		return std_logic_vector is
		variable hdo_offset : natural;
		variable hdo_length : natural;
	begin
		resolve (hdo, hdo_offset, hdo_length);
		return to_stdlogicvector(hdo(hdo_offset to hdo_offset+hdo_length-1));
	end;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return boolean is
	begin
		return resolve(string(hdo) & key);
	end;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return integer is
		variable xxx : integer;
	begin
		xxx :=  resolve(string(hdo) & key);
		return xxx;
	end;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return real is
	begin
		return resolve(string(hdo) & key);
	end;

	function "**" (
		constant hdo : hdo;
		constant key : string)
		return std_logic_vector is
	begin
		return resolve(string(hdo) & key);
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return character is
		constant retval : string := resolve(string(obj) & key);
	begin
		if retval(retval'left)='\' then
			return retval(retval'left+1);
		end if;
		return retval(retval'left);
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return hdo is
	begin
		return resolve(string(obj) & key);
	end;

	function escaped (
		constant obj : string)
		return string is
		variable length : natural;
		variable retval : string(1 to obj'length);
		variable escape : boolean;
		variable bkslh  : boolean;
	begin
		length := 0;
		escape := false;
		bkslh  := false;
		for i in obj'range loop
			if bkslh then
				retval(retval'left+length) := obj(i);
				length := length + 1;
			elsif escape then
				if not (obj(i)=''' or obj(i)='"' or obj(i)='\') then
					retval(retval'left+length) := obj(i);
					length := length + 1;
				end if;
			elsif not (obj(i)=''' or obj(i)='"' or obj(i)='\' or isws(obj(i))) then
				retval(retval'left+length) := obj(i);
				length := length + 1;
			end if;
			if bkslh then
				bkslh := false;
			elsif obj(i)='\' then
				bkslh := true;
			elsif obj(i)=''' or obj(i)='"' then
				escape := not escape;
			end if;
		end loop;
		if length/=0 then
			return retval(retval'left to retval'left+length-1);
		else
			return "";
		end if;
	end;

end;