library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_palette is
	port (
		traces_fg   : in  std_logic_vector;
		traces_dots : in  std_logic_vector;
		grid_fg     : in  std_logic_vector;
		grid_bg     : in  std_logic_vector;
		grid_dot    : in  std_logic;
		hz_fg       : in  std_logic_vector;
		hz_dot      : in  std_logic;
		vt_fg       : in  std_logic_vector;
		vt_dot      : in  std_logic;
		video_rgb   : out std_logic_vector);
end;

architecture beh of scopeio_palette is
	signal traces_on  : std_logic;
begin
	video_rgb <= primux (traces_fg & grid_fg & hz_fg & vt_fg, traces_dots & grid_dot & hz_dot & vt_dot, (video_rgb'range => '0'));

	traces_on <= setif(traces_dots /= (traces_dots'range => '0'));
end;
