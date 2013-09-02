library ieee;
use ieee.std_logic_1164.all;

entity odbuf is
	port (
		i   : in std_logic;
		o_p : in std_logic;
		o_n : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of odbuf is
begin
	oddr_i : olvds
	port map (
		a  => i,
		z  => o_p,
		zn => o_n);
end;
