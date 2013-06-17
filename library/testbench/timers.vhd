library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture timers of testbench is
	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal timer_req : std_logic;
	signal timer_rdy : std_logic;
	signal timer_sel : std_logic_vector(1 downto 0) := (others => '0');

	constant timer_data : natural_vector(0 to 4-1) := (
		58, 33, 55, 128);
begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 45.00001 ns;

	timer_req <= not rst; -- and not timer_rdy;
	du : entity hdl4fpga.timers
	generic map (
		timer_len  => 21,
		timer_data => timer_data)
	port map (
		timer_clk  => clk,
		timer_sel  => timer_sel,
		timer_req  => timer_req,
		timer_rdy  => timer_rdy);
end;
