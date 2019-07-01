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
		scaler_sync   : in  std_logic;
		input_dv      : in  std_logic;
		input_data    : in  std_logic_vector;
		output_dv     : out std_logic;
		output_data   : out std_logic_vector);
end;

architecture beh of scopeio_downsampler is

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
	constant scaler_bits      : natural := signed_num_bits(max(factors)-2);

	signal scale_factor : signed(0 to scaler_bits-1);

begin

	scale_factor <= to_signed(adjusted_factors(to_integer(unsigned(factor))), scale_factor'length);
	process (input_clk)
		variable scaler : signed(scale_factor'range);
	begin
		if rising_edge(input_clk) then
			if scaler_sync='1' then
				scaler    := scale_factor;
				output_dv <= '1';
			elsif input_dv='1' then
				if scaler(0)='1' then
					scaler := scale_factor;
				else
					scaler := scaler - 1;
				end if;
				output_dv <= scaler(0);
			else
				output_dv <= '0';
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
