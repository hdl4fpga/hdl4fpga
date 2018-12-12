library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity align is
	generic (
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		clk    : in  std_logic := '-';
		rst    : in  std_logic := '0';
		value  : in  std_logic_vector;
		align  : out std_logic_vector);
end;
		
architecture def of align_bcd is

	function align (
		constant value : std_logic_vector;
		constant left  : std_logic)
		return std_logic_vector is
		variable retval : unsigned(value'length-1 downto 0);
	begin
		retval := unsigned(value);
		if left='1' then
			retval := retval rol 4;
		end if;
		for i in 0 to value'length/4-1 loop
			if std_logic_vector(retval(4-1 downto 0))=space then
				if left='1' then
					retval := retval rol 4;
				else
					retval := retval ror 4;
				end if;
			elsif left='1' then
				retval := retval ror 4;
				exit;
			else
				exit;
			end if;
		end loop;

		return std_logic_vector(retval);
	end;

	signal left  : std_logic_vector;
	signal right : std_logic_vector;
begin

	process
	begin
		for i in 0 to left'length/space'length-1 loop
			left(space'range) := value;
			left := left rol 4;
		end loop;
		right := left;

		-- lsb first;
		if value/=space then
			left := left ror value'length;
			left(value'range) := value;
		else
			exit;
		end if;

		--  msb first
		if value/=space then
			right := right rol value'length;
			right(value'range) := value;
		else
			exit;
		end if;
end;
