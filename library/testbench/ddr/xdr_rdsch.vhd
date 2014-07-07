library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_rdsch of testbench is
	constant data_phases : natural := 2;
	constant data_edges  : natural := 2;
	constant period : time := 4 ns;
	constant word_size : natural := 4;
	constant byte_size : natural := 1;

	signal clk : std_logic := '0';
	signal sys_clks : std_logic_vector(0 to data_phases/data_edges-1);
	signal sys_rea : std_logic := '0';
begin
	clk <= not clk after period/2;
	process (clk)
		variable k : natural := 0;
	begin
		if rising_edge(clk) then
			k := (k + 1) mod 8;
			if k = 0 then
				sys_rea <= not sys_rea after 1 ps;
			end if;
		end if;

		for i in sys_clks'range loop
			sys_clks(i) <= transport clk after (i*period/data_edges)/sys_clks'length;
		end loop;
	end process;

	du : entity hdl4fpga.xdr_rdsch
	generic map (
		data_phases => data_phases,
		data_edges => data_edges,
		word_size => word_size,
		byte_size => byte_size,
		clword_size => 3,
		clword_lat => (0 to 0 => 4*data_phases),
		clword_data => "101")
	port map (
		sys_cl => "101",
		sys_clks => sys_clks,
		sys_rea => sys_rea);
end;
