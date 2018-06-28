library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_palette is
	port (
		channels_fg       : in  std_logic_vector;
		channels_bg       : in  std_logic_vector;
		hzaxis_fg         : in  std_logic_vector;
		hzaxis_bg         : in  std_logic_vector;
		grid_fg           : in  std_logic_vector;
		grid_bg           : in  std_logic_vector;
		
		channels_on       : in  std_logic_vector;
		objectsfg_on      : in  std_logic_vector;
		objectsbg_on      : in  std_logic_vector;
		gauges_on         : in  std_logic_vector;

		trigger_selected  : in  std_logic_vector;

		video_clk         : in  std_logic;
		video_pixel       : out std_logic_vector);
end;

architecture beh of scopeio_palette is
	signal channel_on  : std_logic;
	signal objectfg_on : std_logic;
	signal objectbg_on : std_logic;
	signal gauge_on    : std_logic;
	signal vtaxis_fg   : std_logic_vector(video_pixel'range);
	signal vtaxis_bg   : std_logic_vector(video_pixel'range);
	signal trigger_fg  : std_logic_vector(video_pixel'range);
	signal trigger_bg  : std_logic_vector(video_pixel'range);
begin

	video_pixel <= primux(
		primux(channels_fg, channels_on) &
		primux(hzaxis_fg & vtaxis_fg & grid_fg & trigger_fg, objectsfg_on) &
		primux(hzaxis_bg & vtaxis_bg & grid_bg, objectsbg_on) &
		primux(channels_fg & hzaxis_fg & trigger_fg, gauges_on),
		channel_on & objectfg_on & objectbg_on & gauge_on,
		(video_pixel'range => '0'));

	vtaxis_fg   <= primux(channels_fg, trigger_selected);
	vtaxis_bg   <= primux(channels_bg, trigger_selected);
	trigger_fg  <= word2byte(channels_fg, trigger_selected);
	trigger_bg  <= word2byte(channels_bg, trigger_selected);
	channel_on  <= setif(channels_on  /= (channels_on'range => '0'));
	objectfg_on <= setif(objectsfg_on /= (objectsfg_on'range => '0'));
	objectbg_on <= setif(objectsbg_on /= (objectsbg_on'range => '0'));
	gauge_on    <= setif(gauges_on    /= (gauges_on'range => '0'));

end;
