library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_amp is
	port (
		input_clk     : in  std_logic;
		input_ena     : in  std_logic;
		input_sample  : in  std_logic_vector;
		gain_value    : in  std_logic_vector;
		output_ena    : out std_logic
		output_sample : out std_logic_vector);
end;

architecture beh of scopeio_amp is

	signal p : signed(0 to 2*input_sample'length-1);
	signal a : signed(input_sample'range);
	signal b : signed(gain_value'range);

begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			p <= a*s;
			a <= signed(gain_value);
			b <= signed(input_sample);
		end if;
	end process;
	output_sample <= p;

	lat_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => 2))
	port map (
		clk   => input_clk,
		di(0) => input_ena,
		do(0) => output_ena);
end;
