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
begin

	ff_e : entity hdl4fpga.ff
	port map (
		clk => sys_clk0,
		d => din,
		q => smp0);

	process (iod_clk)
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				smp1 <= '0';
			else
				smp1 <= smp0;
			end if;
		end if;
	end process;

	iod_inc <= not edge;
	process (iod_clk)
		variable ce : unsigned(0 to 4-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				edge <= '0';
				sync <= '0';
				ce := ('0',  others => '1');
				iod_ce <= '0';
				rdy <= '0';
			elsif sync='0' then
				if smp0=not edge then
					if smp1=not edge then
						if edge='1' then
							sync <='1';
						end if;
						edge <= '1';
					end if;
				end if;
				iod_ce <= not ce(0);
			elsif ce(0)='0' then
				ce := ce - 1;
				iod_ce <= not ce(0);
				rdy <= ce(0);
			end if;
		end if;
	end process;
end;
