library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqi is
	port (
		din     : in  std_logic_vector;
		req     : in  std_logic;
		rdy     : out std_logic;
		iod_clk : in  std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic;
		tp      : out std_logic_vector);
end;

library hdl4fpga;

architecture def of adjdqi is
	signal smp0 : std_logic_vector(din'range);
	signal smp1 : std_logic_vector(din'range);
	signal smp2 : std_logic_vector(din'range);
	signal sync : std_logic;
	signal edge : std_logic;
	signal tmr : unsigned(0 to 4-1);
begin

	smp0 <= din;
	smp2 <= smp0 xor smp1;
	tp <= smp1;

	process (iod_clk)
		variable aux : unsigned(din'range);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				smp1 <= (others => '0');
			elsif tmr(0)='1' then
				aux := unsigned(smp0);
				aux := aux ror 1;
				if (std_logic_vector(aux) xor smp0)=(din'range => '1') then
					smp1 <= smp0;
				end if;
			end if;
		end if;
	end process;

	iod_inc <= not edge;
	process (iod_clk)
		variable ce : signed(0 to 4-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				edge   <= '0';
				sync   <= '0';
				ce     := to_signed(2, ce'length);
				iod_ce <= '0';
				rdy    <= '0';
				tmr    <= (others => '0');
			elsif sync='0' then
				if tmr(0)='1' then
					if (smp0 xor smp1)=(din'range => '1') then
						if smp0(0)=edge then
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
