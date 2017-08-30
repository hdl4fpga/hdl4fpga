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

package std is

	type natural_vector is array (natural range <>) of natural;
	type integer_vector is array (natural range <>) of integer;

	function signed_num_bits (arg: integer) return natural;
	function unsigned_num_bits (arg: natural) return natural;

	subtype byte is std_logic_vector(8-1 downto 0);
	type byte_vector is array (natural range <>) of byte;
	subtype ascii is byte;

	subtype nibble is std_logic_vector(4-1 downto 0);
	type nibble_vector is array (natural range <>) of nibble;

	subtype integer64 is time;
	type integer64_vector is array (natural range <>) of integer64;

	function to_stdlogicvector (
		constant arg : string)
		return std_logic_vector;

	function to_bytevector (
		constant arg : string)
		return byte_vector;

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector;

	function reverse (
		constant arg : std_logic_vector)
		return std_logic_vector;
	
	function bin2bcd (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector;

	function to_bcd (
		constant arg1 : string;
		constant arg2 : natural)
		return std_logic_vector;

	function to_bcd (
		constant arg1   : real;
		constant arg2   : natural;
		constant sign   : boolean := false)
		return std_logic_vector;

	--------------------
	-- Counter functions
	--------------------

	function inc (
		load : std_logic := '1';
		cntr : unsigned;
		data : unsigned;
		ena  : std_logic := '1')
		return unsigned;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : std_logic_vector)
		return std_logic_vector;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : std_logic_vector)
		return unsigned;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : integer)
		return std_logic_vector;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : integer)
		return unsigned;

	-- Logic Functions
	------------------

	function setif (
		arg : boolean)
		return std_logic;

	function setif (
		arg : boolean)
		return natural;

	function mux (
		constant i : std_logic_vector;
		constant s : std_logic_vector)
		return std_logic;

	function mux (
		constant i : std_logic_vector;
		constant s : std_logic_vector)
		return std_logic_vector;

	function demux (
		constant s : std_logic_vector;
		constant e : std_logic := '1')
		return std_logic_vector;

	function word2byte (
		constant word : std_logic_vector;
		constant addr : std_logic_vector)
		return std_logic_vector;

	function byte2word (
		constant byte : std_logic_vector;
		constant mask : std_logic_vector;
		constant word : std_logic_vector)
		return std_logic_vector;

	function byte2word (
		constant di : byte_vector)
		return std_logic_vector;
	
	subtype gray is std_logic_vector;

	function inc (
		constant arg : gray)
		return gray;
	
	function slll (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic := '0')
		return std_logic_vector;

	function pulse_delay (
		constant clk_phases : natural;
		constant phase     : std_logic_vector;
		constant latency   : natural := 12;
		constant extension : natural := 4;
		constant word_size : natural := 4;
		constant width     : natural := 3)
		return std_logic_vector;
	
	-----------
	-- ASCII --
	-----------

	function to_string (
		constant arg : integer)
		return string;

	function to_string (
		constant arg : character)
		return string;

	function to_ascii (
		constant arg : string)
		return std_logic_vector;

	function to_ascii (
		constant arg : nibble)
		return ascii;

	function align (
		constant arg  : string;
		constant size : natural)
		return string;

	function to_nibble (
		constant arg : std_logic_vector)
		return nibble_vector;

	function to_stdlogicvector (
		constant arg : nibble_vector) 
		return std_logic_vector;

	function to_stdlogicvector (
		constant arg : byte_vector) 
		return std_logic_vector;

	function max (
		constant data : natural_vector)
		return natural;

	function max (
		constant left : integer; 
		constant right: integer)
		return integer;

	function min (
		constant left : integer; 
		constant right: integer)
		return integer;

	function selecton (
		constant condition : boolean;
		constant value_if_true  : integer;
		constant value_if_false : integer)
		return integer;

	function selecton (
		constant condition : boolean;
		constant value_if_true  : real;
		constant value_if_false : real)
		return real;

	function oneschecksum (
		constant data : std_logic_vector;
		constant size : natural)
		return std_logic_vector;

	function ipheader_checksumed (
		constant ipheader : std_logic_vector)
		return std_logic_vector;

	function bcd_add (
		constant a      : std_logic_vector;
		constant b      : std_logic_vector;
		constant cin    : std_logic := '0')
		return std_logic_vector;

	function bcd_sub (
		constant a      : std_logic_vector;
		constant b      : std_logic_vector;
		constant cin    : std_logic := '0')
		return std_logic_vector;

	function encoder (
		constant inp : std_logic_vector)
		return         std_logic_vector;
