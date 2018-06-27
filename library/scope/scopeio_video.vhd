library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_palette is
	port (
		channels_fg       : in  std_logic_vector;
		channels_bg       : in  std_logic_vector;
		channels_enable   : in  std_logic_vector;
		channels_selected : in  std_logic_vector;
		trigger_selected  : in  std_logic_vector;
		gauges_on         : in  std_logic_vector;
		video_clk         : in  std_logic;
		video_pixel       : out std_logic_vector);
end;

architecture beh of scopeio is
begin
	process(video_clk)
		variable pcolor_sel   : std_logic_vector(0 to inputs-1);
		variable vcolorfg_sel : std_logic_vector(0 to video_fg'length-1);
		variable vcolorbg_sel : std_logic_vector(0 to video_bg'length-1);
		variable gauge_sel    : std_logic_vector(0 to inputs+2-1);

		variable plot_on      : std_logic;
		variable video_fgon   : std_logic;
		variable video_bgon   : std_logic;
		variable gauges_fgon  : std_logic;

		variable vtaxis_fg    : std_logic_vector(video_rgb'range);
		variable vtaxisfg_e   : std_logic_vector(0 to 0);
		variable vtaxis_bg    : std_logic_vector(video_rgb'range);
		variable trigger_fg   : std_logic_vector(video_rgb'range);
		variable triggerfg_e  : std_logic_vector(0 to 0);
		variable trigger_bg   : std_logic_vector(video_rgb'range);

	begin
		if rising_edge(video_clk) then
			if plot_on='1' then
				pixel <= wirebus(channels_fg, pcolor_sel);
			elsif video_fgon='1' then
				pixel <= wirebus(hzaxis_fg & vtaxis_fg & grid_fg & trigger_fg);
			elsif video_bgon='1' then
				pixel <= wirebus(hzaxis_bg & vtaxis_bg & grid_bg, vcolorbg_sel);
			elsif gauges_fgon='1' then
				pixel <= wirebus(channels_fg & hzaxis_fg & trigger_fg, gauge_sel);
			else
				pixel <= (others => '0');
			end if;

			vtaxisfg_e   := word2byte(channel_ena, channel_select, 1);
			vtaxis_fg    := word2byte(channels_fg, channel_select, vtaxis_fg'length);
			vtaxis_fg    := vtaxis_fg and (vtaxis_fg'range => vtaxisfg_e(0));
			vtaxis_bg    := word2byte(channels_bg, channel_select, vtaxis_bg'length);
			triggerfg_e  := word2byte(channel_ena, trigger_select, 1);
			trigger_fg   := word2byte(channels_fg, trigger_select, trigger_fg'length);
			trigger_fg   := trigger_fg and (trigger_fg'range => triggerfg_e(0));
			trigger_bg   := word2byte(channels_bg, trigger_select, trigger_bg'length);

			vcolorfg_sel := video_fg;
			vcolorbg_sel := video_bg;
			gauge_sel    := gauge_on and (channel_ena & "11");
			pcolor_sel   := plot_fg and channel_ena;
			plot_on      := setif((plot_fg and channel_ena)  /= (plot_fg'range  => '0'));
			video_fgon   := setif(video_fg /= (video_fg'range => '0'));
			video_bgon   := setif(video_bg /= (video_bg'range => '0'));
			gauge_on  := setif((gauges_on and (channel_ena & "11"))/= (gauge_on'range => '0')) and cga_dot;

		end if;
	end process;

end;
