library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqi is
	port (
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
	signal tmr : unsigned(0 to 4-1);
begin

	smp0 <= din;

	process (iod_clk)
	begin
		if rising_edge(iod_clk) then
			if tmr(0)='1' then
				smp1 <= smp0;
			end if;
		end if;
	end process;

	iod_inc <= not edge;
	process (iod_clk)
		variable ce : signed(0 to 4-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				edge <= '0';
				sync <= '0';
				ce := to_signed(0, ce'length);
				iod_ce <= '0';
				rdy <= '0';
				tmr <= (others => '0');
			elsif sync='0' then
				if tmr(0)='1' then
					if smp0=edge then
						if smp1=edge then
							if edge='1' then
								sync <='1';
							end if;
							edge <= '1';
						end if;
					end if;
					iod_ce <= not ce(0);
					tmr <= (others => '0');
				else
					tmr <= tmr + 1;
					iod_ce <= '0';
				end if;
			elsif ce(0)='0' then
				ce :=  ce - 1;
				iod_ce <= not ce(0);
				rdy <= ce(0);
			end if;
		end if;
	end process;
end;
