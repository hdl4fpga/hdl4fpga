library ieee;
use ieee.std_logic_1164.all;

entity digit14 is
	port (
		seg : out std_logic_vector(1 to 14);
		dp  : out std_logic);
end;

architecture default of digit14 is
begin
	seg <= b"111111_01000100";
	dp  <= '1';
end;

