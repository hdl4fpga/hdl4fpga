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
