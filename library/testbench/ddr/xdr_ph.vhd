library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_ph of testbench is
	constant data_phases : natural := 4;
	constant data_edges  : natural := 2;
	constant period : time := 4 ns;

	signal clk : std_logic := '0';
	signal sys_clks : std_logic_vector(0 to data_phases/data_edges-1);
	signal di : std_logic := '0';
	signal j : natural;
begin
	clk <= not clk after period;

	process (clk)
	begin
		for i in sys_clks'range loop
			sys_clks(i) <= clk after (i * period) / sys_clks'length;
		end loop;
		j <= (j + 1) mod 7;
		if j = 6 then
            di <= not di after 1 ps;
        end if;
        if j = 2 then
            di <= not di after 1 ps;
        end if;
	end process;

	du : entity hdl4fpga.xdr_ph
	generic map (
		delay_size => 5)
	port map (
		sys_clks => sys_clks,
		sys_di => di);
end;
