library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity int2bcd is
	port (
		int : in  std_logic_vector;
		bcd : out std_logic_vector);
end;

architecture def of int2bcd is
begin
	process(int)
		variable aux1 : unsigned(0 to int'length-1);
		variable aux2 : unsigned(4*((bcd'length+4-1)/4)-1 downto 0) := (others => '0');
	begin
		aux1 := unsigned(int);
		aux2 := (others => '0');
		for i in 0 to int'length-1 loop
			for j in 0 to aux2'length/4-1 loop
				if aux2(4-1 downto 0) >= "0101" then
					aux2(4-1 downto 0) := aux2(4-1 downto 0) + "0011";
				end if;
				aux2 := aux2 rol 4;
			end loop;
			aux2 := aux2 sll 1;
			aux2(0) := aux1(0);
			aux1 := aux1 sll 1;
		end loop;
		bcd <= std_logic_vector(aux2(bcd'length-1 downto 0));
	end process;
end;

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
		clk     : in  std_logic;
		bin_din : in  std_logic;
		bin_ena : out std_logic;

		bcd_dv  : in  std_logic;
		bcd_di  : in  std_logic_vector(4-1 downto 0),
		bcd_en  : out std_logic;
		bcd_do  : out std_logic_vector(4-1 downto 0));
end;

architecture def of btod is
	signal cy  : std_logic;
	signal rdy : std_logic;
begin
	process(clk)
		variable aux : unsigned(bcd_di'range);
	begin
		if rising_edge(clk) then
			if bcd_dv='1' then
				aux := bcd_di;
				aux := aux rol 1;
				cy  <= aux(0);
				if bin_ena='1' then
					aux(0) <= bin_din;
				else
					aux(0) <= cy;
				end if;
				bcd_en <= '1'
				if aux >= "0101" then
					bcd_do <= std_logic_vector(aux + "0011");
				else
					bcd_do <= std_logic_vector(aux);
				end if;
			else
				bcd_en <= '0';
			end if;
		end loop;
	end process;
end;
