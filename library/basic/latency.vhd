-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity latency is
	generic (
		n : natural := 1;
		d : natural_vector;
		i : std_logic_vector := (0 to 0 => '-'));
	port (
		clk : in  std_logic;
		ini : in  std_logic := '0';
		ena : in  std_logic := '1';
		di  : in  std_logic_vector(0 to n-1);
		do  : out std_logic_vector(0 to n-1));
end;

architecture def of latency is
	constant dly : natural_vector(0 to d'length-1) := d;
	constant val : std_logic_vector(0 to i'length) := i & '-';
begin
	delay: for j in 0 to n-1 generate
		signal q : std_logic_vector(0 to dly(j)) := (others => val(setif(j < i'length, j, i'length)));
	begin
		q(q'right) <= di(j);
		process (clk)
		begin
			if rising_edge(clk) then
				if dly(j) > 0 then
					if ini='1' then
						if j < val'length-1 then
							q(0 to q'right-1) <= (others => val(j));
						end if;
					elsif ena='1' then
						q(0 to q'right-1) <= q(1 to q'right);
					end if;
				end if;
			end if;
		end process;
		do(j) <= q(0);
	end generate;
end;



