library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjpha is
	port (
		clk  : in std_logic;
		rst  : in std_logic;
		crdy : in std_logic;
		creq : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjpha is

	signal pe : std_logic_vector(0 to 5);
	signal dy : unsigned(pe'range);
	signal dg : unsigned(0 to pha'length+1);

begin

	process(clk)
	begin
		if rising_edge(sclk) then
			if rst='1' then
				creq <= '0';
				ordy <= '0';
			elsif crdy='0' then
				creq <= '1';
			else
				creq <= '0';
			end if;
		end if;
	end process;

end;
