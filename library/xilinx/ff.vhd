library ieee;
use ieee.std_logic_1164.all;

entity ff is
	port (
		clk : in  std_logic;
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of ff is
begin
	ffd_i : fdcpe
	port map (
		pre => '0',
		clr => '0',
		c => clk,
		ce => '1',
		d => d,
		q => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity sff is
	port (
		clk : in  std_logic;
		sr  : in  std_logic;
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of sff is
begin
	ffd_i : fdrse
	port map (
		c => clk,
		ce => '1',
		s => '0',
		r => sr,
		d => d,
		q => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity aff is
	port (
		ar  : in  std_logic;
		clk : in  std_logic;
		ena : in  std_logic;
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of aff is
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
