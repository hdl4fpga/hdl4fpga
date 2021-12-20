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
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity main is
end;

architecture def of main is
begin
	main_p : process
		variable msg : line;

		function shr (
			constant arg1 : string;
			constant arg2 : natural)
			return string is
			variable retval : string(arg1'range);
		begin
			retval := arg1;
			for i in arg1'reverse_range loop
				if i > arg2 then
					retval(i) := arg1(i-arg2);
				end if;
				for i in 1 to arg2 loop
					retval(i) := ' ';
				end loop;
			end loop;
			return retval;
		end;

		impure function fcvt (
			constant num     : real;
			constant ndigits : natural)
			return string is
			constant lookup : string := "0123456789";

			variable mant   : real;
			variable exp    : integer;
			variable retval : string(1 to 16);
			variable cy     : natural range 0 to 1;
			variable digit  : natural range 0 to 9;
			variable n      : natural;

			variable msg    : line;
		begin
			mant := abs(num);
			exp  := 0;
			if mant/=0.0 then
				retval(1) := '0';
				n := 1;
				if mant > 1.0 then
					loop
						exit when mant >= 1.0;
						mant := mant * 2.0;
						exp  := exp - 1;
					end loop;

					loop
						exit when mant < 1.0;
						mant := mant / 2.0;
						exp  := exp + 1;
					end loop;

					for i in 0 to exp-1 loop
						mant  := mant * 2.0;
						cy    := setif(mant >= 1.0, 1, 0);
						mant  := mant - real(cy);
						for i in n downto 1 loop
							digit := character'pos(retval(i))-character'pos('0');
							if digit < 5 then
								retval(i) := lookup(2*digit+cy+1);
								cy := 0;
							else
								retval(i) := lookup(2*digit+cy-10+1);
								cy := 1;
							end if;
						end loop;
						if cy > 0 then
							retval := shr(retval, 1);
							n      := n + 1;
							retval(1) := '1';
						end if;

					end loop;
				end if;

				n      := n + 1;
				retval(n) := '.';
				for i in 1 to 5 loop
					digit := natural(floor(10.0*mant));
					mant  := mant*10.0-floor(10.0*mant);
					retval(n+i) := lookup(digit+1);
				end loop;
				write(msg, string'(" -> ") & retval );
				writeline(output, msg);
			end if;
--			write(msg, mant);
--			write(msg, string'(" : "));
--			write(msg, exp);
--			writeline(output, msg);
			return retval;

		end;
	begin
		write(msg, fcvt(0.00001, 10));
		wait;
	end process;

end;
