library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity format_bcd is
	generic (
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		minus : std_logic_vector(4-1 downto 0) := x"d";
		space : std_logic_vector(4-1 downto 0) := x"f";
		check : boolean := true);
		
	port (
		value    : in  std_logic_vector;
		zero     : in  std_logic := '0';
		point    : in  std_logic_vector;
		format   : out std_logic_vector);
end;
		
architecture def of format_bcd is

	impure function format_bcd_f (
		constant value : std_logic_vector;
		constant point : std_logic_vector;
		constant zero  : std_logic)
		return std_logic_vector is
		variable temp  : std_logic_vector(value'length-1 downto 0);
		variable digit : std_logic_vector(4-1 downto 0);
		variable aux   : std_logic_vector(4-1 downto 0);

	begin

		temp  := value;
		digit := dot;

		if point(point'left)='1' then

			for i in 0 to value'length/digit'length-1 loop
				if to_integer(signed(point))+i < 0 then
					temp := std_logic_vector(unsigned(temp) ror digit'length);
					if temp(digit'range)=space then
						temp(digit'range) := x"0";
					end if;
				end if;
			end loop;

			temp := std_logic_vector(unsigned(temp) rol digit'length);
			swap(digit, temp(digit'range));

			for i in 0 to value'length/digit'length-1 loop
				if to_integer(signed(point))+i < 0 then
					temp := std_logic_vector(unsigned(temp) rol digit'length);
					swap(digit, temp(digit'range));
				end if;
			end loop;

		else
			if check then
				if temp(digit'range)=x"0" then
					temp  := std_logic_vector(unsigned(temp) ror digit'length);
					digit := temp(digit'range);
					temp  := std_logic_vector(unsigned(temp) rol digit'length);
					if digit=space then
						return temp;
					end if;
				end if;
			end if;

			if zero /= '1' then
				for i in 0 to value'length/digit'length-1 loop
					if i < to_integer(signed(point)) then
						temp := std_logic_vector(unsigned(temp) rol digit'length);
						if temp(digit'range)=space then
							temp(digit'range) := x"0";
						end if;
					end if;
				end loop;
			end if;

		end if;

		return temp;
	end;

begin

	format <= format_bcd_f(value, point, zero);
		
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_bcd is
	generic (
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		minus : std_logic_vector(4-1 downto 0) := x"d";
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		value    : in  std_logic_vector;
		negative : in  std_logic := '0';
		sign     : in  std_logic;
		format   : out std_logic_vector);
end;
		
architecture def of sign_bcd is

	function sign_bcd_f (
		constant value : std_logic_vector;
		constant code  : std_logic_vector)
		return std_logic_vector is
		variable retval : unsigned(value'length-1 downto 0);
	begin
		retval := unsigned(value);
		for i in 0 to value'length/4-1 loop
			retval := retval rol 4;
			if std_logic_vector(retval(4-1 downto 0))/=space then
				retval := retval ror 4;
				retval(4-1 downto 0) := unsigned(code);
				if i=0 then
					retval := retval ror 4;
				else
					retval := retval ror (4*i);
				end if;
				exit;
			end if;
		end loop;

		return std_logic_vector(retval);
	end;

begin

	format <= 
		sign_bcd_f(value, minus) when negative='1' else 
		sign_bcd_f(value, plus)  when sign='1'     else
		value;

end;

