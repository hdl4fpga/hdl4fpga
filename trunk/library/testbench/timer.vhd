library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture timer of testbench is
	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal req : std_logic;
	signal rdy : std_logic;

begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 45.00001 ns, '1' after 4000.00001 ns, '0' after 4045.0001 ns;
	req <= rst;
	du : entity hdl4fpga.timer
	generic map (
		n  => 3)
	port map (
		data => to_unsigned(300, 9),
		clk  => clk,
		req  => req,
		rdy  => rdy);
end;
