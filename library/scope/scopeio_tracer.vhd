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
		vt_pos  : in  std_logic_vector;
		samples : in  std_logic_vector;
		pixels  : out std_logic_vector);
end;

architecture def of scopeio_tracer is
	constant bias : natural := 2**(y'length-1);

	signal dot : std_logic_vector(0 to pixels'length/inputs-1);

begin

	vertical_position_p : process (clk)
	begin
		if rising_edge(clk) then
			for i in 0 to inputs-1 loop
			end loop;
		end if;
	end process;

	trace_g : for i in 0 to inputs-1 generate

		signal sample : std_logic_vector(0 to samples'length/inputs-1);
		signal row1   : std_logic_vector(sample'range);

	begin

		process (clk)
		begin
			if rising_edge(clk) then
				sample <= std_logic_vector(
					unsigned(word2byte(samples, i, samples'length/inputs)) +
					unsigned(word2byte(vt_pos,  i, vt_pos'length/inputs)));
				row1 <= std_logic_vector(resize(unsigned(y),sample'length) + bias);
			end if;
		end process;

		draw_vline_e : entity hdl4fpga.draw_vline
		generic map (
			n => sample'length)
		port map (
			clk  => clk,
			ena  => ena,
			row1 => row1,
			row2 => sample,
			dot  => dot(i));
	end generate;

	process(dot)
		variable aux : unsigned(0 to pixels'length-1);
	begin
		aux := (others => '0');
		for i in 0 to inputs-1 loop
			aux(0) := dot(i);
			aux(1) := dot(i);
			aux := aux rol (pixels'length/inputs);
		end loop;
		pixels <= std_logic_vector(aux);
	end process;

end;