end;

use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

package body std is

	function bcd_add (
		constant a      : std_logic_vector;
		constant b      : std_logic_vector;
		constant cin    : std_logic := '0')
		return std_logic_vector is
		variable op1    : unsigned(a'length-1 downto 0);
		variable op2    : unsigned(b'length-1 downto 0);
		variable bcd    : unsigned(4 downto 0);
		variable cy     : std_logic;
		variable retval : unsigned(4*((max(b'length,a'length)+4-1)/4)-1 downto 0) := (others => '0');

	begin
		cy  := cin;
		op1 := unsigned(a);
		op2 := unsigned(b);
		for i in 0 to retval'length/4-1 loop
			bcd := resize(op1(4-1 downto 0), bcd'length) + resize(op2(4-1 downto 0), bcd'length);
			if cy='1' then
				bcd := bcd + 1;
			end if;
			retval(4-1 downto 0) := bcd(4-1 downto 0);
			bcd := bcd + unsigned'("00110");
			if bcd(4)='1' then
				retval(4-1 downto 0) := bcd(4-1 downto 0);
			end if;
			cy     := bcd(4);
			op1    := op1 srl 4;
			op2    := op2 srl 4;
			retval := retval ror 4;
		end loop;
		return std_logic_vector(retval);
	end function;

	function bcd_sub (
		constant a      : std_logic_vector;
		constant b      : std_logic_vector;
		constant cin    : std_logic := '0')
		return std_logic_vector is
		variable op1    : unsigned(a'length-1 downto 0);
		variable op2    : unsigned(b'length-1 downto 0);
		variable bcd    : unsigned(4 downto 0);
		variable cy     : std_logic;
		variable retval : unsigned(4*((max(b'length,a'length)+4-1)/4)-1 downto 0) := (others => '0');

	begin
		cy  := cin;
		op1 := unsigned(a);
		op2 := unsigned(b);
		for i in 0 to retval'length/4-1 loop
			bcd := resize(op1(4-1 downto 0), bcd'length) - resize(op2(4-1 downto 0), bcd'length);
			if cy='1' then
				bcd := bcd - 1;
			end if;
			retval(4-1 downto 0) := bcd(4-1 downto 0);
			if bcd(4)='1' then
				retval(4-1 downto 0) := bcd(4-1 downto 0) + unsigned'("1001");
			end if;
			cy     := bcd(4);
			op1    := op1 srl 4;
			op2    := op2 srl 4;
			retval := retval ror 4;
		end loop;
		return std_logic_vector(retval);
	end function;

	function encoder (
		constant inp : std_logic_vector)
		return         std_logic_vector is
		variable val : std_logic_vector(unsigned_num_bits(inp'length-1)-1 downto 0);
	begin
		val := (others => '-');
		for i in 0 to 2**val'length-1 loop
			if i < inp'length then
				if inp=std_logic_vector(to_unsigned(2**i,inp'length)) then
					val := std_logic_vector(to_unsigned(i, val'length));
				end if;
			end if;
		end loop;
		return val;
	end;

	function oneschecksum (
		constant data : std_logic_vector;
		constant size : natural)
		return std_logic_vector is
		constant n : natural := (data'length+size-1)/size;
		variable aux : unsigned(0 to data'length-1);
		variable checksum : unsigned(0 to size);
	begin
		aux := unsigned(data);
		checksum := (others => '0');
		for i in 0 to n-1 loop
			checksum := checksum + resize(unsigned(aux(0 to checksum'right-1)), checksum'length);
			if checksum(0)='1' then
				checksum := checksum + 1;
			end if;
			aux := aux sll checksum'right;
		end loop;
		return std_logic_vector(checksum(1 to size));	
	end;

	function ipheader_checksumed(
		constant ipheader : std_logic_vector)
		return std_logic_vector is
		variable aux : std_logic_vector(0 to ipheader'length-1);
	begin
		aux := ipheader;
		aux(80 to 96-1) := (others => '0');
		aux(80 to 96-1) := not oneschecksum(aux, 16);
		return aux;
	end;

	------------------
	-- Array functions
	------------------

	function reverse (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable aux : std_logic_vector(arg'reverse_range);
		variable val : std_logic_vector(arg'range);
	begin
		for i in arg'range loop
			aux(i) := arg(i);
		end loop;
		val := aux;
		return val;
	end;

	function bin2bcd(
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector is
		variable aux : unsigned(arg2+arg1'length-1 downto 0);
	begin
		aux(arg1'length-1 downto 0) := unsigned(arg1);
		for i in 0 to arg1'length-1 loop
			for j in 0 to arg2/4-1 loop
				if aux(4*(j+1)+arg1'length-1 downto 4*j+arg1'length) >= unsigned'("0101")  then
					aux(4*(j+1)+arg1'length-1 downto 4*j+arg1'length) := aux(4*(j+1)+arg1'length-1 downto 4*j+arg1'length) + 3;
				end if;
			end loop;
			aux := aux sll 1;
		end loop;
		return std_logic_vector(aux(aux'left downto arg1'length));
	end;

	function to_bcd (
		constant arg1   : real;
		constant arg2   : natural;
		constant sign   : boolean := false)
		return std_logic_vector is
		variable i      : natural;
		variable int    : real;
		variable frac   : real;
		variable retval : unsigned(0 to arg2-1) := (others => '-');
	begin
		int  := ieee.math_real.floor(ieee.math_real.sign(arg1)*arg1);
		frac := ieee.math_real.sign(arg1)*arg1-int;
		i    := 0;
		while i < arg2 loop
			if int >= 1.0 or i=0 then
				retval           := retval srl 4;
				retval(0 to 4-1) := to_unsigned(natural(ieee.math_real.floor(int)) mod 10, 4);
				int              := int / 10.0;
			else
				exit;
			end if;
			i := i + 4;
		end loop;
		if i < arg2 then
			if i+8 < arg2 then
				retval := retval srl arg2-i;
				retval := retval(4 to arg2-1) & to_unsigned(10, 4);
			elsif not sign and i+4 < arg2 then
				retval := retval srl arg2-i;
				retval := retval(4 to arg2-1) & to_unsigned(10, 4);
			else
				retval := retval srl arg2-i;
				retval := retval(4 to arg2-1) & "1111";
			end if;
			i := i + 4;
		end if;
		while i < arg2 loop
			frac := frac * 10.0;
			retval := retval(4 to arg2-1) & to_unsigned(natural(ieee.math_real.floor(frac)) mod 10, 4);
			i := i + 4;
		end loop;
		int  := ieee.math_real.floor(ieee.math_real.sign(arg1)*arg1*10.0**(arg2/4-3));
		int  := ieee.math_real.sign(arg1)*int;
		int  := ieee.math_real.sign(int);
		if sign then
			retval           := retval srl 4;
			retval(0 to 4-1) := "1111";
			if int < 0.0 then
				retval(0 to 4-1) := to_unsigned(12, 4);
			elsif int > 0.0 then
				retval(0 to 4-1) := to_unsigned(11, 4);
			end if;
		end if;
		return std_logic_vector(retval);
	end;

	function to_bcd(
		constant arg1 : string;
		constant arg2 : natural)
		return std_logic_vector is
		constant tab    : natural_vector(0 to 12) := (
			character'pos('0'), character'pos('1'), character'pos('2'), character'pos('3'),
			character'pos('4'), character'pos('5'), character'pos('6'), character'pos('7'),
			character'pos('8'), character'pos('9'), character'pos('.'), character'pos('+'),
		   	character'pos('-'));
		variable retval : unsigned(arg2-1 downto 0) := (others => '0');
	begin
		for i in arg1'range loop
			retval := retval sll 4;
			for j in tab'range loop
				if character'pos(arg1(i))=tab(j) then
					retval(4-1 downto 0) := to_unsigned(j, 4);
					exit;
				end if;
			end loop;
		end loop;
		return std_logic_vector(retval);
	end;

	function to_bytevector (
		arg : std_logic_vector) 
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

	--------------------
	-- Logical functions
	--------------------

	function setif (
		arg : boolean)
		return std_logic is
		variable val : std_logic;
	begin
		if arg then
			val := '1';
		else
			val := '0';
		end if;
		return val;
	end function;

	function setif (
		arg : boolean)
		return natural is
		variable val : std_logic;
	begin
		case arg is
		when true =>
			return 1;
		when false =>
			return 0;
		end case;
	end function;

	function slll (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic := '0')
		return std_logic_vector is
		variable aux : std_logic_vector(arg1'range);
	begin
		aux := std_logic_vector(shift_left(unsigned(arg1),1));
		aux(aux'right) := arg2;
		return aux;
	end;

	--------------------
	-- Counter functions
	--------------------

	function count (
		load : std_logic;
		cntr : unsigned;
		data : unsigned;
		ena  : std_logic := '1';
		down : std_logic := '1')
		return unsigned is
	begin
		if ena='1' then
			if load='1' then
				return resize(data,cntr'length);
			else
				if down='1' then
					return cntr-1;
				else
					return cntr+1;
				end if;
			end if;
		else
			return cntr;
		end if;
	end;

	function inc (
		load : std_logic := '1';
		cntr : unsigned;
		data : unsigned;
		ena  : std_logic := '1')
		return unsigned is
	begin
		return count(load,cntr,data,ena,std_logic'('1'));
	end;

	function inc (
		load : std_logic := '1';
		cntr : std_logic_vector;
		data : integer;
		ena  : std_logic := '1')
		return std_logic_vector is
		variable aux : unsigned(cntr'range);
	begin
		aux := unsigned(to_signed(data, cntr'length));
		return std_logic_vector(count(load,unsigned(cntr),aux,ena,std_logic'('1')));
	end;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : std_logic_vector)
		return std_logic_vector is
	begin
		if ena='1' then
			if load='1' then
				return std_logic_vector(resize(unsigned(data), cntr'length));
			else
				return std_logic_vector(unsigned(cntr)-1);
			end if;
		end if;
		return cntr;
	end;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : std_logic_vector)
		return unsigned is
	begin
		return unsigned'(dec(cntr, ena, load, data));
	end;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : integer)
		return std_logic_vector is
	begin
		if ena='1' then
			if load='1' then
				if data < 0 then
					return std_logic_vector(to_signed(data,cntr'length));
				else
					return std_logic_vector(ieee.numeric_std.to_unsigned(data,cntr'length));
				end if;
			else
				return std_logic_vector(unsigned(cntr)-1);
			end if;
		end if;
		return cntr;
	end;

	function dec (
		cntr : std_logic_vector;
		ena  : std_logic := '1';
		load : std_logic := '1';
		data : integer)
		return unsigned is
	begin
		return unsigned(std_logic_vector'(dec(cntr, ena, load, data)));
	end;

	procedure dec (
		signal cntr : inout unsigned;
		constant val : in unsigned) is
	begin
		if cntr(0)/='1' then
			cntr <= cntr - 1;
		else
			cntr <= val;
		end if;
	end procedure;

	function mux (
		constant i : std_logic_vector;
		constant s : std_logic_vector)
		return std_logic is
	begin
		return i(to_integer(unsigned(s)));
	end;

	function mux (
		constant i : std_logic_vector;
		constant s : std_logic_vector)
		return std_logic_vector is
		variable v : unsigned(i'length/2**s'length downto 0);
	begin
		for j in v'range loop
			if i'left > i'right then
 				v := v sll 1;
				v(v'left) := i(to_integer(unsigned(s))+j);
			else
 				v := v srl 1;
				v(v'right) := i(to_integer(unsigned(s))+j);
			end if;
		end loop;
		return std_logic_vector(v);
	end;

	function demux (
		constant s : std_logic_vector;
		constant e : std_logic := '1')
		return std_logic_vector is
		variable o : std_logic_vector(2**s'length-1 downto 0);
	begin
		o := (others => '0');
		o(to_integer(unsigned(s))) := e;
		return o;
	end;

	function word2byte (
		constant word : std_logic_vector;
		constant addr : std_logic_vector)
		return std_logic_vector is
		variable aux  : std_logic_vector(word'length-1 downto 0);
		variable byte : std_logic_vector(word'length/2**addr'length-1 downto 0); 
	begin
		aux := word;
		for i in byte'range loop
			byte(i) := aux(byte'length*to_integer(unsigned(addr))+i);
		end loop;
		return byte;
	end;

	function byte2word (
		constant byte : std_logic_vector;
		constant mask : std_logic_vector;
		constant word : std_logic_vector)
		return std_logic_vector is
		variable di : unsigned(0 to byte'length-1);
		variable do : unsigned(0 to word'length-1);
	begin
		di := unsigned(byte);
		do := unsigned(word);
		for i in mask'range loop
			if mask(i)='1' then
				do(di'range) := di;
			end if;
			do := do rol di'length;
		end loop;
		return std_logic_vector(do);
	end;

	function byte2word (
		constant di : byte_vector)
		return std_logic_vector is
		variable do : unsigned(di'length*di(di'left)'length-1 downto 0);
	begin
		for i in di'range loop
			do(di(di'left)'range) := unsigned(di(i));
			do := do sll di'length;
		end loop;
		return std_logic_vector(do);
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
		if t(a'left-1 downto 0)=(1 to a'left => '0') then
			t(a'left) := '1';
		end if;
		return gray(a xor t);
	end function;

	-----------
	-- ASCII --
	-----------

	function to_string (
		constant arg : integer)
		return string is
		variable msg : line;
	begin
		write (msg, arg);
		return msg.all;
	end function;

	function to_string (
		constant arg : character)
		return string is
		variable msg : line;
	begin
		write (msg, arg);
		return msg.all;
	end function;
		
	function to_ascii(
		constant arg : nibble)
		return ascii is
		constant rom : byte_vector(0 to 15) := (
			x"30", x"31", x"32", x"33",
			x"34", x"35", x"36", x"37",
			x"38", x"39", x"41", x"42",
			x"43", x"44", x"45", x"46");
		variable val : ascii;
	begin
		return ascii(rom(to_integer(unsigned(arg))));
	end function;

	function to_ascii(
		constant arg : string)
		return std_logic_vector is
	begin
		return to_stdlogicvector(arg);
	end;

	function align (
		constant arg  : string;
		constant size : natural)
		return string is
		variable aux  : string(1 to arg'length);
		variable val  : string(1 to size) := (others => ' ');
	begin
		aux := arg;
		for i in aux'range loop
			val(i) := aux(i);
		end loop;
		return val;
	end;

	function to_nibble (
		constant arg : std_logic_vector)
		return nibble_vector is
		variable val : nibble_vector((arg'length+nibble'length-1)/nibble'length-1 downto 0);
		variable aux : unsigned(val'length*nibble'length-1 downto 0);
	begin
		aux := resize(unsigned(arg), aux'length);
		val := (others => (others => '-'));
		for i in val'reverse_range loop
			val(i) := std_logic_vector(aux(nibble'range));
			aux := aux srl nibble'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : nibble_vector) 
		return std_logic_vector is
		variable val : unsigned(arg'length*nibble'length-1 downto 0);
	begin
		val := (others => '-');
		for i in arg'range loop
			val := val sll nibble'length;
			val(nibble'range) := unsigned(arg(i));
		end loop;
		return std_logic_vector(val);
	end;

	function to_stdlogicvector (
		arg : byte_vector)
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
		variable val : natural := 0;
	begin
		for i in data'range loop
			if val < data(i) then
				val := data(i);
			end if;
		end loop;
		return val;
	end;

	function max (
		constant left : integer; 
		constant right: integer)
		return integer is
	begin
		if left > right then
			return left;
		else 
			return right;
		end if;
	end;

	function min (
		constant left : integer;
		constant right: integer)
		return integer is
	begin
		if left < right then
			return left;
		else
			return right;
		end if;
	end;

	function selecton (
		constant condition : boolean;
		constant value_if_true  : real;
		constant value_if_false : real)
		return real is
	begin
		if condition then
			return value_if_true;
		else
			return value_if_false;
		end if;
	end;

	function selecton (
		constant condition : boolean;
		constant value_if_true  : integer;
		constant value_if_false : integer)
		return integer is
	begin
		if condition then
			return value_if_true;
		else
			return value_if_false;
		end if;
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
		constant clk_phases : natural;
		constant phase     : std_logic_vector;
		constant latency   : natural := 12;
		constant extension : natural := 4;
		constant word_size : natural := 4;
		constant width     : natural := 3)
		return std_logic_vector is
	
		variable latency_mod : natural;
		variable latency_quo : natural;
		variable delay : natural;
		variable pulse : std_logic;

		variable distance : natural;
		variable width_quo : natural;
		variable width_mod : natural;
		variable tail : natural;
		variable tail_quo : natural;
		variable tail_mod : natural;
		variable pulses : std_logic_vector(0 to word_size-1);
		variable ph : natural;
	begin

		latency_mod := latency mod pulses'length;
		latency_quo := latency  /  pulses'length;
		for j in pulses'range loop
			ph := (latency+j) mod pulses'length;
			distance  := (extension-j+pulses'length-1)/pulses'length;
			width_quo := (distance+width-1)/width;
			width_mod := (width_quo*width-distance) mod width;

			delay := latency_quo+(j+latency_mod)/pulses'length;
--			pulse := phase(delay);
			pulse := phase(delay*clk_phases+ph mod clk_phases);


			if width_quo /= 0 then
				tail_quo := width_mod  /  width_quo;
				tail_mod := width_mod mod width_quo;
				for l in 1 to width_quo loop
					tail  := tail_quo + (l*tail_mod) / width_quo;
--					pulse := pulse or phase(delay+l*width-tail);
					pulse := pulse or phase((delay+l*width-tail)*clk_phases+ph mod clk_phases);
				end loop;
			end if;
--			pulses((latency+j) mod pulses'length) := pulse;
			pulses(ph) := pulse;
		end loop;
		return pulses;
	end;

end;
