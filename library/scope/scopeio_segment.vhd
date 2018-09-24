library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_segment is
	generic(
		latency       : natural;
		inputs        : natural);
	port (
		in_clk        : in  std_logic;

		hz_req        : in  std_logic;
		hz_rdy        : out std_logic;
		hz_on         : in  std_logic;
		hz_sel        : in  std_logic_vector;

		vt_req        : in  std_logic;
		vt_rdy        : out std_logic;
		vt_on         : in  std_logic;
		vt_sel        : in  std_logic_vector;

		video_clk     : in  std_logic;
		grid_on       : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;
		trigger_level : in  std_logic_vector;
		samples       : in  std_logic_vector;
		hz_dot        : out std_logic;
		vt_dot        : out std_logic;
		grid_dot      : out std_logic;
		trigger_dot   : out std_logic;
		traces_dots   : out std_logic_vector);
end;

architecture def of scopeio_segment is
	signal hz_from : std_logic_vector(6-1 downto 0) := b"00_0000";
	signal hz_step : std_logic_vector(6-1 downto 0) := b"00_1000";
	signal hz_pnt  : std_logic_vector(3-1 downto 0) := b"111";
	signal vt_from : std_logic_vector(6-1 downto 0) := b"00_0000";
	signal vt_step : std_logic_vector(6-1 downto 0) := b"00_1000";
	signal vt_pnt  : std_logic_vector(3-1 downto 0) := b"111";
begin


	grid_e : entity hdl4fpga.scopeio_grid
	generic map (
		latency => latency-2)
	port map (
		clk  => video_clk,
		ena  => grid_on,
		x    => x,
		y    => y,
		dot  => grid_dot);

--	trigger_e : entity hdl4fpga.scopeio_hline
--	generic map (
--		latency   => latency)
--	port map (
--		row => trigger_level,
--		clk => video_clk,
--		ena => grid_on,
--		x   => win_x,
--		y   => win_y,
--		dot => trigger_dot);

	axis_e : entity hdl4fpga.scopeio_axis
	port map (
		in_clk      => in_clk,

		hz_on       => hz_on,
		hz_req      => hz_req,
		hz_rdy      => hz_rdy,
		hz_step     => hz_step,
		hz_from     => hz_from,
		hz_pnt      => hz_pnt,
		hz_dot      => hz_dot,

		vt_on       => vt_on,
		vt_req      => vt_req,
		vt_rdy      => vt_rdy,
		vt_step     => vt_step,
		vt_from     => vt_from,
		vt_pnt      => vt_pnt,
		vt_dot      => vt_dot,

		video_clk   => video_clk,
		video_hcntr => x,
		video_vcntr => y);

	tracer_e : entity hdl4fpga.scopeio_tracer
	generic map (
		latency => latency-2,
		inputs  => inputs)
	port map (
		clk     => video_clk,
		ena     => grid_on,
		y       => y,
		samples => samples,
		dots    => traces_dots);

end;
