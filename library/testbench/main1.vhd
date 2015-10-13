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

architecture main of testbench is
	constant extension : natural := 22;
	constant width : natural := 3;
	subtype word is bit_vector(0 to 4);
begin
	process 
		variable msg : line;

		constant latency : natural := 12;
		variable latency_mod : natural;
		variable latency_quo : natural;
		variable pha : natural;
--		variable aux : std_logic;

		variable xxx : natural;
		variable j_quo : natural;
		variable j_mod : natural;
		variable tail : natural;
	begin

			latency_mod := latency mod word'length;
			latency_quo := latency  /  word'length;
			for j in word'range loop
				xxx := (extension-j+word'length-1)/word'length;
				j_quo := (xxx+width-1)/width;
				j_mod := (j_quo*width-xxx) mod width;
				write (msg, string'("----------------"));
				writeline (output, msg);

				write (msg, string'("j : "));
				write (msg, j);
				write (msg, string'(" : xxx : "));
				write (msg, xxx);
				write (msg, string'(" : j_quo : "));
				write (msg, j_quo);
				write (msg, string'(" : j_mod : "));
				write (msg, j_mod);

				writeline (output, msg);
				write (msg, string'("----------------"));
				writeline (output, msg);

				tail := 0;
				for l in 0 to j_quo loop
					pha   := (j+latency_mod)/word'length+l*width-tail;
					write (msg, pha);
					writeline (output, msg);

					if j_quo /= 0 then
						tail := j_mod / j_quo + (l*(j_mod mod j_quo)) / j_quo;
					end if;
				end loop;
			end loop;
		wait ;
	end process;
end;
