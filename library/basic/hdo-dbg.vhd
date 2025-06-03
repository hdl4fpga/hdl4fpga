-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hdo is
	function compact (
		constant obj : string)
		return string;

	procedure resolve (
		constant obj          : in    string;
		variable value_offset : inout positive;
		variable value_length : inout natural;
		variable tag1_offset  : inout positive;
		variable tag1_length  : inout natural);

	function resolve (
		constant obj : string)
		return string;

	function resolve (
		constant obj : string)
		return integer;

	function resolve (
		constant obj : string)
		return boolean;

	subtype hdo is string;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return boolean;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return integer;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return real;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return std_ulogic;

	function "**" (
		constant obj : hdo;
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

	function to_integer (
		constant value : string)
		return integer;

	function tag (
		constant obj : hdo)
		return string;

	procedure escaped (
		variable retval : inout string;
		variable length : inout natural;
		constant obj    : in    string);

	function escaped (
		constant obj : string)
		return string;

	function to_stdulogic (
		constant value : character)
		return std_ulogic;

	function to_stdlogicvector (
		constant value : string)
		return std_logic_vector;
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
	constant log                  : natural := log_parsetagvaluekey + log_resolve + log_locatevalue + log_parsekeytag + log_parsekey; --    + log_parsevalue ;

	function unsigned_num_bits (
		arg: natural)
		return natural is
		variable nbits: natural;
		variable n: natural;
	begin
		n := arg;
		nbits := 1;
		for i in 0 to n loop          -- to avoid synthesizes tools loop-warnings
			exit when n < 2;          -- to avoid synthesizes tools loop-warnings
			nbits := nbits+1;
			n := n / 2;
		end loop;
		return nbits;
	end;

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
			assert false 
			report LF & "wrong digit " & character'image(char)
			severity failure;
			return -1;
		end case;
	end;

	function to_integer (
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
							report LF & "Wrong number " & character'image(value(i)) & " " & natural'image(base)  & " @ " & value--|
							severity failure; --|
					end if;
				else
					assert false --|
						report LF & "Wrong number " & character'image(value(i)) & " " & natural'image(base) --|
						severity failure; --|
				end if;
			end if;
		end loop;
		return sign*retval;
	end;

	function to_stdulogic (
		constant value : character)
		return std_ulogic is
	begin
		if value='1' then
			return '1';
		else
			return '0';
		end if;
	end;

	function to_stdlogicvector (
		constant char : character;
		constant base : natural)
		return std_logic_vector is
		constant log2base : natural := unsigned_num_bits(base-1);
	begin
		case char is
		when '-' =>
			return (0 to log2base-1 => '-');
		when 'Z' =>
			return (0 to log2base-1 => 'Z');
		when 'X' =>
			return (0 to log2base-1 => 'X');
		when others =>
			return std_logic_vector(to_unsigned(to_integer(char), log2base));
		end case;
	end;

	function to_stdlogicvector (
		constant value : string)
		return std_logic_vector is

		function to_bin(
			constant value : string;
			constant base  : natural)
			return std_logic_vector is
			constant log2base : natural := unsigned_num_bits(base-1);
			variable n        : natural;
			variable retval   : std_logic_vector(0 to log2base*value'length-1);
		begin
			n := value'left;
			for i in 0 to value'length-1 loop
				for l in value'range loop -- avoid synthesizes tools loop-warnings
					exit when value(n)/='_'; -- avoid synthesizes tools loop-warnings

					n := n + 1;
					if n > value'right then
						return retval(0 to i*log2base-1);
					end if;
				end loop;
				retval(i*log2base to (i+1)*log2base-1) := to_stdlogicvector(value(n), base);
				n := n + 1;
				if n > value'right then
					return retval(0 to (i+1)*log2base-1);
				end if;
			end loop;
			return retval;
		end;

	begin
		if value'length > 1 then
			if value(value'left)='0' then
				case value(value'left+1) is
				when 'x'|'X' =>
					return to_bin(value(value'left+2 to value'right), 16);
				when 'b'|'B' =>
					return to_bin(value(value'left+2 to value'right),  2);
				when others =>
					return to_bin(value(value'left   to value'right),  2);
				end case;
			else
				return to_bin(value, 2);
			end if;
		elsif value'length > 0 then
			return to_bin(value(value'left to value'right), 2);
		else
			assert false --|
				report LF & "value'range is nul" --|
				severity failure; --|
			return "X";
		end if;
	end;

	function to_integer (
		constant value : string)
		return integer is
		variable retval : integer;
	begin
		if value'length > 1 then
			if value(value'left)='0' then
				case value(value'left+1) is
				when 'x'|'X' =>
					return to_integer(value(value'left+2 to value'right), 16);
				when 'b'|'B' =>
					return to_integer(value(value'left+2 to value'right),  2);
				when others =>
					return to_integer(value(value'left+1 to value'right), 10);
				end case;
			else
				return to_integer(value, 10);
			end if;
		else
			return to_integer(value, 10);
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
		for l in value'range loop -- avoid synthesizes tools loop-warnings
			exit when idx > value'right; -- avoid synthesizes tools loop-warnings

			if value(idx)='.' then
				idx := idx + 1;
				exit;
			end if;
			mant := 10.0*mant + real(character'pos(value(idx))-character'pos('0'));
			idx  := idx + 1;
		end loop;

		exp := 0;
		for l in value'range loop -- avoid synthesizes tools loop-warnings
			exit when idx > value'right; -- avoid synthesizes tools loop-warnings

			if value(idx)='e' then
				idx := idx + 1;
				exit;
			end if;
			if not isdigit(value(idx)) then --| Xilinx ISE 14.7 warning complain
				report LF & "wrong character to_real" --|
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
		for l in value'range loop           -- avoid synthesizes tools loop-warnings
			exit when idx > value'right;    -- avoid synthesizes tools loop-warnings

			exp := 10*exp + (character'pos(value(idx))-character'pos('0'));
			idx := idx + 1;
		end loop;
		if sign='-' then
			exp := -exp;
		end if;

		return mant*10.0**exp;
	end;
	
	function skipws (
		constant obj       : in string;
		constant obj_index : in positive)
		return positive is
		variable retval : natural;
	begin
		for i in obj_index to obj'right loop
			if not isws(obj(i)) then
				return i;
			end if;
		end loop;
		return obj'right+1;
	end;

	procedure skipws (
		constant obj       : in    string;
		variable obj_index : inout positive) is
	begin
		for i in obj'range loop
			if i >= obj_index then 
				if not isws(obj(i)) then
					exit;
				end if;
				obj_index := obj_index + 1;
			end if;
		end loop;
	end;

	procedure parse_string (
		constant obj       : in    string;
		variable obj_index : inout positive;
		variable offset    : inout positive;
		variable length    : inout natural) is
		variable aphos     : boolean := false;
		variable bkslh     : boolean := false;
	begin

		skipws(obj, obj_index);
		offset := obj_index;
		for l in obj'range loop -- avoid synthesizes tools loop-warnings
			exit when obj_index > obj'right; -- avoid synthesizes tools loop-warnings

			if obj(obj_index)='\' then
				bkslh := true;
				next;
			elsif (obj_index-offset)=0 then
				if obj(obj_index)=''' then
					aphos     := true;
					offset    := obj_index;
					obj_index := obj_index + 1;
					next;
				end if;
			end if;
			if not bkslh then
				if aphos then
					if obj(obj_index)=''' then
						obj_index := obj_index + 1;
						assert (log/log_parsestring) mod 2=0 --|note
							report LF & "parse_string => " & '"' & obj(offset to offset+length-1) & '"' --|note
							severity note; --|note
						exit;
					else
						obj_index := obj_index + 1;
					end if;
				elsif isalnum(obj(obj_index)) then
					obj_index := obj_index + 1;
				else
					case obj(obj_index) is
					when '-'|'_' =>
						obj_index := obj_index + 1;
					when others =>
						exit;
					end case;
				end if;
			else
				obj_index := obj_index + 1;
				bkslh := false;
			end if;
		end loop;
		length := obj_index-offset;
		assert (log/log_parsestring) mod 2=0 --|note
			report LF & "parse_string => " & '"' & obj(offset to offset+length-1) & '"' --|note
			severity note; --|note
	end;

	function compare_string (
		constant arg1 : string;
		constant arg2 : string)
		return boolean is
		constant esc1 : string := escaped(arg1);
		constant esc2 : string := escaped(arg2);
	begin
		if esc1'length=esc2'length then
			if esc1=esc2 then
				return true;
			end if;
		end if;
		return false;
	end;

	procedure parse_natural (
		constant obj       : in    string;
		variable obj_index : inout positive;
		variable offset    : inout positive;
		variable length    : inout natural) is
	begin
		skipws(obj, obj_index);
		offset := obj_index;
		for l in obj'range loop -- avoid synthesizes tools loop-warnings
			exit when obj_index > obj'right; -- avoid synthesizes tools loop-warnings

			if isalnum(obj(obj_index)) then
				obj_index := obj_index + 1;
			else
				exit;
			end if;
		end loop;
		length := obj_index-offset;
		assert (log/log_parsenatural) mod 2=0 --|note
			report "LF & parse_string => " & '"' & obj(offset to offset+length-1) & '"' --|note
			severity note; --|note
	end;

	procedure parse_keytag (
		constant obj       : in    string;
		variable obj_index : inout positive;
		variable offset    : inout positive;
		variable length    : inout natural) is
		variable open_char : character;
	begin
		skipws(obj, obj_index);

		assert ((log/log_parsekeytag) mod 2=0) --|note
			report LF & "parse_keytag => obj_index -> " & natural'image(obj_index) --|note
			severity note; --|note

		assert ((log/log_parsekeytag) mod 2=0) or obj_index > obj'right --|note
			report LF & "parse_keytag => obj_index -> " & natural'image(obj_index) & " -> " & ''' & obj(obj_index) & ''' --|note
			severity note; --|note

		length := 0;
		for l in obj'range loop -- avoid synthesizes tools loop-warnings
			exit when obj_index > obj'right; -- avoid synthesizes tools loop-warnings

			case obj(obj_index) is
			when '['|'{' =>
				open_char := obj(obj_index);
				obj_index := obj_index + 1;
				parse_string(obj, obj_index, offset, length);

				assert ((log/log_parsekeytag) mod 2=0) or length=0   --|note
					report LF & "parse_keytag => [ is position" --|note
					severity note; --|note

				assert ((log/log_parsekeytag) mod 2=0) or length/=0  --|note
					report LF & "parse_keytag  => [ is string"  --|note
					severity note; --|note

				if length=0 then
					assert false --|
						report LF & "parse_keytag -> invalid key : " & obj(obj_index to obj'right)  --|
						severity failure; --|
				end if;

				assert ((log/log_parsekeytag) mod 2=0) --|note
					report LF & "parse_keytag => " & natural'image(obj_index) & "->" & ''' & obj(obj_index) & ''' --|note
					severity note; --|note

				skipws(obj, obj_index);
				case obj(obj_index) is
				when ']' => 
					if open_char/='[' then --| Xilinx ISE 14.7 warning complain
						assert false --|
							report LF & "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & obj(obj_index) & ''' --|
							severity failure; --|
					end if; --|

					assert ((log/log_parsekeytag) mod 2=0) --|note
						report LF & "parse_keytag => ]" --|note
						severity note; --|note
					obj_index := obj_index + 1;
				when '}' => 

					if open_char/='{' then --| Xilinx ISE 14.7 warning complain
						assert false --|
							report LF & "parse_keytag => wrong close key " & ''' & open_char & ''' & " " & ''' & obj(obj_index) & ''' --|
							severity failure; --|
					end if; --|

					assert ((log/log_parsekeytag) mod 2=0) --|note
						report LF & "parse_keytag => }" --|note
						severity note; --|note

					obj_index := obj_index + 1;
				when others =>
					assert false --|
						report LF & "parse_keytag => wrong token -> " & obj(obj_index) & " @ " & obj --|
						severity failure; --|
				end case;
				exit;
			when '.' =>
				obj_index := obj_index + 1;
				skipws(obj, obj_index);
				parse_string(obj, obj_index, offset, length);
				if length=0 then --|note Xilinx ISE 14.7 warning complain
					assert false --|note
						report LF & "parse_keytag => null key : " & obj(obj_index to obj'right) --|note
						severity note; --|note
				end if; --|note
				obj_index := offset+length;
				exit;
			when others =>
				length := 0;
				assert ((log/log_parsekeytag) mod 2=0) --|note
					report LF & "parse_keytag => null" --|note
					severity note; --|note
				exit;
			end case;
		end loop;

		assert ((log/log_parsekeytag) mod 2=0) or obj_index > obj'right --|note
			report LF & "parse_keytag => key -> " & '"' & obj(offset to offset+length-1) & '"' & ' ' & integer'image(offset) & ':' & integer'image(length) --|note
			severity note; --|note
	end;

	procedure parse_key (
		constant obj        : in    string;
		variable obj_index  : inout natural;
		variable offset     : inout positive;
		variable length     : inout natural) is
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		skipws(obj, obj_index);
		offset := obj_index;
		assert ((log/log_parsekey) mod 2=0) --|note
			report LF & "parse_key => obj : " & '"' & obj(obj_index to obj'right)  & '"'--|note
			severity note; --|note
		for i in obj'range loop
			parse_keytag(obj, obj_index, tag_offset, tag_length);
			assert ((log/log_parsekey) mod 2=0) --|note
				report LF & "parse_key => tag -> " & '"' & obj(tag_offset to tag_offset+tag_length-1) & '"' --|note
				severity note; --|note
			if tag_length=0 then
				length := obj_index-offset;
				exit;
			end if;
		end loop;
		assert ((log/log_parsekey) mod 2=0) --|note
			report LF & "parse_key => " & '"' & obj(offset to offset+length-1) & '"' --|note
			severity note; --|note
	end;

	procedure parse_value (
		constant obj       : in    string;
		variable obj_index : inout positive;
		variable offset    : inout positive;
		variable length    : inout natural) is
		variable obj_stack : string(1 to 32);
		variable obj_stptr : positive := obj_stack'left;
		procedure push (
			variable obj_stptr : inout positive;
			constant char : in character) is
		begin
			obj_stack(obj_stptr) := char;
			obj_stptr := obj_stptr + 1;
		end;

		procedure pop (
			variable obj_stptr : inout positive) is
		begin
			obj_stptr := obj_stptr - 1;
		end;

		variable aphos  : boolean := false;
		variable bkslh  : boolean := false;
		variable list   : boolean := false;
	begin
		skipws(obj, obj_index);
		offset := obj_index;
		for i in offset to obj'right loop
			if not aphos and not bkslh then
				case obj(obj_index) is
				when '['|'{' =>
					if obj_stptr=obj_stack'left then 
						if offset=obj_index then
							list := true;
							assert ((log/log_parsevalue) mod 2=0) --|note
								report LF & "parse_value => list" --|note
								severity note; --|note
						end if;
					end if;
					push(obj_stptr, obj(obj_index));
				when ',' =>
					if obj_stptr=obj_stack'left then
						exit;
					end if;
				when ']' =>
					if obj_stptr/=obj_stack'left then
						if obj_stack(obj_stptr-1)/='[' then --| Xilinx ISE 14.7 warning complain
							assert false --|
							report LF & "parse_value => close key " & obj_stack(obj_stptr-1) & obj(obj_index) --|
							severity failure; --|
						end if; --|
						pop(obj_stptr);
					else
						exit;
					end if;
				when '}' =>
					if obj_stptr/=obj_stack'left then
						if obj_stack(obj_stptr-1)/='{' then --| Xilinx ISE 14.7 warning complain
							assert false --|
							report LF & "parse_value => close key " & obj_stack(obj_stptr-1) & obj(obj_index) --|
							severity failure; --|
						end if; --|
						pop(obj_stptr);
					else
						exit;
					end if;
				when others =>
				end case;
			end if;
			if not bkslh then
				if obj(obj_index)='\' then
					bkslh := true;
				elsif obj(obj_index)=''' then
					aphos := not aphos;
				end if;
			else
				bkslh := false;
			end if;
			obj_index := obj_index + 1;
			if list then
				if obj_stptr=obj_stack'left then
					exit;
				end if;
			end if;
		end loop;
		length := obj_index-offset;
		assert ((log/log_parsevalue) mod 2=0) --|note
			report LF & "parse_value => value -> " &  obj(offset to offset+length-1) --|note
			severity note; --|note
	end;

	procedure parse_tagvaluekey (
		constant obj          : string;  -- Xilinx ISE bug left and right are not sent according slice
		variable obj_index    : inout positive;
		constant obj_right    : positive; -- Xilinx ISE bug. left and right are not sent according slice
		variable tag_offset   : inout positive;
		variable tag_length   : inout natural;
		variable value_offset : inout positive;
		variable value_length : inout natural;
		variable key_offset   : inout positive;
		variable key_length   : inout natural) is
	begin
		assert ((log/log_parsetagvaluekey) mod 2=0) --|note
			report LF & "parse_tagvaluekey => obj -> " & '"' & obj(obj_index to obj'right) & '"' & --|note
			       LF & "parse_tagvaluekey => obj_index -> " & '"' & natural'image(obj_index) & '"' & --|note
			       LF & "parse_tagvaluekey => obj_right -> " & '"' & natural'image(obj_right) & '"' --|note
			severity note; --|note
		parse_string(obj, obj_index, value_offset, value_length);
		skipws(obj, obj_index);
		tag_offset := value_offset;
		tag_length := 0;
		if obj_index <= obj'right then
			if value_length=0 then
				tag_length   := 0;
				value_offset := obj_index;
				value_length := obj'right-obj_index+1; 
				parse_value(obj, obj_index, value_offset, value_length);
				if obj_index > obj'right then --|note
					assert ((log/log_parsetagvaluekey) mod 2=0) --|note
						report LF & --|note
							"parse_tagvaluekey => no tag" & LF & --|note
							"parse_tagvaluekey => value          -> " & '"' & obj(value_offset to value_offset+value_length-1) & '"' & LF & --|note
							"parse_tagvaluekey => obj(obj_index) -> " & natural'image(obj_index) & ':' & "EOF" --|note
						severity note; --|note
				else --|note
					assert ((log/log_parsetagvaluekey) mod 2=0) --|note
						report LF & --|note
							"parse_tagvaluekey => no tag" & LF & --|note
							"parse_tagvaluekey => value          -> " & '"' & obj(value_offset to value_offset+value_length-1) & '"' & LF & --|note
							"parse_tagvaluekey => obj(obj_index) -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
						severity note; --|note
				end if; --|note
			elsif obj(obj_index)/=':' then
				assert ((log/log_parsetagvaluekey) mod 2=0) --|note
					report LF & --|note
						"parse_tagvaluekey => tag token not found" & LF & --|note
						"parse_tagvaluekey => value     -> " & '"' & obj(value_offset to value_offset+value_length-1) & '"' & LF & --|note
						"parse_tagvaluekey => obj_index -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
					severity note; --|note
				tag_length   := 0;
				tag_offset   := value_offset;
			else
				tag_offset   := value_offset;
				tag_length   := value_length;
				obj_index    := obj_index + 1;
				value_offset := obj_index;
				value_length := obj'right-obj_index+1; 
				skipws(obj, obj_index);
				parse_value(obj, obj_index, value_offset, value_length);
				assert ((log/log_parsetagvaluekey) mod 2=0) --|note
					report LF & --|note
						"parse_tagvaluekey => tag   -> " & '"' & obj(tag_offset to tag_offset+tag_length-1) & '"' & LF & --|note
						"parse_tagvaluekey => value -> " & '"' & obj(value_offset to value_offset+value_length-1) & '"'  --|note
					severity note; --|note
				assert ((log/log_parsetagvaluekey) mod 2=0) or obj_index <= obj'right --|note
					report LF & "parse_tagvaluekey => obj_index passed end of the obj -> " & natural'image(obj_index) --|note
					severity note; --|note
				assert ((log/log_parsetagvaluekey) mod 2=0) or obj_index > obj'right --|note
					report LF & "parse_tagvaluekey => obj(obj_index) -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
					severity note; --|note
			end if;
		else
			assert ((log/log_parsetagvaluekey) mod 2=0) --|note
				report LF & --|note
					"parse_tagvaluekey => string value -> " & '"' & obj(value_offset to value_offset+value_length-1) & '"' & LF & --|note
					"parse_tagvaluekey => obj_index passed end of the obj -> " & natural'image(obj_index) --|note
				severity note; --|note
		end if;
		skipws(obj, obj_index);
		parse_key(obj, obj_index, key_offset, key_length);
		assert ((log/log_parsetagvaluekey) mod 2=0) --|note
			report LF & --|note
				"parse_tagvaluekey => key       -> " & '"' & obj(key_offset to key_offset+key_length-1) & '"' & LF & --|note
				"parse_tagvaluekey => obj_index -> " & natural'image(obj_index) --|note
			severity note; --|note
	end;
		
	procedure parse_tagvaluekeydefault (
		constant obj            : in    string; -- Xilinx ISE bug left and right are not sent according slice
		variable obj_index      : inout positive;
		constant obj_right      : in    positive; -- Xilinx ISE bug. left and right are not sent according slice
		variable tag_offset     : inout positive;
		variable tag_length     : inout natural;
		variable value_offset   : inout positive;
		variable value_length   : inout natural;
		variable key_offset     : inout positive;
		variable key_length     : inout natural;
		variable default_offset : inout positive;
		variable default_length : inout natural) is
	begin
		parse_tagvaluekey(
			obj, obj_index, obj_right, 
			tag_offset,   tag_length, 
			value_offset, value_length, 
			key_offset,   key_length);

		-- skipws(obj, obj_index);
		if key_length/=0 then
			if obj'right >= obj_index then
				if obj(obj_index)='=' then
					default_offset := obj_index+1;
					-- default_length := obj_right-obj_index;
					default_length := obj'right-obj_index;
					assert false --|note
					report LF & "parse_tagvaluekeydefault => default " & natural'image(default_offset) & ':' & natural'image(default_length) & " -> " & obj(default_offset to default_offset+default_length-1) --|note
					severity note; --|note
				end if;
			end if;
		end if;
	end;

	procedure locate_value (
		constant obj            : in    string;
		variable obj_index      : inout positive;
		constant key_left       : in    positive;
		constant key_right      : in    positive;
		variable tag_offset     : inout positive;
		variable tag_length     : inout natural;
		variable offset         : inout positive;
		variable length         : inout natural) is
		variable key_offset     : positive;
		variable key_length     : natural;
		variable value_offset   : positive;
		variable value_length   : natural;
		variable default_offset : positive;
		variable default_length : natural;
		variable position       : natural;
		variable open_char      : character;
		variable opened         : boolean;
	begin

		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF & "locate_value => vvvvvvvvvvvvvvvvvvvv" --|note
			severity note; --|note

		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF & "locate_value => obj -> " & natural'image(obj_index) & ':' & natural'image(obj'right) & " " & '"' & obj(obj_index to obj'right) & '"' --|note
			severity note; --|note

		parse_tagvaluekeydefault(
			obj, obj_index,  obj'right,
			tag_offset,     tag_length, 
			value_offset,   value_length, 
			key_offset,     key_length, 
			default_offset, default_length);

		obj_index := value_offset;
		offset    := tag_offset;
		length    := 0;
		position  := 0;
		opened    := false;

		for l in obj'range loop -- avoid synthesizes tools loop-warnings
			exit when obj_index > obj'right; -- avoid synthesizes tools loop-warnings
		
			assert ((log/log_locatevalue) mod 2=0) --|note
				report LF & "locale_value.loop => obj(obj_index) -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
				severity note; --|note

			skipws(obj, obj_index);
			case obj(obj_index) is
			when '['|'{' =>
				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF & "locate_value => start -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
					severity note; --|note

				open_char := obj(obj_index);
				opened    := true;
				obj_index := obj_index + 1;
			when ',' =>
				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF & "locate_value => next position -> [" & natural'image(position+1) & "] -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
					severity note; --|note

				position  := position + 1;
				obj_index := obj_index + 1;
			when ']' =>
				if not opened then
					assert false --|note
						report LF & "locate_value => close " & character'image(obj(obj_index)) & " key at " & natural'image(obj_index) --|note
						severity note; --|note

					return;
				end if;
				if open_char/='[' then --| Xilinx ISE 14.7 warning complain
					assert false --| Xilinx ISE 14.7 warning complain
						report LF &  "locate_value => wrong close key at " & natural'image(obj_index) & " open with  " & ''' & open_char & ''' & " close by " & character'image(obj(obj_index)) & " -> " & obj(obj_index to obj'right) --|
						severity failure; --|
				end if; --|

				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF &  "locate_value => close -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
					severity note; --|note

				opened    := false;
				obj_index := obj_index + 1;
				exit;
			when '}' =>
				if not opened then
					assert false --|note
						report LF & "locate_value => close " & character'image(obj(obj_index)) & " key at " & natural'image(obj_index) --|note
						severity note; --|note
					return;
				end if;
				if open_char/='{' then --| Xilinx ISE 14.7 warning complain
					assert false --| Xilinx ISE 14.7 warning complain
						report LF & "locate_value => wrong close key at " & natural'image(obj_index) & " open with  " & ''' & open_char & ''' & " close by " & character'image(obj(obj_index)) & LF & obj(obj_index to obj'right) --|
						severity failure; --|
				end if; --|

				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF & "locate_value => close -> " & natural'image(obj_index) & ':' & character'image(obj(obj_index)) --|note
					severity note; --|note

				opened    := false;
				obj_index := obj_index + 1;
				exit;
			when others =>
			end case;

			parse_tagvaluekeydefault(
				obj, obj_index, obj'right,
				tag_offset,     tag_length, 
				value_offset,   value_length, 
				key_offset,     key_length, 
				default_offset, default_length);

			assert ((log/log_locatevalue) mod 2=0) --|note
				report LF & "locate_value => obj -> " & natural'image(value_offset) & ':' & natural'image(value_offset+value_length-1) & " " & '"' & obj(value_offset to value_offset+value_length-1) & '"' --|note
				severity note; --|note

			-- if not isdigit(key(key'left)) then
			if not isdigit(obj(key_left)) then
				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF &"locate_value => object request key " & obj(key_left to key_right) & " -> " & natural'image(tag_offset) & ':' & natural'image(tag_offset+tag_length-1) & ' ' & '"' & obj(tag_offset to tag_offset+tag_length-1) & '"' --|note
					severity note; --|note

				if tag_length/=0 then
					if compare_string(obj(key_left to key_right), obj(tag_offset to tag_offset+tag_length-1)) then
						offset := tag_offset;
						length := obj_index-offset;
					end if;
				end if;
			elsif to_integer(obj(key_left to key_right)) <= position then
				offset := tag_offset;
				length := obj_index-offset;

				assert ((log/log_locatevalue) mod 2=0) --|note
					report LF & "locate_value => object position -> " & natural'image(tag_offset) & ':' & natural'image(tag_offset+tag_length-1) & obj(tag_offset to tag_offset+tag_length-1) --|note
					severity note; --|note

				exit;
			end if;

			assert ((log/log_locatevalue) mod 2=0) --|note
				report LF & "locale_value => obj_index end loop-> " & natural'image(obj_index) & " '" &obj(obj_index) & "'" --|note
				severity note; --|note
		end loop;

		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF &  --|note
				"locate_value => tag   -> " & natural'image(tag_offset)   & ':' & natural'image(tag_offset+tag_length-1) & '"' & obj(tag_offset   to tag_offset+tag_length-1) & '"' & LF &  --|note
				"locate_value -> value -> " & natural'image(value_offset) & ':' & natural'image(obj_index-1)             & '"' & obj(value_offset to obj_index-1) & '"' --|note
			severity note; --|note

		assert ((log/log_locatevalue) mod 2=0) --|note
			report LF & "locate_value => ^^^^^^^^^^^^^^^^^^^^" --|note
			severity note; --|note
	end;

	function compact (
		constant obj : string)
		return string is
		variable retval : string(1 to obj'length);
		variable escape : boolean;
		variable bkslh  : boolean;
		variable n      : positive;
	begin
		bkslh  := false;
		escape := false;
		n      := retval'left;
		for i in obj'range loop
			if bkslh then
				retval(n) := obj(i);
				n := n + 1;
			elsif escape then
				retval(n) := obj(i);
				n := n + 1;
			elsif not isws(obj(i)) then
				retval(n) := obj(i);
				n := n + 1;
			end if;
			if bkslh then
				bkslh := false;
			elsif obj(i)='\' then
				bkslh := true;
			elsif obj(i)=''' or obj(i)='"' then
				escape := not escape;
			end if;
		end loop;
		return retval(1 to n-1);
	end;

	procedure resolve (
		constant obj           : in    string;
		variable value_offset  : inout positive;
		variable value_length  : inout natural;
		variable tag1_offset   : inout positive;
		variable tag1_length   : inout natural) is

		variable obj_index     : positive;
		variable key_offset    : positive;
		variable key_length    : natural;
		variable keytag_offset : positive;
		variable keytag_length : natural;
		variable keytag_index  : positive;

		variable obj_offset    : positive;
		variable obj_length    : natural;
		variable tag_offset    : positive;
		variable tag_length    : natural;
		variable default_offset    : positive;
		variable default_length    : natural;
	begin
		obj_index := obj'left;

		parse_tagvaluekeydefault(
			obj, obj_index, obj'right,
			tag_offset,     tag_length, 
			value_offset,   value_length, 
			keytag_offset,  keytag_length, 
			default_offset, default_length);
		assert ((log/log_resolve) mod 2=0)  --|note
			report LF & "resolve => keytag -> " & natural'image(keytag_offset) & ":" & natural'image(keytag_length) & ":" & '"' & obj(keytag_offset to keytag_offset+keytag_length-1) & '"' & LF & --|note
			       "resolve => value  -> " & natural'image(value_offset)  & ":" & natural'image(value_length)  & ":" & '"' & obj(value_offset  to value_offset+value_length-1)   & '"' & LF --|note
			severity note; --|note
		if keytag_length/=0 then
			keytag_index := keytag_offset;
			for i in obj'range loop -- avoid synthesizes tools loop-warnings
				parse_keytag(obj, keytag_index, tag_offset, tag_length);
				if tag_length=0 then
					exit;
				end if;
				assert ((log/log_resolve) mod 2=0) --|note
					report LF &  --|note
						"resolve => tag         -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ":" & '"' & obj(tag_offset to tag_offset+tag_length-1) & LF & --|note
						"resolve => obj_index   -> " & natural'image(obj_index) --|note
					severity note; --|note
				locate_value(obj, value_offset, tag_offset, tag_offset+tag_length-1 , tag1_offset, tag1_length, obj_offset, obj_length);
				if obj_length=0 then -- Xilinx ISE 14.7 assert statement warning complain
					assert false --|note
						report LF & "resolve => invalid key -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ":" & '"' & obj(tag_offset to tag_offset+tag_length-1) & '"' & LF --|note
						severity note; --|note
					assert false --|note
						report LF & "resolve => default_offset -> " & natural'image(default_offset) & ":" & natural'image(default_offset+default_length-1) & ":" & '"' & obj(default_offset to default_offset+default_length-1) & '"' & LF --|note
						severity note; --|note
					obj_offset   := default_offset;
					obj_length   := default_length;
					value_offset := default_offset;
					exit;
				end if;
				assert ((log/log_resolve) mod 2=0) --|note
					report LF & --|note
						"resolve => key   -> " & natural'image(tag_offset) & ":" & natural'image(tag_length) & ' ' & '"' & obj(tag_offset to tag_offset+tag_length-1) & '"' & LF & --|note
						"resolve => value -> " & natural'image(obj_offset) & ":" & natural'image(obj_length) & ' ' & '"' & obj(obj_offset to obj_offset+obj_length-1) & '"' --|note
					severity note; --|note
				value_offset := obj_offset;
				-- resolve(obj(obj_offset to obj_offset+obj_length-1), obj_offset, obj_length);
			end loop;
		else
			obj_offset := obj'left;
			obj_length := obj'length;
		end if;
		obj_index := obj_offset;
		assert ((log/log_resolve) mod 2=0) --|note
			report LF & --|note
				"resolve => tag   -> " & natural'image(tag_offset)   & ":" & natural'image(tag_length)   & ' ' & '"' & obj(tag_offset   to tag_offset+tag_length-1)     & '"' & LF --|note
			severity note; --|note
		parse_tagvaluekeydefault(
			obj, obj_index, obj_offset+obj_length-1,
			tag_offset,     tag_length, 
			value_offset,   value_length, 
			keytag_offset,  keytag_length,
			default_offset, default_length);
		assert ((log/log_resolve) mod 2=0) --|note
			report LF & --|note
				"exit resolve => tag   -> " & natural'image(tag_offset)   & ":" & natural'image(tag_length)   & ' ' & '"' & obj(tag1_offset   to tag1_offset+tag1_length-1)     & '"' & LF & --|note
				"resolve => value -> " & natural'image(value_offset) & ":" & natural'image(value_length) & ' ' & '"' & obj(value_offset to value_offset+value_length-1) & '"' & LF & --|note
				"resolve => key   -> " & natural'image(key_offset)   & ":" & natural'image(key_length)   & ' ' & '"' & obj(key_offset   to key_offset+key_length-1)     & '"' & LF --|note
			severity note; --|note
	end;

	function resolve (
		constant obj : string)
		return string is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (obj, obj_offset, obj_length, tag_offset, tag_length);
		if obj_length/=0 then
			return obj(obj_offset to obj_offset+obj_length-1);
		else
			return "";
		end if;
	end;

	function resolve (
		constant obj : string)
		return boolean is
        constant true_value : string := "true";
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (obj, obj_offset, obj_length, tag_offset, tag_length);
		if obj_length/=true_value'length then          -- avoid synthesizes tools length-warnings
			return false;
        elsif obj(obj_offset to obj_offset+obj_length-1)/=true_value then
			return false;
		end if;
		return true;
	end;

	function resolve (
		constant obj : string)
		return integer is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (obj, obj_offset, obj_length, tag_offset, tag_length);
		return to_integer(obj(obj_offset to obj_offset+obj_length-1));
	end;

	function resolve (
		constant obj : string)
		return real is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (obj, obj_offset, obj_length, tag_offset, tag_length);
		return to_real(obj(obj_offset to obj_offset+obj_length-1));
	end;

	function resolve (
		constant obj : string)
		return std_logic_vector is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (obj, obj_offset, obj_length, tag_offset, tag_length);
		return to_stdlogicvector(escaped(obj(obj_offset to obj_offset+obj_length-1)));
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return boolean is
	begin
		return resolve(string(obj) & key);
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return integer is
		variable retval : integer;
	begin
		retval := resolve(string(obj) & key);
		return retval;
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return real is
	begin
		return resolve(string(obj) & key);
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return std_ulogic is
		constant value : string := escaped(resolve(string(obj) & key));
	begin
		if value'length > 0 then
			if value(value'left)='1' then
				return '1';
			else
				return '0';
			end if;
		end if;
		return 'X';
	end;

	function "**" (
		constant obj : hdo;
		constant key : string)
		return std_logic_vector is
	begin
		return resolve(string(obj) & key);
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

	function tag (
		constant obj : hdo)
		return string is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		report LF & "Entre";
		resolve (obj, obj_offset, obj_length, tag_offset, tag_length);
		report LF &  obj(tag_offset to tag_offset+tag_length-1);
		return obj(tag_offset to tag_offset+tag_length-1);
	end;

	procedure escaped (
		variable retval : inout string;
		variable length : inout natural;
		constant obj    : in    string) is
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
	end;

	function escaped (
		constant obj : string)
		return string is
		variable length : natural;
		variable retval : string(1 to obj'length);
		variable escape : boolean;
	begin
		escaped(retval, length, obj);
		if length/=0 then
			return retval(retval'left to retval'left+length-1);
		else
			return "";
		end if;
	end;

end;
