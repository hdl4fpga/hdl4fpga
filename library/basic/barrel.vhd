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

entity barrel is
	generic (
		shift : boolean := FALSE;
		left  : boolean := TRUE);
	port (
		shf : in  std_logic_vector;
		di  : in  std_logic_vector;
		do  : out std_logic_vector);
end;

architecture beh of barrel is
begin
	process (di, shf)
		variable aux :  unsigned(di'length-1 downto 0);
	begin
		aux := unsigned(di);

		for i in shf'range loop
			if shf(i)= '1' then
				if left then
					if shift then
						aux := shift_left (aux, 2**i);
					else
						aux := rotate_left(aux, 2**i);
					end if;
				else
					if shift then
						aux := shift_left(aux,   2**i);
					else
						aux := rotate_right(aux, 2**i);
					end if;
				end if;
			end if;
		end loop;

		do <= std_logic_vector(aux);
	end process;
end;
