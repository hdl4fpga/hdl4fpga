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
	constant bias_latency      : natural := 1;
	constant drawvline_latency : natural := 3;

	constant sample_size       : natural := samples'length/inputs;

	signal row1 : std_logic_vector(0 to sample_size);
	signal ena1 : std_logic;

begin

	bias_p : process (clk)
	begin
		if rising_edge(clk) then
			row1 <= std_logic_vector(resize(unsigned(y),sample_size)+to_unsigned(2**(y'length-2), row1'length));
		end if;
	end process;

	trace_g : for i in 0 to inputs-1 generate

		signal sample : std_logic_vector(0 to sample_size-1);
		signal dot    : std_logic;

	begin

		bias_p : process (clk)
			variable aux : unsigned(0 to samples'length-1);
		begin
			if rising_edge(clk) then
				aux    := unsigned(samples);
				aux    := aux rol (i*sample'length);
				ena1   <= ena;
				sample <= std_logic_vector(aux(sample'range) + 2**(sample'length-1));
			end if;
		end process;

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
			d => (0 => latency-(bias_latency+drawvline_latency)))
		port map (
			clk   => clk,
			di(0) => dot,
			do(0) => dots(i));

	end generate;

end;
