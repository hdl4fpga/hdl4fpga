library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture counter of testbench is
	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal req : std_logic;
	signal rdy : std_logic;
	signal ena : std_logic;
	signal co : std_logic_vector(3-1 downto 0);

  constant stage_size : natural_vector(3-1 downto 0) := (2 => 9, 1 => 5, 0 => 3);
begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 45.00001 ns;
	req <= rst;
	ena <= '1', '0' after 345.00001 ns;
	du : entity hdl4fpga.counter
	generic map (
		stage_size => stage_size)
	port map (
		data => to_unsigned(64, 9),
		clk  => clk,
		load  => req,
		co => co,
		ena  => ena);
end;
