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
	oddr : 	oddr
	generic map (
		init => '0')
	port map (
		c => clk,
		ce => '1',
		r  => '0',
		s  => '0',
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
	oddrt : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clk,
		ce => '1',
		d  => d,
		q  => q);
end;
