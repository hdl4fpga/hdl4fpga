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

entity main is
end;

architecture def of main is

	type yyy is record
		frac : natural;
		exp  : integer;
		prec : natural;
		unit : integer;
		mult : natural;
	end record;

	impure function xxx (
		constant arg : real)
		return yyy is
		variable rval : yyy;
		variable prec : integer;
		variable temp : real;
		variable mult : real;
		variable mesg : line;
	begin
		mult := 1.0;
		while arg > mult loop
			mult := mult * 1.0e3;
		end loop;
		mult := mult / 1.0e3;
		temp := arg  / mult;

		prec := -3;
		for i in 0 to 3-1 loop
		write (mesg, temp);
		writeline(output, mesg);
			if 10.0 < temp then
				prec := prec + 1;
			elsif 4.0 < temp  then
				prec := prec + 0;
			end if;
			temp := temp / 10.0;
		end loop;
		write (mesg, prec);
		writeline(output, mesg);
		return rval;
	end;

begin
	process
		variable pp : yyy;
	begin
		pp := xxx(101.0e12);
		wait;

	end process;
end;
