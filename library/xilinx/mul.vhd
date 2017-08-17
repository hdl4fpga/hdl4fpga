library ieee;
use ieee.std_logic_1164;
use ieee.numeric_std.all;

entity is
	port (
		clk : in std_logic;
		a   : in std_logic_vector;
		b   : in std_logic_vector;
		d   : out std_logic_vector);
end

architecture of is
begin
	mul_e : mult18x18
	port map (
		a => ,
		b => ,
		bcin => );
