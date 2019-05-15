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

		wu_frm        : out std_logic;
		wu_irdy       : out std_logic;
		wu_trdy       : in  std_logic;
		wu_unit       : out std_logic_vector;
		wu_neg        : out std_logic;
		wu_sign       : out std_logic;
		wu_align      : out std_logic;
		wu_value      : out std_logic_vector;
		wu_format     : in  std_logic_vector;

		hz_dv         : in  std_logic;
		hz_scale      : in  std_logic_vector;
		hz_base       : in  std_logic_vector;
		hz_offset     : in  std_logic_vector;

		gain_ids      : in  std_logic_vector;
		vt_dv         : in  std_logic;
		vt_chanid     : in  std_logic_vector;
		vt_offsets    : in  std_logic_vector;

		trigger_level : in  std_logic_vector;

		video_clk     : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;

		grid_on       : in  std_logic;
		hz_on         : in  std_logic;
		vt_on         : in  std_logic;

		samples       : in  std_logic_vector;

		hz_dot        : out std_logic;
		vt_dot        : out std_logic;
		grid_dot      : out std_logic;
		trigger_dot   : out std_logic;
		traces_dots   : out std_logic_vector);
end;

architecture def of scopeio_segment is

	signal vt_offset    : std_logic_vector(vt_offsets'length/inputs-1 downto 0);
	signal vt_scale     : std_logic_vector(gain_ids'length/inputs-1 downto 0);

	signal axis_dv      : std_logic := '0';
	signal axis_sel     : std_logic;
	signal axis_scale   : std_logic_vector(4-1 downto 0);
	signal axis_base    : std_logic_vector(0 to 5-1);
	signal axis_voffset : std_logic_vector(0 to vt_offsets'length-1);

begin

	vt_offset <= word2byte(vt_offsets, vt_chanid, vt_offset'length);
	vt_scale  <= word2byte(gain_ids,   vt_chanid, vt_offset'length);

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

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if vt_dv='1' then
				axis_sel <= '1';
				axis_dv  <= '1';
			elsif hz_dv='1' then
				axis_sel <= '0';
				axis_dv  <= '1';
			else
				axis_dv  <= '0';
			end if;
		end if;
	end process;
	axis_scale <= word2byte(hz_scale & vt_scale, axis_sel);

	process (axis_sel, hz_base, vt_offset)
		alias vt_base : std_logic_vector(0 to vt_offset'length-1) is vt_offset;
	begin
		axis_base <= word2byte(hz_base & vt_base(axis_base'range), axis_sel);
	end process;

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		latency => latency,
		axis_unit => std_logic_vector(to_unsigned(25,5)))
	port map (
		clk         => in_clk,

		axis_dv     => axis_dv,
		axis_sel    => axis_sel,
		axis_base   => axis_base,
		axis_scale  => axis_scale,

		wu_frm      => wu_frm,
		wu_irdy     => wu_irdy,
		wu_trdy     => wu_trdy,
		wu_unit     => wu_unit,
		wu_neg      => wu_neg,
		wu_sign     => wu_sign,
		wu_value    => wu_value,
		wu_align    => wu_align,
		wu_format   => wu_format,

		video_clk   => video_clk,
		video_hcntr => x,
		video_vcntr => y,

		hz_offset   => hz_offset,
		video_hzon  => hz_on,
		video_hzdot => hz_dot,

		vt_offset   => vt_offset(8-1 downto 0),
		video_vton  => vt_on,
		video_vtdot => vt_dot);

	trigger_b : block 
		signal row  : unsigned(trigger_level'range);
		signal ena  : std_logic;
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
