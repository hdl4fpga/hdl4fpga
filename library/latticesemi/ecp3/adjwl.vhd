library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjdll is
	port (
		clk  : in std_logic;
		rst  : in std_logic;
		ordy : in std_logic;
		crdy : in std_logic;
		creq : out std_logic;
		cnxt : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdll is

	signal pe : std_logic_vector(0 to 5);
	signal dy : unsigned(pe'range);
	signal dg : unsigned(0 to pha'length+1);

begin

	process(clk)
	begin
		if rising_edge(sclk) then
			if rst='1' then
				dy <= (others => '0');
			if dg(dg'right)='0' then
				dy <= dy(1 to dy'right) & not dy(0);
				if pe(3)='1' then
					dg <= dg srl 1;
				end if;
			elsif stop='1' then
				dy <= dy(1 to dy'right) & not dy(0);
			end if;
		end if;
	end process;

end;
