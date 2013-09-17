library ieee;
use ieee.std_logic_1164.all;

entity i2c_master is
	port (
		sys_rst : in  std_logic;
		sys_clk : in  std_logic;
		sys_ena : in  std_logic;
		sys_di  : in  std_logic;
		sys_do  : out std_logic;

	 start : out std_logic;
		i2c_scl : inout std_logic;
		i2c_sda : inout std_logic);
end;

architecture def of i2c_master is
	signal sttp : std_logic_vector(0 to 1);
begin

	process (i2c_sda, sys_rst)
	begin
		if sys_rst='1' then
			sttp(0) <= '1';
		elsif falling_edge(i2c_sda) then
			if i2c_scl='1' then
				sttp(0) <= not sttp(1);
			end if;
		end if;
	end process;

	process (i2c_sda, sys_rst)
	begin
		if sys_rst='1' then
			sttp(1) <= '1';
		elsif rising_edge(i2c_sda) then
			if i2c_scl='1' then
				sttp(1) <= sttp(0);
			end if;
		end if;
	end process;

	with sttp select
	start <= 
		'1' when "01"|"10",
		'0' when others;
end;
