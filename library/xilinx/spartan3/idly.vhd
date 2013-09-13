library ieee;
use ieee.std_logic_1164.all;

entity idly is
	port (
		i : in  std_logic;
		o : out std_logic);
end;

architecture spartan3 of idly is
begin
	o <= i;
end;
