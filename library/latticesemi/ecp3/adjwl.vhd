library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjwl is
	port (
		clk  : in std_logic;
		rst  : in std_logic;
		crdy : in std_logic;
		creq : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjwl is

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				creq <= '0';
			elsif crdy='0' then
				creq <= '1';
			else
				creq <= '0';
			end if;
		end if;
	end process;

end;
