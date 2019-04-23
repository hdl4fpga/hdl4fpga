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

		axis_dv       : in  std_logic;
		axis_sel      : in  std_logic;
		axis_base     : in  std_logic_vector;
		axis_scale    : in  std_logic_vector;

		wu_frm      : out std_logic;
		wu_irdy     : out std_logic;
		wu_trdy     : in  std_logic;
		wu_value    : out std_logic_vector;
		wu_format   : in  std_logic_vector;

		video_clk     : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;

		hz_offset     : in  std_logic_vector;
		vt_offset     : in  std_logic_vector;
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
begin


	process (axis_scale)
	begin
		axis_unit <= (others => '-');
		case axis_scale(2-1 downto 0) is
		when "00" =>
			axis_unit <= b"0001";
		when "01" =>
			axis_unit <= b"0010";
		when "10" =>
			axis_unit <= b"0100";
		when "11" =>
			axis_unit <= b"0101";
		when others =>
		end case;
	end process;

	grid_b : block
		signal x_offset : std_logic_vector(x'range);
	begin
		x_offset <= std_logic_vector(unsigned(x) + unsigned(hz_offset(5-1 downto 0)));
		grid_e : entity hdl4fpga.scopeio_grid
		generic map (
			latency => latency)
		port map (
			clk  => video_clk,
			ena  => grid_on,
			x    => x_offset,
			y    => y,
			dot  => grid_dot);
	end block;

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		latency => latency)
	port map (
		clk         => in_clk,

		frm         => axis_dv,
		irdy        => '1',
		trdy        => open,

		wu_irdy     => wu_irdy,
		wu_trdy     => wu_trdy,
		wu_value    => wu_value,
		wu_format   => wu_format,

--		axis_point  => axis_scale(4-1 downto 2),
		unit   => axis_unit,
--		axis_base   => axis_base,
--		axis_sel    => axis_sel,

		video_clk   => video_clk,
		video_hcntr => x,
		video_vcntr => y,

		hz_offset   => hz_offset,
		video_hzon  => hz_on,
		video_hzdot => hz_dot,

		vt_offset   => vt_offset,
		video_vton  => vt_on,
		video_vtdot => vt_dot);

	trigger_b : block 
		signal row : unsigned(trigger_level'range);
		signal ena : std_logic;
		signal hdot : std_logic;
	begin
		row <= unsigned(trigger_level)+2**(y'length-2);
		ena <= grid_on when resize(unsigned(y), row'length)=row else '0';

		hline_e : entity hdl4fpga.draw_line
		port map (
			ena   => ena,
			mask  => b"1",
			x     => x,
			dot   => hdot);

		align_e :entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => latency))
		port map (
			clk   => video_clk,
			di(0) => hdot,
			do(0) => trigger_dot);

	end block;

	tracer_e : entity hdl4fpga.scopeio_tracer
	generic map (
		latency => latency,
		inputs  => inputs)
	port map (
		clk     => video_clk,
		ena     => grid_on,
		y       => y,
		samples => samples,
		dots    => traces_dots);

end;
