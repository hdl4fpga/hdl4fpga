--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity barrel is
		generic (
			N : natural;
			M : natural);
	port (
		sht  : in  std_ulogic_vector(M-1 downto 0);
		din  : in  std_ulogic_vector(N-1 downto 0);
		dout : out std_ulogic_vector(N-1 downto 0));
end;

architecture beh of barrel is
begin
	process (din, sht)

		function RotateLeft (val: std_ulogic_vector; disp : natural) 
			return std_ulogic_vector is
			variable aux : std_ulogic_vector (val'length-1 downto 0) := val;
		begin
			return aux(aux'left-disp downto 0) & aux(aux'left downto aux'left-disp+1);
		end;

		variable auxIn:  std_ulogic_vector(din'length-1 downto 0);
		variable auxSht: std_ulogic_vector(sht'length-1 downto 0);
		
	begin
		auxIn  := din;

		for i in sht'range loop
			if sht(i)= '1' then
				auxIn := RotateLeft(auxIn, 2**i);
			end if;
		end loop;

		dout<= auxIn;
	end process;
end;
