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

	subtype integer64 is time;
	type integer64_vector is array (natural range <>) of integer64;

	-------------
	-- string --
	-------------

	subtype ascii is std_logic_vector(8-1 downto 0);

	function toupper(
		constant char : character)
		return character;

	function tolower(
		constant char : character)
		return character;

	function rotate_left (
		constant arg1 : string;
		constant arg2 : natural)
		return string;

	function shift_right (
		constant arg1 : string;
		constant arg2 : natural)
		return string;

	function ftoa (
		constant num     : real;
		constant ndigits : natural)
		return string;

	function to_bcd (
		constant arg : string)
		return std_logic_vector;

	function to_hex(
		constant arg : std_logic_vector)
		return string;

	function to_ascii(
		constant arg : character)
		return std_logic_vector;

	function to_ascii(
		constant arg : std_logic_vector)
		return string;

	function to_ascii(
		constant arg : string)
		return std_logic_vector;

	function to_utf16(
		constant arg : string)
		return std_logic_vector;

	function to_string (
		constant arg : std_logic_vector)
		return string;

	function to_string (
		constant arg : unsigned)
		return string;

	function textalign (
		constant text   : string;
		constant width  : natural;
		constant align  : string := "left")
		return string;

	-----------
	-- arith --
	-----------

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

	function gcd(
		constant a : natural; 
		constant b : natural)
		return natural;
		
	function min (
		constant arg1 : integer;
		constant arg2 : integer)
		return integer;

	function min (
		constant arg1 : signed;
		constant arg2 : signed)
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
		constant op1  : unsigned;
		constant op2  : natural;
		constant size : natural := 0)
		return unsigned;

	function mcm(
		constant a : natural; 
		constant b : natural)
		return natural;
		
	function roundup (
		constant number : natural;
		constant round  : natural)
		return natural;

	function summation (
		constant elements : natural_vector)
		return natural;

	-----------------
	-- bit-shuffle --
	-----------------

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

	---------------------
	-- Logic Functions --
	---------------------

	function "and" (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic)
		return std_logic_vector;

	function "or" (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic)
		return std_logic_vector;

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

	function galois_crc (
		constant m : std_logic_vector;
		constant r : std_logic_vector;
		constant g : std_logic_vector)
		return std_logic_vector;

	-------------
	-- boolean --
	-------------

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

end;

library ieee;
use ieee.math_real.all;

library hdl4fpga;

package body base is

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
		for i in 0 to n loop          -- to avoid synthesizes tools loop-warnings
			exit when n < 2;          -- to avoid synthesizes tools loop-warnings
			nbits := nbits+1;
			n := n / 2;
		end loop;
		return nbits;
	end;

	-------------
	-- string --
	-------------

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
			for j in 1 to arg2 loop
				retval(j) := ' ';
			end loop;
		end loop;
		return retval;
	end;

	function rotate_left (
		constant arg1 : string;
		constant arg2 : natural)
		return string is
		variable retval : string(arg1'range);
	begin
		for i in arg1'range loop
			retval(i) := arg1(arg1'left+(i-arg1'left+arg2) mod arg1'length);
		end loop;
		return retval;
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
					for j in n downto 1 loop
						digit := character'pos(retval(j))-character'pos('0');
						if digit < 5 then
							retval(j) := lookup(2*digit+cy+1);
							cy := 0;
						else
							retval(j) := lookup(2*digit+cy-10+1);
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

		return retval(1 to ndigits);
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

	function to_hex(
		constant arg : std_logic_vector)
		return string is
		constant tab    : string :="01234567890ABCDEF"; 
		variable aux    : unsigned(0 to 4*((arg'length+4-1)/4)-1);
		variable retval : string(1 to aux'length/4);
	begin
		aux := resize(unsigned(arg), aux'length);
		for i in retval'range loop
			retval(i) := tab(to_integer(aux(0 to 4-1))+1);
			aux := aux sll 4;
		end loop;
		return retval;
	end;

	function to_ascii(
		constant arg : character)
		return std_logic_vector is
		subtype ascii is std_logic_vector(0 to 8-1);
	begin
		return std_logic_vector(to_unsigned(character'pos(arg), ascii'length));
	end;

	function to_ascii(
		constant arg : string)
		return std_logic_vector is
		subtype ascii is std_logic_vector(0 to 8-1);
		variable retval : unsigned(0 to ascii'length*arg'length-1) := (others => '0');
	begin
		for i in arg'range loop
			retval(ascii'range) := unsigned(to_ascii(arg(i)));
			retval := retval rol ascii'length;
		end loop;
		return std_logic_vector(retval);
	end;

	function to_ascii(
		constant arg : std_logic_vector)
		return string is
		variable aux    : unsigned(0 to 8*((arg'length+8-1)/8)-1);
		variable retval : string(1 to aux'length/8);
	begin
		aux := resize(unsigned(arg), aux'length);
		for i in retval'range loop
			retval(i) := character'val(to_integer(aux(0 to 8-1)));
			aux := aux sll 8;
		end loop;
		return retval;
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

	function textalign (
		constant text   : string;
		constant width  : natural;
		constant align  : string := "left")
		return string is
		variable retval : string(1 to width);
	begin
		retval := (others => ' ');
		if retval'length < text'length then
			retval := text(text'left to text'left+retval'length-1);
		else
			retval(retval'left to retval'left+text'length-1) := text;
		end if;
		if align="right" then
			retval := rotate_left(retval, text'length);
		elsif align="center" then
			retval := rotate_left(retval, (text'length+width)/2);
		end if; 
		return retval;
	end;

	-----------
	-- arith --
	-----------

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
		constant op1  : signed;
		constant op2  : natural)
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
		constant op1  : unsigned;
		constant op2  : natural;
		constant size : natural := 0)
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
		if size=0 then
			return rval;
		else
			return resize(rval, size);
		end if;
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
		
	function roundup (
		constant number : natural;
		constant round  : natural)
		return natural is
	begin
		return ((number+round-1)/round)*round;
	end;

	-----------------
	-- bit-shuffle --
	-----------------

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

	--------------------
	-- Logical functions
	--------------------

	function "and" (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic)
		return std_logic_vector is
		variable retval : std_logic_vector(arg1'range);
	begin
		retval := arg1;
		for i in retval'range loop
			retval(i) := retval(i) and arg2;
		end loop;
		return retval;
	end;

	function "or" (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic)
		return std_logic_vector is
		variable retval : std_logic_vector(arg1'range);
	begin
		retval := arg1;
		for i in retval'range loop
			retval(i) := retval(i) or arg2;
		end loop;
		return retval;
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
			report "std_logic wirebus " & natural'image(arg1'length) & " " & natural'image(arg2'length)
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
			report "natural wirebus " & natural'image(arg1'length) & " " & natural'image(arg2'length)
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
			report "integer wirebus " & natural'image(arg1'length) & " " & natural'image(arg2'length)
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

	-------------
	-- boolean --
	-------------

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

end;
