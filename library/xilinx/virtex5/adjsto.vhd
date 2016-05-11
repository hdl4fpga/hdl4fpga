library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjsto is
	port (
		sys_clk0 : in std_logic;
		iod_clk  : in std_logic;
		smp : in  std_logic;
		sti : in  std_logic;
		sto : out std_logic;
		req : in  std_logic;
		rdy : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of adjsto is
	signal st  : std_logic;
	signal inc : std_logic;
	signal sel : std_logic_vector(2-1 downto 0);
	signal dly : std_logic_vector(2**sel'length-1 downto 1);
	signal start : std_logic;
	signal finish : std_logic;
begin

	process (sys_clk0)
		variable cnt : unsigned(0 to 3-1);
		variable d   : std_logic_vector(0 to 0);
		constant p : natural := 0;
	begin
		if rising_edge(sys_clk0) then
			if start='0' then
				cnt := to_unsigned(p, cnt'length);
				inc <= '0';
			elsif st='1' then
				if smp='1'  then
					cnt := cnt + 1;
				end if;
			else
				inc <= not cnt(0);
				cnt := to_unsigned(p, cnt'length);
			end if;
			d := word2byte(reverse(dly & sti), sel);
			st  <= d(0);
			dly <= dly(dly'left-1 downto 1) & sti;
			sto <= st;
		end if;
	end process;

	process (req, sys_clk0)
	begin
		if req='0' then
			start <= '0';
		elsif rising_edge(sys_clk0) then
			if sti='0' then
				start <= '1';
			end if;
		end if;
	end process;

	process (start, iod_clk)
		variable ce : unsigned(0 to 5-1);
	begin
		if start='0' then
			finish  <= '0';
			ce  := (others => '0');
			sel <= (others => '0');
		elsif rising_edge(iod_clk) then
			if finish='0' then 
				if start='1' then
					if ce(0)='1' then
						if inc='1' then
							ce  := (others => '0');
							sel <= std_logic_vector(unsigned(sel)+1);
						else
							finish <= '1';
						end if;
					else
						ce := ce + 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	rdy <= finish;
end;
