library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_clks of testbench is
	signal sys_ini   : std_logic;
	signal ddr_clk0  : std_logic := '0';
	signal ddr_clk90 : std_logic := '0';
begin

	sys_ini   <= '1', '0' after 50 ns;
	ddr_clk0  <= not ddr_clk0 after 5 ns;
	ddr_clk90 <= transport not ddr_clk0 after 7.5 ns;

	du : entity hdl4fpga.xdr_clks
	port map (
		sys_ini   => sys_ini,
		sys_clk0  => ddr_clk0,
		sys_clk90 => ddr_clk90,
		dqs_rst   => '1',
		ddr_dqsi => (others => '-'));
end;
