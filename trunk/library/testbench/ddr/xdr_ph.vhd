library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;

architecture ddr_ph of testbench is
	constant data_phases : natural := 4;
	constant data_edges  : natural := 2;
	constant period : time := 4 ns;

	signal sys_clks : std_logic_vector(0 to data_phases/data_edges-1) := (others => '0');
	signal di : std_logic := '0';
	signal j : natural;
begin
	sys_clks(0) <= not sys_clks(0) after period/2;
	process (sys_clks(0))
	begin
		for i in 1 to sys_clks'length-1 loop
			sys_clks(i) <= sys_clks(0) after period / sys_clks'length;
		end loop;
		j <= (j + 1) mod 7;
	end process;

	di <=
		not di when j = 2 else
		not di when j = 6 else
		di;

	du : entity hdl4fpga.xdr_ph
	generic map (
		delay_size => 5)
	port map (
		sys_clks => sys_clks,
		sys_di => di);
end;
