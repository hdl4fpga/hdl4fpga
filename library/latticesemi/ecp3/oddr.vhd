library ieee;
use ieee.std_logic_1164.all;

entity oddr is
	port (
		clk : in std_logic;
		da  : in std_logic;
		db  : in std_logic;
		q   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of oddr is
begin
	oddr_i : oddrxd1
	port map (
		sclk => clk,
		da => da,
		db => db,
		q  => q);
end;
