library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;

architecture ddr_timer of testbench is
	signal ddr_timer_clk : std_logic := '0';
	signal ddr_timer_rst : std_logic := '1';
	signal ddr_init_rst  : std_logic := '0';
	signal ddr_init_cke  : std_logic := '0';
	signal dll_timer_req : std_logic := '0';
	signal dll_timer_rdy : std_logic := '0';
	signal ref_timer_req : std_logic := '0';
	signal ref_timer_rdy : std_logic := '0';

	constant tCP2  : time := 2.5 ns;
	constant tREF : time := 7.2 us;
	constant cDLL : natural := 200;

begin

	ddr_timer_clk <= not ddr_timer_clk after tCP2;
	ddr_timer_rst <= '1', '0' after 30 ns;
	dll_timer_req <= '1' after 800 us;
	ref_timer_req <= '1' after 1000 us;

	process
	begin
		if rising_edge(ddr_timer_clk) then
		end if;

		wait on ddr_timer_clk;
	end process;

	du : entity work.ddr_timer
	generic map (
		c200u => 200 us/(2*tCP2),
		cDLL  => 200,
		c500u => 500 us/(2*tCP2),
		cxpr  => 20 ns/(2*tCP2),
		cREF  => tREf/(2*tCP2))
	port map (
		ddr_timer_clk => ddr_timer_clk,
		ddr_timer_rst => ddr_timer_rst,
		ddr_init_rst  => ddr_init_rst,
		ddr_init_cke  => ddr_init_cke,
		dll_timer_req => dll_timer_req,
		dll_timer_rdy => dll_timer_rdy,
		ref_timer_req => ref_timer_req,
		ref_timer_rdy => ref_timer_rdy);
end;
