library ieee;
use ieee.std_logic_1164.all;

entity srff is
	port (
		clk : in  std_logic;
		ena : in  std_logic := '1';
		sr  : in  std_logic := '0';
		d   : in  std_logic;
		q   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture lttsm of srff is
begin
	ffd_i : fd1p3ix
	port map (
		ck => clk,
		sp => ena,
		cd => sr,
		d  => d,
		q  => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity arff is
	port (
		ar  : in  std_logic := '0';
		clk : in  std_logic;
		ena : in  std_logic := '1';
		d   : in  std_logic;
		q   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture lttsm of arff is
begin
	ffd_i : fd1p3dx
	port map (
		cd => ar,
		ck => clk,
		sp => ena,
		d  => d,
		q  => q);
end;
