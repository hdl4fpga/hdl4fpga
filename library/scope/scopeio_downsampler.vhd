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
		input_dv      : in  std_logic;
		input_data    : in  std_logic_vector;
		input_shot    : in  std_logic;
		output_dv     : out std_logic;
		output_shot   : out std_logic;
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

	signal factor   : std_logic_vector(0 to scaler_bits-1);
	signal data_vld : std_logic;

begin

	factorrom_e : entity hdl4fpga.rom
	generic map (
		bitrom => to_bitrom(adjust(factors), scaler_bits))
	port map (
		addr => factor_id,
		data => factor);

	scaler_p : process (input_clk)
		variable shot_dis : std_logic;
		variable scaler   : unsigned(factor'range); -- := (others => '0'); -- Debug purpose
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				if input_shot='1' and shot_dis='0' then
					scaler := (others => '1');
				elsif scaler(0)='1' then
					scaler := unsigned(factor);
				else
					scaler := scaler - 1;
				end if;
				shot_dis := input_shot;
				data_vld <= scaler(0);
			else
				data_vld <= '0';
			end if;
			output_shot <= shot_dis;
		end if;
	end process;
	output_dv <= data_vld;

	envelope_g : for i in 0 to inputsi-1 generate
		signal sample : signed(0 to input_data'length/inputs-1);
		signal maxx   : signed(sample'range);
		signal minn   : signed(sample'range);
	begin
		sample <= signed(word2byte(input_data, i, sample'length));
		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if data_vld='1' then
					maxx <= word2byte(max(maxx, sample), sample,     sel);
					minn <= word2byte(min(minn, sample), sample, not sel);
				else
					maxx <= max(maxx, sample);
					minn <= min(minn, sample);
				end if;
			end if;
		end process;
		output_data(i*sample'length to (i+1)*sample'length) <= word2byte(maxx, minn, sel);
	end loop;

end;
