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
		iod_inc : out std_logic);
end;

library hdl4fpga;

architecture def of adjdqs is
	signal smp0 : std_logic;
	signal smp1 : std_logic;
	signal sync : std_logic;
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
		variable ce  : unsigned(0 to 2-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				sync <= '0';
				ce := (others => '0');
				iod_inc <= '0';
				iod_ce  <= '0';
			elsif sync='0' then
				if smp0='0' then
					if smp1='1' then
						sync  <= '1';
						ce(0) := '1';
						iod_inc <= '1';
					end if;
				else 
					sync  <= '0';
					ce(0) := '1';
					iod_inc <= '0';
				end if;
				iod_ce  <= ce(0);
			end if;
			iod_ce <= ce(ce'right);
			ce  := ce  srl 1;
		end if;
	end process;
	rdy <= sync;
	iod_rst <= not req;
end;
