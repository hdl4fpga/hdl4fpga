use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

architecture ddr_timer of testbench is
	signal ddr_timer_clk  : std_logic := '0';
	signal ddr_timer_rst  : std_logic := '1';
	signal ddr_timer_sel  : std_logic := '0';
	signal ddr_timer_200u : std_logic := '0';
	signal ddr_timer_dll  : std_logic := '0';
	signal ddr_timer_ref  : std_logic := '0';
	constant tCP2  : time := 2.5 ns;
	constant tREF : time := 7.2 us;
	constant cDLL : natural := 200;
begin
	ddr_timer_clk <= not ddr_timer_clk after tCP2;

	process
		variable msg : line;
		variable step : natural := 0;
	begin
		if rising_edge(ddr_timer_clk) then
			if step=0 then
				write (msg, string'("step : sel : req : 200 : dll : ref"));
				writeline (output, msg);
			end if;
			write (msg, step, field => 4);
			write (msg, string'(" : ")); write (msg, ddr_timer_rst,  field => 3);
			write (msg, string'(" : ")); write (msg, ddr_timer_sel,  field => 3);
			write (msg, string'(" : ")); write (msg, ddr_timer_200u, field => 3);
			write (msg, string'(" : ")); write (msg, ddr_timer_dll,  field => 3);
			write (msg, string'(" : ")); write (msg, ddr_timer_ref,  field => 3);
			writeline (output, msg);
		end if;

		if rising_edge(ddr_timer_clk) then
			step := step + 1;
			if step > 4 then
				ddr_timer_rst <= '0';
			end if;
	ddr_timer_sel <= ddr_timer_200u;
--			ddr_timer_sel <= '0';
			if ddr_timer_200u='1' then
--				ddr_timer_sel <= '0';
				if ddr_timer_dll='0' then
				end if;
			end if;
		end if;
		wait on ddr_timer_clk;
	end process;

	du : entity work.ddr_timer
	generic map (
		c200u => 200 us/(2*tCP2),
		cDLL  => cDLL,
		cREF  => tREf/(2*tCP2))
	port map (
		ddr_timer_clk  => ddr_timer_clk,
		ddr_timer_rst  => ddr_timer_rst,
		ddr_timer_sel  => ddr_timer_sel,
		ddr_timer_200u => ddr_timer_200u,
		ddr_timer_dll  => ddr_timer_dll,
		ddr_timer_ref  => ddr_timer_ref);
end;
