library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_tracer is
	generic (
		inputs  : natural);
	port (
		clk     : in  std_logic;
		ena     : in  std_logic;
		y       : in  std_logic_vector;
		samples : in  std_logic_vector;
		dots    : out std_logic_vector);
end;

architecture def of scopeio_tracer is
begin

	trace_g : for i in 0 to inputs-1 generate

		signal sample : std_logic_vector(0 to samples'length/inputs-1);
		signal row1   : std_logic_vector(sample'range);

	begin

		sample <= word2byte(samples, i, samples'length/inputs);
		row1   <= std_logic_vector(resize(unsigned(y),sample'length));

		draw_vline_e : entity hdl4fpga.draw_vline
		generic map (
			n => sample'length)
		port map (
			clk  => clk,
			ena  => ena,
			row1 => row1,
			row2 => sample,
			dot  => dots(i));
	end generate;

end;
