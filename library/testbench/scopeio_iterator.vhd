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

architecture scopeio_iterator of testbench is

	signal clk   : std_logic := '0';

	signal value : signed(3*4-1 downto 0);

	signal init  : std_logic;
	signal ena   : std_logic := '1';
	signal start : signed(value'range) := x"000";
	signal stop  : signed(value'range) := x"010";
	signal step  : signed(value'range) := x"003";
	signal ended : std_logic;

begin

	init <= ended;
	clk  <= not clk after 10 ns;

	iterator_e : entity hdl4fpga.scopeio_iterator
	port map (
		clk   => clk,
		init  => init,
		ena   => ena,
		start => start,
		stop  => stop,
		step  => step,
		ended => ended,
		value => value);

end;
