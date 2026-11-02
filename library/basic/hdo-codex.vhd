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
		constant object         : in    string;
		variable value_position : inout positive;
		variable value_length   : inout natural;
		variable tag_position   : inout positive;
		variable tag_length     : inout natural);

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
		constant path   : string)
		return boolean;

	function "**" (
		constant object : hdo;
		constant path : string)
		return integer;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return real;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return std_ulogic;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return std_logic_vector;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return unsigned;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return character;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return hdo;

	function "**" (
		constant object   : hdo;
		constant position : natural)
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
		constant object : in    string);

	function escaped (
		constant object : string)
		return string;

	function to_stdulogic (
		constant value : character)
		return std_ulogic;

	function to_stdlogicvector (
		constant value : string)
		return std_logic_vector;

	function length(
		constant object : string)
		return natural;

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

	-- VHDL-87 has no predefined 'image attributes. Keep diagnostics
	-- self-contained so the source also compiles without preprocessing.
	function image (
		constant value : integer)
		return string is
		variable image_buf : string(1 to 32) := (others => ' ');
		variable magnitude : natural;
		variable digit     : natural;
		variable first     : positive := image_buf'right;
		variable negative  : boolean := false;
	begin
		if value < 0 then
			negative  := true;
			magnitude := natural(-(value+1)) + 1;
		else
			magnitude := natural(value);
		end if;
		loop
			digit := magnitude mod 10;
			image_buf(first) := character'val(character'pos('0') + digit);
			exit when magnitude < 10;
			magnitude := magnitude / 10;
			first := first - 1;
		end loop;
		if negative then
			first := first - 1;
			image_buf(first) := '-';
		end if;
		return image_buf(first to image_buf'right);
	end;

	function image (
		constant value : character)
		return string is
	begin
		return "'" & value & "'";
	end;

	function compact (
		constant object : string)
		return string is
		variable retval : string(1 to object'length);
		variable quote  : character;
		variable bkslh  : boolean;
		variable n      : positive;
	begin
		bkslh  := false;
		quote  := NUL;
		n      := retval'left;
		for i in object'range loop
			if bkslh then
				retval(n) := object(i);
				n := n + 1;
			elsif quote/=NUL then
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
			elsif quote=NUL and (object(i)=''' or object(i)='"') then
				quote := object(i);
			elsif quote/=NUL and object(i)=quote then
				quote := NUL;
			end if;
		end loop;
		assert not bkslh
			report "compact: trailing escape character"
			severity failure;
		assert quote=NUL
			report "compact: unterminated quoted string"
			severity failure;
		return retval(1 to n-1);
	end;

	constant log_parsestring  : natural := 2**0;
	constant log_parsenatural : natural := 2**1;
	constant log_parsedomain  : natural := 2**2;
	constant log_parsepath    : natural := 2**3;
	constant log_parsevalue   : natural := 2**4;
	constant log_parsetagvaluepath : natural := 2**5;
	constant log_parsetagvaluepathdefault : natural := 2**8;
	constant log_locatevalue  : natural := 2**6;
	constant log_resolve      : natural := 2**7;
	constant log_flags        : natural := 511-log_parsestring;

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
			return character'pos(char)-character'pos('a')+10;
		when others =>
			assert false
				report "wrong digit " & image(char)
				severity failure;
			return -1;
		end case;
	end;

	function to_integer (
		constant value : string;
		constant base  : natural)
		return integer is
		variable sign      : integer;
		variable digit     : integer;
		variable retval    : integer;
		variable limit     : integer;
		variable multmin   : integer;
		variable digits    : natural;
	begin
		assert base >= 2 and base <= 16
			report "to_integer: base must be in the range 2 to 16"
			severity failure;
		if base < 2 or base > 16 then
			return 0;
		end if;
		sign   := 1;
		retval := 0;
		digits := 0;
		for i in value'range loop
			if i=value'left and (value(i)='-' or value(i)='+') then
				if value(i)='-' then
					sign := -1;
				end if;
			elsif value(i)/='_' then
				digit := to_integer(value(i));
				assert digit >= 0 and digit < base
						report "Wrong number " & value & " " & image(integer(base))
					severity failure;
				if digit < 0 or digit >= base then
					return 0;
				end if;
				digits := digits + 1;
				if sign < 0 then
					limit := integer'low;
				else
					limit := -integer'high;
				end if;
				multmin := limit / base;
				assert retval >= multmin
					report "to_integer: value out of integer range: " & value
					severity failure;
				if retval < multmin then
					return 0;
				end if;
				retval := retval*base;
				assert retval >= limit + digit
					report "to_integer: value out of integer range: " & value
					severity failure;
				if retval < limit + digit then
					return 0;
				end if;
				retval := retval - digit;
			end if;
		end loop;
		assert digits > 0
			report "to_integer: number contains no digits: " & value
			severity failure;
		if digits=0 then
			return 0;
		end if;
		if sign < 0 then
			return retval;
		else
			return -retval;
		end if;
	end;

	function to_stdulogic (
		constant value : character)
		return std_ulogic is
	begin
		if value='1' then
			return '1';
		elsif value= '0' then
			return '0';
		else
			return '-';
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
			variable i        : natural;
			variable retval   : std_logic_vector(0 to log2base*value'length-1);
		begin
			n := value'left;
			i := 0;
			for j in value'range loop
				for k in value'range loop    -- avoid synthesizes tools loop-warnings
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
				i := i + 1;
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
			return "";
		end if;
	end;

	function to_integer (
		constant value : string)
		return integer is
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
		variable pos         : integer;
		variable sign        : real := 1.0;
		variable mant        : real := 0.0;
		variable exponent    : integer := 0;
		variable exp_sign    : integer := 1;
		variable frac_digits : natural := 0;
		variable digits      : natural := 0;
		variable exp_digits  : natural := 0;
	begin
		assert value'length > 0
			report "to_real: empty string"
			severity failure;
		if value'length=0 then
			return 0.0;
		end if;

		pos := value'left;
		if value(pos)='-' then
			sign := -1.0;
			pos := pos + 1;
		elsif value(pos)='+' then
			pos := pos + 1;
		end if;

		-- Mantissa: digits with an optional decimal point.
		while pos <= value'right loop
			exit when not isdigit(value(pos));
			mant := mant*10.0 + real(character'pos(value(pos))-character'pos('0'));
			digits := digits + 1;
			pos := pos + 1;
		end loop;
		if pos <= value'right and value(pos)='.' then
			pos := pos + 1;
			while pos <= value'right loop
				exit when not isdigit(value(pos));
				mant := mant*10.0 + real(character'pos(value(pos))-character'pos('0'));
				digits := digits + 1;
				frac_digits := frac_digits + 1;
				pos := pos + 1;
			end loop;
		end if;
		assert digits > 0
			report "to_real: mantissa contains no digits: " & value
			severity failure;
		if digits=0 then
			return 0.0;
		end if;

		-- Optional exponent; accept both lower- and upper-case E.
		if pos <= value'right then
			if value(pos)='e' or value(pos)='E' then
				pos := pos + 1;
				if pos <= value'right then
					if value(pos)='-' then
						exp_sign := -1;
						pos := pos + 1;
					elsif value(pos)='+' then
						pos := pos + 1;
					end if;
				end if;
				while pos <= value'right loop
					assert isdigit(value(pos))
						report "to_real: invalid exponent in " & value
						severity failure;
					if not isdigit(value(pos)) then
						return 0.0;
					end if;
					exp_digits := exp_digits + 1;
					assert exponent < integer'high/10 or
					       (exponent = integer'high/10 and
					        character'pos(value(pos))-character'pos('0') <= integer'high mod 10)
						report "to_real: exponent is too large in " & value
						severity failure;
					if exponent < integer'high/10 or
					   (exponent = integer'high/10 and
					    character'pos(value(pos))-character'pos('0') <= integer'high mod 10) then
						exponent := exponent*10 + character'pos(value(pos))-character'pos('0');
					else
						return 0.0;
					end if;
					pos := pos + 1;
				end loop;
				assert exp_digits > 0
					report "to_real: missing exponent digits in " & value
					severity failure;
				if exp_digits=0 then
					return 0.0;
				end if;
			else
				assert false
					report "to_real: unexpected character in " & value
					severity failure;
				return 0.0;
			end if;
		end if;
		assert pos > value'right
			report "to_real: trailing characters in " & value
			severity failure;
		if pos <= value'right then
			return 0.0;
		end if;

		for i in 1 to frac_digits loop
			mant := mant / 10.0;
		end loop;
		return sign*mant*10.0**(exp_sign*exponent);
	end;

	function field (
		constant arg      : string;
		constant position : positive;
		constant length   : natural)
		return string is
		constant separator : string := '"' & " ... " & '"';
		variable content   : string(1 to 50);
		variable j : positive;
	begin
		content := (others => ' ');
		if length > content'length-2 then
			j := position;
			content(content'left) := '"';
			for i in content'left+1 to (content'length-separator'length)/2 loop
				content(i) := arg(j);
				j := j + 1;
			end loop;
			j := (content'length-separator'length)/2;
			for i in separator'range loop
				j := j + 1;
				content(j) := separator(i);
			end loop;
			j := position+length;
			content(content'right) := '"';
			for i in content'right-1 downto (content'length+separator'length)/2+1 loop
				j := j - 1;
				content(i) := arg(j);
			end loop;
			return '(' & image(integer(position)) & " to " & image(integer(position+length-1)) & ')' & '=' & content;
		else
			if length > 0 then 
				content(1 to length+2) := '"' & arg(position to position+length-1) & '"';
			else
				content(1 to 2) := '"' & '"';
			end if;
			return '(' & image(integer(position)) & " to " & image(integer(position+length-1)) & ')' & '=' & content(1 to length+2);
		end if;
	end;

	function field (
		constant name     : string;
		constant arg      : string;
		constant position : positive;
		constant length   : natural)
		return string is
	begin
		return name&field(arg, position, length);
	end;

	function field (
		constant name     : string;
		constant arg      : string;
		constant position : positive)
		return string is
	begin
		return field(name, arg, position, arg'right-position+1);
	end;

	function field (
		constant arg      : string;
		constant position : positive)
		return string is
	begin
		return field(arg, position, arg'right-position+1);
	end;

	function skipws (
		constant object   : in string;
		constant position : in positive)
		return positive is
		variable retval : natural;
	begin
		for i in position to object'right loop
			if not isws(object(i)) then
				return i;
			end if;
		end loop;
		return object'right+1;
	end;

	procedure skipws (
		constant object   : in string;
		variable position : inout positive) is
	begin
		for i in object'range loop
			if i >= position then 
				if not isws(object(i)) then
					exit;
				end if;
				position := position + 1;
			end if;
		end loop;
	end;

	procedure parse_string (
		constant object         : in  string;
		variable position       : inout positive;
		variable value_position : inout positive;
		variable value_length   : inout natural) is
		variable quote  : character := NUL;
		variable bkslh  : boolean := false;
	begin

		skipws(object, position);
		value_position := position;
		for l in object'range loop           -- Avoid synthesizes tools loop-warnings
			exit when position > object'right; -- Avoid synthesizes tools loop-warnings

			if bkslh then
				position := position + 1;
				bkslh := false;
			elsif object(position)='\' then
				bkslh := true;
				position := position + 1;
			elsif (position-value_position)=0 and (object(position)=''' or object(position)='"') then
					quote  := object(position);
					value_position := position;
					position := position + 1;
			elsif quote/=NUL then
					if object(position)=quote then
						position := position + 1;
						quote := NUL;
						assert (log_flags/log_parsestring) mod 2=0                                --|note
							report "@parse_string : " & field(object,value_position,value_length) --|note
							severity note;                                                        --|note
						exit;
					else
						position := position + 1;
					end if;
			elsif isalnum(object(position)) then
					position := position + 1;
				else
					case object(position) is
					when '-'|'_' =>
						position := position + 1;
					when others =>
						exit;
					end case;
				end if;
		end loop;
		value_length := position-value_position;
		assert not bkslh
			report "unterminated escape sequence " & field(object, value_position, value_length)
			severity failure;
		assert quote=NUL
			report "unterminated quoted string " & field(object, value_position, value_length)
			severity failure;
		assert (log_flags/log_parsestring) mod 2=0                                  --|note
			report "@parse_string : " & field(object, value_position, value_length) --|note
			severity note;                                                          --|note
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
		constant object         : in    string;
		variable position       : inout positive;
		variable value_position : inout positive;
		variable value_length   : inout natural) is
	begin
		skipws(object, position);
		value_position := position;
		for l in object'range loop            -- Avoid synthesizes tools loop-warnings
			exit when position > object'right; -- Avoid synthesizes tools loop-warnings

			if isalnum(object(position)) then
				position := position + 1;
			else
				exit;
			end if;
		end loop;
		value_length := position-value_position;
		assert (log_flags/log_parsenatural) mod 2=0                                                         --|note
			report "parse_natural : " & '"' & object(value_position to value_position+value_length-1) & '"' --|note
			severity note;                                                                                  --|note
	end;


	function at (
		constant arg      : string;
		constant position : positive)
		return string is
	begin
		return '(' & image(integer(position)) & ')' & "=" & image(arg(position));
	end;

	procedure resolve (
		constant object           : in    string;
		variable value_position   : inout positive;
		variable value_length     : inout natural;
		variable tag_position     : inout positive;
		variable tag_length       : inout natural) is

		variable object_position  : positive;
		variable path_position    : positive;
		variable path_length      : natural;

		variable domain_position  : positive;
		variable domain_length    : natural;
		variable default_position : positive;
		variable default_length   : natural;

		function indent (
			constant msg : string)
			return string is
		begin
			-- Preserve the complete diagnostic message; do not truncate it.
			return msg;
		end;

		procedure parse_domain (
			constant object          : in    string;
			variable position        : inout positive;
			variable domain_position : inout positive;
			variable domain_length   : inout natural) is
			variable open_char       : character;
		begin
			skipws(object, position);

			assert (log_flags/log_parsedomain) mod 2=0 --|note
				report indent("@parsedomain")          --|note
				severity note;                         --|note

			domain_length := 0;
			for l in object'range loop             -- Avoid synthesizes tools loop-warnings
				exit when position > object'right; -- Avoid synthesizes tools loop-warnings

				assert (log_flags/log_parsedomain) mod 2=0         --|note
					report indent(field("path", object, position)) --|note
					severity note;                                 --|note

				case object(position) is
				when '['|'{' =>
					open_char := object(position);
					position    := position + 1;
					parse_string(object, position, domain_position, domain_length);

					assert ((log_flags/log_parsedomain) mod 2=0)                                 --|note
						report indent(field("position", object, domain_position, domain_length)) --|note
						severity note;                                                           --|note

					if domain_length=0 then
						assert false
							report "invalid path : " & field(object,position)
							severity failure;
					end if;

					skipws(object, position);
					assert position <= object'right
						report "unterminated path domain: " & field(object, domain_position, domain_length)
						severity failure;
					if position > object'right then
						return;
					end if;
					case object(position) is
					when ']' => 
						if open_char/='[' then -- Xilinx ISE 14.7 warning complain
							assert false                                                                                             
								report "wrong closing character " & at(object, position) & " opened by " & image(open_char)
								severity failure;                                                                                       
						end if;                                                                                                        

						assert ((log_flags/log_parsedomain) mod 2=0)                   --|note
							report indent("closing character " & at(object, position)) --|note
							severity note;                                             --|note

						position := position + 1;
					when '}' => 

						if open_char/='{' then -- Xilinx ISE 14.7 warning complain
							assert false
								report "wrong closing character " & at(object, position) & " opened by " & image(open_char)
								severity failure; 
						end if;

						assert ((log_flags/log_parsedomain) mod 2=0)                   --|note
							report indent("closing character " & at(object, position)) --|note
							severity note;                                             --|note

						position := position + 1;

					when others =>
						assert false
							report "wrong token : " & at(object, position)
							severity failure;
					end case;
					exit;
				when '.' =>
					position := position + 1;
					skipws(object, position);
					parse_string(object, position, domain_position, domain_length);
					if domain_length=0 then                                         --|note
						assert false                                                --|note
							report indent("null path : " & field(object, position)) --|note
							severity note;                                          --|note
					end if;                                                         --|note
					position := domain_position+domain_length;
					exit;
				when others =>
					domain_length := 0;
					assert ((log_flags/log_parsedomain) mod 2=0) --|note
						report indent("null")                    --|note
						severity note;                           --|note
					exit;
				end case;
			end loop;

			assert ((log_flags/log_parsedomain) mod 2=0)                                 --|note
				report indent("domain " & field(object, domain_position, domain_length)) --|note
				severity note;                                                           --|note

			assert (log_flags/log_parsedomain) mod 2=0 --|note
				report indent("#parsedomain")          --|note
				severity note;                         --|note
		end;

		procedure parse_path (
			constant object        : in    string;
			variable position      : inout natural;
			variable path_position : inout positive;
			variable path_length   : inout natural) is
			variable tag_position  : positive;
			variable tag_length    : natural;
		begin
			assert ((log_flags/log_parsepath) mod 2=0) --|note
				report indent("@parsepath")            --|note
				severity note;                         --|note

			skipws(object, position);
			path_position := position;
			assert ((log_flags/log_parsepath) mod 2=0)          --|note
				report indent("path" & field(object, position)) --|note
				severity note;                                  --|note

			for i in object'range loop
				parse_domain(object, position, tag_position, tag_length);
				assert ((log_flags/log_parsepath) mod 2=0)                           --|note
					report indent("domain" & field(object,tag_position, tag_length)) --|note
					severity note;                                                   --|note

				if tag_length=0 then
					path_length := position-path_position;
					exit;
				end if;
			end loop;

			assert ((log_flags/log_parsepath) mod 2=0)                          --|note
				report indent("path" & field(object,path_position,path_length)) --|note
				severity note;                                                  --|note

			assert ((log_flags/log_parsepath) mod 2=0) --|note
				report indent("#parsepath")            --|note
				severity note;                         --|note
		end;

		procedure parse_value (
			constant object         : in    string;
			variable position       : inout positive;
			variable value_position : inout positive;
			variable value_length   : inout natural) is
			variable stack : string(1 to 32);
			variable stptr : positive := stack'left;
			procedure push (
				variable stptr : inout positive;
				constant char : in character) is
			begin
				stack(stptr) := char;
				stptr := stptr + 1;
			end;

			procedure pop (
				variable stptr : inout positive) is
			begin
				stptr := stptr - 1;
			end;

			variable quote  : character := NUL;
			variable bkslh  : boolean := false;
			variable list   : boolean := false;
		begin
			assert ((log_flags/log_parsevalue) mod 2=0) --|note
				report indent("@parsevalue")            --|note
				severity note;                          --|note

			skipws(object, position);
			value_position := position;
			for i in value_position to object'right loop
				if quote=NUL and not bkslh then
					case object(position) is
					when '['|'{' =>
						if stptr=stack'left then 
							if value_position=position then
								list := true;
							end if;
						end if;
						assert stptr<=stack'right
							report "parse_value nesting exceeds " & image(integer(stack'length))
							severity failure;
						if stptr<=stack'right then
							push(stptr, object(position));
						end if;
					when ',' =>
						if stptr=stack'left then
							exit;
						end if;
					when ']' =>
						if stptr/=stack'left then
							if stack(stptr-1)/='[' then
								assert false
									report "parse_value # close path " & at(object,position) & " expecting " & at(stack, stptr-1)
									severity failure;
							end if;
							pop(stptr);
						else
							exit;
						end if;
					when '}' =>
						if stptr/=stack'left then
							if stack(stptr-1)/='{' then
								assert false
									report "parse_value # close path " & at(object,position) & " expecting " & at(stack, stptr-1)
									severity failure;
							end if;
							pop(stptr);
						else
							exit;
						end if;
					when others =>
					end case;
				end if;
				if bkslh then
					bkslh := false;
				elsif object(position)='\' then
					bkslh := true;
				elsif quote=NUL and (object(position)=''' or object(position)='"') then
					quote := object(position);
				elsif quote/=NUL and object(position)=quote then
					quote := NUL;
				end if;
				position := position + 1;
				if list then
					if stptr=stack'left then
						exit;
					end if;
				end if;
		end loop;
		value_length := position-value_position;
		assert not bkslh
			report "unterminated escape sequence " & field(object, value_position, value_length)
			severity failure;
		assert quote=NUL
			report "unterminated quoted value " & field(object, value_position, value_length)
			severity failure;
		assert stptr=stack'left
			report "unterminated nested value " & field(object, value_position, value_length)
			severity failure;
			assert ((log_flags/log_parsevalue) mod 2=0)                            --|note
				report indent(field("value", object,value_position, value_length)) --|note
				severity note;                                                     --|note

			assert ((log_flags/log_parsevalue) mod 2=0) --|note
				report indent("#parsevalue")            --|note
				severity note;                          --|note
		end;

		procedure parse_tagvaluepath (
			constant object         : string;  -- Xilinx ISE bug left and right are not sent according slice
			variable position       : inout positive;
			variable tag_position   : inout positive;
			variable tag_length     : inout natural;
			variable value_position : inout positive;
			variable value_length   : inout natural;
			variable path_position  : inout positive;
			variable path_length    : inout natural) is
		begin

			assert ((log_flags/log_parsetagvaluepath) mod 2=0) --|note
				report indent("@tagvaluepath")                 --|note
				severity note;                                 --|note

			if position > object'right then
				assert ((log_flags/log_parsetagvaluepath) mod 2=0) --|note
					report indent("#tagvaluepath")                 --|note
					severity note;                                 --|note
					-- return; -- Xilinx 14.7 doesn't like a return in a procedure
			else
				assert ((log_flags/log_parsetagvaluepath) mod 2=0)                            --|note
					report indent(field("object", object, position, object'right-position+1)) --|note
					severity note;                                                            --|note

				parse_string(object, position, value_position, value_length);
				skipws(object, position);
				tag_position := value_position;
				tag_length   := 0;
				if position <= object'right then
					if value_length=0 then
						tag_length     := 0;
						value_position := position;
						value_length   := object'right-position+1; 
						parse_value(object, position, value_position, value_length);
						if position > object'right then                                            --|note
							assert ((log_flags/log_parsetagvaluepath) mod 2=0)                     --|note
								report indent(field("value",object, value_position, value_length)) --|note
								severity note;                                                     --|note
						else                                                                       --|note
							assert ((log_flags/log_parsetagvaluepath) mod 2=0)                     --|note
								report indent(field("value",object, value_position, value_length)) --|note
								severity note;                                                     --|note
						end if;                                                                    --|note
					elsif object(position)/=':' then
						tag_length     := 0;
						tag_position   := value_position;

						assert ((log_flags/log_parsetagvaluepath) mod 2=0)                      --|note
							report indent(field("value", object, value_position, value_length)) --|note
							severity note;                                                      --|note
					else
						tag_position   := value_position;
						tag_length     := value_length;
						position       := position + 1;
						skipws(object, position);
						parse_value(object, position, value_position, value_length);

						assert ((log_flags/log_parsetagvaluepath) mod 2=0)                      --|note
							report indent(field("tag",   object, tag_position,   tag_length))   --|note
							severity note;                                                      --|note
						assert ((log_flags/log_parsetagvaluepath) mod 2=0)                      --|note
							report indent(field("value", object, value_position, value_length)) --|note
							severity note;                                                      --|note
					end if;
				else
					assert ((log_flags/log_parsetagvaluepath) mod 2=0)                       --|note
						report indent(field("string", object, value_position, value_length)) --|note
						severity note;                                                       --|note
				end if;
				skipws(object, position);
				parse_path(object, position, path_position, path_length);
				assert ((log_flags/log_parsetagvaluepath) mod 2=0)                  --|note
					report indent(field("path", object,path_position, path_length)) --|note
					severity note;                                                  --|note

				assert ((log_flags/log_parsetagvaluepath) mod 2=0) --|note
					report indent("#parsetagvaluepath")            --|note
					severity note;                                 --|note
			end if;
		end;
			
		procedure parse_tagvaluepathdefault (
			constant object           : in    string;
			variable position         : inout positive;
			variable tag_position     : inout positive;
			variable tag_length       : inout natural;
			variable value_position   : inout positive;
			variable value_length     : inout natural;
			variable path_position    : inout positive;
			variable path_length      : inout natural;
			variable default_position : inout positive;
			variable default_length   : inout natural) is
		begin
			assert ((log_flags/log_parsetagvaluepathdefault) mod 2=0) --|note
				report indent("@tagvaluepathdefault")                 --|note
				severity note;                                        --|note

			parse_tagvaluepath(
				object,         position,
				tag_position,   tag_length, 
				value_position, value_length, 
				path_position,  path_length);

			skipws(object, position);
			default_position := position+1;
			default_length   := 0;
			if path_length/=0 then
				if object'right >= position then
					if object(position)='=' then
						default_length := object'right-position;
						assert ((log_flags/log_parsetagvaluepathdefault) mod 2=0)                     --|note
							report indent(field("default", object, default_position, default_length)) --|note
							severity note;                                                            --|note
					end if;
				end if;
			end if;

			assert ((log_flags/log_parsetagvaluepathdefault) mod 2=0) --|note
				report indent("#tagvaluepathdefault")                 --|note
				severity note;                                        --|note
		end;

		procedure locate_value (
			constant object          : in    string;
			variable position        : inout positive;
			constant domain_position : in    positive;
			constant domain_length   : in    positive;
			variable tag_position    : inout positive;
			variable tag_length      : inout natural;
			variable value_position  : inout positive;
			variable value_length    : inout natural) is
			variable path_position   : positive;
			variable path_length     : natural;
			variable default_position : positive;
			variable default_length : natural;
			variable index          : natural;
			variable open_char      : character;
			variable closed         : boolean;
		begin

			assert ((log_flags/log_locatevalue) mod 2=0) --|note
				report indent("@locatevalue")            --|note
				severity note;                           --|note
	
			assert ((log_flags/log_locatevalue) mod 2=0)          --|note
				report indent("object" & field(object, position)) --|note
				severity note;                                    --|note

			parse_tagvaluepathdefault(
				object,           position,
				tag_position,     tag_length, 
				value_position,   value_length, 
				path_position,    path_length, 
				default_position, default_length);

			position       := value_position;
			value_length   := 0;
			value_position := tag_position;
			index := 0;
			closed := true;

			for l in object'range loop             -- Avoid synthesizes tools loop-warnings
				exit when position > object'right; -- Avoid synthesizes tools loop-warnings
			
				skipws(object, position);
				exit when position > object'right;
				case object(position) is
				when '['|'{' =>
					assert ((log_flags/log_locatevalue) mod 2=0)          --|note
						report indent("token open" & at(object,position)) --|note
						severity note;                                    --|note

					open_char := object(position);
					closed    := false;
					position  := position + 1;
				when ',' =>
					index := index + 1;
					assert ((log_flags/log_locatevalue) mod 2=0)           --|note
						report indent("token next" & at(object, position)) --|note
						severity note;                                     --|note

					position := position + 1;
				when ']' =>
					assert ((log_flags/log_locatevalue) mod 2=0)            --|note
						report indent("token close" & at(object, position)) --|note
						severity note;                                      --|note

					if closed then
						assert false
							report "array haven't been opened yet" & at(object, position)
							severity failure;
						exit;
					end if;

					if open_char/='[' then
						assert false
								report "wrong close token " & at(object, position) & " opened by " & image(open_char)
							severity failure;
					end if;

					closed   := true;
					position := position + 1;
				when '}' =>
					assert ((log_flags/log_locatevalue) mod 2=0)            --|note
						report indent("token close" & at(object, position)) --|note
						severity note;                                      --|note

					if closed then
						assert false                                               --|note
							report indent("close path at " & at(object, position)) --|note
							severity note;                                         --|note
						exit;
					end if;
					if open_char/='{' then
						assert false
								report "wrong close path at " & at(object, position) & " opened by " & image(open_char)
							severity failure;
					end if;

					closed   := true;
					position := position + 1;
				when others =>
				end case;

				if not closed then 
					parse_tagvaluepathdefault(
						object,           position,
						tag_position,     tag_length, 
						value_position,   value_length, 
						path_position,    path_length, 
						default_position, default_length);
	
					assert ((log_flags/log_locatevalue) mod 2=0)                                                       --|note
						report indent("[" & image(integer(index)) & "]=" & field(object, value_position, value_length)) --|note
						severity note;                                                                                 --|note
				end if;

				if not isdigit(object(domain_position)) then
					assert ((log_flags/log_locatevalue) mod 2=0)                                                                                                --|note
						report indent("object requested path " & field("domain", object, domain_position, domain_length) & " " & field("tag", object, tag_position, tag_length)) --|note
						severity note;                                                                                                                          --|note

					if tag_length/=0 then
						if compare_string(object(domain_position to domain_position+domain_length-1), object(tag_position to tag_position+tag_length-1)) then
							value_position := tag_position;
							value_length   := position-value_position;
							exit;
						else
							tag_position   := position;
							tag_length     := 0;
							value_position := position;
							value_length   := 0;
						end if;
					else
						tag_position   := position;
						tag_length     := 0;
						value_position := position;
						value_length   := 0;

						assert ((log_flags/log_locatevalue) mod 2=0)                                             --|note
							report indent("domain not found : " & field(object, domain_position, domain_length)) --|note
							severity note;                                                                       --|note
						exit;
					end if;
				elsif to_integer(object(domain_position to domain_position+domain_length-1)) <= index then
					value_position := tag_position;
					value_length   := position-value_position;

					assert ((log_flags/log_locatevalue) mod 2=0)                                --|note
						report indent("object index" & field(object, tag_position, tag_length)) --|note
						severity note;                                                          --|note
					exit;
				elsif closed then
					tag_position   := position;
					tag_length     := 0;
					value_position := position;
					value_length   := 0;

					assert ((log_flags/log_locatevalue) mod 2=0)                                                 --|note
						report indent("out of range " & field("domain", object, domain_position, domain_length)) --|note
						severity note;                                                                           --|note
					exit;
				end if;

			end loop;

			assert ((log_flags/log_locatevalue) mod 2=0)                      --|note
				report indent("tag" & field(object,tag_position, tag_length)) --|note
				severity note;                                                --|note
			assert ((log_flags/log_locatevalue) mod 2=0)                            --|note
				report indent("value" & field(object,value_position, value_length)) --|note
				severity note;                                                      --|note

			assert ((log_flags/log_locatevalue) mod 2=0) --|note
				report indent("#locatevalue")            --|note
				severity note;                           --|note
	
		end;

	begin

		assert ((log_flags/log_resolve) mod 2=0) --|note
			report indent("@resolve")            --|note
			severity note;                       --|note

		object_position := object'left;
		parse_tagvaluepathdefault(
			object,         object_position,
			tag_position,     tag_length, 
			value_position,   value_length, 
			path_position,    path_length, 
			default_position, default_length);

		assert ((log_flags/log_resolve) mod 2=0)                                       --|note
			report indent("tag" & field(object, tag_position, tag_length))             --|note
			severity note;                                                             --|note
		assert ((log_flags/log_resolve) mod 2=0)                                       --|note
			report indent("path" & field(object, path_position, path_length))          --|note
			severity note;                                                             --|note
		assert ((log_flags/log_resolve) mod 2=0)                                       --|note
			report indent("value" & field(object, value_position, value_length))       --|note
			severity note;                                                             --|note
		assert ((log_flags/log_resolve) mod 2=0)                                       --|note
			report indent("default" & field(object, default_position, default_length)) --|note
			severity note;                                                             --|note

		object_position := value_position;
		if path_length/=0 then
			for i in object'range loop -- Avoid synthesizes tools loop-warnings
				parse_domain(object, path_position, domain_position, domain_length);
				exit when domain_length=0;

				assert ((log_flags/log_resolve) mod 2=0)                                   --|note
					report indent(field("domain", object, domain_position, domain_length)) --|note
					severity note;                                                         --|note

				locate_value(object, object_position, domain_position, domain_length, tag_position, tag_length, value_position, value_length);
				if value_length=0 then 

					assert ((log_flags/log_resolve) mod 2=0)                                                           --|note
						report indent("invalid path     : " & field("domain", object, domain_position, domain_length)) --|note
						severity note;                                                                                 --|note
					assert ((log_flags/log_resolve) mod 2=0)                                      --|note
						report indent(field("default", object, default_position, default_length)) --|note
						severity note;                                                            --|note
					assert ((log_flags/log_resolve) mod 2=0)                                      --|note
						report indent("object_position  : " & image(integer(object_position)))    --|note
						severity note;                                                            --|note
					assert ((log_flags/log_resolve) mod 2=0)                                      --|note
						report indent("default_position : " & image(integer(default_position)))   --|note
						severity note;                                                            --|note
					assert ((log_flags/log_resolve) mod 2=0)                                      --|note
						report indent("default_length   : " & image(integer(default_length)))   --|note
						severity note;                                                            --|note

					value_position  := default_position;
					value_length    := default_length;
					object_position := value_position;
					exit;
				end if;

				assert ((log_flags/log_resolve) mod 2=0)                                --|note
					report indent(field("path", object,domain_position, domain_length)) --|note
					severity note;                                                      --|note
				assert ((log_flags/log_resolve) mod 2=0)                                --|note
					report indent(field("value",object, value_position, value_length))  --|note
					severity note;                                                      --|note

				object_position := value_position;
				-- resolve(object(value_position to value_position+value_length-1), value_position, value_length);
			end loop;
		else
			object_position := object'left;
		end if;

		assert ((log_flags/log_resolve) mod 2=0)                                      --|note
			report indent(field("domain", object, domain_position, domain_length))    --|note
			severity note;                                                            --|note
		assert ((log_flags/log_resolve) mod 2=0)                                      --|note
			report indent(field("dafault", object, default_position, default_length)) --|note
			severity note;                                                            --|note
		assert ((log_flags/log_resolve) mod 2=0)                                      --|note
			report indent(field("value", object, value_position, value_length))       --|note
			severity note;                                                            --|note
		
		parse_tagvaluepathdefault(
			object,           object_position,
			tag_position,     tag_length, 
			value_position,   value_length, 
			path_position,    path_length,
			default_position, default_length);

		assert ((log_flags/log_resolve) mod 2=0)                               --|note
			report indent(field("tag",   object, tag_position,  tag_length))   --|note
			severity note;                                                     --|note
		assert ((log_flags/log_resolve) mod 2=0)                               --|note
			report indent(field("value", object,value_position, value_length)) --|note
			severity note;                                                     --|note

		assert ((log_flags/log_resolve) mod 2=0) --|note
			report indent("#resolve")            --|note
			severity note;                       --|note
	end;

	function resolve (
		constant object : string)
		return string is
		variable value_position : positive;
		variable value_length   : natural;
		variable tag_position   : positive;
		variable tag_length     : natural;
	begin
		resolve (object, value_position, value_length, tag_position, tag_length);
		if value_length/=0 then
			return object(value_position to value_position+value_length-1);
		else
			return "";
		end if;
	end;

	function resolve (
		constant object : string)
		return boolean is
		constant true_value     : string := "true";
		variable value_position : positive;
		variable value_length   : natural;
		variable tag_position   : positive;
		variable tag_length     : natural;
	begin
		resolve (object, value_position, value_length, tag_position, tag_length);
		if value_length/=true_value'length then          -- avoid synthesizes tools length-warnings
			return false;
		elsif object(value_position to value_position+value_length-1)/=true_value then
			return false;
		end if;
		return true;
	end;

	function resolve (
		constant object : string)
		return integer is
		variable value_position : positive;
		variable value_length   : natural;
		variable tag_position   : positive;
		variable tag_length     : natural;
	begin
		resolve (object, value_position, value_length, tag_position, tag_length);
		return to_integer(object(value_position to value_position+value_length-1));
	end;

	function resolve (
		constant object : string)
		return real is
		variable value_position : positive;
		variable value_length   : natural;
		variable tag_position   : positive;
		variable tag_length     : natural;
	begin
		resolve (object, value_position, value_length, tag_position, tag_length);
		if value_length=0 then
			return 0.0;
		end if;
		return to_real(object(value_position to value_position+value_length-1));
	end;

	function resolve (
		constant object : string)
		return std_logic_vector is
		variable value_position : positive;
		variable value_length   : natural;
		variable tag_position   : positive;
		variable tag_length     : natural;
	begin
		resolve (object, value_position, value_length, tag_position, tag_length);
		if value_length=0 then
			return "X";
		end if;
		return to_stdlogicvector(escaped(object(value_position to value_position+value_length-1)));
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return boolean is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return integer is
		variable retval : integer;
	begin
		retval := resolve(string(object) & path);
		return retval;
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return real is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return std_ulogic is
		constant value : string := escaped(resolve(string(object) & path));
	begin
		if value'length > 0 then
			if value(value'left)='1' then
				return '1';
			elsif value(value'left)='0' then
				return '0';
			else
				return '-';
			end if;
		end if;
		return 'X';
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return unsigned is
	begin
		return unsigned(std_logic_vector'(resolve(string(object) & path)));
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return std_logic_vector is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return character is
		constant retval : string := resolve(string(object) & path);
	begin
		if retval'length=0 then
			return NUL;
		end if;
		if retval(retval'left)='\' then
			return retval(retval'left+1);
		end if;
		return retval(retval'left);
	end;

	function "**" (
		constant object : hdo;
		constant path   : string)
		return hdo is
	begin
		return resolve(string(object) & path);
	end;

	function "**" (
		constant object   : hdo;
		constant position : natural)
		return hdo is
	begin
		return resolve(string(object) & '[' & image(integer(position)) & ']');
	end;

	function tag (
		constant object : hdo)
		return string is
		variable value_position : positive;
		variable value_length   : natural;
		variable tag_position   : positive;
		variable tag_length     : natural;
	begin
		resolve (object, value_position, value_length, tag_position, tag_length);
		return object(tag_position to tag_position+tag_length-1);
	end;

	procedure escaped (
		variable retval : inout string;
		variable length : inout natural;
		constant object : in    string) is
		variable quote  : character;
		variable bkslh  : boolean;
	begin
		length := 0;
		quote  := NUL;
		bkslh  := false;
		for i in object'range loop
			if bkslh then
				retval(retval'left+length) := object(i);
				length := length + 1;
			elsif quote/=NUL then
				if object(i)/=quote then
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
			elsif quote=NUL and (object(i)=''' or object(i)='"') then
				quote := object(i);
			elsif quote/=NUL and object(i)=quote then
				quote := NUL;
			end if;
		end loop;
		assert not bkslh
			report "escaped: trailing escape character"
			severity failure;
		assert quote=NUL
			report "escaped: unterminated quoted string"
			severity failure;
	end;

	function escaped (
		constant object : string)
		return string is
		variable length : natural;
		variable retval : string(1 to object'length);
	begin
		escaped(retval, length, object);
		if length/=0 then
			return retval(retval'left to retval'left+length-1);
		else
			return "";
		end if;
	end;

	function length(
		constant object : string)
		return natural is

		function check (
			constant arg : string)
			return boolean is
		begin
			if arg'length=0 then
				return false;
			end if;
			return true;
		end;
		variable length : natural;
	begin
		length := 0;
		for i in object'range loop
			exit when not check(hdo(object)**length);
			length := length + 1;
		end loop;
		return length;
	end;

end;
