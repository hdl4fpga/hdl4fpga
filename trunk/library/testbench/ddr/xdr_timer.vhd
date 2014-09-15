library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture xdr_timer of testbench is
	signal sys_clk : std_logic := '0';
	signal sys_req : std_logic;
	signal sys_rdy : std_logic;

	constant timer_sel : std_logic_vector(0 to 1) := "11";
	constant timer_data : natural_vector(0 to 4-1) := (
		58, 03, 55, 128);
begin

	sys_clk <= not sys_clk after 5 ns;
	sys_req <= '1', '0' after 45.00001 ns;

	du : entity hdl4fpga.xdr_timer
	generic map (
		tmr_high => 9,
		tmr_low  => 4,
		timers   => timer_data)
	port map (
		sys_clk => sys_clk,
		tmr_id  => timer_sel,
		sys_req => sys_req,
		sys_rdy => sys_rdy);
end;
