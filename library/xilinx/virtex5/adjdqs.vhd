library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqs is
	port (
		sys_clk0 : in  std_logic;
		iod_clk  : in  std_logic;
		smp : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		iod_rst : out std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic);
end;

library hdl4fpga;

architecture def of adjdqs is
	constant edge : std_logic :='0';
	signal smp0 : std_logic;
	signal smp1 : std_logic;
	signal sync : std_logic;
	signal tmr : unsigned(0 to 4-1);
begin

	smp0 <= smp;
	process (iod_clk)
		variable q : std_logic;
	begin
		if rising_edge(iod_clk) then
			if tmr(0)='1' then
				smp1 <= smp;
			end if;
		end if;
	end process;

	process (iod_clk)
		variable ce : unsigned(0 to 4-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				sync <= '0';
				ce := to_unsigned(1, ce'length);
				tmr <= (others => '0');
				iod_ce  <= '0';
				rdy <= '0';
				iod_inc <= '0';
			elsif sync='0' then
				if tmr(0)='1' then
					if smp0=edge then
						if smp1=not edge then
							sync  <= '1';
						end if;
					end if;
					iod_ce <= not ce(0);
					tmr <= (others => '0');
				else
					tmr <= tmr + 1;
					iod_ce <= '0';
				end if;
				rdy <= ce(0);
				iod_inc <= '0';
			elsif ce(0)='0' then
				ce :=  ce - 1;
				iod_ce <= not ce(0);
				rdy <= ce(0);
				iod_inc <= '1';
			end if;
		end if;
	end process;
	iod_rst <= not req;
end;
