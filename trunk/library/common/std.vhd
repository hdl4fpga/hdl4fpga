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

	function to_bytevector (
		constant arg : string)
		return byte_vector;

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector;

	function reverse (
		constant arg : std_logic_vector)
		return std_logic_vector;
	
	function resize (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector;

	function resize (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic_vector;

	function resize (
		constant arg1 : unsigned;
		constant arg2 : std_logic_vector)
		return std_logic_vector;

	function "rol" (
		constant arg1 : std_logic_vector;
		constant arg2 : integer)
		return std_logic_vector;

	function "ror" (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector;

	function "sll" (
		constant arg1 : unsigned;
		constant arg2 : natural)
		return std_logic_vector;

	function "sll" (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector;

	function "srl" (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector;

	function "and" (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic)
		return std_logic_vector;

	impure function "mod" (
		constant arg1 : time;
		constant arg2 : time)
		return time;

	function to_unsigned (
		constant arg1 : natural;
		constant arg2 : std_logic_vector)
		return std_logic_vector;

	function to_unsigned (
		constant arg1 : natural;
		constant arg2 : natural)
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

	impure function word2byte (
		constant word : std_logic_vector;
		constant addr : std_logic_vector;
		constant litt : std_logic := '1')
		return std_logic_vector;

	function byte2word (
		constant byte : std_logic_vector;
		constant mask : std_logic_vector;
		constant word : std_logic_vector;
		constant litt : std_logic := '1')
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

	-----------
	-- ASCII --
	-----------

	function to_string (
		constant arg : integer)
		return string;

	function to_string (
		constant arg : character)
		return string;

--	function to_string (
--		constant arg : real)
--		return string;

	function to_ascii (
		constant arg : nibble)
		return ascii;

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
end;

use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

package body std is

	function resize (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(resize(unsigned(arg1), arg2));
	end;

	function resize (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic_vector is
	begin
		return std_logic_vector(resize(unsigned(arg1), arg2'length));
	end;

	function resize (
		constant arg1 : unsigned;
		constant arg2 : std_logic_vector)
		return std_logic_vector is
	begin
		return std_logic_vector(resize(arg1, arg2'length));
	end;

	function "rol" (
		constant arg1 : std_logic_vector;
		constant arg2 : integer)
		return std_logic_vector is
	begin
		return std_logic_vector(rotate_left(unsigned(arg1), arg2));
	end;

	function "ror" (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(rotate_right(unsigned(arg1), arg2));
	end;

	function "sll" (
		constant arg1 : unsigned;
		constant arg2 : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(shift_left(arg1, arg2));
	end;

	function "sll" (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector is
		variable aux : unsigned(arg1'range);
	begin
		return std_logic_vector(shift_left(unsigned(arg1), arg2));
	end;

	function "srl" (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector is
		variable aux : unsigned(arg1'range);
	begin
		return std_logic_vector(shift_right(unsigned(arg1), arg2));
	end;

	function "and" (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic)
		return std_logic_vector is
		variable aux : std_logic_vector(arg1'range);
	begin
		for i in arg1'range loop
			aux(i) := arg1(i) and arg2;
		end loop;
		return aux;
	end;

	impure function "mod" (
		constant arg1 : time;
		constant arg2 : time)
		return time is
		variable val : integer;
	begin
		val := arg1 / arg2;
		if val*arg2 < arg1 then
			return arg2-arg1*val;
		end if;
		return 0 ns;
	end;

	------------------
	-- Array functions
	------------------

	function reverse (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable aux : std_logic_vector(arg'reverse_range);
	begin
		for i in arg'range loop
			aux(i) := arg(i);
		end loop;
		return aux;
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

	function to_unsigned (
		constant arg1 : natural;
		constant arg2 : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(unsigned'(to_unsigned(arg1,arg2)));
	end;

	function to_unsigned (
		constant arg1 : natural;
		constant arg2 : std_logic_vector)
		return std_logic_vector is
	begin
		return std_logic_vector(unsigned'(to_unsigned(arg1,arg2'length)));
	end;

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
		variable v : std_logic_vector(i'length/2**s'length downto 0);
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
		return v;
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

	impure function word2byte (
		constant word : std_logic_vector;
		constant addr : std_logic_vector;
		constant litt : std_logic := '1')
		return std_logic_vector is
		variable byte : std_logic_vector(word'length/2**addr'length-1 downto 0); 
	begin
		for i in byte'range loop
			byte(i) := word(byte'length*to_integer(unsigned(addr))+i+word'low);
		end loop;
		return byte;
	end;

	function byte2word (
		constant byte : std_logic_vector;
		constant mask : std_logic_vector;
		constant word : std_logic_vector;
		constant litt : std_logic := '1')
		return std_logic_vector is
		variable di : std_logic_vector(0 to byte'length-1);
		variable do : std_logic_vector(0 to word'length-1);
	begin
		di := byte;
		do := word;
		for i in mask'range loop
			if mask(i)='1' then
				do(di'range) := di;
			end if;
			do := do rol di'length;
		end loop;
		return do;
	end;

	function byte2word (
		constant di : byte_vector)
		return std_logic_vector is
		variable do : std_logic_vector(di'length*di(di'left)'length-1 downto 0);
	begin
		for i in di'range loop
			do(di(di'left)'range) := di(i);
			do := do sll di'length;
		end loop;
		return do;
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

--	function to_string (
--		constant arg : real)
--		return string is
--		variable msg : line;
--	begin
--		write (msg, arg);
--		return msg.all;
--	end function;

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

	function to_nibble (
		constant arg : std_logic_vector)
		return nibble_vector is
		variable val : nibble_vector((arg'length+nibble'length-1)/nibble'length-1 downto 0);
		variable aux : std_logic_vector(val'length*nibble'length-1 downto 0);
	begin
		aux := std_logic_vector(resize(unsigned(arg),aux'length));
		val := (others => (others => '-'));
		for i in val'reverse_range loop
			val(i) := aux(nibble'range);
			aux := aux srl nibble'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : nibble_vector) 
		return std_logic_vector is
		variable val : std_logic_vector(arg'length*nibble'length-1 downto 0);
	begin
		val := (others => '-');
		for i in arg'range loop
			val := val sll nibble'length;
			val(nibble'range) := arg(i);
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(byte'length*arg'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll byte'length;
			val(byte'range) := dat(i);
		end loop;
		return val;
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

end;
