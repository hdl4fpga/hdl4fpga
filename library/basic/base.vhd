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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package base is

	type natural_vector is array (natural range <>) of natural;
	type integer_vector is array (natural range <>) of integer;
	type real_vector    is array (natural range <>) of real;
	type time_vector    is array (natural range <>) of time;

	function signed_num_bits (arg: integer) return natural;
	function unsigned_num_bits (arg: natural) return natural;

	subtype byte is std_logic_vector(8-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype integer64 is time;
	type integer64_vector is array (natural range <>) of integer64;

	function toupper(
		constant char : character)
		return character;

	function tolower(
		constant char : character)
		return character;

	function isalpha (
		constant char : character)
		return boolean;

	function isspace (
		constant char : character)
		return boolean;

	function isword (
		constant stream : string)
		return natural;

	function strlen (
		constant str : string)
		return natural;

	function strcmp (
		constant str1 : in string;
		constant str2 : in string)
		return boolean;

	function strstr(
		constant key    : string;
		constant domain : string)
		return natural;

	function strrev (
		constant arg : string)
		return string;

	function strfill (
		constant s    : string;
		constant size : natural;
		constant char : character := NUL)
		return string;

	function shift_right (
		constant arg1 : string;
		constant arg2 : natural)
		return string;

	function itoa (
		constant arg : integer)
		return string;

	function ftoa (
		constant num     : real;
		constant ndigits : natural)
		return string;

	function to_stdlogicvector (
		constant arg : string)
		return std_logic_vector;

	function to_bytevector (
		constant arg : string)
		return byte_vector;

	function to_bytevector (
		constant arg : std_logic_vector)
		return byte_vector;

	function to_bitrom (
		constant data : natural_vector;
		constant size : natural)
		return std_logic_vector;

	function to_bitrom (
		constant data : integer_vector;
		constant size : natural)
		return std_logic_vector;

	function summation (
		constant elements : natural_vector)
		return natural;

	function push_left (
		constant queue   : std_logic_vector;
		constant element : std_logic_vector)
		return std_logic_vector;

	function reverse (
		constant arg : std_logic_vector;
		constant keep_range : boolean := true)
		return std_logic_vector;

	function reverse (
		constant arg  : std_logic_vector;
		constant size : natural)
		return std_logic_vector;

	function reverse (
		constant arg : unsigned)
		return unsigned;

	function reverse (
		constant arg  : unsigned;
		constant size : natural)
		return unsigned;

	function to_ascii(
		constant arg : string)
		return std_logic_vector;

	function to_utf16(
		constant arg : string)
		return std_logic_vector;

	function to_bcd (
		constant arg : string)
		return std_logic_vector;

	function neg (
		constant arg : signed;
		constant ena : std_logic := '1')
		return signed;

	function mul (
		constant op1 : signed;
		constant op2 : unsigned)
		return signed;

	function mul (
		constant op1 : signed;
		constant op2 : natural)
		return signed;

	function mul (
		constant op1 : unsigned;
		constant op2 : natural)
		return unsigned;

	-- Logic Functions
	------------------

	function wor (
		constant arg : std_logic_vector)
		return std_logic;

	function wirebus (					-- Solve Xilinx XST bug
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic;

	function wirebus (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic_vector;

	function wirebus (
		constant arg1 : natural_vector;
		constant arg2 : std_logic_vector)
		return natural;

	function wirebus (
		constant arg1 : integer_vector;
		constant arg2 : std_logic_vector)
		return integer;

	function setif (
		constant arg  : boolean;
		constant argt : boolean := true;
		constant argf : boolean := false)
		return boolean;

	function setif (
		constant arg  : boolean;
		constant argt : bit := '1';
		constant argf : bit := '0')
		return bit;

	function setif (
		constant arg  : boolean;
		constant argt : std_logic := '1';
		constant argf : std_logic := '0')
		return std_logic;

	function setif (
		constant arg   : boolean;
		constant argt  : std_logic_vector;
		constant argf  : std_logic_vector)
		return std_logic_vector;

	function setif (
		constant arg   : boolean;
		constant argt  : unsigned;
		constant argf  : unsigned)
		return unsigned;

	function setif (
		constant arg   : boolean;
		constant argt  : unsigned;
		constant argf  : unsigned)
		return std_logic_vector;

	function setif (
		constant arg  : boolean;
		constant argt : integer := 1;
		constant argf : integer := 0)
		return integer;

	function setif (
		constant arg  : boolean;
		constant argt : real;
		constant argf : real)
		return real;

	function setif (
		constant arg  : boolean;
		constant argt : string;
		constant argf : string)
		return string;

	function primux (
		constant inp  : std_logic_vector;
		constant ena  : std_logic_vector;
		constant def  : std_logic_vector := (0 to 0 => '0'))
		return std_logic_vector;

	function primux (
		constant inp  : natural_vector;
		constant ena  : std_logic_vector;
		constant def  : natural := 0)
		return natural;

	function multiplex (		-- Solve Xilinx XST bug
		constant word : std_logic_vector;
		constant addr : std_logic_vector)
		return std_logic;

	function multiplex (		-- Solve Xilinx XST bug
		constant word : unsigned;
		constant addr : std_logic_vector)
		return std_logic;

	function multiplex (		-- Solve Xilinx XST bug
		constant word : unsigned;
		constant addr : unsigned)
		return std_logic;

	function multiplex (		-- Solve Xilinx XST bug
		constant word : std_logic_vector;
		constant addr : std_logic)
		return std_logic;

	function multiplex (
		constant word : std_logic_vector;
		constant addr : std_logic_vector)
		return std_logic_vector;

	function multiplex (
		constant word : unsigned;
		constant addr : unsigned)
		return unsigned;

	function multiplex (
		constant word : std_logic_vector;
		constant addr : std_logic)
		return std_logic_vector;

	function multiplex (
		constant word : unsigned;
		constant addr : std_logic)
		return unsigned;
	
	function multiplex (
		constant word : signed;
		constant addr : std_logic)
		return signed;

	function multiplex (
		constant word  : std_logic_vector;
		constant addr  : std_logic_vector;
		constant size  : natural)
		return std_logic_vector;

	function multiplex (
		constant word  : std_logic_vector;
		constant addr  : natural;
		constant size  : natural)
		return std_logic_vector;

	function multiplex (
		constant word  : natural_vector;
		constant addr  : std_logic_vector)
		return natural;

	function byte2word (
		constant word : std_logic_vector;
		constant addr : std_logic_vector;
		constant data : std_logic_vector)
		return std_logic_vector;

	subtype gray is std_logic_vector;

	function inc (
		constant arg : gray)
		return gray;

	function pulse_delay (
		constant phase     : std_logic_vector;
		constant latency   : natural := 0;
		constant extension : natural := 0;
		constant word_size : natural := 4;
		constant width     : natural := 1)
		return std_logic_vector;

	-----------
	-- ASCII --
	-----------

	function to_string (
		constant arg : std_logic_vector)
		return string;

	function to_string (
		constant arg : unsigned)
		return string;

	function to_stdlogicvector (
		constant arg : byte_vector)
		return std_logic_vector;

	function max (
		constant data : natural_vector)
		return natural;

	function max (
		constant data : integer_vector)
		return integer;

	function max (
		constant arg1 : integer;
		constant arg2 : integer)
		return integer;

	function max (
		constant arg1 : signed;
		constant arg2 : signed)
		return signed;

	function min (
		constant arg1 : integer;
		constant arg2 : integer)
		return integer;

	function min (
		constant arg1 : signed;
		constant arg2 : signed)
		return signed;

	procedure swap (
		variable arg1 : inout character;
		variable arg2 : inout character);

	procedure swap (
		variable arg1 : inout std_logic_vector;
		variable arg2 : inout std_logic_vector);

	function ispower2(
		constant value : natural)
		return boolean;

	function oneschecksum (
		constant data : std_logic_vector;
		constant size : natural)
		return std_logic_vector;

	function ipheader_checksummed (
		constant ipheader : std_logic_vector)
		return std_logic_vector;

	function udp_checksum (
		constant src : std_logic_vector(0 to 32-1);
		constant dst : std_logic_vector(0 to 32-1);
		constant udp : std_logic_vector)
		return std_logic_vector;

	function udp_checksummed (
		constant src : std_logic_vector(0 to 32-1);
		constant dst : std_logic_vector(0 to 32-1);
		constant udp : std_logic_vector)
		return std_logic_vector;

	function encoder (
		constant arg : std_logic_vector)
		return         std_logic_vector;

	function fill (
		constant data  : std_logic_vector;
		constant size  : natural;
		constant right : boolean := true;
		constant full  : boolean := false;
		constant value : std_logic := '-')
		return std_logic_vector;

	function bcd2ascii (
		constant arg : std_logic_vector)
		return std_logic_vector;

	function galois_crc (
		constant m : std_logic_vector;
		constant r : std_logic_vector;
		constant g : std_logic_vector)
		return std_logic_vector;

	function gcd(
		constant a : natural; 
		constant b : natural)
		return natural;
		
	function mcm(
		constant a : natural; 
		constant b : natural)
		return natural;
		
end;

use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

package body base is

	function toupper(
		constant char : character)
		return character is
	begin
		if character'pos('a') > character'pos(char) then
			return char;
		elsif character'pos('z') < character'pos(char) then
			return char;
		else
			return character'val(character'pos(char)-character'pos('a')+ character'pos('A'));
		end if;
	end;

	function tolower(
		constant char : character)
		return character is
	begin
		if character'pos('A') > character'pos(char) then
			return char;
		elsif character'pos('Z') < character'pos(char) then
			return char;
		else
			return character'val(character'pos(char)-character'pos('A')+ character'pos('a'));
		end if;
	end;

	function isalpha (
		constant char : character)
		return boolean is
	begin
		if    character'pos('a') > character'pos(tolower(char)) then
			return false;
		elsif character'pos('z') < character'pos(tolower(char)) then
			return false;
		else 
			return true;
		end if;
	end;

	function isspace (
		constant char : character)
		return boolean is
	begin
		case char is
		when ' ' =>
			return true;
		when others =>
			return false;
		end case;
	end;

	function isword (
		constant stream : string)
		return natural is
	begin
		for i in stream'range loop
			if isalpha(stream(i)) then
				next;
			elsif stream(i)='-' then
				next;
			else
				return i-1;
			end if;
		end loop;
		return stream'right;
	end;

	function strfill (
		constant s    : string;
		constant size : natural;
		constant char : character := NUL)
		return string
	is
		variable retval : string(1 to size);
	begin
		retval := (others => char);
		retval(1 to s'length) := s;
		return retval;
	end;

	function strcmp (
		constant str1 : in string;
		constant str2 : in string)
		return boolean
	is
		alias astr1 : string(1 to str1'length) is str1;
		alias astr2 : string(1 to str2'length) is str2;
	begin
--		report astr2 & " " & astr1;
--		report integer'image(astr2'length) & " " & integer'image(astr1'length);
		if strlen(str1)/=strlen(str2) then
			return false;
		else
		 	for i in 1 to strlen(str1) loop
				if astr1(i)/=astr2(i) then
					return false;
				end if;
			end loop;
			return true;
		end if;
	end;

	procedure strcmp (
		variable sucess : inout boolean;
		variable index  : inout natural;
		constant key    : in    string;
		constant domain : in    string)
	is
	begin
		sucess := false;
		for i in key'range loop
			if index < domain'length then
				if key(i)/=domain(index) then
					return;
				else
					index := index + 1;
				end if;
			elsif key(i)=NUL then
				sucess := true;
				return;
			else
				return;
			end if;
		end loop;
		if index < domain'length then
			if domain(index)=NUL then
				sucess := true;
				return;
			else
				return;
			end if;
		else
			sucess := true;
			return;
		end if;
	end;

	function strstr(
		constant key    : string;
		constant domain : string)
		return natural is
		variable sucess : boolean;
		variable index  : natural;
		variable ref    : natural;
	begin
		ref   := 0;
		index := domain'left;
		while index < domain'right loop
			strcmp(sucess, index, key, domain);
			if sucess then
				return ref;
			end if;
			while domain(index) /= NUL loop
				index := index + 1;
			end loop;
			index := index + 1;
		end loop;
	end;

	function strlen (
		constant str : string)
		return natural
	is
		variable retval : natural;
	begin
		retval := 0;
		for i in str'range loop
			if str(i)=NUL then
				return retval;
			end if;
			retval := retval + 1;
		end loop;
		return retval;
	end;

	function strrev (
		constant arg : string)
		return string
	is
		variable retval : string(1 to arg'length);
	begin
		retval := arg;
		for i in 1 to retval'length/2 loop
			swap(retval(i), retval(retval'length+1-i));
		end loop;
		return retval;
	end;

	function shift_right (
		constant arg1 : string;
		constant arg2 : natural)
		return string is
		variable retval : string(arg1'range);
	begin
		retval := arg1;
		for i in arg1'reverse_range loop
			if i > arg2 then
				retval(i) := arg1(i-arg2);
			end if;
			for i in 1 to arg2 loop
				retval(i) := ' ';
			end loop;
		end loop;
		return retval;
	end;

	function itoa (
		constant arg : integer)
		return string
	is
		constant asciitab : string(1 to 10) := "0123456789";
		variable retval   : string(1 to 256) := (others => NUL);
		variable value    : natural;
	begin
		value := abs(arg);
		for i in retval'range loop
			retval(i) := asciitab((value mod 10)+1);
			value     := value / 10;
			if value=0 then
				if arg < 0 then
					retval(i+1) := '-';
				end if;
				exit;
			end if;
		end loop;
		return strrev(retval(1 to strlen(retval)));
	end;

	function ftoa (
		constant num     : real;
		constant ndigits : natural)
		return string is
		constant lookup : string := "0123456789";

		variable mant   : real;
		variable exp    : integer;
		variable retval : string(1 to ndigits+1);
		variable cy     : natural range 0 to 1;
		variable digit  : natural range 0 to 9;
		variable n      : natural;

		variable msg    : line;
	begin
		mant := abs(num);
		exp  := 0;
		n    := 1;
		retval(1) := '0';
		if mant/=0.0 then
			if mant > 1.0 then
				loop
					exit when mant >= 1.0;
					mant := mant * 2.0;
					exp  := exp - 1;
				end loop;

				loop
					exit when mant < 1.0;
					mant := mant / 2.0;
					exp  := exp + 1;
				end loop;

				double_dabble_lp : for i in 0 to exp-1 loop
					mant  := mant * 2.0;
					cy    := setif(mant >= 1.0, 1, 0);
					mant  := mant - real(cy);
					for i in n downto 1 loop
						digit := character'pos(retval(i))-character'pos('0');
						if digit < 5 then
							retval(i) := lookup(2*digit+cy+1);
							cy := 0;
						else
							retval(i) := lookup(2*digit+cy-10+1);
							cy := 1;
						end if;
					end loop;
					if cy > 0 then
						retval := shift_right(retval, 1);
						n      := n + 1;
						retval(1) := '1';
					end if;
				end loop;

			end if;
		end if;

		n := n + 1;
		retval(n) := '.';
		for i in 1 to ndigits-n loop
			digit := natural(floor(10.0*mant));
			mant  := mant*10.0-floor(10.0*mant);
			retval(n+i) := lookup(digit+1);
		end loop;
		n := ndigits;

		cy := setif(character'pos(retval(n))-character'pos('0') >= 5, 1, 0);
		round_loop : if cy > 0 then
			for i in n downto 1 loop
				next when retval(i)='.';
				digit := character'pos(retval(i))-character'pos('0');
				if digit < 9 then
					retval(i) := lookup(digit+cy+1);
					cy := 0;
				elsif cy > 0 then
					retval(i) := lookup(digit+cy-10+1);
					cy := 1;
				end if;
			end loop;
			if cy > 0 then
				retval := shift_right(retval, 1);
				n      := n + 1;
				retval(1) := '1';
			end if;
		end if;

		if num < 0.0 then
			retval := shift_right(retval,1);
			retval(1) := '-';
		end if;
		if retval(ndigits)='.' then
			retval := shift_right(retval,1);
		end if;

--		write(msg, string'(" -> ") & retval(1 to ndigits));
--		writeline(output, msg);
--		write(msg, mant);
--		write(msg, string'(" : "));
--		write(msg, exp);
--		writeline(output, msg);
		return retval(1 to ndigits);
	end;

	function encoder (
		constant arg : std_logic_vector)
		return   std_logic_vector is
		variable val : std_logic_vector(0 to unsigned_num_bits(arg'length-1)-1) := (others => '-');
		variable aux : unsigned(0 to arg'length-1) := (0 => '1', others => '0');
	begin
		for i in aux'range loop
			if arg=std_logic_vector(aux) then
				val := std_logic_vector(to_unsigned(i, val'length));
			end if;
			aux := aux ror 1;
		end loop;
		return val;
	end;

	function oneschecksum (
		constant data : std_logic_vector;
		constant size : natural)
		return std_logic_vector is
		constant n        : natural := (data'length+size-1)/size;
		variable aux      : unsigned(0 to n*size-1);
		variable checksum : unsigned(0 to size);
		variable retval   : std_logic_vector(0 to size-1);
	begin
		aux := (others => '0');
		aux(0 to data'length-1) := unsigned(data);
		checksum := ('0', others => '1');
		for i in 0 to n-1 loop
			checksum := checksum + resize(aux(0 to size-1), checksum'length);
			if checksum(0)='1' then
				checksum := checksum + to_unsigned(1, checksum'length); -- Xilinx's bug
			end if;
			checksum(0) := '0';
			aux := aux sll size;
		end loop;
		return std_logic_vector(checksum(1 to size));
	end;

	function ipheader_checksummed(
		constant ipheader : std_logic_vector)
		return std_logic_vector is
		variable aux : std_logic_vector(0 to ipheader'length-1);
	begin
		aux := ipheader;
		aux(80 to 96-1) := (others => '0');
		aux(80 to 96-1) := not oneschecksum(aux, 16);
		return aux;
	end;

	function udp_checksum(
		constant src : std_logic_vector(0 to 32-1);
		constant dst : std_logic_vector(0 to 32-1);
		constant udp : std_logic_vector)
		return std_logic_vector is
		variable aux : unsigned(0 to 32+src'length+dst'length+udp'length-1) := (others => '0');
		variable retval : std_logic_vector(0 to 16-1);
	begin
		aux(src'range) := unsigned(src);
		aux := aux rol src'length;
		aux(dst'range) := unsigned(dst);
		aux := aux rol dst'length;
		aux( 0 to 16-1) := x"0011";
		aux(16 to 32-1) := to_unsigned(udp'length/8, 16);
		aux := aux rol 32;

		aux(0 to udp'length-1) := unsigned(udp);
		retval := not oneschecksum(std_logic_vector(aux), 16);
		if retval=(retval'range => '0') then
			retval := (others => '1');
		end if;
		return retval;
	end;

	function udp_checksummed(
		constant src  : std_logic_vector(0 to 32-1);
		constant dst  : std_logic_vector(0 to 32-1);
		constant udp  : std_logic_vector)
		return std_logic_vector is
		variable len : unsigned(0 to 16-1);
		variable aux : unsigned(0 to udp'length+src'length+32+dst'length-1) := (others => '0');
	begin
		aux(0 to udp'length-1) := unsigned(udp);
		len := aux(32 to 48-1);
		aux := aux rol udp'length;
		aux(src'range) := unsigned(src);
		aux := aux rol src'length;
		aux(dst'range) := unsigned(dst);
		aux := aux rol dst'length;
		aux( 0 to 16-1) := x"0011";
		aux(16 to 32-1) := len;
		aux := aux rol 32;

		aux(48 to 64-1) := unsigned(oneschecksum(not std_logic_vector(aux), 16));
		return std_logic_vector(aux(0 to udp'length-1));
	end;

	------------------
	-- Array functions
	------------------

	function reverse (
		constant arg : std_logic_vector;
		constant keep_range : boolean := true)
		return std_logic_vector is
		variable range_inverted  : std_logic_vector(arg'reverse_range);
		variable range_unchanged : std_logic_vector(arg'range);
	begin
		-- Possible Xilinx ISE's bug
		for i in arg'range loop
			range_inverted(i) := arg(i);
		end loop;

		range_unchanged := range_inverted;
		if keep_range then
			return range_unchanged;
		else
			return range_inverted;
		end if;
	end;

	function reverse (
		constant arg  : std_logic_vector;
		constant size : natural)
		return std_logic_vector is
		variable aux : std_logic_vector(0 to size*((arg'length+size-1)/size)-1);
	begin

		aux(0 to arg'length-1) := arg;
		for i in 0 to aux'length/size-1 loop
			aux(0 to size-1) := reverse(aux(0 to size-1));
			aux:= std_logic_vector(unsigned(aux) rol size);
		end loop;
		return aux(0 to arg'length-1);
	end;

	function reverse (
		constant arg  : unsigned)
		return unsigned is
	begin
		return unsigned(reverse(std_logic_vector(arg)));
	end;

	function reverse (
		constant arg  : unsigned;
		constant size : natural)
		return unsigned is
	begin
		return unsigned(reverse(std_logic_vector(arg), size));
	end;

	function summation (
		constant elements : natural_vector)
		return natural is
		variable retval : natural;
	begin
		retval := 0;
		for i in elements'range loop
			retval := retval + elements(i);
		end loop;
		return retval;
	end;

	function push_left (
		constant queue   : std_logic_vector;
		constant element : std_logic_vector)
		return std_logic_vector is
		variable retval  : unsigned(0 to queue'length-1);
	begin
		retval := unsigned(queue);
		retval := retval srl element'length;
		retval(0 to element'length-1) := unsigned(element);
		return std_logic_vector(retval);
	end;

	function to_ascii(
		constant arg : string)
		return std_logic_vector is
		subtype ascii is std_logic_vector(0 to 8-1);
		variable retval : unsigned(0 to ascii'length*arg'length-1) := (others => '0');
	begin
		for i in arg'range loop
			retval(ascii'range) := to_unsigned(character'pos(arg(i)), ascii'length);
			retval := retval rol ascii'length;
		end loop;
		return std_logic_vector(retval);
	end;

	function to_utf16(
		constant arg : string)
		return std_logic_vector is
		subtype utf16 is std_logic_vector(0 to 16-1);
		variable retval : unsigned(0 to utf16'length*arg'length-1) := (others => '0');
	begin
		for i in arg'range loop
			retval(utf16'range) := to_unsigned(character'pos(arg(i)), utf16'length);
			retval := retval rol utf16'length;
		end loop;
		return std_logic_vector(retval);
	end;

	function to_bcd(
		constant arg    : string)
		return std_logic_vector is
		constant tab    : natural_vector(0 to 12) := (
			character'pos('0'), character'pos('1'), character'pos('2'), character'pos('3'),
			character'pos('4'), character'pos('5'), character'pos('6'), character'pos('7'),
			character'pos('8'), character'pos('9'), character'pos('.'), character'pos('+'),
		   	character'pos('-'));
		variable retval : unsigned(4*arg'length-1 downto 0) := (others => '0');
	begin
		for i in arg'range loop
			retval := retval sll 4;
			for j in tab'range loop
				if character'pos(arg(i))=tab(j) then
					retval(4-1 downto 0) := to_unsigned(j, 4);
					exit;
				end if;
			end loop;
		end loop;
		return std_logic_vector(retval);
	end;

	function to_bytevector (
		constant arg : std_logic_vector)
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'length-1 downto 0));
			dat := dat srl byte'length;
		end loop;
		return val;
	end;

	function to_string(
		constant arg : std_logic_vector)
		return string is
		variable aux    : unsigned(0 to arg'length-1);
		variable retval : string(1 to arg'length);
	begin
		aux := unsigned(arg);
		for i in retval'range loop
			if aux(0)='1' then
				retval(i) := '1';
			else
				retval(i) := '0';
			end if;
--			retval(i) := std_logic'image(aux(0))(2);
			aux := aux sll 1;
		end loop;
		return retval;
	end;

	function to_string(
		constant arg : unsigned)
		return string is
	begin
		return to_string(std_logic_vector(arg));
	end;

	function to_stdlogicvector (
		constant arg : character)
		return std_logic_vector is
		variable val : unsigned(byte'length-1 downto 0);
	begin
		val(byte'range) := to_unsigned(character'pos(arg),byte'length);
		return std_logic_vector(val);
	end function;

	function to_stdlogicvector (
		constant arg : string)
		return std_logic_vector is
		variable val : unsigned(arg'length*byte'length-1 downto 0);
	begin
		for i in arg'range loop
			val := val sll byte'length;
			val(byte'range) := to_unsigned(character'pos(arg(i)),byte'length);
		end loop;
		return std_logic_vector(val);
	end function;

	function to_bytevector (
		constant arg : string)
		return byte_vector is
		variable val : byte_vector(arg'range);
	begin
		for i in arg'range loop
			val(i) := std_logic_vector(unsigned'(to_unsigned(character'pos(arg(i)),byte'length)));
		end loop;
		return val;
	end function;

	function to_bitrom (
		constant data : natural_vector;
		constant size : natural)
		return std_logic_vector is
		alias    dataa  : natural_vector(0 to data'length-1) is data;
		variable retval : unsigned(0 to data'length*size-1);
	begin
		for i in dataa'range loop
			retval(i*size to (i+1)*size-1) := to_unsigned(dataa(i), size);
		end loop;
		return std_logic_vector(retval);
	end;

	function to_bitrom (
		constant data : integer_vector;
		constant size : natural)
		return std_logic_vector is
		alias    dataa  : integer_vector(0 to data'length-1) is data;
		variable retval : signed(0 to data'length*size-1);
	begin
		for i in dataa'range loop
			retval(i*size to (i+1)*size-1) := to_signed(dataa(i), size);
		end loop;
		return std_logic_vector(retval);
	end;

	--------------------
	-- Logical functions
	--------------------

	function wor (
		constant arg : std_logic_vector)
		return std_logic is
	begin
		for i in arg'range loop
			if arg(i)='1' then
				return '1';
			end if;
		end loop;
		return '0';
	end;

	function wirebus (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic is
		variable retval : std_logic_vector(0 to 0);
	begin
		retval := wirebus(arg1, arg2);
		return retval(0);
	end;

	function wirebus (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic_vector is
		variable aux    : unsigned(0 to arg1'length-1) := (others => '0');
		variable retval : std_logic_vector(0 to arg1'length/arg2'length-1);
	begin
		assert arg1'length mod arg2'length = 0
			report "std_logic wirebus " & itoa(arg1'length) & " " & itoa(arg2'length)
			severity failure;

		aux(0 to arg1'length-1) := unsigned(arg1);
		retval := (others => '0');
		for i in arg2'range loop
			if arg2(i)='1' then
				retval := retval or std_logic_vector(aux(retval'range));
			end if;
			aux := aux sll retval'length;
		end loop;
		return retval;
	end;

	function wirebus (
		constant arg1 : natural_vector;
		constant arg2 : std_logic_vector)
		return natural is
		variable aux1 : natural_vector(0 to arg1'length-1);
		variable aux2 : std_logic_vector(0 to arg2'length-1);
		variable retval : natural;
	begin
		assert arg1'length mod arg2'length = 0
			report "natural wirebus " & itoa(arg1'length) & " " & itoa(arg2'length)
			severity failure;

		aux1 := arg1;
		aux2 := arg2;
		for i in aux2'range loop
			if aux2(i)='1' then
				retval := aux1(i);
			end if;
		end loop;
		return retval;
	end;

	function wirebus (
		constant arg1 : integer_vector;
		constant arg2 : std_logic_vector)
		return integer is
		variable aux1 : integer_vector(0 to arg1'length-1);
		variable aux2 : std_logic_vector(0 to arg2'length-1);
		variable retval : integer;
	begin
		assert arg1'length mod arg2'length = 0
			report "integer wirebus " & itoa(arg1'length) & " " & itoa(arg2'length)
			severity failure;


		aux1 := arg1;
		aux2 := arg2;
		for i in aux2'range loop
			if aux2(i)='1' then
				retval := aux1(i);
			end if;
		end loop;
		return retval;
	end;

	function setif (
		constant arg  : boolean;
		constant argt : boolean := true;
		constant argf : boolean := false)
		return boolean is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : bit := '1';
		constant argf : bit := '0')
		return bit is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : std_logic := '1';
		constant argf : std_logic := '0')
		return std_logic is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : unsigned;
		constant argf : unsigned)
		return unsigned is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : unsigned;
		constant argf : unsigned)
		return std_logic_vector is
	begin
		if arg then
			return std_logic_vector(argt);
		end if;
		return std_logic_vector(argf);
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : std_logic_vector;
		constant argf : std_logic_vector)
		return std_logic_vector is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : integer := 1;
		constant argf : integer := 0)
		return integer is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : real;
		constant argf : real)
		return real is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function setif (
		constant arg  : boolean;
		constant argt : string;
		constant argf : string)
		return string is
	begin
		if arg then
			return argt;
		end if;
		return argf;
	end function;

	function neg (
		constant arg : signed;
		constant ena : std_logic := '1')
		return signed is
	begin
		if ena='1' then
			return -arg;
		end if;
		return arg;
	end;

	function mul (
		constant op1 : signed;
		constant op2 : unsigned)
		return signed is
		variable muld : signed(op1'length-1 downto 0);
		variable mulr : unsigned(op2'length-1 downto 0);
		variable rval : signed(0 to muld'length+mulr'length-1);
	begin
		muld := op1;
		mulr := op2;
		rval := (others => '0');
		for i in mulr'range loop
			rval := shift_right(rval, 1);
			if mulr(0)='1' then
				rval(0 to muld'length) := rval(0 to muld'length) + resize(muld, muld'length+1);
			end if;
			mulr := mulr srl 1;
		end loop;
		return rval;
	end;

	function mul (
		constant op1 : signed;
		constant op2 : natural)
		return signed is
		variable mulr : natural;
		variable muld : signed(op1'length-1 downto 0);
		variable rval : signed(0 to muld'length+unsigned_num_bits(op2)-1);
	begin
		muld := op1;
		mulr := op2;
		rval := (others => '0');
		for i in 0 to unsigned_num_bits(op2)-1 loop
			rval := shift_right(rval, 1);
			if (mulr mod 2)=1 then
				rval(0 to muld'length) := rval(0 to muld'length) + resize(muld, muld'length+1);
			end if;
			mulr := mulr / 2;
		end loop;
		return rval;
	end;

	function mul (
		constant op1 : unsigned;
		constant op2 : natural)
		return unsigned is
		variable mulr : natural;
		variable muld : unsigned(op1'length-1 downto 0);
		variable rval : unsigned(0 to muld'length+unsigned_num_bits(op2)-1);
	begin
		muld := op1;
		mulr := op2;
		rval := (others => '0');
		while mulr /= 0 loop
			rval := shift_right(rval, 1);
			if (mulr mod 2)=1 then
				rval(0 to muld'length) := rval(0 to muld'length) + resize(muld, muld'length+1);
			end if;
			mulr := mulr / 2;
		end loop;
		return rval;
	end;

	function primux (
		constant inp  : std_logic_vector;
		constant ena  : std_logic_vector;
		constant def  : std_logic_vector := (0 to 0 => '0'))
		return std_logic_vector is
		constant size : natural := (inp'length+ena'length-1)/ena'length;
		variable aux  : unsigned(0 to size*ena'length-1) := (others => '0');
		variable rval : std_logic_vector(0 to size-1) := fill(data => def, size => size, right => true);
	begin

		assert inp'length mod ena'length = 0
			report "primux mod"
			severity failure;

		assert inp'length = aux'length
			report "primux length"
			severity failure;

		aux(0 to inp'length-1) := unsigned(inp);
		for i in ena'range loop
			if ena(i)='1' then
				rval := std_logic_vector(aux(0 to size-1));
				exit;
			end if;
			aux := aux rol size;
		end loop;
		return rval;
	end;

	function primux (
		constant inp  : natural_vector;
		constant ena  : std_logic_vector;
		constant def  : natural := 0)
		return natural is
		alias alias_inp : natural_vector(0 to inp'length-1) is inp;
		alias alias_ena : std_logic_vector(0 to ena'length-1) is ena;
	begin
		for i in alias_ena'range loop
			if i < alias_inp'length then
				if alias_ena(i)='1' then
					return alias_inp(i);
				end if;
			else
				exit;
			end if;
		end loop;
		return def;
	end;

	function multiplex (
		constant word : std_logic_vector;
		constant addr : std_logic_vector)
		return std_logic is
		variable retval : std_logic_vector(0 to 0);
	begin
		retval := multiplex(word, addr, 1);
		return retval(0);
	end;

	function multiplex (
		constant word : unsigned;
		constant addr : std_logic_vector)
		return std_logic is
	begin
		return multiplex(std_logic_vector(word), addr);
	end;

	function multiplex (
		constant word : unsigned;
		constant addr : unsigned)
		return std_logic is
	begin
		return multiplex(std_logic_vector(word), std_logic_vector(addr));
	end;

	function multiplex (
		constant word : std_logic_vector;
		constant addr : std_logic)
		return std_logic is
		variable retval : std_logic_vector(0 to 0);
	begin
		retval := multiplex(word, (0 to 0 => addr), 1);
		return retval(0);
	end;

	function multiplex (
		constant word : unsigned;
		constant addr : std_logic)
		return unsigned is
	begin
		return unsigned(std_logic_vector'(multiplex(std_logic_vector(word), addr)));
	end;

	function multiplex (
		constant word : std_logic_vector;
		constant addr : std_logic_vector)
		return std_logic_vector is
		variable aux  : std_logic_vector(0 to word'length-1);
		variable byte : std_logic_vector(0 to word'length/2**addr'length-1);
	begin
		assert word'length mod byte'length = 0
			report "multiplex mod"
			severity failure;

		assert word'length mod 2**addr'length = 0
			report "multiplex mod"
			severity failure;

		aux := word;
		for i in byte'range loop
			byte(i) := aux(byte'length*to_integer(unsigned(addr))+i);
		end loop;
		return byte;
	end;

	function multiplex (
		constant word : unsigned;
		constant addr : unsigned)
		return unsigned is
	begin
		return unsigned(std_logic_vector'(multiplex(std_logic_vector(word), std_logic_vector(addr))));
	end;

	function multiplex (
		constant word : std_logic_vector;
		constant addr : std_logic)
		return std_logic_vector is
	begin
		return multiplex(word, (0 to 0 => addr));
	end;

	function multiplex (
		constant word : signed;
		constant addr : std_logic)
		return signed is
	begin
		return signed(std_logic_vector'(multiplex(std_logic_vector(word), (0 to 0 => addr))));
	end;

	function multiplex (
		constant word  : std_logic_vector;
		constant addr  : std_logic_vector;
		constant size  : natural)
		return std_logic_vector is
	begin
		assert word'length mod size = 0
			report "multiplex mod"
			severity failure;
		return multiplex(fill(data => word, size => size*(2**addr'length), right => true), addr);
	end;

	function multiplex (
		constant word  : std_logic_vector;
		constant addr  : natural;
		constant size  : natural)
		return std_logic_vector is
		variable aux : unsigned(0 to size*((word'length+size-1)/size)-1);
	begin
		assert word'length mod size = 0
			report "multiplex mod"
			severity failure;
		aux(0 to word'length-1) := unsigned(word);
		aux := aux rol ((addr*size) mod word'length);
		return std_logic_vector(aux(0 to size-1));
	end;

	function multiplex (
		constant word  : natural_vector;
		constant addr  : std_logic_vector)
		return natural is
		alias    arg    : natural_vector(0 to word'length-1) is word;
		variable retval : natural_vector(0 to 2**addr'length-1);
	begin
		retval := (others => 0);
		if retval'length < arg'length then
			retval := arg(retval'range);
		else
			retval(arg'range) := arg;
		end if;

		return retval(to_integer(unsigned(addr)));
	end;

	function byte2word (
		constant word : std_logic_vector;
		constant addr : std_logic_vector;
		constant data : std_logic_vector)
		return std_logic_vector is
		variable retval : unsigned(0 to data'length*((word'length+data'length-1)/data'length)-1);
	begin
		assert word'length mod data'length=0
		report "byte2word"
		severity failure;
		retval(0 to word'length-1) := unsigned(word);
		for i in 0 to retval'length/data'length-1 loop
			if to_unsigned(i,addr'length)=unsigned(addr) then
				retval(0 to data'length-1) := unsigned(data);
			end if;
			retval := retval rol data'length;
		end loop;
		return std_logic_vector(retval(0 to word'length-1));
	end;

	function inc (
		constant arg : gray)
		return gray is
		variable a : std_logic_vector(arg'length-1 downto 0);
		variable t : std_logic_vector(a'range) := (others => '0');
	begin
		a := std_logic_vector(arg);
		for i in a'reverse_range loop
			for j in i to a'left loop
				t(i) := t(i) xor a(j);
			end loop;
			t(i) := not t(i);
			if i > 0 then
				for j in 0 to i-1 loop
					t(i) := t(i) and (not t(j));
				end loop;
			end if;
		end loop;
		if t'length > 1 then
			if t(a'left-1 downto 0)=(1 to a'left => '0') then
				t(a'left) := '1';
			end if;
		else
			t(a'left) := '1';
		end if;
		return gray(a xor t);
	end function;

	-----------
	-- ASCII --
	-----------

	function to_stdlogicvector (
		constant arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : unsigned(byte'length*arg'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll byte'length;
			val(byte'range) := unsigned(dat(i));
		end loop;
		return std_logic_vector(val);
	end;

	function max (
		constant data : natural_vector)
		return natural is
		variable val : natural:= data(data'left);
	begin
		for i in data'range loop
			if val < data(i) then
				val := data(i);
			end if;
		end loop;
		return val;
	end;

	function max (
		constant data : integer_vector)
		return integer is
		variable val : integer:= data(data'left);
	begin
		for i in data'range loop
			if val < data(i) then
				val := data(i);
			end if;
		end loop;
		return val;
	end;

	function max (
		constant arg1 : integer;
		constant arg2 : integer)
		return integer is
	begin
		if arg1 > arg2 then
			return arg1;
		else
			return arg2;
		end if;
	end;

	function max (
		constant arg1 : signed;
		constant arg2 : signed)
		return signed is
	begin
		if arg1 > arg2 then
			return arg1;
		else
			return arg2;
		end if;
	end;

	function min (
		constant arg1 : integer;
		constant arg2 : integer)
		return integer is
	begin
		if arg1 < arg2 then
			return arg1;
		else
			return arg2;
		end if;
	end;

	function min (
		constant arg1 : signed;
		constant arg2 : signed)
		return signed is
	begin
		if arg1 < arg2 then
			return arg1;
		else
			return arg2;
		end if;
	end;

	procedure swap (
		variable arg1 : inout character;
		variable arg2 : inout character)
	is
		variable aux : character;
	begin
		aux  := arg1;
		arg1 := arg2;
		arg2 := aux;
	end;

	procedure swap (
		variable arg1 : inout std_logic_vector;
		variable arg2 : inout std_logic_vector)
	is
		variable aux : std_logic_vector(arg1'range);
	begin
		aux  := arg1;
		arg1 := arg2;
		arg2 := aux;
	end;

	function ispower2(
		constant value : natural)
		return boolean is
		variable div  : natural;
		variable rmdr : natural;
	begin
		rmdr := 0;
		div  := value;
		while div /= 0 loop
			exit when rmdr /= 0;
			rmdr := div mod 2;
			div  := div  /  2;
		end loop;
		if div /= 0 then
			return false;
		end if;
		return true;
	end;

	function signed_num_bits (
		arg: integer)
		return natural is
		variable nbits : natural;
		variable n : natural;
	begin
		if arg>= 0 then
			n := arg;
		else
			n := -(arg+1);
		end if;
		nbits := 1;
		while n>0 loop
			nbits := nbits + 1;
			n := n / 2;
		end loop;
		return nbits;
	end;

	function unsigned_num_bits (
		arg: natural)
		return natural is
		variable nbits: natural;
		variable n: natural;
	begin
		n := arg;
		nbits := 1;
		while n > 1 loop
			nbits := nbits+1;
			n := n / 2;
		end loop;
		return nbits;
	end;

	function pulse_delay (
		constant phase     : std_logic_vector;
		constant latency   : natural := 0;
		constant extension : natural := 0;
		constant word_size : natural := 4;
		constant width     : natural := 1)
		return std_logic_vector is

		variable latency_mod : natural;
		variable latency_quo : natural;
		variable delay     : natural;
		variable pulse     : std_logic;

		variable distance  : natural;
		variable width_quo : natural;
		variable width_mod : natural;
		variable tail      : natural;
		variable tail_quo  : natural;
		variable tail_mod  : natural;
		variable pulses    : std_logic_vector(0 to word_size-1);
	begin

		latency_mod := latency mod pulses'length;
		latency_quo := latency  /  pulses'length;
		for j in pulses'range loop
			distance  := (extension-j+pulses'length-1)/pulses'length;
			width_quo := (distance+width-1)/width;
			width_mod := (width_quo*width-distance) mod width;

			delay := latency_quo+(j+latency_mod)/pulses'length;
			pulse := phase(delay);

			if width_quo /= 0 then
				tail_quo := width_mod  /  width_quo;
				tail_mod := width_mod mod width_quo;
				for l in 1 to width_quo loop
					tail  := tail_quo + (l*tail_mod) / width_quo;
					pulse := pulse or phase(delay+l*width-tail);
				end loop;
			end if;
			pulses((latency+j) mod pulses'length) := pulse;
		end loop;
		return pulses;
	end;

	function fill (
		constant data  : std_logic_vector;
		constant size  : natural;
		constant right : boolean := true;
		constant full  : boolean := false;
		constant value : std_logic := '-')
		return std_logic_vector is
		variable retval_right : unsigned(0 to size-1)     := (others => value);
		variable retval_left  : unsigned(size-1 downto 0) := (others => value);
	begin
		if full then
				assert true
				report "XXXXXX **** " & natural'image(data'length) & "XXXXXX **** " & natural'image(size)
				severity failure;
			for i in 0 to size/data'length-1 loop

				retval_right := rotate_right(retval_right, data'length);
				retval_right(0 to data'length-1) := unsigned(data);
				retval_left := rotate_left(retval_left, data'length);
				retval_left(data'length-1 downto 0) := unsigned(data);
			end loop;
				return std_logic_vector(retval_right);
			if right then
			else
				return std_logic_vector(retval_left);
			end if;
		else
    		if right then
    			if data'length > size then
    				retval_right(0 to size-1):= resize(rotate_left(unsigned(data), size), size);
    				return std_logic_vector(retval_right(0 to size-1));
    			end if;
    			retval_right(0 to data'length-1) := unsigned(data);
    			return std_logic_vector(retval_right);
    		end if;
    		if data'length > size then
    			retval_left(size-1 downto 0) :=  resize(unsigned(data), size);
    			return std_logic_vector(retval_left(size-1 downto 0));
    		end if;
    		retval_left(data'length-1 downto 0) := unsigned(data);
    		return std_logic_vector(retval_left);
		end if;
	end;

	function bcd2ascii (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable aux : unsigned(0 to arg'length-1);
		variable val : unsigned(8*arg'length/4-1 downto 0);
	begin
		val := (others => '-');
		aux := unsigned(arg);
		for i in 0 to aux'length/4-1 loop
			val := val sll 8;
			if to_integer(unsigned(aux(0 to 4-1))) < 10 then
				val(8-1 downto 0) := unsigned'("0011") & unsigned(aux(0 to 4-1));
			elsif to_integer(unsigned(aux(0 to 4-1))) < 15 then
				val(8-1 downto 0) := unsigned'("0010") & unsigned(aux(0 to 4-1));
			else
				val(8-1 downto 0) := x"20";
			end if;
			aux := aux sll 4;
		end loop;
		return std_logic_vector(val);
	end;

	function gcd(
		constant a : natural; 
		constant b : natural)
		return natural is
		variable var_a : natural;
		variable var_b : natural;
		variable aux   : natural;
	begin
		var_a := a;
		var_b := b;
		while var_b /= 0 loop
			aux   := var_b;
			var_b := var_a mod var_b;
			var_a := aux;
		end loop;
		return var_a;
	end function;
		
	function mcm(
		constant a : natural; 
		constant b : natural)
		return natural is
		variable var_a : natural;
		variable var_b : natural;
	begin
		return (a*b)/gcd(a,b);
	end function;
		
	function galois_crc(
		constant m : std_logic_vector;
		constant r : std_logic_vector;
		constant g : std_logic_vector)
		return std_logic_vector is
		variable aux_m : unsigned(0 to m'length-1) := unsigned(m);
		variable aux_r : unsigned(0 to r'length-1) := unsigned(r);
	begin
		for i in aux_m'range loop
			aux_r := (aux_r sll 1) xor ((aux_r'range => aux_r(0) xor aux_m(0)) and unsigned(g));
			aux_m := aux_m sll 1;
		end loop;
		return std_logic_vector(aux_r);
	end;

end;
