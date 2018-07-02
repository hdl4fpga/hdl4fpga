library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_hline is
	generic(
		delay        : natural := 4;
		inputs       : natural;
		num_of_seg   : natural;
		hz_scales    : scale_vector;
		vt_scales    : scale_vector;
		chan_x       : natural;
		chan_width   : natural;
		chan_height  : natural;
		scr_width    : natural;
		height       : natural);
	port (
		video_clk    : in  std_logic;
		video_nhl    : in  std_logic;
		abscisa      : out std_logic_vector;
		ordinates    : in  std_logic_vector;
		offset       : in  std_logic_vector;
		trigger      : in  std_logic_vector;
		hz_scale     : in  std_logic_vector(4-1 downto 0);
		vt_scale     : in  std_logic_vector(4-1 downto 0);
		win_frm      : in  std_logic_vector;
		win_on       : in  std_logic_vector;
		gpannel_on   : out std_logic_vector;
		gpannel_y    : out std_logic_vector;
		gpannel_x    : out std_logic_vector;
		tracers_on   : out std_logic_vector;
		widgets      : out std_logic_vector);
end;

architecture def of scopeio_hline is
begin
	_e : entity draw_hline is
	port map (
		mask : in  std_logic_vector;
		x    => win_x,
		y    => win_y,
		row  => trigger,
		dot  => dot);

	trigger_b : block
		signal dot : std_logic;
	begin
		dot <= win_x(1) and setif(resize(unsigned(win_y), trigger'length)=unsigned(trigger)) and grid_on;
		align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => total_delay))
		port map (
			clk   => video_clk,
			di(0) => dot,
			do(0) => trigger_dot);
	end block;

	traces   <= not tracer_dot & tracer_dot;
	widgets  <= axis_bg & axis_fg & grid_dot(1) & trigger_dot;
	video_bg <= axis_bg & grid_dot(0);
end;
