library ieee;
use ieee.std_logic_1164.all;

entity i2c_master is
	port (
		sys_rst : in  std_logic;
		sys_rdy : out std_logic;
		sys_do  : out std_logic_vector(8-1 downto 0);

		i2c_scl : inout std_logic := 'Z';
		i2c_sda : inout std_logic := 'Z');
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of i2c_master is
	signal i2c_s : std_logic;
	signal sda_rise : std_logic;
	signal sda_fall : std_logic;
	signal start    : std_logic;
	signal ena : std_logic;
	signal do  : std_logic_vector(8-1 downto 0);

begin

	sda_fall_p : process (sys_rst, i2c_sda)
	begin
		if sys_rst='1' then
			sda_fall <= '0';
		elsif falling_edge(i2c_sda) then
			if i2c_scl='1' then
				sda_fall <= not sda_rise;
			end if;
		end if;
	end process;

	sda_rise_p : process (sys_rst, i2c_sda)
	begin
		if sys_rst='1' then
			sda_rise <= '0';
		elsif rising_edge(i2c_sda) then
			if i2c_scl='1' then
				sda_rise <= sda_fall;
			end if;
		end if;
	end process;

	start <= sda_fall xor sda_rise;

	s_p : process (start, i2c_scl)
	begin
		if start='0' then
			i2c_s <= '0';
		elsif falling_edge(i2c_scl) then
			i2c_s <= start;
		end if;
	end process;

	process (i2c_scl)
	begin
		if falling_edge(i2c_scl) then
			if ena='1' then
				do <= do(7-1 downto 0) & i2c_sda;
			end if;
		end if;
	end process;
	sys_do <= do;

	seq_p : process (i2c_scl)
		variable cntr : std_logic_vector(0 to 3);
	begin
		if falling_edge(i2c_scl) then
			cntr := dec (
				cntr => cntr,
				ena  => not i2c_s or (not i2c_sda or not cntr(0)),
				load => not i2c_s or (not i2c_sda and cntr(0)),
				data => 9-2);
			ena <= not cntr(0);
		end if;
	end process;
end;
