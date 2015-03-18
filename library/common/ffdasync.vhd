library ieee;
use ieee.std_logic_1164.all;

entity ffdasync is
	generic (
		n : natural := 1);
	port (
		arst : in std_logic := '0';
		srst : in std_logic := '0';
		clk  : in  std_logic;
		d    : in  std_logic_vector(0 to n-1);
		q    : out std_logic_vector(0 to n-1));
end;

architecture arch of ffdasync is
begin
	g : for i in d'range generate
		process (arst, clk)
			variable shr : std_logic_vector(0 to 1);
		begin
			if arst='1' then
				shr(1) := '0';
			elsif rising_edge(clk) then
				if srst='1' then
					q(i) <= '0';
					shr := (others => '0');
			else
				q(i) <= shr(0);
				shr := shr(1 to 1) & d(i);
				end if;
			end if;
		end process;
	end generate;
end;
