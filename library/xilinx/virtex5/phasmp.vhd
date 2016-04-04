library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity smppha is
	port map (
		din : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		clk : in  std_logic;
		smp : out std_logic);
end;

architecture def of smppha is
begin

	process (clk)
		variable q : std_logic;
	begin
		if rising_edge(clk) then
			smp <= q;
			q := din;
		end if;
	end process;

	process (clk)
		variable cntr : unsigned(0 to );
	begin
		if rising_edge(clk) then
			if req='0' then
				cntr := (others => '0');
			elsif cntr(0)='1' then
				cntr := (others => '0');
			else
				cntr := cntr + 1;
			end if;
			rdy <= cntr(0);
		end if;
	end process;
end;
