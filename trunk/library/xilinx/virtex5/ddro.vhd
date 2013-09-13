library ieee;
use ieee.std_logic_1164.all;

entity ddro is
	port (
		clk : in std_logic;
		dr  : in std_logic;
		df  : in std_logic;
		q   : out std_logic);
end;

library hdl4fpga;

library unisim;
use unisim.vcomponents.all;

architecture virtex5 of ddro is
begin
	oddr_i : oddr
	port map (
		c => clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => dr,
		d2 => df,
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

architecture virtex5 of ddrto is
begin
	ffd_i : fdrse
	port map (
		c  => clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d  => d,
		q  => q);
end;
