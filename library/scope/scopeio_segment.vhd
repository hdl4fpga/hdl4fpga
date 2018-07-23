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
		video_clk     : in  std_logic;
		grid_on       : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;
		trigger_level : in  std_logic_vector;
		samples       : in  std_logic_vector;
		grid_dot      : out std_logic;
		trigger_dot   : out std_logic;
		traces_dots   : out std_logic_vector);
end;

architecture def of scopeio_segment is
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
