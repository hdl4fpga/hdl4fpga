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

library hdl4fpga;

architecture bcddiv2e of testbench is

	signal rst : std_logic := '0';
	signal clk : std_logic := '0';

	signal bcd_do  : std_logic_vector(4-1 downto 0);
	signal bcd_cy  : std_logic;

begin
	rst    <= '1', '0' after 15 ns;
	clk    <= not clk after 10 ns;

	du : entity hdl4fpga.bcddiv2e
	generic map (
		max => 16)
	port map (
		clk     => clk,
		bcd_ena => '0',
		bcd_exp => x"e",

		bcd_ini => '1',
		bcd_di  => x"4",
		bcd_do  => bcd_do);

end;
