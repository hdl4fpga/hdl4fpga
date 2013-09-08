library ieee;
use ieee.std_logic_1164.all;

entity ddro is
	port (
		clk : in std_logic;
		dr  : in std_logic;
		df  : in std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture spartan3 of ddro is
	signal fclk : std_logic;
begin
	fclk <= not clk;
	ddro : oddr2
	port map (
		c0 => clk,
		c1 => fclk,
		ce => '1',
		r  => '0',
		s  => '0',
		d0 => dr,
		d1 => df,
		q  => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity ddrto is
	port (
		clk : in std_logic;
		d : in std_logic;
		q : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture spartan3 of ddrto is
begin
	ddrto : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clk,
		ce => '1',
		d  => d,
		q  => q);
end;
