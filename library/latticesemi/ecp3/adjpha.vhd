library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjpha is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		nxt : in  std_logic;
		ok  : in  std_logic;
		dg  : in  std_logic_vector;
		pha : out std_logic_vector);
		
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjpha is

	signal ph : unsigned(pha'range);

begin

	process(clk)
		variable aux : unsigned(pha'range);
	begin
		if rising_edge(clk) then
			if req='0' then
				aux := (others => '0');
				pha <= std_logic_vector(ph + 2);
			elsif nxt='1' then
				aux := aux or dg(0 to ph'length-1);
				if ok='0' then
					aux := aux and not dg(1 to ph'length);
				end if;
				ph  <= aux;
				pha <= std_logic_vector(aux);
			end if;
		end if;
	end process;

end;
