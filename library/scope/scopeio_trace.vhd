library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_trace is
	generic (
		inputs : natural);
	port (
		clk : in  std_logic;
		ena : in  std_logic;
		x   : in  std_logic_vector;
		y   : in  std_logic_vector;
		pxl : out std_logic_vector);
end;

architecture def of scopeio_trace is
	constant 
begin

	trace_g : for i in 0 to inputs-1 generate
	begin

		word2byte( , i, 
		row1 <= std_logic_vector(
			unsigned(to_unsigned(2**(y'length-1), row1'length)+resize(unsigned(y),row1'length)));
		draw_vline_e : entity hdl4fpga.draw_vline
		generic map (
			n => vmword'length)
		port map (
			video_clk  => clk,
			video_ena  => ena,
			video_row1 => row1,
			video_row2 => samples(i),
			video_dot  => tracer_dot(i));
	end generate;

end;
