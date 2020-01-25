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

entity ddr_ph is
	generic (
		clk_phases : natural := 1;
		clk_edges  : natural := 1;
		delay_phase : natural := 2;
		delay_size  : natural := 2);
	port (
		sys_clks : in std_logic_vector(0 to clk_phases/clk_edges-1);
		sys_di : in std_logic;
		ph_qo  : out std_logic_vector(0 to delay_size));
end;

library hdl4fpga;
use hdl4fpga.std.all;

use std.textio.all;

architecture slr of ddr_ph is
	signal clks : std_logic_vector(0 to clk_phases-1) := (others => '-');
	signal phi  : std_logic_vector(clks'range) := (others => '-');
	signal phi0 : std_logic_vector(clks'range) := (others => '-');
	signal qo : std_logic_vector(0 to delay_size);

begin
	
	clks(sys_clks'range) <= sys_clks;
	falling_edge_g : if clk_edges /= 1 generate
		clks(clk_phases/clk_edges to clk_phases-1) <= not sys_clks;
	end generate;

	g0: block
		signal q : std_logic_vector(0 to delay_size/clk_phases);
	begin
		q(0) <= sys_di;
		process (clks(0))
		begin
			if rising_edge(clks(0)) then
				q(1 to q'right) <= q(0 to q'right-1);
			end if;
		end process;
		phi (clks'length-1) <= q(0);
		j: for j in q'range generate
			qo(j*clk_phases) <= q(j);
		end generate;
	end block;

	gn : for i in 1 to clk_phases-1 generate
		signal q  : std_logic_vector((clk_phases-i)*(clks'length-1)/clk_phases to (delay_size-i)/clk_phases) := (others => '-');
	begin
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				q <= phi(i) & q(q'left to q'right-1);
			end if;
		end process;
		phi ((i+clks'length-1) mod clks'length) <= q(q'left);
		j: for j in q'range generate
			qo(j*clk_phases+i) <= q(j);
		end generate;
	end generate;

	clk_phases_g : if clk_phases > 1 generate
		phi0 (delay_phase) <= sys_di;

		g : for i in 1 to clk_phases-1 generate
			constant left : natural := setif (
				clk_phases*((delay_phase+i)/clk_phases) > delay_phase,
				(delay_phase+i-1)/clk_phases,
				(delay_phase+i-1)/clk_phases+1);
			signal q : std_logic_vector(left to (clk_phases-i)*(clks'length-1)/clk_phases-1) := (others => '-');
		begin
			q1_g : if q'length > 0 generate
				process (clks(i))
				begin
					if rising_edge(clks(i)) then
						q(q'left) <= phi0(i);
						for i in q'left+1 to q'right loop
							q(i) <= q(i-1);
						end loop;
					end if;
				end process;

				phi0 ((i+clks'length-1) mod clks'length) <= q(q'left);

				qo_g : for j in q'range generate
					qo(j*clk_phases+i) <= q(j);
				end generate;

			end generate;
		end generate;
	end generate;

	ph_qo <= qo;
end;
