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

		vt_req        : in  std_logic;
		vt_rdy        : out std_logic;

		axis_sel      : in  std_logic_vector(2-1 downto 0);
		axis_from     : in  std_logic_vector;

		video_clk     : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;

		hz_offset     : in  std_logic_vector;
		vt_offset     : in  std_logic_vector := std_logic_vector'(b"0000");
		hz_on         : in  std_logic;
		vt_on         : in  std_logic;
		grid_on       : in  std_logic;

		trigger_level : in  std_logic_vector;
		samples       : in  std_logic_vector;

		hz_dot        : out std_logic;
		vt_dot        : out std_logic;
		grid_dot      : out std_logic;
		trigger_dot   : out std_logic;
		traces_dots   : out std_logic_vector);
end;

architecture def of scopeio_segment is
	signal axis_unit  : std_logic_vector(4-1 downto 0);
	signal axis_point : std_logic_vector(2-1 downto 0) := b"01";
	signal x_offset   : std_logic_vector(x'range);
begin


	process (axis_sel)
	begin
		axis_unit <= (others => '-');
		case axis_sel is
		when "00" =>
			axis_unit <= b"0001";
		when "01" =>
			axis_unit <= b"0010";
		when "10" =>
			axis_unit <= b"0101";
		when others =>
		end case;
	end process;

	x_offset <= std_logic_vector(unsigned(x) + unsigned(hz_offset(5-1 downto 0)));
	grid_e : entity hdl4fpga.scopeio_grid
	generic map (
		latency => latency-2)
	port map (
		clk  => video_clk,
		ena  => grid_on,
		x    => x_offset,
		y    => y,
		dot  => grid_dot);

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		latency => latency-2)
	port map (
		in_clk      => in_clk,

		axis_unit   => axis_unit,
		axis_from   => axis_from,
		axis_point  => axis_point,

		hz_on       => hz_on,
		hz_req      => hz_req,
		hz_rdy      => hz_rdy,
		hz_dot      => hz_dot,
		hz_offset   => hz_offset(13-1 downto 5),

		vt_on       => vt_on,
		vt_req      => vt_req,
		vt_rdy      => vt_rdy,
		vt_dot      => vt_dot,
		vt_offset   => vt_offset,

		video_clk   => video_clk,
		video_hcntr => x_offset,
		video_vcntr => y);

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
