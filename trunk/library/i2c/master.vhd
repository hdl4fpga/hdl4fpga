library ieee;
use ieee.std_logic_1164.all;

entity i2c_master is
	port (
		sys_rst : in  std_logic;
		sys_clk : in  std_logic;
		sys_di  : in  std_logic_vector(0 to 8-1);
		sys_do  : out std_logic_vector(0 to 8-1);
		sys_sbi : out std_logic;
		sys_req : in  std_logic;
		sys_rdy : out std_logic;
		sys_ack : out std_logic;

		i2c_scl : inout std_logic;
		i2c_sda : inout std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of i2c_master is
	signal data  : std_logic_vector(0 to 8-1);

	signal start : std_logic;
	signal stop  : std_logic;
	signal sbit  : std_logic;
	signal ack   : std_logic;
	signal rdy   : std_logic;
	signal req   : std_logic;

	signal lat : std_logic_vector(0 to 3);

begin

	if rdy='1' then
		if sys_req='1' then
			i2c_scl <= sys_clk and sys_req;
	process (sys_rst, i2c_sda)
	begin
		if sys_rst='1' then
			start<= '0';
		elsif falling_edge(i2c_sda) then
			if i2c_scl='1' then
				start <= not stop;
				req <= '0';
			end if;
		end if;
	end process;

	process (sys_rst, i2c_sda)
	begin
		if sys_rst='1' then
			stop <= '0';
		elsif rising_edge(i2c_sda) then
			if i2c_scl='1' then
				stop <= start;
			end if;
		end if;
	end process;

	process (sys_rst, i2c_scl)
	begin
		if sys_rst='1' then
		elsif falling_edge(i2c_scl) then
			lat <= dec (
				cntr => lat,
				ena  => not sbit or rdy or not lat(0),
				load => not sbit or rdy,
				data => 8-2);
			ack  <= not i2c_sda and lat(0);
			rdy  <= lat(0);
			sbit <= stop xnor start;

			if lat(0)='1' then
				data <= sys_di;
			elsif sbit='0' then
				data <= sys_di;
			else
				data <= data sll 1;
			end if;
		end if;
	end process;
	sys_rdy <= lat(0);
	sys_sbi <= sbit;
	sys_ack <= ack;
	i2c_sda <= data(0);
end;
