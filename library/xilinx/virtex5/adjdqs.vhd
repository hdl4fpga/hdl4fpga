library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqs is
	port map (
		din : in  std_logic;
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		iod_rst : out std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic;
		iod_dly : out std_logic_vector);
end;

architecture def of adjdqs is
	signal smp : std_logic;
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
		variable cntr : unsigned(0 to iod_dly'length);
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
			iod_dly <= cntr(1 to iod_dly'length);
		end if;
	end process;
end;
