library ieee;
use ieee.std_logic_1164.all;

entity ddro is
	port (
		clk : in std_logic;
		dr  : in std_logic;
		df  : in std_logic;
		q   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddro is
	attribute oddrapps : string;
	attribute oddrapps of oddr_i : label is "SCLK_ALIGNED";
begin
	oddr_i : oddrxd1
	port map (
		sclk => clk,
		da => dr,
		db => df,
		q  => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity ddrto is
	port (
		clk : in std_logic;
		d   : in std_logic;
		q   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddrto is
begin
	oddrt_i : ofd1s3ax
	port map (
		sclk => clk,
		d => d,
		q => q);
end;
