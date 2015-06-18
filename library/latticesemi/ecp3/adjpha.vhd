library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjpha is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : in  std_logic;
		hld : in  std_logic;
		smp  : in  std_logic;
		dg  : in  std_logic_vector;
		pha : out std_logic_vector);
		
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjpha is
begin

	process(clk)
		variable aux : unsigned(pha'range);
	begin
		if rising_edge(clk) then
			if req='0' then
				aux := (others => '0');
				pha <= (pha'range => '0');
			elsif rdy='1' then
				pha <= std_logic_vector(aux + 2);
			elsif hld='1' then
				aux := aux or unsigned(dg(0 to pha'length-1));
				if smp='1' then
					aux := aux and not unsigned(dg(1 to pha'length));
				end if;
				pha <= std_logic_vector(aux);
			end if;
		end if;
	end process;
end;
