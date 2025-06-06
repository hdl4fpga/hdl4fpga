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
		constant object : string)
		return string;

	procedure resolve (
		constant object          : in    string;
		variable value_offset : inout positive;
		variable value_length : inout natural;
		variable tag1_offset  : inout positive;
		variable tag1_length  : inout natural);

	function resolve (
		constant object : string)
		return string;

	function resolve (
		constant object : string)
		return integer;

	function resolve (
		constant object : string)
		return boolean;

	subtype hdo is string;

	function "**" (
		constant object : hdo;
		constant path : string)
		return boolean;

	function "**" (
		constant object : hdo;
		constant path : string)
		return integer;

	function "**" (
		constant object : hdo;
		constant path : string)
		return real;

	function "**" (
		constant object : hdo;
		constant path : string)
		return std_ulogic;

	function "**" (
		constant object : hdo;
		constant path : string)
		return std_logic_vector;

	function "**" (
		constant object : hdo;
		constant path : string)
		return character;

	function "**" (
		constant object : hdo;
		constant path : string)
		return hdo;

	function to_integer (
		constant value : string)
		return integer;

	function tag (
		constant object : hdo)
		return string;

	procedure escaped (
		variable retval : inout string;
		variable length : inout natural;
		constant object    : in    string);

	function escaped (
		constant object : string)
		return string;

	function to_stdulogic (
		constant value : character)
		return std_ulogic;

	function to_stdlogicvector (
		constant value : string)
		return std_logic_vector;
end;

