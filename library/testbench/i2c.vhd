use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

library hdl4fpga;

architecture i2c_master of testbench is
	signal rst : std_logic := '0';
	signal i2c_scl  : std_logic := '0';
	signal i2c_sda  : std_logic;
begin
	i2c_scl <= not i2c_scl after 5 ns;
	i2c_sda <= 
		'1' , 
		'0' after 27 ns,
		'1' after 32 ns;

	rst <= '1', '0' after 10 ns;
	du : entity hdl4fpga.i2c_master
	port map (
		sys_rst => rst,
		i2c_scl => i2c_scl,
		i2c_sda => i2c_sda);
end;
