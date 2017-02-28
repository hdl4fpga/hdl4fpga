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
	subtype word is unsigned(0 to 4-1);
	constant p   : unsigned(0 to 8)   := b"100000111";
begin
	process
		variable data : unsigned(0 to 8-1) := b"11101010"; --b"01010111";
		variable aux  : unsigned(p'range)  := (others => '0');
		variable msg  : line;
	begin
		for k in 0 to data'length/word'length-1 loop
			aux(word'range) := aux(word'range) xor data(word'range);
			for i in word'range loop
				if aux(0)='1' then
					for j in p'range loop
						aux(j) := aux(j) xor p(j);
					end loop;
				end if;
				aux  := aux  sll 1;
			end loop;
			data := data sll word'length;
		end loop;
		write (msg, std_logic_vector(aux(0 to aux'right-1)));
		writeline (output, msg);
		wait;
	end process;
end;
