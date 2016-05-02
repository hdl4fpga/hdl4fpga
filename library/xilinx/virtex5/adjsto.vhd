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
	signal dly : std_logic_vector(2*sel'length-1 downto 1);
	signal ry : std_logic;
begin

	process (sys_clk0)
		variable cnt : unsigned(2**3-1 downto 0);
	begin
		if rising_edge(sys_clk0) then
			if st='1' then
				if smp='1'  then
					cnt := cnt + 1;
				end if;
			else
				inc <= cnt(0);
				cnt := ('0', others => '1');
			end if;
			st  <= word2byte(dly & sti, sel)(0);
			dly <= dly(dly'left-1 downto 1) & sti;
		end if;
	end process;
	sto <= st;

	process (iod_clk)
		variable ce : unsigned(0 to 4-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				ry  <= '0';
				ce  := (others => '0');
				sel <= (others => '0');
			elsif ry='0' then 
				if ce(0)='1' then
					if inc='1' then
						ce  := (others => '0');
						sel <= std_logic_vector(unsigned(sel)+1);
					else
						ry <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
	rdy <= ry;
end;
