-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture cntrcs of testbench is

	constant slices : natural_vector := (0 => 1, 1 => 2);

	signal eoc  : std_logic_vector(slices'range);
	signal clk  : std_logic := '0';
	signal load : std_logic := '1';

	signal q    : std_logic_vector(0 to 3-1);
	signal d    : std_logic_vector(0 to 3-1) := (others => '0');

begin

	clk <= not clk after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if load='1'  then
				load <= '0';
			end if;
		end if;
	end process;

	du : entity hdl4fpga.cntrcs
	generic map (
		slices => slices)
	port map (
		clk    => clk,
		load   => load,
		d      => d,
		q      => q,
		eoc    => eoc);

end;
