--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity randrom is
	constant n : natural := 1024;
	constant p : natural := 10;
	constant m : natural := 16;
end;

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

architecture def of randrom is
begin
	process
		variable seed1 : natural := 3;
		variable seed2 : natural := 2;
		variable unifR : real;

		variable buf : line;
	begin
		write (buf, string'("constant xxx : std_logic_vector"));
		for i in 0 to n-1 loop
			uniform(seed1,seed2,unifR);
			unifR := round(unifR*(2.0**p-1.0));
			if i mod m=0 then
				writeline (output, buf);
				write (buf, character'(HT));
				write (buf, character'(HT));
			else
				write (buf, string'(" "));
			end if;
			write (buf, '"');
			hwrite (buf, std_logic_vector(to_unsigned(integer(unifR),p)));
			write (buf, '"');
			if i /= n-1 then
				write (buf, string'(","));
			end if;
			if i mod 12=m-1 or i=n-1 then
				writeline (output, buf);
			end if;
		end loop;
		wait;
	end process;
end;
