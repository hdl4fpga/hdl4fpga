library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frac2bcd is
	port (
		frac : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

architecture def of frac2bcd is
begin
	process (frac)
		variable aux1 : unsigned(0 to 4+frac'length-1);
		variable aux2 : unsigned(4*((bcd'length+4-1)/4)-1 downto 0);
	begin
		aux1(4 to aux1'right) := unsigned(frac);
		for i in 0 to aux2'length/4-1 loop
			aux2 := aux2 sll 4;
			aux1(0 to 4-1) := (others => '0');
			aux1 := (aux1 sll 3) + (aux1 sll 1);
			aux2(4-1 downto 0) := aux1(0 to 4-1);
			bcd  <= std_logic_vector(aux2(bcd'length-1 downto 0));
		end loop;
	end process;
end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btod is
	port (
		clk    : in  std_logic;

		bin_dv : in  std_logic;
		bin_di : in  std_logic_vector;

		bcd_dv : in  std_logic;
		bcd_di : in  std_logic_vector;
		bcd_do : out std_logic_vector);
end;

architecture def of btod is

	procedure dbdbb(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		if digit >= "0101" then
			digit := digit + "0011";
		end if;
		digit    := digit rol 1;
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
	end;

begin

	process(clk)
		variable value : unsigned(bcd_di'length-1 downto 0);
		variable shtio : unsigned(bin_di'length-1 downto 0);
	begin
		if rising_edge(clk) then
			if bcd_dv='1' then
				value := unsigned(bcd_di);
			end if;
			if bin_dv='1' then
				shtio := unsigned(bin_di);
			end if;

			for k in shtio'range loop
				shtio := shtio rol 1;
				for i in 0 to value'length/4-1 loop
					dbdbb(shtio(0), value(4-1 downto 0));
					value := value ror 4;
				end loop;
			end loop;

			bcd_do <= std_logic_vector(value);
		end if;
	end process;

end;
