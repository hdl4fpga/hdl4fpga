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
		D : string := "LEFT";
		N : natural;
		M : natural);
	port (
		rot  : in  std_logic_vector(M-1 downto 0);
		din  : in  std_logic_vector(N-1 downto 0);
		dout : out std_logic_vector(N-1 downto 0));
end;

architecture beh of barrel is
begin
	process (din, rot)

--		function rotate (val: std_logic_vector; disp : natural, dir : string) 
--			return std_logic_vector is
--			variable aux : std_logic_vector (val'length-1 downto 0) := val;
--		begin
--			if dir="LEFT" then
--				return aux(aux'left-disp downto 0) & aux(aux'left downto aux'left-disp+1);
--			else
--				return aux(disp-1 downto 0)        & aux(aux'left downto disp);
--			end if;
--		end;

		variable aux :  unsigned(din'length-1 downto 0);
		
	begin
		aux := unsigned(din);

		for i in rot'range loop
			if rot(i)= '1' then
				if d="LEFT" then
					aux := aux rol 2**i;
				else
					aux := aux ror 2**i;
				end if;
			end if;
		end loop;

		dout <= std_logic_vector(aux);
	end process;
end;
