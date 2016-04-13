library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqi is
	port (
		sys_clk0 : in std_logic;
		d0 : in  std_logic;
		d1 : in  std_logic;
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
	signal sync: std_logic;
	signal edge : std_logic;
	signal q0 : std_logic;
	signal q1 : std_logic;
begin

	ffd0_e : entity hdl4fpga.ff
	port map (
		clk => sys_clk0,
		d   => d0,
		q   => q0);

	ffd1_e : entity hdl4fpga.ff
	port map (
		clk => sys_clk0,
		d   => d1,
		q   => q1);
--	smp0 <= qi0 xor qi1;
	smp0 <= q0;

	process (iod_clk)
		variable q : std_logic;
	begin
		if rising_edge(iod_clk) then
			smp1 <= smp0;
		end if;
	end process;

	iod_inc <= not edge;
	process (iod_clk)
		variable ce  : unsigned(0 to 3-1);
		variable cntr : unsigned(0 to 6-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				edge <= '0';
				sync <= '0';
				cntr := (others => '0');
				iod_ce <= '0';
			elsif sync='0' then
				if smp0=edge then
					if smp1=not edge then
						if edge='1' then
							cntr := not (cntr srl 1);
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
			end if;
		end if;
	end process;
	rdy <= sync;
end;
