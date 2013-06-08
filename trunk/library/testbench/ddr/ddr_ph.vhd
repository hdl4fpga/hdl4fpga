library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

architecture ddr_ph of testbench is
	signal ddr_clk   : std_logic := '0';
	signal ddr_clk90 : std_logic := '0';
	constant n : natural := 12;
	signal ddr_ph_qout : std_logic_vector(1 to 4*n+3*3);
	signal ddr_sel : std_logic_vector(0 to n+2);
	signal q : std_logic := '0';
begin

	ddr_clk   <= not ddr_clk after 5 ns;
	ddr_clk90 <= transport not ddr_clk after 7.5 ns;

	ddr_sel <= (others => '0'), (others => '1') after 200 ns;
	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then
			q <= not q;
		end if;
	end process;

	du : entity hdl4fpga.ddr_ph
	generic map (
		n => n)
	port map (
		ddr_ph_clk   => ddr_clk,
		ddr_ph_clk90 => ddr_clk90,
		ddr_ph_sel => ddr_sel,
		ddr_ph_din(0) => q,
		ddr_ph_din(1 to n+2) => (others => '0'),
		ddr_ph_qout => ddr_ph_qout);
end;
