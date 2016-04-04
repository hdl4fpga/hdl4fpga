library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdly is
	port map (
		clk : in std_logic;
		dly : in std_logic_vector;
		hld : in std_logic;
		iod_rst : out std_logic;
		iod_inc : out std_logic;
		iod_ce  : out std_logic);
end;

architecture def of adjdly is
begin
	iod_rst <= hld;
	iod_inc <= '1';
	process (clk)
		variable cntr : unsigned(dly'range);
	begin
		if rising_edge(clk) then
			if hld='1' then
				cntr := dly;
			elsif cntr(0)='0' then
				cntr := cntr - 1;
			end if;
			iodelay_ce <= not cntr(0);
		end if;
	end process;
end;
