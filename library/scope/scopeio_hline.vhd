library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;

entity scopeio_hline is
	generic (
		lat   : natural);
	port (
		clk   : in  std_logic;
		ena   : in  std_logic;
		x     : in  std_logic_vector;
		y     : in  std_logic_vector;
		row   : in  std_logic_vector;
		pixel : out std_logic_vector);
end;

architecture def of scopeio_hline is

	signal dot : std_logic;
	signal pxl : std_logic_vector(0 to pixel'length-1);

begin

	hline_e : entity hdl4fpga.draw_hline
	port map (
		mask => "0001",
		x    => x,
		y    => y,
		row  => row,
		dot  => dot);

	align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => lat))
	port map (
		clk   => clk,
		di(0) => dot,
		do(0) => pxl(0));

	pxl(1 to pxl'length-1) <= (others => pxl(0));

	pixel <= pxl;

end;
