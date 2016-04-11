library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqs is
	port (
		sys_clk0 : in  std_logic;
		iod_clk  : in  std_logic;
		din : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		iod_rst : out std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic;
		iod_dly : out std_logic_vector);
end;

library hdl4fpga;

architecture def of adjdqs is
	signal smp0 : std_logic;
	signal smp1 : std_logic;
	signal cntr : unsigned(0 to iod_dly'length);
	signal sync : std_logic;
	signal sync1: std_logic;
begin

	ffd_e : entity hdl4fpga.ff
	port map (
		clk => sys_clk0,
		d   => din,
		q   => smp0);

	process (iod_clk)
		variable q : std_logic;
	begin
		if rising_edge(iod_clk) then
			smp1 <= smp0;
		end if;
	end process;

	process (iod_clk)
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				iod_rst <= '0';
				iod_ce  <= '0';
				iod_inc <= '1';
				sync <= '0';
				cntr <= (others => '0');
			elsif sync='0' then
				if smp0='0' then
					if smp1='1' then
						iod_rst <= '0';
						iod_ce  <= '1';
						iod_inc <= '0';
						sync <= '1';
						iod_dly <= std_logic_vector(cntr(1 to iod_dly'length)-2);
					else
						iod_rst <= '0';
						iod_ce  <= '1';
						iod_inc <= '1';
						sync <= '0';
					end if;
				else 
					iod_rst <= '0';
					iod_ce  <= '1';
					iod_inc <= '1';
					sync <= '0';
				end if;
				cntr <= cntr + 1;
			else
				iod_rst <= '0';
				iod_ce  <= not sync;
				iod_inc <= '0';
				sync <= '1';
			end if;
			sync1 <= sync;
		end if;
	end process;
	rdy <= sync;
end;
