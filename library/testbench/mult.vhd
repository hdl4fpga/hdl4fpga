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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;

architecture mult of testbench is

	signal clk : std_logic := '0';
	signal rst : std_logic;
	signal ini : std_logic;

	signal product : std_logic_vector(0 to 8-1);
begin
	clk <= not clk after 5 ns;
	rst <= '1', '0' after 26 ns;

	process (clk)
	begin
		if rising_edge(clk) then
		end if;
	end process;


	ini <= rst;
	mulp_b : block
		variable prod : std_logic_vector(0 to mand'length+mier'length-1);
	begin
		multp_e : entity hdl4fpga.mult
		port map (
			clk     => clk,
			ini     => ini ,
			multand => mand,
			multier => mier,
			product => prod);

		acc_e : entity hdl4fpga.adder
		port map (
			ci => ci,
			a  => 
			b  =>
			s  => prod(0 to),
			co => );

		fifo_e : entity hdl4fpga.align
		port map (
			clk => clk,
			di  => prod(0 to),
			do  => );

		process (clk)
			variable cntr : unsigned;
		begin
			if rising_edge(clk) then 
				cntr := cntr + 1;
			end if;
		end process;
	end block;

end;
