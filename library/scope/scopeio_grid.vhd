library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_grid is
	generic (
		latency : natural);
	port (
		clk     : in  std_logic;
		ena     : in  std_logic;
		x       : in  std_logic_vector;
		y       : in  std_logic_vector;
		dot     : out std_logic);
end;

architecture def of scopeio_grid is
	signal gdot : std_logic;
begin

	grid_e : entity hdl4fpga.grid
	port map (
		clk => clk,
		ena => ena,
		row => y,
		col => x,
		dot => gdot);

	align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => latency-2))
	port map (
		clk   => clk,
		di(0) => gdot,
		do(0) => dot);

end;
