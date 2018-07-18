library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_palette is
	port (
		tracers_fg  : in  std_logic_vector;
		tracers_bg  : in  std_logic_vector;
		hzaxis_fg    : in  std_logic_vector;
		hzaxis_bg    : in  std_logic_vector;
		grid_fg      : in  std_logic_vector;
		grid_bg      : in  std_logic_vector;
		
		tracers_on   : in  std_logic_vector;
		objectsfg_on : in  std_logic_vector;
		objectsbg_on : in  std_logic_vector;
		gauges_on    : in  std_logic_vector;

		trigger_on   : in  std_logic_vector;

		video_clk    : in  std_logic;
		video_rgb    : out std_logic_vector);
end;

architecture beh of scopeio_palette is
	signal tracer_on  : std_logic;
	signal objectfg_on : std_logic;
	signal objectbg_on : std_logic;
	signal gauge_on    : std_logic;
	signal vtaxis_fg   : std_logic_vector(video_rgb'range);
	signal vtaxis_bg   : std_logic_vector(video_rgb'range);
	signal trigger_fg  : std_logic_vector(video_rgb'range);
begin

	video_rgb <= primux(
		primux(tracers_fg, tracers_on) &
		primux(hzaxis_fg & vtaxis_fg & grid_fg & trigger_fg, objectsfg_on) &
		primux(hzaxis_bg & vtaxis_bg & grid_bg, objectsbg_on) &
		primux(tracers_fg & hzaxis_fg & trigger_fg, gauges_on),
		tracers_on & objectfg_on & objectbg_on & gauge_on,
		(video_rgb'range => '0'));

	vtaxis_fg   <= primux(tracers_fg, tracers_on);
	vtaxis_bg   <= primux(tracers_bg, tracers_on);
	trigger_fg  <= primux(tracers_fg, trigger_on);
	tracer_on  <= setif(tracers_on  /= (tracers_on'range => '0'));
	objectfg_on <= setif(objectsfg_on /= (objectsfg_on'range => '0'));
	objectbg_on <= setif(objectsbg_on /= (objectsbg_on'range => '0'));
	gauge_on    <= setif(gauges_on    /= (gauges_on'range => '0'));

end;
