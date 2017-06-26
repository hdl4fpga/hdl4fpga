library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fractobcd is
	port (
		clk  : in  std_logic;
		load : in  std_logic;
		fix  : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

architecture def of fractobcd is
begin
	process (clk)
		variable aux : unsigned(0 to 4+fix'length-1);
	begin
		if rising_edge(clk) then
			if load='1' then
				aux(4 to aux'right) := unsigned(fix);
			else
				aux(4-1) := '0';
				aux := aux sll 3 + aux sll 1;
				bcd := std_logic_vector((unsigned(bcd) sll 4);
				bcd(4-1 downto 0) := aux(0 to 4-1);
			end if;
		end if;
	end process;
end;

entity inttobcd is
end;