package body hdo is

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

	function compact (
		constant object : string)
		return string is
		variable retval : string(1 to object'length);
		variable escape : boolean;
		variable bkslh  : boolean;
		variable n      : positive;
	begin
		bkslh  := false;
		escape := false;
		n      := retval'left;
		for i in object'range loop
			if bkslh then
				retval(n) := object(i);
				n := n + 1;
			elsif escape then
				retval(n) := object(i);
				n := n + 1;
			elsif not isws(object(i)) then
				retval(n) := object(i);
				n := n + 1;
			end if;
			if bkslh then
				bkslh := false;
			elsif object(i)='\' then
				bkslh := true;
			elsif object(i)=''' or object(i)='"' then
				escape := not escape;
			end if;
		end loop;
		return retval(1 to n-1);
	end;

	constant log_parsestring      : natural := 2**0;
	constant log_parsenatural     : natural := 2**1;
	constant log_parsedomain      : natural := 2**2;
	constant log_parsepath         : natural := 2**3;
	constant log_parsevalue       : natural := 2**4;
	constant log_parsetagvaluepath : natural := 2**5;
	constant log_locatevalue      : natural := 2**6;
	constant log_resolve          : natural := 2**7;
	constant log_flags                  : natural := log_parsetagvaluepath; -- + log_resolve + log_locatevalue + log_parsedomain + log_parsepath; --    + log_parsevalue ;
	-- constant log_flags                  : natural := log_resolve; -- + log_locatevalue + log_parsedomain + log_parsepath; --    + log_parsevalue ;
	-- constant log_flags                  : natural := log_locatevalue; -- + log_parsedomain + log_parsepath; --    + log_parsevalue ;

	function max (
		constant arg1 : natural;
		constant arg2 : natural)
		return natural is
	begin
		if arg1 > arg2 then
			return arg1;
		else
			return arg2;
		end if;
	end;

	function format (
		constant arg   : string;
		constant width : natural) 
		return string is
		variable formatted : string(1 to max(width,1));
		variable j : positive;
	begin
		if width > 0 then
			j := arg'left;
			for i in 1 to width loop
				if j <= arg'right then
					formatted(i) := arg(j);
					j := j + 1;
				else
					formatted(i) := ' ';
				end if;
			end loop;
			return formatted;
		else
			return arg;
		end if;
	end;

	function xxx(
		constant arg    : string;
		constant offset : positive;
		constant length : natural)
		return string is
		constant separator : string := " ... ";
		variable content   : string(1 to 50);
		variable j : positive;
	begin
		content := (others => ' ');
		if length > content'length then
			j := arg'left;
			for i in 1 to (content'length-separator'length)/2 loop
				content(i) := arg(j);
				j := j + 1;
			end loop;
			for i in separator'range loop
				content(j) := separator(i);
				j := j + 1;
			end loop;
			j := arg'right;
			for i in content'length downto (content'length+separator'length)/2+1 loop
				content(i) := arg(j);
				j := j - 1;
			end loop;
		else
			content := format(arg(offset to offset+length-1), 50);
		end if;
		return '(' & positive'image(offset) & " to " & positive'image(offset+length-1) & ')' & content;
	end;

	function xxx(
		constant arg    : string;
		constant offset : positive)
		return string is
	begin
		return xxx(arg, offset, arg'right-offset+1);
	end;

	function yyy(
		constant arg    : string;
		constant offset : positive)
		return string is
	begin
		return '(' & positive'image(offset) & ')' & character'image(arg(offset));
	end;

	function log (
		constant fname : string;
		constant msg   : string)
		return string is
	begin
		return format(fname, 20) & " # " & format(msg, 10);
	end;

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
				for l in value'range loop    -- avoid synthesizes tools loop-warnings
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
		constant object : in string;
		constant cursor : in positive)
		return positive is
		variable retval : natural;
	begin
		for i in cursor to object'right loop
			if not isws(object(i)) then
				return i;
			end if;
		end loop;
		return object'right+1;
	end;

	procedure skipws (
		constant object : in string;
		variable cursor : inout positive) is
	begin
		for i in object'range loop
			if i >= cursor then 
				if not isws(object(i)) then
					exit;
				end if;
				cursor := cursor + 1;
			end if;
		end loop;
	end;

	procedure parse_string (
		constant object : in  string;
		variable cursor : inout positive;
		variable offset : inout positive;
		variable length : inout natural) is
		variable aphos  : boolean := false;
		variable bkslh  : boolean := false;
	begin

		skipws(object, cursor);
		offset := cursor;
		for l in object'range loop -- avoid synthesizes tools loop-warnings
			exit when cursor > object'right; -- avoid synthesizes tools loop-warnings

			if object(cursor)='\' then
				bkslh := true;
				next;
			elsif (cursor-offset)=0 then
				if object(cursor)=''' then
					aphos  := true;
					offset := cursor;
					cursor := cursor + 1;
					next;
				end if;
			end if;
			if not bkslh then
				if aphos then
					if object(cursor)=''' then
						cursor := cursor + 1;
						assert (log_flags/log_parsestring) mod 2=0                           --|note
							report LF                                                        --|note
								& log("parse_string", "") & xxx(object, offset, length) & LF --|note
							severity note;                                                   --|note
						exit;
					else
						cursor := cursor + 1;
					end if;
				elsif isalnum(object(cursor)) then
					cursor := cursor + 1;
				else
					case object(cursor) is
					when '-'|'_' =>
						cursor := cursor + 1;
					when others =>
						exit;
					end case;
				end if;
			else
				cursor := cursor + 1;
				bkslh := false;
			end if;
		end loop;
		length := cursor-offset;
		assert (log_flags/log_parsestring) mod 2=0                           --|note
			report LF                                                        --|note
				& log("parse_string", "") & xxx(object, offset, length) & LF --|note
			severity note;                                                   --|note
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
		constant object    : in   string;
		variable cursor : inout positive;
		variable offset : inout positive;
		variable length : inout natural) is
	begin
		skipws(object, cursor);
		offset := cursor;
		for l in object'range loop -- avoid synthesizes tools loop-warnings
			exit when cursor > object'right; -- avoid synthesizes tools loop-warnings

			if isalnum(object(cursor)) then
				cursor := cursor + 1;
			else
				exit;
			end if;
		end loop;
		length := cursor-offset;
		assert (log_flags/log_parsenatural) mod 2=0                    --|note
			report "LF"                                                --|note
				& "parse_string # " & xxx(object, offset, length) & LF --|note
			severity note;                                             --|note
	end;

	procedure parse_domain (
		constant object    : in    string;
		variable cursor    : inout positive;
		variable offset    : inout positive;
		variable length    : inout natural) is
		variable open_char : character;
	begin
		skipws(object, cursor);

		length := 0;
		for l in object'range loop           -- Avoid synthesizes tools loop-warnings
			exit when cursor > object'right; -- Avoid synthesizes tools loop-warnings

			assert (log_flags/log_parsedomain) mod 2=0                      --|note
				report LF                                                   --|note
					& "parse_domain # cursor % " & yyy(object, cursor) & LF --|note
				severity note;                                              --|note

			case object(cursor) is
			when '['|'{' =>
				open_char := object(cursor);
				cursor    := cursor + 1;
				parse_string(object, cursor, offset, length);

				assert ((log_flags/log_parsedomain) mod 2=0)                                   --|note
					report LF                                                                  --|note
						& log("parse_domain [ is position","") & xxx(object, offset, length) & LF --|note
					severity note;                                                             --|note

				if length=0 then
					assert false
						report LF & "parse_domain # invalid path : " & xxx(object,cursor)
						severity failure;
				end if;

				assert ((log_flags/log_parsedomain) mod 2=0) --|note
					report LF & "parse_domain # " & yyy(object, cursor) & LF --|note
					severity note; --|note

				skipws(object, cursor);
				case object(cursor) is
				when ']' => 
					if open_char/='[' then -- Xilinx ISE 14.7 warning complain
						assert false                                                                                             
							report LF & "parse_domain # wrong close path " & character'image(open_char) & " "  & yyy(object, cursor)
							severity failure;                                                                                       
					end if;                                                                                                        

					assert ((log_flags/log_parsedomain) mod 2=0)      --|note
						report LF                                     --|note
							& "parse_domain # " & yyy(object, cursor) --|note
						severity note;                                --|note
					cursor := cursor + 1;
				when '}' => 

					if open_char/='{' then -- Xilinx ISE 14.7 warning complain
						assert false
							report LF 
								& "parse_domain # wrong close path " & yyy(object, cursor) & " expecting " & character'image(open_char) & LF
							severity failure; 
					end if;

					assert ((log_flags/log_parsedomain) mod 2=0)      --|note
						report LF                                     --|note
							& "parse_domain # " & yyy(object, cursor) --|note
						severity note;                                --|note

					cursor := cursor + 1;
				when others =>
					assert false
						report LF & "parse_domain # wrong token % " & yyy(object, cursor) & LF
						severity failure;
				end case;
				exit;
			when '.' =>
				cursor := cursor + 1;
				skipws(object, cursor);
				parse_string(object, cursor, offset, length);
				if length=0 then                                                       --|note
					assert false                                                       --|note
						report LF                                                      --|note
							& "parse_domain # null path : " & xxx(object, cursor) & LF --|note
						severity note;                                                 --|note
				end if;                                                                --|note
				cursor := offset+length;
				exit;
			when others =>
				length := 0;
				assert ((log_flags/log_parsedomain) mod 2=0) --|note
					report LF                                --|note
						& "parse_domain # null" & LF         --|note
					severity note;                           --|note
				exit;
			end case;
		end loop;

		assert ((log_flags/log_parsedomain) mod 2=0)                         --|note
			report LF                                                        --|note
				& "parse_domain # path % " & xxx(object,offset, length) & LF --|note
			severity note;                                                   --|note
	end;

	procedure parse_path (
		constant object     : in    string;
		variable cursor     : inout natural;
		variable offset     : inout positive;
		variable length     : inout natural) is
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		skipws(object, cursor);
		offset := cursor;
		assert ((log_flags/log_parsepath) mod 2=0)                    --|note
			report LF                                                 --|note
				& "parse_path # object : " & xxx(object, cursor) & LF --|note
			severity note;                                            --|note

		for i in object'range loop
			parse_domain(object, cursor, tag_offset, tag_length);
			assert ((log_flags/log_parsepath) mod 2=0)                                --|note
				report LF                                                             --|note
					& "parse_path # tag % " & xxx(object,tag_offset, tag_length) & LF --|note
				severity note;                                                        --|note

			if tag_length=0 then
				length := cursor-offset;
				exit;
			end if;
		end loop;
		assert ((log_flags/log_parsepath) mod 2=0)                       --|note
			report LF                                                    --|note
				& "parse_path # " & '"' & xxx(object,offset,length) & LF --|note
			severity note;                                               --|note
	end;

	procedure parse_value (
		constant object    : in    string;
		variable cursor    : inout positive;
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
		skipws(object, cursor);
		offset := cursor;
		for i in offset to object'right loop
			if not aphos and not bkslh then
				case object(cursor) is
				when '['|'{' =>
					if obj_stptr=obj_stack'left then 
						if offset=cursor then
							list := true;
							assert ((log_flags/log_parsevalue) mod 2=0)          --|note
								report LF                                        --|note
									& "parse_value # list" & yyy(object, cursor) --|note
								severity note;                                   --|note
						end if;
					end if;
					push(obj_stptr, object(cursor));
				when ',' =>
					if obj_stptr=obj_stack'left then
						exit;
					end if;
				when ']' =>
					if obj_stptr/=obj_stack'left then
						if obj_stack(obj_stptr-1)/='[' then
							assert false
								report LF 
									& "parse_value # close path " & yyy(object,cursor) & " expecting " & yyy(obj_stack, obj_stptr-1) & LF
								severity failure;
						end if;
						pop(obj_stptr);
					else
						exit;
					end if;
				when '}' =>
					if obj_stptr/=obj_stack'left then
						if obj_stack(obj_stptr-1)/='{' then
							assert false
								report LF 
									& "parse_value # close path " & yyy(object,cursor) & " expecting " & yyy(obj_stack, obj_stptr-1) & LF
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
				if object(cursor)='\' then
					bkslh := true;
				elsif object(cursor)=''' then
					aphos := not aphos;
				end if;
			else
				bkslh := false;
			end if;
			cursor := cursor + 1;
			if list then
				if obj_stptr=obj_stack'left then
					exit;
				end if;
			end if;
		end loop;
		length := cursor-offset;
		assert ((log_flags/log_parsevalue) mod 2=0) --|note
			report LF & "parse_value # value % " &  object(offset to offset+length-1) --|note
			severity note; --|note
	end;

	procedure parse_tagvaluepath (
		constant object       : string;  -- Xilinx ISE bug left and right are not sent according slice
		variable cursor       : inout positive;
		variable tag_offset   : inout positive;
		variable tag_length   : inout natural;
		variable value_offset : inout positive;
		variable value_length : inout natural;
		variable path_offset  : inout positive;
		variable path_length  : inout natural) is
	begin
		assert ((log_flags/log_parsetagvaluepath) mod 2=0)                    --|note
			report LF                                                         --|note
				& "object " & xxx(object, cursor, object'right-cursor+1) & LF --|note
			severity note;                                                    --|note

		parse_string(object, cursor, value_offset, value_length);
		skipws(object, cursor);
		tag_offset := value_offset;
		tag_length := 0;
		if cursor <= object'right then
			if value_length=0 then
				tag_length   := 0;
				value_offset := cursor;
				value_length := object'right-cursor+1; 
				parse_value(object, cursor, value_offset, value_length);
				if cursor > object'right then                                         --|note
					assert ((log_flags/log_parsetagvaluepath) mod 2=0)                --|note
						report LF                                                     --|note
							& "no tag " & LF                                          --|note
							& "value " & xxx(object, value_offset, value_length) & LF --|note
							& "object(cursor) " & natural'image(cursor) & ':' & "EOF" --|note
						severity note;                                                --|note
				else                                                                  --|note
					assert ((log_flags/log_parsetagvaluepath) mod 2=0)                --|note
						report LF &                                                   --|note
							"no tag" & LF &                                           --|note
							"value " & xxx(object, value_offset, value_length) & LF & --|note
							"object(cursor) % " & yyy(object, cursor) & LF            --|note
						severity note;                                                --|note
				end if;                                                               --|note
			elsif object(cursor)/=':' then
				assert ((log_flags/log_parsetagvaluepath) mod 2=0)                  --|note
					report LF                                                       --|note
						& "tag token not found" & LF                                --|note
						& "value  : " & xxx(object,value_offset,value_length) & LF  --|note
						& "cursor : " & yyy(object, cursor)                         --|note
					severity note;                                                  --|note
				tag_length   := 0;
				tag_offset   := value_offset;
			else
				tag_offset   := value_offset;
				tag_length   := value_length;
				cursor       := cursor + 1;
				value_offset := cursor;
				value_length := object'right-cursor+1; 
				skipws(object, cursor);
				parse_value(object, cursor, value_offset, value_length);
				assert ((log_flags/log_parsetagvaluepath) mod 2=0)                  --|note
					report LF                                                       --|note
						& "tag   % " & xxx(object, tag_offset,   tag_length)   & LF --|note
						& "value % " & xxx(object, value_offset, value_length) & LF --|note
					severity note;                                                  --|note
			end if;
		else
			assert ((log_flags/log_parsetagvaluepath) mod 2=0)                       --|note
				report LF                                                            --|note
					& "string value " & xxx(object, value_offset, value_length) & LF --|note
				severity note;                                                       --|note
		end if;
		skipws(object, cursor);
		parse_path(object, cursor, path_offset, path_length);
		assert ((log_flags/log_parsetagvaluepath) mod 2=0)              --|note
			report LF                                                   --|note
				& "path   " & xxx(object,path_offset, path_length) & LF --|note
				& "cursor " & natural'image(cursor)                     --|note
			severity note;                                              --|note
	end;
		
	procedure parse_tagvaluepathdefault (
		constant object         : in    string;
		variable cursor         : inout positive;
		variable tag_offset     : inout positive;
		variable tag_length     : inout natural;
		variable value_offset   : inout positive;
		variable value_length   : inout natural;
		variable path_offset    : inout positive;
		variable path_length    : inout natural;
		variable default_offset : inout positive;
		variable default_length : inout natural) is
	begin
		parse_tagvaluepath(
			object,       cursor,
			tag_offset,   tag_length, 
			value_offset, value_length, 
			path_offset,  path_length);

		skipws(object, cursor);
		if path_length/=0 then
			if object'right >= cursor then
				if object(cursor)='=' then
					default_offset := cursor+1;
					default_length := object'right-cursor;
					assert ((log_flags/log_parsetagvaluepath) mod 2=0)                       --|note
						report LF                                                            --|note
							& " default % " & xxx(object,default_offset,default_length) & LF --|note
						severity note;                                                       --|note
				end if;
			end if;
		end if;
	end;

	procedure locate_value (
		constant object         : in    string;
		variable cursor         : inout positive;
		constant path_left      : in    positive;
		constant path_right     : in    positive;
		variable tag_offset     : inout positive;
		variable tag_length     : inout natural;
		variable offset         : inout positive;
		variable length         : inout natural) is
		variable path_offset    : positive;
		variable path_length    : natural;
		variable value_offset   : positive;
		variable value_length   : natural;
		variable default_offset : positive;
		variable default_length : natural;
		variable position       : natural;
		variable open_char      : character;
		variable opened         : boolean;
	begin

		assert ((log_flags/log_locatevalue) mod 2=0)  --|note
			report LF                                 --|note
				& "vvvvvvvvvvvvvvvvvvvv" & LF         --|note
				& "object" & xxx(object, cursor) & LF --|note
			severity note;                            --|note

		parse_tagvaluepathdefault(
			object,         cursor,
			tag_offset,     tag_length, 
			value_offset,   value_length, 
			path_offset,    path_length, 
			default_offset, default_length);

		cursor   := value_offset;
		offset   := tag_offset;
		length   := 0;
		position := 0;
		opened   := false;

		for l in object'range loop           -- Avoid synthesizes tools loop-warnings
			exit when cursor > object'right; -- Avoid synthesizes tools loop-warnings
		
			assert ((log_flags/log_locatevalue) mod 2=0) --|note
				report LF                                --|note
					 & "cursor" & yyy(object,cursor)     --|note
				severity note;                           --|note

			skipws(object, cursor);
			case object(cursor) is
			when '['|'{' =>
				assert ((log_flags/log_locatevalue) mod 2=0) --|note
					report LF                                --|note
						& "open" & yyy(object,cursor) & LF   --|note
					severity note;                           --|note

				open_char := object(cursor);
				opened    := true;
				cursor := cursor + 1;
			when ',' =>
				assert ((log_flags/log_locatevalue) mod 2=0)        --|note
					report LF                                       --|note
						& "position" & natural'image(position) & LF --|note
					severity note;                                  --|note

				position := position + 1;
				cursor   := cursor + 1;
			when ']' =>
				if not opened then
					assert false                                 --|note
						report LF                                --|note
							& "close" & yyy(object, cursor) & LF --|note
						severity note;                           --|note
					return;
				end if;
				if open_char/='[' then
					assert false
						report LF
							& "@locate_value : wrong close path at " & natural'image(cursor) & " opened by " & character'image(open_char) & " closed by " & yyy(object, cursor)
						severity failure;
				end if;

				assert ((log_flags/log_locatevalue) mod 2=0)  --|note
					report LF                                 --|note
						& "close" & yyy(object, cursor)  & LF --|note
					severity note;                            --|note

				opened := false;
				cursor := cursor + 1;
				exit;
			when '}' =>
				if not opened then
					assert false                                          --|note
						report LF                                         --|note
							& "close path at " & yyy(object, cursor) & LF --|note
						severity note;                                    --|note
					return;
				end if;
				if open_char/='{' then
					assert false
						report LF
							& "@locate_value wrong close path at " & yyy(object, cursor) & " opened by " & character'image(open_char) & LF
						severity failure;
				end if;

				assert ((log_flags/log_locatevalue) mod 2=0) --|note
					report LF                                --|note
						& "close" & yyy(object, cursor) & LF --|note
					severity note;                           --|note

				opened := false;
				cursor := cursor + 1;
				exit;
			when others =>
			end case;

			parse_tagvaluepathdefault(
				object,         cursor,
				tag_offset,     tag_length, 
				value_offset,   value_length, 
				path_offset,    path_length, 
				default_offset, default_length);

			assert ((log_flags/log_locatevalue) mod 2=0)                                                                                                                                                     --|note
				report LF                                                                                                                                                                                    --|note
					& "object " & xxx(object, value_offset, value_length) & LF --|note
				severity note;                                                                                                                                                                               --|note

			if not isdigit(object(path_left)) then
				assert ((log_flags/log_locatevalue) mod 2=0)                                                                                      --|note
					report LF                                                                                                                     --|note
						 & "object request path " & xxx(object, path_left, path_right-path_left) & " " & xxx(object, tag_offset, tag_length) & LF --|note
					severity note;                                                                                                                --|note

				if tag_length/=0 then
					if compare_string(object(path_left to path_right), object(tag_offset to tag_offset+tag_length-1)) then
						offset := tag_offset;
						length := cursor-offset;
					end if;
				end if;
			elsif to_integer(object(path_left to path_right)) <= position then
				offset := tag_offset;
				length := cursor-offset;

				assert ((log_flags/log_locatevalue) mod 2=0)                           --|note
					report LF                                                          --|note
						& "object position" & xxx(object, tag_offset, tag_length) & LF --|note
					severity note;                                                     --|note

				exit;
			end if;

			assert ((log_flags/log_locatevalue) mod 2=0)          --|note
				report LF                                         --|note
					& "cursor end loop" & yyy(object,cursor) & LF --|note
				severity note;                                    --|note
		end loop;

		assert ((log_flags/log_locatevalue) mod 2=0)                           --|note
			report LF                                                          --|note
				& "tag"   & xxx(object,tag_offset,   tag_length) & LF          --|note
				& "value" & xxx(object,value_offset, cursor-value_offset) & LF --|note
				& "^^^^^^^^^^^^^^^^^^^^"                                      --|note
			severity note;                                                                                                                                                                          --|note
	end;

	procedure resolve (
		constant object         : in    string;
		variable value_offset   : inout positive;
		variable value_length   : inout natural;
		variable tag1_offset    : inout positive;
		variable tag1_length    : inout natural) is

		variable cursor         : positive;
		variable path_offset     : positive;
		variable path_length     : natural;
		variable domain_offset  : positive;
		variable domain_length  : natural;
		variable domain_index   : positive;

		variable obj_offset     : positive;
		variable obj_length     : natural;
		variable tag_offset     : positive;
		variable tag_length     : natural;
		variable default_offset : positive;
		variable default_length : natural;
	begin
		cursor := object'left;

		parse_tagvaluepathdefault(
			object,         cursor,
			tag_offset,     tag_length, 
			value_offset,   value_length, 
			domain_offset,  domain_length, 
			default_offset, default_length);
		assert ((log_flags/log_resolve) mod 2=0)  --|note
			report LF
				& "domain" & xxx(object, domain_offset, domain_length) & LF --|note
				& "value"  & xxx(object, value_offset,  value_length)  & LF --|note
			severity note; --|note
		if domain_length/=0 then
			domain_index := domain_offset;
			for i in object'range loop -- avoid synthesizes tools loop-warnings
				parse_domain(object, domain_index, tag_offset, tag_length);
				if tag_length=0 then
					exit;
				end if;
				assert ((log_flags/log_resolve) mod 2=0)                    --|note
					report LF                                               --|note 
						& "tag   " & xxx(object,tag_offset,tag_length) & LF --|note
						& "cursor" & natural'image(cursor)                  --|note
					severity note;                                          --|note
				locate_value(object, value_offset, tag_offset, tag_offset+tag_length-1, tag1_offset, tag1_length, obj_offset, obj_length);
				if obj_length=0 then 
					assert ((log_flags/log_resolve) mod 2=0)                                      --|note
						report LF                                                                 --|note
							& "invalid path  " & xxx(object,tag_offset,tag_length) & LF          --|note
							& "default_offset" & xxx(object,default_offset,default_length) & LF --|note
						severity note;                                                            --|note
					cursor := default_offset;
					obj_offset   := default_offset;
					obj_length   := default_length;
					value_offset := default_offset;
					value_length := default_length;
					exit;
				end if;
				assert ((log_flags/log_resolve) mod 2=0)                   --|note
					report LF                                              --|note
						& "path"  & xxx(object,tag_offset,tag_length) & LF --|note
						& "value" & xxx(object,obj_offset,obj_length)      --|note
					severity note;                                         --|note
				value_offset := obj_offset;
				-- resolve(object(obj_offset to obj_offset+obj_length-1), obj_offset, obj_length);
			end loop;
		else
			cursor :=  object'left;
		end if;
		assert ((log_flags/log_resolve) mod 2=0)                                                                                                                                                     --|note
			report LF &                                                                                                                                                                              --|note
				log("resolve", "tag")     & natural'image(tag_offset)     & ":" & natural'image(tag_length)     & ' ' & '"' & object(tag_offset     to tag_offset+tag_length-1)         & '"' & LF & --|note
				log("resolve", "default") & natural'image(default_offset) & ":" & natural'image(default_length) & ' ' & '"' & object(default_offset to default_offset+default_length-1) & '"' & LF   --|note
			severity note;                                                                                                                                                                           --|note
		
		parse_tagvaluepathdefault(
			object,         cursor,
			tag_offset,     tag_length, 
			value_offset,   value_length, 
			domain_offset,  domain_length,
			default_offset, default_length);
		assert ((log_flags/log_resolve) mod 2=0)                                                                                                                                             --|note
			report LF &                                                                                                                                                                      --|note
				log("resolve", "tag")    & natural'image(tag_offset)   & ":" & natural'image(tag_length)      & ' ' & '"' & object(tag1_offset  to tag1_offset+tag1_length-1)   & '"' & LF & --|note
				log("resolve", "cursor") & natural'image(cursor)       & '"' & object(cursor to object'right) & '"' & LF  &                                                                  --|note
				log("resolve", "value")  & natural'image(value_offset) & ":" & natural'image(value_length)    & ' ' & '"' & object(value_offset to value_offset+value_length-1) & '"' & LF & --|note
				log("resolve", "path")   & natural'image(path_offset)  & ":" & natural'image(path_length)     & ' ' & '"' & object(path_offset  to path_offset+path_length-1)   & '"' & LF   --|note
			severity note;                                                                                                                                                                   --|note
	end;

	function resolve (
		constant object : string)
		return string is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (object, obj_offset, obj_length, tag_offset, tag_length);
		if obj_length/=0 then
			return object(obj_offset to obj_offset+obj_length-1);
		else
			return "";
		end if;
	end;

	function resolve (
		constant object : string)
		return boolean is
        constant true_value : string := "true";
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (object, obj_offset, obj_length, tag_offset, tag_length);
		if obj_length/=true_value'length then          -- avoid synthesizes tools length-warnings
			return false;
        elsif object(obj_offset to obj_offset+obj_length-1)/=true_value then
			return false;
		end if;
		return true;
	end;

	function resolve (
		constant object : string)
		return integer is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (object, obj_offset, obj_length, tag_offset, tag_length);
		return to_integer(object(obj_offset to obj_offset+obj_length-1));
	end;

	function resolve (
		constant object : string)
		return real is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (object, obj_offset, obj_length, tag_offset, tag_length);
		return to_real(object(obj_offset to obj_offset+obj_length-1));
	end;

	function resolve (
		constant object : string)
		return std_logic_vector is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (object, obj_offset, obj_length, tag_offset, tag_length);
		return to_stdlogicvector(escaped(object(obj_offset to obj_offset+obj_length-1)));
	end;

	function "**" (
		constant object : hdo;
		constant path : string)
		return boolean is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object : hdo;
		constant path : string)
		return integer is
		variable retval : integer;
	begin
		retval := resolve(string(object) & path);
		return retval;
	end;

	function "**" (
		constant object : hdo;
		constant path : string)
		return real is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object : hdo;
		constant path : string)
		return std_ulogic is
		constant value : string := escaped(resolve(string(object) & path));
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
		constant object : hdo;
		constant path : string)
		return std_logic_vector is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object : hdo;
		constant path : string)
		return character is
		constant retval : string := resolve(string(object) & path);
	begin
		if retval(retval'left)='\' then
			return retval(retval'left+1);
		end if;
		return retval(retval'left);
	end;

	function "**" (
		constant object : hdo;
		constant path : string)
		return hdo is
	begin
		return resolve(string(object) & path);
	end;

	function tag (
		constant object : hdo)
		return string is
		variable obj_offset : positive;
		variable obj_length : natural;
		variable tag_offset : positive;
		variable tag_length : natural;
	begin
		resolve (object, obj_offset, obj_length, tag_offset, tag_length);
		report LF & "Entre";
		report LF &  '"' & object(tag_offset to tag_offset+tag_length-1) & '"';
		return object(tag_offset to tag_offset+tag_length-1);
	end;

	procedure escaped (
		variable retval : inout string;
		variable length : inout natural;
		constant object    : in    string) is
		variable escape : boolean;
		variable bkslh  : boolean;
	begin
		length := 0;
		escape := false;
		bkslh  := false;
		for i in object'range loop
			if bkslh then
				retval(retval'left+length) := object(i);
				length := length + 1;
			elsif escape then
				if not (object(i)=''' or object(i)='"' or object(i)='\') then
					retval(retval'left+length) := object(i);
					length := length + 1;
				end if;
			elsif not (object(i)=''' or object(i)='"' or object(i)='\' or isws(object(i))) then
				retval(retval'left+length) := object(i);
				length := length + 1;
			end if;
			if bkslh then
				bkslh := false;
			elsif object(i)='\' then
				bkslh := true;
			elsif object(i)=''' or object(i)='"' then
				escape := not escape;
			end if;
		end loop;
	end;

	function escaped (
		constant object : string)
		return string is
		variable length : natural;
		variable retval : string(1 to object'length);
		variable escape : boolean;
	begin
		escaped(retval, length, object);
		if length/=0 then
			return retval(retval'left to retval'left+length-1);
		else
			return "";
		end if;
	end;

end;
