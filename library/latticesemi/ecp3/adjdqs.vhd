library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjpha is
	generic (
		period : natural);
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		smp : in  std_logic;
		pha : out std_logic_vector);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjpha is
	signal hld : in  std_logic;
begin

	process(clk)
		variable mph : unsigned(pha'length-1 downto 0);
		variable sph : std_logic;
		variable fst : std_logic;
	begin
		if rising_edge(clk) then
			if req='0' then
				mph := (others => '0');
				sph := '0';
				fst := '0';
			else
				if rdy='1' then
					if hld='1' then
						if smp='0' then
							if fst='0' then
								sph := '1';
							else
								rdy <= '1';
							end if
						else
							mph := mph + 1;
						end if;
					end if;
				end if;
				fst <='1';
			end if;
			pha <= std_logic_vector(mph & sph);
		end if;
	end process;

end;
