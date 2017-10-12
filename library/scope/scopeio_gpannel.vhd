library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_gpannel is
	generic (
		inputs         : natural;
		gauge_labels   : string;
		trigger_scales : std_logic_vector;
		time_scales    : std_logic_vector;
		hz_scales      : scale_vector;
		vt_scales      : scale_vector);
	port (
		pannel_clk     : in  std_logic;
		time_scale     : in  std_logic_vector;
		time_value     : in  std_logic_vector;
		trigger_scale  : in  std_logic_vector;
		trigger_value  : in  std_logic_vector;
		channel_scale  : in  std_logic_vector;
		channel_level  : in  std_logic_vector;
		text_addr      : in  std_logic_vector;
		text_data      : out std_logic_vector);
end;

architecture beh of scopeio_gpannel is
	constant row_length : natural := unsigned_num_bits(row_size-1);

	signal glabel  : std_logic_vector(0 to ascii'length*(gauge_labels'length/(2+2*inputs))-1);
	signal amp     : std_logic_vector(4*inputs-1 downto 0);

	signal scale   : std_logic_vector(4-1 downto 0);
	signal value   : std_logic_vector(inputs*9-1 downto 0);
	signal unit    : std_logic_vector(0 to 4*8-1);
	signal reading : std_logic_vector(10-1 downto 0);
begin

	process (pannel_clk)
		constant rtxt_size : natural := unsigned_num_bits(2+inputs-1);
	begin
		if rising_edge(pannel_clk) then
			glabel <= to_ascii(word2byte(fill(
				gauge_labels,
				2**rtxt_size*scale'length, value => '1'),
				addr(rtxt_size+row_length-1 downto row_length)));

			scale <= word2byte(fill(
				word2byte(time_scales,    time_scale)    &
				word2byte(trigger_scales, trigger_scale) &
				amp,
				2**rtxt_size*scale'length, value => '1'),
				addr(rtxt_size+row_length-1 downto row_length));

			value <= word2byte(fill(
				word2byte(time_value,    time_scale)    &
				word2byte(trigger_value, trigger_scale) &
				channel_level,
				2**rtxt_size*scale'length, value => '1'),
				addr(rtxt_size+row_length-1 downto row_length));

			unit <= word2byte(fill(
				word2byte(time_scales,    time_scale)    &
				word2byte(trigger_scales, trigger_scale) &
				unit,
				2**rtxt_size*scale'length, value => '1'),
				addr(rtxt_size+row_length-1 downto row_length));
		end if;
	end process;

	display_e : entity hdl4fpga.scopeio_gauge
	generic map (
		frac => 6,
		int  => 2,
		dec  => 2)
	port map (
		value => value(9-1 downto 0),
		scale => scale,
		fmtds => reading);	

	process (pannel_clk)
	begin
		if rising_edge(pannel_clk) then
			text_data <= word2byte(
				glabel & bcd2ascii(reading) & to_ascii(unit),
				not text_addr);
		end if;

	end process;

end;
