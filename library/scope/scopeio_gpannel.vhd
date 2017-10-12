library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_gpannel is
	generic (
		inputs         : natural := 1;
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
		channel_scale  : in  std_logic;
		channel_level  : in  std_logic;
		text_addr      : inout std_logic_vector;
		video_rgb      : out std_logic_vector);
end;

architecture beh of scopeio_gpannel is

	signal glabel  : std_logic_vector(0 to ascii'length*(gauge_labels'length/(2+2*inputs))-1);
	signal amp     : std_logic_vector(4*inputs-1 downto 0);

	signal scale   : std_logic_vector(4-1 downto 0);
	signal value   : std_logic_vector(inputs*9-1 downto 0);
	signal unit    : std_logic_vector(0 to 4*8-1);

begin

	process (pannel_clk)
		constant rtxt_size : natural := unsigned_num_bits(2+inputs-1);
	begin
		if rising_edge(pannel_clk) then
			glabel <= to_ascii(word2byte(fill(
				gauge_labels,
				2**rtxt_size*scale'length, value => '1'),
				text_addr(rtxt_size+5-1 downto 5)));

			scale <= word2byte(fill(
				word2byte(time_scales,    time_scale)    &
				word2byte(trigger_scales, trigger_scale) &
				amp,
				2**rtxt_size*scale'length, value => '1'),
				text_addr(rtxt_size+5-1 downto 5));

			value <= word2byte(fill(
				word2byte(time_value,    time_scale)    &
				word2byte(trigger_value, trigger_scale) &
				channel_level,
				2**rtxt_size*scale'length, value => '1'),
				text_addr(rtxt_size+5-1 downto 5));

			unit <= word2byte(fill(
				word2byte(time_scales,    time_scale)    &
				word2byte(trigger_scales, trigger_scale) &
				unit,
				2**rtxt_size*scale'length, value => '1'),
				text_addr(rtxt_size+5-1 downto 5));
		end if;
	end process;

	display_e : entity hdl4fpga.meter_display
	generic map (
		frac => 6,
		int  => 2,
		dec  => 2)
	port map (
		value => value(9-1 downto 0),
		scale => scale,
		fmtds => reading);	

	process (pannel_clk)
		variable addr : unsigned(text_addr'range) := (others => '0');
		variable aux  : unsigned(0 to data'length-1);
	begin
		if rising_edge(pannel_clk) then
			text_addr <= std_logic_vector(addr);
			text_data <= word2byte(fill(
				glabel & bcd2ascii(display) & to_ascii(unit))
				not std_logic_vector(addr(5-1 downto 0)));
			addr := addr + 1;
			aux  := unsigned(data);
		end if;

	end process;

end;
