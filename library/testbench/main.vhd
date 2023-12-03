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
use ieee.math_real.all;

library hdl4fpga;
use work.jso.all;

entity main is
end;

architecture def of main is
begin
	process 
		-- constant key    : string := " . hola . hello";
		constant key    : string := "[ xyz ] . hola . hello[ 345 ]";
		variable offset : natural;
		variable length : natural;
	begin
		set_index(key'left);
		for i in 0 to 4-1 loop
			next_key(key, offset, length);
		-- report character'image(key(offset+length));
			report "subkey : " & '"' & key(offset to offset+length-1) & '"';
		-- report integer'image(offset+length);
		end loop;
		wait;
	end process;
end;
