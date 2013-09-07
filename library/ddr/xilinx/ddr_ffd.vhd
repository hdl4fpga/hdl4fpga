library ieee;
use ieee.std_logic_1164.all;

entity ddr_sffd is
	port (
		clk : in  std_logic;
		ena : in  std_logic := '1';
		sr  : in  std_logic := '0';
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of ddr_sffd is
begin
	ffd_i : fdrse
	port map (
		s => '0',
		r => sr,
		c => clk,
		ce => ena,
		d => d,
		q => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity ddr_affd is
	port (
		ar  : in  std_logic := '0';
		clk : in  std_logic;
		ena : in  std_logic := '1';
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of ddr_affd is
begin
	ffd_i : fdcpe
	port map (
		pre => '0',
		clr => ar,
		c => clk,
		ce => ena,
		d => d,
		q => q);
end;
