--
-- Decriptcion de un FFD
--

library ieee ;
use ieee.std_logic_1164.all;

entity ffd is
	port(
		d   : in std_logic;
		clk : in std_logic;
		q   : out std_logic);
end;

architecture behv of dff is
begin
	process(clk)
	begin
		if (clk='1' and clk'event) then
			q <= d;
		end if;
	end process;	
end;
