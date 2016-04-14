library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqi is
	port (
		sys_clk0 : in std_logic;
		sti : in std_logic;
		din : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		iod_clk  : in std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic);
end;

library hdl4fpga;

architecture def of adjdqi is
	signal smp0 : std_logic;
	signal smp1 : std_logic;
	signal sync : std_logic;
	signal edge : std_logic;
	signal ena  : std_logic;
		signal cntr0 : unsigned(0 to 7-1);
begin

	process (sys_clk0)
	begin
		if rising_edge(sys_clk0) then
			if sti='0' then
				ena <= '0';
			else
				ena <= not ena;
			end if;
		end if;
	end process;

	ff_e : entity hdl4fpga.ff
	port map (
		clk => sys_clk0,
		ena => ena,
		d => din,
		q => smp0);

	process (iod_clk)
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				smp1 <= '1';
			else
				smp1 <= smp0;
			end if;
		end if;
	end process;

	iod_inc <= edge;
	process (iod_clk)
		variable ce   : unsigned(0 to 3-1);
		variable cntr : unsigned(0 to 7-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				edge <= '0';
				sync <= '0';
				cntr := (others => '0');
				iod_ce <= '0';
				rdy <= '0';
			elsif sync='0' then
				if smp0='0' then
					if smp1=edge then
						if edge='1' then
							cntr(1 to cntr'right) := not (cntr(1 to cntr'right) srl 1);
							sync <='1';
						end if;
						edge <= '1';
					elsif edge='1' then
						cntr := cntr + 1;
					end if;
				elsif edge='1' then
					cntr := cntr + 1;
				end if;
				iod_ce <= not cntr(0);
			elsif cntr(0)='0' then
				cntr := cntr + 1;
				iod_ce <= not cntr(0);
				rdy <= cntr(0);
			end if;
			cntr0 <= cntr;
		end if;
	end process;
end;
