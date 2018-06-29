library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_grid is
	generic (
		lat : natural);
	port (
		clk : in  std_logic;
		ena : in  std_logic;
		x   : in  std_logic_vector;
		y   : in  std_logic_vector;
		pxl : out std_logic_vector(0 to 2-1));
end;

architecture def of scopeio_grid is
	signal dot : std_logic;
begin

	grid_e : entity hdl4fpga.grid
	port map (
		clk => clk,
		don => ena,
		row => y,
		col => x,
		dot => dot);

	align_e : entity hdl4fpga.align
	generic map (
		n => 2,
		d => (0 => lat, 1 => lat-2))
	port map (
		clk   => clk,
		di(0) => ena,
		di(1) => dot,
		do    => pxl);

end;
