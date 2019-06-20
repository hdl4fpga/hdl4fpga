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

entity scopeio_amp is
	generic (
		lat : natural := 0);
	port (
		input_clk     : in  std_logic;
		input_ena     : in  std_logic;
		input_sample  : in  std_logic_vector;
		gain_value    : in  std_logic_vector;
		output_ena    : out std_logic;
		output_sample : out std_logic_vector);
end;

architecture beh of scopeio_amp is

	signal p : signed(0 to gain_value'length+input_sample'length-1);
	signal a : signed(gain_value'range);
	signal b : signed(input_sample'range);

begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			p <= a*b;
			a <= signed(gain_value);
			b <= signed(input_sample);

		end if;
	end process;
	output_sample <= std_logic_vector(resize(p(0 to output_sample'length), input_sample'length));

	lat_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => lat+2))
	port map (
		clk   => input_clk,
		di(0) => input_ena,
		do(0) => output_ena);
end;
