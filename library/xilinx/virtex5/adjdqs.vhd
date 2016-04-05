library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqs is
	port (
		iod_clk : in  std_logic;
		din : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		iod_rst : out std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic
		--iod_dly : out std_logic_vector
		);
end;

architecture def of adjdqs is
	signal smp0 : std_logic;
	signal smp1 : std_logic;
begin

	process (iod_clk)
		variable q : std_logic;
	begin
		if rising_edge(iod_clk) then
			smp1 <= smp0;
			smp0 <= q;
			q := din;
		end if;
	end process;

	process (iod_clk)
--		variable cntr : unsigned(0 to iod_dly'length);
		variable sync : std_logic;
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				iod_rst <= '0';
				iod_ce  <= '0';
				iod_inc <= '0';
				sync := '0';
--				cntr := (others => '0');
			elsif sync='0' then
				if smp0='0' then
					if smp1='1' then
						iod_rst <= '0';
						iod_ce  <= '1';
						iod_inc <= '1';
						sync := '1';
--						cntr := cntr - 1;
					else
						iod_rst <= '0';
						iod_ce  <= '1';
						iod_inc <= '0';
						sync := '0';
--						cntr := cntr + 1;
					end if;
				else 
					iod_rst <= '0';
					iod_ce  <= '1';
					iod_inc <= '0';
					sync := '0';
--					cntr := cntr + 1;
				end if;
			end if;
			rdy <= sync;
--			iod_dly <= cntr(1 to iod_dly'length);
		end if;
	end process;
end;
