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

library altera_lnsim;
use altera_lnsim.altera_lnsim_components.all;

architecture test of dkdev5cea7n is
begin
	pll_i : altera_pll
	generic map (
		fractional_vco_multiplier => "false",
		reference_clock_frequency => "50.0 MHz",
		operation_mode => "normal",
		number_of_clocks => 7,
		output_clock_frequency0 => "300.000000 MHz",
		phase_shift0 => "0 ps",
		duty_cycle0 => 50,
		output_clock_frequency1 => "300.000000 MHz",
		phase_shift1 => "2500 ps",
		duty_cycle1 => 50,
		output_clock_frequency2 => "150.000000 MHz",
		phase_shift2 => "0 ps",
		duty_cycle2 => 50,
		output_clock_frequency3 => "150.000000 MHz",
		phase_shift3 => "5000 ps",
		duty_cycle3 => 50,
		output_clock_frequency4 => "300.000000 MHz",
		phase_shift4 => "0 ps",
		duty_cycle4 => 50,
		output_clock_frequency5 => "150.000000 MHz",
		phase_shift5 => "0 ps",
		duty_cycle5 => 50,
		output_clock_frequency6 => "25.000000 MHz",
		phase_shift6 => "0 ps",
		duty_cycle6 => 50)
	port map (
		rst       => user_pbs(0),
		refclk    => clkin_50_fpga_top);
end;
