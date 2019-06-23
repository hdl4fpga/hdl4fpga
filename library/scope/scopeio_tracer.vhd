library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_tracer is
	generic (
		latency : natural;
		inputs  : natural;
		vt_height    : natural);
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
			row1 <= std_logic_vector(resize(unsigned(y),sample_size)+to_unsigned(2**(sample_size-1)-vt_height/2, row1'length));
		end if;
	end process;

	trace_g : for i in 0 to inputs-1 generate

		signal dot    : std_logic;
		signal row2   : std_logic_vector(row1'range);

	begin

		bias_p : process (clk)
			variable sample  : unsigned(0 to sample_size-1);
			variable shtrgtr : unsigned(0 to samples'length-1);
		begin
			if rising_edge(clk) then
				ena1    <= ena;
				shtrgtr := unsigned(samples);
				shtrgtr := shtrgtr rol (i*sample'length);
				sample  := shtrgtr(sample'range) + 2**(sample'length-1);
				row2    <= std_logic_vector(resize(sample, row2'length));
			end if;
		end process;

		draw_vline_e : entity hdl4fpga.draw_vline
		port map (
			clk  => clk,
			ena  => ena1,
			row1 => row1,
			row2 => row2,
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
