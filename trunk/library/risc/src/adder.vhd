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
