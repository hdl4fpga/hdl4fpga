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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

architecture pgm_delay of testbench is
	constant n : natural := 4;
	signal clk : std_logic := '0';
	signal xp : std_logic;
	signal xn : std_logic;
	signal ena : std_logic_vector(0 to n-1) := (others => '0');
begin
	clk <= not clk after 5 ns;
	ena(n-n) <= '0', '1' after 40 ns;

	du : entity hdl4fpga.pgm_delay
	generic map (
		n => 4)
	port map (
		ena => ena,
		xi => clk,
		x_p => xp,
		x_n => xn);

end;
