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

entity test is
end;

architecture mix of test is
begin
	process
		variable data : unsigned(0 to 8) := b"111010100"; --b"010101110";
		constant p    : unsigned(0 to 8)   := b"100000111";
		variable msg  : line;
	begin
		for k in 0 to data'right-1	loop
			if data(0)='1' then
				for j in p'range loop
					data(j) := data(j) xor p(j);
				end loop;
			end if;
			data := data sll 1;
			write (msg, std_logic_vector(data(0 to data'right-1)));
			writeline (output, msg);
		end loop;
		wait;
	end process;
end;
