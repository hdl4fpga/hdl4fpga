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

entity bfyram is
end;

architecture def of bfyram is
	signal clk : std_logic := '0';
begin
	clk <= not clk after 10 ns;

	process 
		constant n : natural := 8;
		variable k : natural;
		variable m : natural;
		variable b : natural;
		variable l : natural;
		variable msg : line;
	begin
		k := 2**n/2;
		m := 1;
		for l in 0 to n/2-1 loop
			b := 0;
			for i in 0 to 2*m-1 loop
				if i mod 2 = 0 then
				else
					for j in 0 to k-1 loop
						write (msg, string'(" l : "));   write (msg, l);
						write (msg, string'(" : i : ")); write (msg, i/2);
						write (msg, string'(" : k : ")); write (msg, k);
						write (msg, string'(" : p : ")); write (msg, j+b);
						write (msg, string'(" : "));     write (msg, j+b+k);
						writeline (output, msg);
					end loop;
					b := b + 2*k;
				end if;
			end loop;
--				write (msg, string'(" : "));   write (msg, l);
----				write (msg, string'(" : "));   write (msg, b);
--				write (msg, string'(" : "));   write (msg, m);
--				write (msg, string'(" : "));   write (msg, k);
--				writeline (output, msg);
			m := m * 4;
			k := k / 4;
		end loop;
		wait;
	end process;
end;
