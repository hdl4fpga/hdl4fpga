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
use ieee.math_real.all;

entity main is
end;

architecture def of main is

	type sio_float is record
		frac  : natural;
		exp   : integer;
		order : natural;
	end record;

	function to_siofloat (
		constant unit : real)
		return sio_float is
		variable frac : real;
		variable exp   : integer;
		variable order : natural;
		variable mult  : real;
	begin
		assert unit >= 1.0  
			report "Invalid unit value"
			severity failure;

		mult  := 1.0;
		order := 0;
		while unit >= mult loop
			mult  := mult * 1.0e1;
			order := order + 1;
		end loop;
		mult  := mult / 1.0e1;
		order := order - 1;
		frac  := unit / mult;

		exp  := 0;
		for i in 0 to 3-1 loop
			assert i /= 2
				report "Invalid unit value"
				severity failure;
			frac := frac * 2.0;
			exp  := exp - 1;
			exit when floor(frac)=(frac);
		end loop;

		return sio_float'(frac => natural(frac), exp => exp, order => order);
	end;

begin
	process
		variable arg  : real;
		variable unit : real;
		variable mult : real;
		variable order : integer;
		variable prec : integer;
		variable exp  : integer;
		variable mesg : line;
	begin
		arg := 125.0;

		mult  := 1.0;
		order := 0;
		while arg >= mult loop
			mult  := mult * 1.0e3;
			order := order + 1;
		end loop;
		mult  := mult / 1.0e3;
		order := order - 1;
		unit  := arg  / mult;

		mult := 1.0;
		prec := 2;
		while unit >= mult loop
			mult := mult * 1.0e1;
			prec := prec - 1;
		end loop;
		mult := mult / 1.0e1;
		prec := prec + 1;
		unit := unit  / mult;

		mult := 1.0;
		exp  := 0;
		for i in 0 to 3-1 loop
			assert i /= 2
				report "Invalid unit value"
				severity failure;
			unit := unit * 2.0;
			exp  := exp + 1;
			exit when floor(unit)=(unit);
		end loop;

		write (mesg, string'("unit : "));
		write (mesg, unit);
		write (mesg, string'(" : order : "));
		write (mesg, order);
		write (mesg, string'(" : prec : "));
		write (mesg, prec);
		write (mesg, string'(" : exp : "));
		write (mesg, exp);
--		writeline(output, mesg);
		wait;

	end process;
	process
		variable p : sio_float;
		variable mesg : line;
	begin
		p := to_siofloat(25.0*4.0);

		write (mesg, string'("frac : "));
		write (mesg, p.frac);
		write (mesg, string'(" : exp : "));
		write (mesg, p.exp);
		write (mesg, string'(" : order : "));
		write (mesg, p.order);
		writeline(output, mesg);
		wait;
	end process;
end;
