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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.hdo.all;

entity main is
end;

architecture def of main is
begin
	process 
		constant c : string := significand(31.25e-6);
		variable x : string(c'range);
	begin
			-- "value => " & (hdo(normalize(*coefs(i)))**".norm");
		-- report "VALUE : " & ''' & get_value("[hola,mundo:[kkkk:12345,dddd:[67890]],hello,world].kkk", "[mundo].dddd") & ''';
			-- report "VALUE : " & ''' & hdo(c)**".norm" & ''';
			report CR & "VALUE : " & ''' & c & ''';
		wait;
	end process;
end;
