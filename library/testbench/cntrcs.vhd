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

architecture cntrcs of testbench is

	constant slices : natural_vector := (0 => 4, 1 => 4);

	signal clk  : std_logic := '0';
	signal load : std_logic := '0';

	signal q    : std_logic_vector(0 to 8-1);
	signal d    : std_logic_vector(0 to 8-1);

begin

	clk <= not clk after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if load='1'  then
				loadd <= '0';
			end if;
		end if;
	end process;

	du : entity hdl4fpga.cntrcs
	generic (
		slices => slices);
	port (
		clk    => clk,
		load   => load,
		d      => d,
		q      => q,
		eoc    => eoc);

end;
