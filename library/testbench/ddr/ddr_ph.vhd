--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

architecture ddr_ph of testbench is
	signal ddr_clk   : std_logic := '0';
	signal ddr_clk90 : std_logic := '0';
	constant n : natural := 12;
	signal ddr_ph_qout : std_logic_vector(0  to 4*n+3*3);
	signal ddr_sel : std_logic_vector(0 to 4*n+3*3);
	signal q : std_logic := '0';
begin

	ddr_clk   <= not ddr_clk after 5 ns;
	ddr_clk90 <= transport not ddr_clk after 7.5 ns;

	ddr_sel <= (others => '1'), (others => '0') after 1 us;
	q <= '0', '1' after 5.06 ns , '0' after 35.06  ns, '1' after 105.6 ns;

	du : entity hdl4fpga.ddr_ph(slr)
	generic map (
		n => n)
	port map (
		ddr_ph_clk   => ddr_clk,
		ddr_ph_clk90 => ddr_clk90,
		ddr_ph_sel => ddr_sel,
		ddr_ph_din(0) => q,
		ddr_ph_din(1 to 4*n+3*3) => (others => '0'),
		ddr_ph_qout => ddr_ph_qout);
end;
