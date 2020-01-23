--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;
use hdl4fpga.ddr_param.all;

architecture ddr_sch of testbench is
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
			k := (k + 1) mod 4;
			if k = 0 then
				sys_rea <= not sys_rea after 1 ps;
			end if;
		end if;

		for i in sys_clks'range loop
			sys_clks(i) <= transport clk after (i*period/sclk_edges)/sys_clks'length;
		end loop;
	end process;

		STRL_TAB  => ddr_lattab(std, STRT,  tDDR =>1 ns, tCP => 0.25 ns),
		STRX_LAT  => 8, --ddr_latency(std, STRXL,  tDDR =>1 ns, tCP => 0.25 ns),
		WID_LAT   => ddr_latency(std, WIDL,   tDDR =>1 ns, tCP => 0.25 ns))
	du : entity hdl4fpga.ddr_sch
	generic map (
		sclk_phases => sclk_phases,
		sclk_edges => sclk_edges,
		data_phases => data_phases,
		data_edges  => data_edges,
		line_size   => line_size,
		word_size   => word_size,
		byte_size   => byte_size,

		CL_COD    => ddr_latcod(std, ddr_selcwl(std)),
		CWL_COD   => ddr_latcod(std, ddr_selcwl(std)),

		RWNL_tab  => ddr_lattab(std, RWNT,  tDDR =>1 ns, tCP => 0.25 ns),
		DQSZL_TAB => ddr_lattab(std, DQSZT, tDDR =>1 ns, tCP => 0.25 ns),
		DQSOL_TAB => ddr_lattab(std, DQST,  tDDR =>1 ns, tCP => 0.25 ns),
		DQZL_TAB  => ddr_lattab(std, DQZT,  tDDR =>1 ns, tCP => 0.25 ns),
		WWNL_TAB  => ddr_lattab(std, WWNT,  tDDR =>1 ns, tCP => 0.25 ns),

		RWNX_LAT  => ddr_latency(std, RWNXL,  tDDR =>1 ns, tCP => 0.25 ns),
		DQSZX_LAT => ddr_latency(std, DQSZXL, tDDR =>1 ns, tCP => 0.25 ns),
		DQSX_LAT  => ddr_latency(std, DQSXL,  tDDR =>1 ns, tCP => 0.25 ns),
		DQZX_LAT  => ddr_latency(std, DQZXL,  tDDR =>1 ns, tCP => 0.25 ns),
		WWNX_LAT  => ddr_latency(std, WWNXL,  tDDR =>1 ns, tCP => 0.25 ns),
	port map (
        sys_cl => "101",
        sys_cwl => "101",
		sys_clks => sys_clks,
		sys_rea => sys_rea,
		sys_wri => sys_rea);
end;
