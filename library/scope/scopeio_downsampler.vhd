library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_downsampler is
	generic (
		inputs  : natural;
		factors : natural_vector);
	port (
		factor_id    : in  std_logic_vector;
		input_clk    : in  std_logic;
		input_dv     : in  std_logic;
		input_data   : in  std_logic_vector;
		input_shot   : in  std_logic;
		downsampling : buffer std_logic;
		output_dv    : buffer std_logic;
		output_shot  : buffer std_logic;
		output_shota0 : out std_logic;
		output_data  : out std_logic_vector);
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

	signal factor    : std_logic_vector(0 to scaler_bits-1);
	signal data_min  : signed(0 to output_data'length/2-1);
	signal data_max  : signed(0 to output_data'length/2-1);
	signal start     : std_logic;
	signal a0        : std_logic;

begin

	factorrom_e : entity hdl4fpga.rom
	generic map (
		bitrom => to_bitrom(adjust(factors), scaler_bits))
	port map (
		addr => factor_id,
		data => factor);

	downsampleron_p: process (factor_id)
	begin
		downsampling <= '0';
		for i in 1 to 2**factor_id'length-1 loop
			if unsigned(factor_id)=i then
				downsampling <= setif(factors(0)/=factors(i));
			end if;
		end loop;
	end process;

	shot_p : process (input_clk)
		variable scaler : unsigned(factor'range); -- := (others => '0'); -- Debug purpose
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				if scaler(0)='1' then
					scaler := unsigned(factor);
				else
					scaler := scaler - 1;
				end if;

				if downsampling='0' then
					if a0='0' then 
						output_shot <= input_shot;
					elsif output_shot='0' then
						output_shot <= input_shot;
					end if;
				else
					if start='1' then
						output_shot <= input_shot;
					elsif output_shot='0' then
						output_shot <= input_shot;
					end if;
				end if;

				if input_shot='1' then
					output_shota0 <= a0;
				end if;
				if downsampling='0' then
					output_dv <= a0;
				else
					output_dv <= scaler(0);
				end if;
				a0 <= not to_stdulogic(to_bit(a0));
			else
				output_dv <= '0';
			end if;
			start <= scaler(0);
		end if;
	end process;

	compress_g : for i in 0 to inputs-1 generate
		signal sample : signed(0 to input_data'length/inputs-1);
		signal maxx   : signed(sample'range);
		signal minn   : signed(sample'range);
		signal max0   : signed(sample'range);
		signal min0   : signed(sample'range);
	begin
		sample <= signed(multiplex(input_data, i, sample'length));
		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if input_dv='1' then
					if downsampling='0' then
						if a0='0' then
							maxx <= sample;
						else
							minn <= sample;
						end if;
					else
						if start='1' then
							maxx <= hdl4fpga.base.max(min0, sample);
							minn <= hdl4fpga.base.min(max0, sample);
							max0 <= sample;
							min0 <= sample;
						else
							if maxx < sample then
								maxx <= sample;
								max0 <= sample;
							elsif max0 < sample then
								max0 <= sample;
							end if;

							if minn > sample then
								minn <= sample;
								min0 <= sample;
							elsif min0 > sample then
								min0 <= sample;
							end if;
						end if;
					end if;
				end if;
			end if;
		end process;
		data_max(i*sample'length to (i+1)*sample'length-1) <= maxx;
		data_min(i*sample'length to (i+1)*sample'length-1) <= minn;
	end generate;

	output_data <= std_logic_vector(data_max & data_min);

end;
