library ieee;
use ieee.std_logic_1164.all;

library ecp3;
use ecp3.components.all;

entity digit14 is
	port (
		seg : out std_logic_vector(1 to 14);
		dp  : out std_logic);
end;

architecture default of digit14 is
begin
--a: AND2
--PORT map ( 
--	A => '1',
	--B => '1',
	--Z => dp);
	seg <= b"111111_01000100";
	dp  <= '0';
end;

