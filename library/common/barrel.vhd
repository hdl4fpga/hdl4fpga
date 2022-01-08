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
		shf  : in  std_logic_vector;
		di    : in  std_logic_vector;
		do    : out std_logic_vector);
end;

architecture beh of barrel is
begin
	process (di, shf)

--		function rotate (val: std_logic_vector; shf : natural, dir : string) 
--			return std_logic_vector is
--			variable aux : std_logic_vector (val'length-1 downto 0) := val;
--		begin
--			if dir="LEFT" then
--				return aux(aux'left-shf downto 0) & aux(aux'left downto aux'left-shf+1);
--			else
--				return aux(shf-1 downto 0)        & aux(aux'left downto shf);
--			end if;
--		end;

		variable aux :  unsigned(di'length-1 downto 0);
		
	begin
		aux := unsigned(di);

		for i in shf'range loop
			if shf(i)= '1' then
				if left then
					aux := aux rol 2**i;
					aux := aux sll 2**i;
				else
					aux := aux ror 2**i;
					aux := aux srl 2**i;
				end if;
			end if;
		end loop;

		do <= std_logic_vector(aux);
	end process;
end;
