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

entity unsigned_adder is
 	port (
 		sum   : out std_ulogic_vector;
 		op1   : in  std_ulogic_vector;
 		op2   : in  std_ulogic_vector;
 		cout  : out std_ulogic;
 		cin   : in  std_ulogic);
end;

architecture beh of unsigned_adder is
	signal result : UNSIGNED(sum'length+1 downto 0);
begin
 	result <= 
 		UNSIGNED(std_logic_vector('0' & op1 & '1')) +
 		UNSIGNED(std_logic_vector('0' & op2 & cin));
 	sum  <= std_ulogic_vector(result(result'left-1 downto result'right+1));
 	cout <= std_ulogic(result(result'left));
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_subtracter is
 	port (
 		sub  : out std_ulogic_vector;
 		op1  : in  std_ulogic_vector;
 		op2  : in  std_ulogic_vector;
 		bout : out std_ulogic;
 		bin  : in  std_ulogic);
end;

architecture beh of unsigned_subtracter is
	signal result : UNSIGNED(sub'length+1 downto 0);
begin
 	result <= 
 		UNSIGNED(std_logic_vector('0' & op1 & '1')) -
		UNSIGNED(std_logic_vector('0' & op2 & bin));
 	sub  <= std_ulogic_vector(result(result'left-1 downto result'right+1));
 	bout <= std_ulogic(result(result'left));
end;
