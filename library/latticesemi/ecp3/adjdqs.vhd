library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjdqs is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		smp : in  std_logic;
		pha : out std_logic_vector);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdqs is
	signal hld : std_logic;
	signal adj : std_logic;
begin

	process(clk)
		variable cntr : unsigned(0 to 4-1);
	begin
		if rising_edge(clk) then
			if req='0' then
				cntr := (others => '0');
			elsif adj='1' then
				cntr := (others => '0');
			elsif cntr(0)='1' then
				cntr := (others => '0');
			else
				cntr := cntr + 1;
			end if;
			hld <= cntr(0);
		end if;
	end process;

	process(clk)
		variable mph : unsigned(pha'length-1-1 downto 0);
		variable sph : std_logic;
		variable fst : std_logic;
	begin
		if rising_edge(clk) then
			if req='0' then
				mph := (others => '0');
				sph := '0';
				fst := '0';
				adj <= '0';
			else
				if adj='0' then
					if hld='1' then
						if smp='1' then
							if fst='0' then
								sph := '1';
							else
								adj <= '1';
							end if;
						else
							mph := mph + 1;
						end if;
						fst :='1';
					end if;
				end if;
			end if;
			pha <= std_logic_vector(sph & mph);
		end if;
	end process;
	rdy <= adj;

end;
