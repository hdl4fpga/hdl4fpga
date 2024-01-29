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

library hdl4fpga;
use hdl4fpga.base.all;

architecture mul_ser_tb of testbench is
	signal clk  : std_logic := '0';
	signal ena  : std_logic := '1';
	signal init : std_logic := '1';
	signal load : std_logic := '1';
	signal feed : std_logic := '1';
	signal p : std_logic_vector(0 to 10-1);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if init='1' then
				init <= '0';
			end if;
		end if;
	end process;

	load <= init or feed;
	du_e : entity hdl4fpga.mul_ser
	port map (
		clk  => clk,
		ena  => ena,
		load => load,
		feed => feed,
		a  => b"01111",
		b  => b"01001",
		s  => p);

	process (p)
	begin
		report to_string(p);
	end process;

end;