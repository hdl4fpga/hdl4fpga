use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio_gauge is
	generic (
		inputs         : natural := 1;
		trigger_scales : std_logic_vector;
		time_scales    : std_logic_vector;
		hz_scales      : scale_vector;
		vt_scales      : scale_vector);
	port (
		txt_clk       : in  std_logic;
		time_scale    : in
		trigger_scale : in 
		channel_scale : in  std_logic;
		level_scale   : in  std_logic;
		video_rgb   : out std_logic_vector;
end;

architecture beh of scopeio is

	subtype input_sel is (unsigned_num_bits(inputs-1)-1 downto 0);

	signal scale_y : std_logic_vector(4-1 downto 0);
	signal scale_x : std_logic_vector(4-1 downto 0);
	signal amp     : std_logic_vector(4*inputs-1 downto 0);

	signal scale   : std_logic_vector(4-1 downto 0);
	signal value   : std_logic_vector(inputs*9-1 downto 0);
	signal unit    : std_logic_vector(0 to 4*8-1);
begin


	process (mii_rxc)
		constant rtxt_size : natural := unsigned_num_bits(2+inputs-1);
	begin
		if rising_edge(mii_rxc) then
			name <= word2byte(fill(
				names,
				2**rtxt_size*scale'length, value => '1'),
				text_addr(rtxt_size+5-1 downto 5));
			scale <= word2byte(fill(
				word2byte(time_scales,    scale_x)     &
				word2byte(trigger_scales, trigger_sel) &
				amp,
				2**rtxt_size*scale'length, value => '1'),
				text_addr(rtxt_size+5-1 downto 5));

			value <= word2byte(fill(
				word2byte(time_value,    scale_x);
					word2byte(trigger_value, trigger_sel) &
					offset,
					2**rtxt_size*scale'length, value => '1'),
					text_addr(rtxt_size+5-1 downto 5));

				unit <= word2byte(
					word2byte(time_scales,    scale_x)     &
					word2byte(trigger_scales, trigger_sel) &
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
			fmtds => meassure);	

		process (mii_rxc)
			variable addr : unsigned(text_addr'range) := (others => '0');
			variable aux  : unsigned(0 to data'length-1);
		begin
			if rising_edge(mii_rxc) then
				text_addr <= std_logic_vector(addr);
				text_data <= word2byte(fill(
					to_ascii(name) & bcd2ascii(display) & to_ascii(unit))
					not std_logic_vector(addr(5-1 downto 0)));
				addr := addr + 1;
				aux  := unsigned(data);
			end if;

		end process;

	end block;

	scopeio_channel_e : entity hdl4fpga.scopeio_channel
	generic map (
		inputs      => inputs,
		num_of_seg  => ly_dptr(layout_id).num_of_seg,
		chan_x      => ly_dptr(layout_id).chan_x,
		chan_width  => ly_dptr(layout_id).chan_width,
		chan_height => ly_dptr(layout_id).chan_height,
		scr_width   => ly_dptr(layout_id).scr_width,
		height      => ly_dptr(layout_id).chan_y,
		hz_scales   => hz_scales,
		vt_scales   => vt_scales)
	port map (
		video_clk  => video_clk,
		video_nhl  => video_nhl,
		ordinates  => ordinates,
		text_clk   => mii_rxc,
		text_addr  => text_addr,
		text_data  => text_data,
		offset     => std_logic_vector(scale_offset),
		trigger    => std_logic_vector(trigger),
		abscisa    => abscisa,
		scale_x    => scale_x,
		scale_y    => scale_y,
		win_frm    => win_frm,
		win_on     => win_don,
		plot_fg    => plot_fg,
		video_bg   => video_bg,
		video_fg   => video_fg);

	process(video_clk)
		variable pcolor_sel   : input_sel;
		variable vcolorfg_sel : std_logic_vector(0 to unsigned_num_bits(video_fg'length-1)-1);
		variable vcolorbg_sel : std_logic_vector(0 to unsigned_num_bits(video_bg'length-1)-1);

		variable plot_on    : std_logic;
		variable video_fgon : std_logic;
		variable video_bgon : std_logic;

		variable vtaxis_fg  : std_logic_vector(3-1 downto 0);
		variable vtaxis_bg  : std_logic_vector(3-1 downto 0);
		variable trigger_fg : std_logic_vector(3-1 downto 0);
		variable trigger_bg : std_logic_vector(3-1 downto 0);

	begin
		if rising_edge(video_clk) then
			vtaxis_fg  := word2byte(fill(channels_fg, 2**channel_sel'length*vtaxis_fg'length),  not channel_sel);
			trigger_fg := word2byte(fill(channels_fg, 2**trigger_sel'length*trigger_fg'length), not trigger_sel);
			trigger_bg := word2byte(fill(channels_bg, 2**trigger_sel'length*trigger_bg'length), not trigger_sel);

			if plot_on='1' then
				pixel <= word2byte(fill(channels_fg, 2**pcolor_sel'length*pixel'length), not pcolor_sel);
			elsif video_fgon='1' then
				pixel <= word2byte(fill(trigger_fg  & hzaxis_fg & vtaxis_fg  & grid_fg & hzaxis_fg & trigger_fg & vtaxis_fg, 2**vcolorfg_sel'length*pixel'length), not vcolorfg_sel);
			elsif video_bgon='1' then                                                                                                                       
				pixel <= word2byte(fill(channels_bg & hzaxis_bg & trigger_bg & grid_bg & hzaxis_bg & vtaxis_bg, 2**vcolorbg_sel'length*pixel'length), not vcolorbg_sel);
			else
				pixel <= (others => '0');
			end if;

			vcolorfg_sel := encoder(video_fg);
			vcolorbg_sel := encoder(video_bg);
			pcolor_sel   := encoder(plot_fg);
			plot_on      := setif(plot_fg  /= (plot_fg'range => '0'));
			video_fgon   := setif(video_fg /= (video_fg'range => '0'));
			video_bgon   := setif(video_bg /= (video_bg'range => '0'));
		end if;
	end process;

	video_rgb   <= (video_rgb'range => video_io(2)) and pixel;
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
