library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_tracer is
	generic (
		latency : natural;
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
		signal ena1   : std_logic;
		signal dot    : std_logic;

	begin

		process (clk)
			variable aux : unsigned(0 to samples'length-1);
		begin
			if rising_edge(clk) then
				aux    := unsigned(samples);
				aux    := aux rol (i*sample'length);
				ena1   <= ena;
				sample <= std_logic_vector(aux(sample'range) + 2**(sample'length-1));
			end if;
		end process;

		row1 <= std_logic_vector(resize(unsigned(y),sample'length)+to_unsigned(2**(y'length-2), sample'length));

		draw_vline_e : entity hdl4fpga.draw_vline
		port map (
			clk  => clk,
			ena  => ena1,
			row1 => row1,
			row2 => sample,
			dot  => dot);

		latency_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => latency-4))
		port map (
			clk   => clk,
			di(0) => dot,
			do(0) => dots(i));

	end generate;

end;
