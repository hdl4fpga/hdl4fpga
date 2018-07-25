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
		bcd_di : in  std_logic_vector(4-1 downto 0);
		bcd_en : out std_logic;
		bcd_do : out std_logic_vector(4-1 downto 0));
end;

architecture def of btod is

	procedure dbdbb(
		variable shtio : inout std_logic;
		variable digit : inout unsigned);
		return std_logic_vector is
		variable save  : std_logic;
	begin
		digit    := digit rol 1;
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
		if digit >= "0101" then
			digit <= digit + "0011";
		end if;
	end;

begin

	process(clk)
		variable value : unsigned(bcd_di'length-1 downto 0);
		variable shtio : unsigned(bin_di'length-1 downto 0);
	begin
		if rising_edge(clk) then
			bcd_en <= '0';
			if bcd_dv='1' then
				if bin_dv='1' then
					shtio := unsigned(bin_di);
				end if;
				value  := unsigned(bcd_di);
				for k in shtio'range loop
					for i in 0 to val'length/4-1 loop
						dbdbb(shtio(0), val(4-1 downto 0));
						val := val rol 4;
					end loop;
					shtio := shtio ror 1;
				end loop;
				bcd_en <= '1';
			end if;
			bcd_do <= val;
		end if;
	end process;

end;
