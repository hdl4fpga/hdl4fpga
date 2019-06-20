library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_downsampler is
	generic (
		factors : natural_vector);
	port (
		factor        : in  std_logic_vector;
		input_clk     : in  std_logic;
		input_ena     : in  std_logic;
		input_data    : in  std_logic_vector;
		trigger_shot  : in std_logic;
		display_ena   : in  std_logic;
		output_ena    : out std_logic;
		output_data   : out std_logic_vector);
end;

architecture beh of scopeio_downsampler is
	signal scaler : signed(0 to signed_num_bits(max(factors)-2)-1);

	function adjust (
		constant arg : natural_vector)
		return integer_vector is
		variable retval : integer_vector(arg'range);
	begin
		for i in arg'range loop
			retval(i) := arg(i)-2;
		end loop;
		return retval;
	end;

	constant adjusted_factors : integer_vector := adjust(factors);
	signal scale_factor : signed(scaler'range);

begin

	scale_factor <= to_signed(adjusted_factors(to_integer(unsigned(factor))), scale_factor'length);
	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if display_ena='0' and trigger_shot='1' then
				output_ena <= '1';
				scaler     <= scale_factor;
			else
				if input_ena='1' then
					if scaler(scaler'left)='1' then
						scaler <= scale_factor;
					else
						scaler <= scaler - 1;
					end if;
					output_ena <= scaler(scaler'left);
				else
					output_ena <= '0';
				end if;
			end if;
		end if;
	end process;

	lat_e : entity hdl4fpga.align
	generic map (
		n => input_data'length,
		d => (1 to input_data'length => 1))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);
end;
