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

entity ffdArray is
 	generic (
 		ini : std_ulogic_vector);
 	port (
 		rst : in  std_ulogic;
 		clk : in  std_ulogic;
 		q     : out std_ulogic_vector;
 		d     : in  std_ulogic_vector;
 		ena   : in  std_ulogic);
end;

architecture beh of ffdArray is 
begin
 	process (clk, rst)
 	begin
 		if clk='1' and clk'event then
-- 			if rst='1' then
-- 				q <= ini;
-- 			els
				if ena='1' then
 				q <= d;
 			end if;
 		end if;
 	end process;
end;
