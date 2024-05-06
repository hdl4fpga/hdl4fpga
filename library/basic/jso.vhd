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

package jso is

	procedure resolve (
		constant jso           : in    string;
		variable value_offset  : inout natural;
		variable value_length  : inout natural);

	function resolve (
		constant jso : string)
		return string;

	function resolve (
		constant jso : string)
		return integer;

	function resolve (
		constant jso : string)
		return boolean;

	subtype jso is string;

	function "**" (
		constant jso : jso;
		constant key : string)
		return boolean;

	function "**" (
		constant jso : jso;
		constant key : string)
		return natural;

	function "**" (
		constant jso : jso;
		constant key : string)
		return real;

	function "**" (
		constant jso : jso;
		constant key : string)
		return std_logic_vector;

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
					end if;
				else
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
		constant jso       : in string;
		constant jso_index : in natural)
		return positive is
		variable retval : natural;
	begin
		for i in jso_index to jso'right loop
			if not isws(jso(i)) then
				return i;
			end if;
		end loop;
		return jso'right+1;
	end;

	procedure skipws (
		constant jso       : in    string;
		variable jso_index : inout natural) is
	begin
		for i in jso'range loop
			if i >= jso_index then 
				if not isws(jso(i)) then
					exit;
				end if;
				jso_index := jso_index + 1;
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
					return;
				else
					jso_index := jso_index + 1;
				end if;
			elsif isalnum(jso(jso_index)) then
				jso_index := jso_index + 1;
			else
				case jso(jso_index) is
				when '-'|'_' =>
					jso_index := jso_index + 1;
				when others =>
					exit;
				end case;
			end if;
		end loop;
		length := jso_index-offset;
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
	end;

	procedure parse_keytag (
		constant jso       : in    string;
		variable jso_index : inout natural;
		variable offset    : inout natural;
		variable length    : inout natural) is
		variable open_char : character;
	begin
		skipws(jso, jso_index);
		length := 0;
		while jso_index <= jso'right loop
			case jso(jso_index) is
			when '['|'{' =>
				open_char := jso(jso_index);
				jso_index := jso_index + 1;
				parse_natural(jso, jso_index, offset, length);
				if length=0 then
					parse_string(jso, jso_index, offset, length);
				end if;
				skipws(jso, jso_index);
				case jso(jso_index) is
				when ']' => 
					jso_index := jso_index + 1;
				when '}' => 
					jso_index := jso_index + 1;
				when others =>
				end case;
				exit;
			when '.' =>
				jso_index := jso_index + 1;
				skipws(jso, jso_index);
				parse_string(jso, jso_index, offset, length);
				jso_index := offset+length;
				exit;
			when others =>
				length := 0;
				exit;
			end case;
		end loop;
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
		variable jso_stptr : positive := jso_stack'left;
		procedure push (
			variable jso_stptr : inout positive;
			constant char : in character) is
		begin
			jso_stack(jso_stptr) := char;
			jso_stptr := jso_stptr + 1;
		end;

		procedure pop (
			variable jso_stptr : inout positive) is
		begin
			jso_stptr := jso_stptr - 1;
		end;

		variable aphos  : boolean := false;
		variable list   : boolean := false;
	begin
		skipws(jso, jso_index);
		offset := jso_index;
		for i in offset to jso'right loop
			if not aphos then
				case jso(jso_index) is
				when '['|'{' =>
					if jso_stptr=jso_stack'left then 
						if offset=jso_index then
							list := true;
						end if;
					end if;
					push(jso_stptr, jso(jso_index));
				when ',' =>
					if jso_stptr=jso_stack'left then
						exit;
					end if;
				when ']' =>
					if jso_stptr/=jso_stack'left then
						pop(jso_stptr);
					else
						exit;
					end if;
				when '}' =>
					if jso_stptr/=jso_stack'left then
						pop(jso_stptr);
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
				if jso_stptr=jso_stack'left then
					exit;
				end if;
			end if;
		end loop;
		length := jso_index-offset;
	end;

	procedure parse_tagvaluekey (
		constant jso          : string; -- Xilinx ISE bug left and right are not sent according slice
		constant jso_left     : natural; -- Xilinx ISE bug. left and right are not sent according slice
		constant jso_right    : natural; -- Xilinx ISE bug. left and right are not sent according slice
		variable jso_index    : inout natural;
		variable tag_offset   : inout natural;
		variable tag_length   : inout natural;
		variable value_offset : inout natural;
		variable value_length : inout natural;
		variable key_offset   : inout natural;
		variable key_length   : inout natural) is
	begin
		parse_string(jso, jso_index, value_offset, value_length);
		skipws(jso, jso_index);
		tag_offset := value_offset;
		tag_length := 0;
		skipws(jso, jso_index);
		if jso_index <= jso_right then
			if value_length=0 then
				tag_length   := 0;
				value_offset := jso_index;
				value_length := jso_right-jso_index+1; 
				parse_value(jso, jso_index, value_offset, value_length);
			elsif jso(jso_index)/=':' then
				tag_length   := 0;
				tag_offset   := value_offset;
			else
				tag_offset   := value_offset;
				tag_length   := value_length;
				jso_index    := jso_index + 1;
				value_offset := jso_index;
				value_length := jso_right-jso_index+1; 
				skipws(jso, jso_index);
				parse_value(jso, jso_index, value_offset, value_length);
			end if;
		else
		end if;
		skipws(jso, jso_index);
		parse_key(jso, jso_index, key_offset, key_length);
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
		parse_tagvaluekey(jso, jso'left, jso'right, jso_index, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
		jso_index := value_offset;
		offset    := tag_offset;
		length    := 0;
		position  := 0;
		while jso_index <= jso'right loop
			skipws(jso, jso_index);
			case jso(jso_index) is
			when '['|'{' =>
				open_char := jso(jso_index);
				jso_index := jso_index + 1;
			when ',' =>
				position  := position + 1;
				jso_index := jso_index + 1;
			when ']' =>
				jso_index := jso_index + 1;
			when '}' =>
				jso_index := jso_index + 1;
			when others =>
			end case;
			parse_tagvaluekey(jso, jso'left, jso'right, jso_index, tag_offset, tag_length, value_offset, value_length, key_offset, key_length);
			if isdigit(tag(tag'left)) then
				if to_natural(tag) <= position then
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
		end loop;
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
		parse_tagvaluekey (jso, jso'left, jso'right, jso_index, tag_offset, tag_length, value_offset, value_length, keytag_offset, keytag_length);
		if keytag_length/=0 then
			keytag_index := keytag_offset;
			loop
				parse_keytag(jso, keytag_index, tag_offset, tag_length);
				if tag_length=0 then
					exit;
				end if;
				locate_value(jso, value_offset, jso(tag_offset to tag_offset+tag_length-1), jso_offset, jso_length);
				value_offset := jso_offset;

				-- resolve(jso(jso_offset to jso_offset+jso_length-1), jso_offset, jso_length);
			end loop;
		else
			jso_offset := jso'left;
			jso_length := jso'length;
		end if;
		jso_index := jso_offset;
		parse_tagvaluekey (jso, jso_offset, jso_offset+jso_length-1, jso_index, tag_offset, tag_length, value_offset, value_length, keytag_offset, keytag_length);
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

	function resolve (
		constant jso : string)
		return integer is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		resolve (jso, jso_offset, jso_length);
		return to_natural(jso(jso_offset to jso_offset+jso_length-1));
	end;

	function resolve (
		constant jso : string)
		return real is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		resolve (jso, jso_offset, jso_length);
		return to_real(jso(jso_offset to jso_offset+jso_length-1));
	end;

	function resolve (
		constant jso : string)
		return std_logic_vector is
		variable jso_offset : natural;
		variable jso_length : natural;
	begin
		resolve (jso, jso_offset, jso_length);
		return to_stdlogicvector(jso(jso_offset to jso_offset+jso_length-1));
	end;

	function "**" (
		constant jso : jso;
		constant key : string)
		return boolean is
	begin
		return resolve(string(jso) & key);
	end;

	function "**" (
		constant jso : jso;
		constant key : string)
		return integer is
		variable xxx : integer;
	begin
		xxx :=  resolve(string(jso) & key);
		return xxx;
	end;

	function "**" (
		constant jso : jso;
		constant key : string)
		return real is
	begin
		return resolve(string(jso) & key);
	end;

	function "**" (
		constant jso : jso;
		constant key : string)
		return std_logic_vector is
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
