library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;
use hdl4fpga.xdr_param.all;

architecture xdr_sch of testbench is
	constant std : natural := 2;
	constant data_phases : natural := 1; --2;
	constant data_edges  : natural := 1; --2;
	constant sclk_phases : natural := 1; --4;
	constant sclk_edges  : natural := 1; --2;
	constant period : time := 4 ns;
	constant line_size : natural := 4;
	constant word_size : natural := 1;
	constant byte_size : natural := 1;

	signal clk : std_logic := '0';
	signal sys_clks : std_logic_vector(0 to sclk_phases/sclk_edges-1);
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
			sys_clks(i) <= transport clk after (i*period/sclk_edges)/sys_clks'length;
		end loop;
	end process;

	du : entity hdl4fpga.xdr_sch
	generic map (
		sclk_phases => sclk_phases,
		sclk_edges => sclk_edges,
		data_phases => data_phases,
		data_edges  => data_edges,
		line_size   => line_size,
		word_size   => word_size,
		byte_size   => byte_size,

		CL_COD    => xdr_latcod(std, xdr_selcwl(std)),
		CWL_COD   => xdr_latcod(std, xdr_selcwl(std)),

		STRL_TAB  => xdr_lattab(std, STRT,  tDDR =>1 ns, tCP => 0.25 ns),
		RWNL_tab  => xdr_lattab(std, RWNT,  tDDR =>1 ns, tCP => 0.25 ns),
		DQSZL_TAB => xdr_lattab(std, DQSZT, tDDR =>1 ns, tCP => 0.25 ns),
		DQSOL_TAB => xdr_lattab(std, DQST,  tDDR =>1 ns, tCP => 0.25 ns),
		DQZL_TAB  => xdr_lattab(std, DQZT,  tDDR =>1 ns, tCP => 0.25 ns),
		WWNL_TAB  => xdr_lattab(std, WWNT,  tDDR =>1 ns, tCP => 0.25 ns),

		STRX_LAT  => 13, --xdr_latency(std, STRXL,  tDDR =>1 ns, tCP => 0.25 ns),
		RWNX_LAT  => xdr_latency(std, RWNXL,  tDDR =>1 ns, tCP => 0.25 ns),
		DQSZX_LAT => xdr_latency(std, DQSZXL, tDDR =>1 ns, tCP => 0.25 ns),
		DQSX_LAT  => xdr_latency(std, DQSXL,  tDDR =>1 ns, tCP => 0.25 ns),
		DQZX_LAT  => xdr_latency(std, DQZXL,  tDDR =>1 ns, tCP => 0.25 ns),
		WWNX_LAT  => xdr_latency(std, WWNXL,  tDDR =>1 ns, tCP => 0.25 ns),
		WID_LAT   => xdr_latency(std, WIDL,   tDDR =>1 ns, tCP => 0.25 ns))
	port map (
        sys_cl => "101",
        sys_cwl => "101",
		sys_clks => sys_clks,
		sys_rea => sys_rea,
		sys_wri => sys_rea);
end;
