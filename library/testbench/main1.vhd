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

		variable distance : natural;
		variable word_quo : natural;
		variable word_mod : natural;
		variable tail : natural;
		variable tail_quo : natural;
		variable tail_mod : natural;
	begin

			latency_mod := latency mod word'length;
			latency_quo := latency  /  word'length;
			for j in word'range loop
				distance  := (extension-j+word'length-1)/word'length;
				width_quo := (distance+width-1)/width;
				width_mod := (width_quo*width-distance) mod width;

				pha := (j+latency_mod)/word'length;
				if word_quo /= 0 then
					tail_quo := width_mod  /  width_quo;
					tail_mod := width_mod mod width_quo;
					for l in 1 to width_quo loop
						tail := tail_quo + (l*tail_mod) / j_quo;
						pha  := (j+latency_mod)/word'length+l*width-tail;
					end loop;
				end if;
			end loop;
		wait ;
	end process;
end;
