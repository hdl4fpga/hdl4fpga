library ieee;
use ieee.std_logic_1164.all;

entity oddr is
	port (
		clk : in std_logic;
		dr  : in std_logic;
		df  : in std_logic;
		q   : out std_logic);
end;

library hdl4fpga;

library ecp3;
use ecp3.components.all;

architecture  of oddr is
begin
	oddr_i : oddr
	port map (
		sclk => clk,
		da => dr,
		db => df,
		q  => q);
end;
