library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdqs is
	port (
		iod_clk  : in  std_logic;
		smp      : in  std_logic_vector;
		req      : in  std_logic;
		rdy      : out std_logic;
		iod_ce   : out std_logic;
		iod_inc  : out std_logic);
end;

library hdl4fpga;

architecture def of adjdqs is
	constant edge  : std_logic :='0';
	signal   smp0  : std_logic_vector(smp'range);
	signal   smp1  : std_logic_vector(smp'range);
	signal   sync  : std_logic;
	signal   tmr   : unsigned(0 to 4-1);
	signal   stop  : std_logic;
begin

	smp0 <= smp;
	process (iod_clk)
		variable aux : unsigned(smp'range);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				smp1 <= (others => '0');
			elsif tmr(0)='1' then
				aux := unsigned(smp0);
				aux := aux ror 1;
				if (std_logic_vector(aux) xor smp0)=(smp'range => '1') then
					smp1 <= smp;
				end if;
			end if;
		end if;
	end process;

	process (iod_clk)
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				tmr <= (others => '0');
			elsif tmr(0)='1' then
				tmr <= (others => '0');
			elsif stop='0' then
				tmr <= tmr + 1;
			end if;
		end if;
	end process;

	process (iod_clk)
		variable ce : signed(0 to 4-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				sync    <= '0';
				ce := to_signed(0, ce'length);
				iod_ce  <= '0';
				stop    <= '0';
				iod_inc <= '0';
			elsif sync='0' then
				if tmr(0)='1' then
					if (smp0 xor smp1)=(smp'range => '1') then
						if smp0(0)=edge then
							sync <= '1';
						end if;
					end if;
					iod_ce <= not ce(0);
				else
					iod_ce <= '0';
				end if;
				stop    <= ce(0);
				iod_inc <= '0';
			elsif ce(0)='0' then
				ce      :=  ce - 1;
				iod_ce  <= not ce(0);
				stop    <= ce(0);
				iod_inc <= '0';
			end if;
		end if;
	end process;
	rdy <= stop;
end;
