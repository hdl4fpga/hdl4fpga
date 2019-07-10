library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_downsampler is
	generic (
		factors : natural_vector);
	port (
		factor_id     : in  std_logic_vector;
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

	constant scaler_bits : natural := signed_num_bits(max(factors)-2);

	signal factor : std_logic_vector(0 to scaler_bits-1);

begin

	factorrom_e : entity hdl4fpga.rom
	generic map (
		bitrom => to_bitrom(adjust(factors), scaler_bits))
	port map (
		addr => factor_id,
		data => factor);

	process (input_clk)
		variable scaler : unsigned(factor'range);
	begin
		if rising_edge(input_clk) then
			if scaler_sync='1' then
				scaler    := (others => '1');
				output_dv <= '1';
			elsif input_dv='1' then
				if scaler(0)='1' then
					scaler := unsigned(factor);
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
		ena => input_dv,
		di  => input_data,
		do  => output_data);
end;
