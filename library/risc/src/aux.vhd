--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

package aux_parts is
 	component unsigned_adder
 		port (
 			sum  : out std_ulogic_vector;
 			op1  : in  std_ulogic_vector;
 			op2  : in  std_ulogic_vector;
 			cout : out std_ulogic;
 			cin  : in  std_ulogic := '0');
 	end component;

 	component unsigned_subtracter
 		port (
 			sub  : out std_ulogic_vector;
 			op1  : in  std_ulogic_vector;
 			op2  : in  std_ulogic_vector;
 			bout : out std_ulogic;
 			bin  : in  std_ulogic := '0');
 	end component;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aux_functions is
	function SetIf (cond: boolean)
		return std_ulogic;

 	function "and" (val1 : std_ulogic_vector; val2 : std_ulogic)
		return std_ulogic_vector;
 	function "and" (val1 : std_ulogic; val2 : std_ulogic_vector)
		return std_ulogic_vector;
 	function "xor" (val1 : std_ulogic_vector; val2 : std_ulogic)
		return std_ulogic_vector;
end;

package body aux_functions is
	function SetIf (cond: boolean)
		return std_ulogic is
	begin
		if cond then
			return '1';
		else
			return '0';
		end if;
	end;

 	function "+" (val1 : std_ulogic_vector; val2 : std_ulogic_vector)
 		return std_ulogic_vector is
 	begin
		return std_ulogic_vector(UNSIGNED(val1) + UNSIGNED(val2));
 	end;

 	function "and" (val1 : std_ulogic_vector; val2 : std_ulogic)
 		return std_ulogic_vector is
 		variable aux : std_ulogic_vector(val1'range);
 	begin
 		for i in val1'range loop
 			aux(i) := val1(i) and val2;
 		end loop;
 		return aux;
 	end;

 	function "and" (val1 : std_ulogic; val2 : std_ulogic_vector)
 		return std_ulogic_vector is
 	begin
 		return val2 and val1;
 	end;

 	function "xor" (val1 : std_ulogic_vector; val2 : std_ulogic)
 		return std_ulogic_vector is
 		variable aux : std_ulogic_vector (val1'range);
 	begin
 		for i in val1'range loop
 			aux(i) := val1(i) xor val2;
 		end loop;
 		return aux;
 	end;
end;
