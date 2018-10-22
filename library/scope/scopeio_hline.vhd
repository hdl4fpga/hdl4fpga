library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;

entity scopeio_hline is
	generic (
		latency   : natural);
	port (
		clk : in  std_logic;
		ena : in  std_logic;
		x   : in  std_logic_vector;
		y   : in  std_logic_vector;
		row : in  std_logic_vector;
		dot : out std_logic);
end;

architecture def of scopeio_hline is

	signal hdot : std_logic;

begin

	hline_e : entity hdl4fpga.draw_hline
	port map (
		ena  => ena,
		mask => "0001",
		x    => x,
		y    => y,
		row  => row,
		dot  => hdot);

	align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => latency))
	port map (
		clk   => clk,
		di(0) => hdot,
		do(0) => dot);

end;
