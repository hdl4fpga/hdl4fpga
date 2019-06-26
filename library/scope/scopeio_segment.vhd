library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_segment is
	generic(
		input_latency : natural;
		latency       : natural;
		inputs        : natural;
		vt_height     : natural;
		font_size     : natural;
		division_size : natural);
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

		gain_dv       : in  std_logic;
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

	constant division_bits   : natural := unsigned_num_bits(division_size-1);
	constant vttick_bits     : natural := unsigned_num_bits(8*font_size-1);
	constant vtheight_bits   : natural := unsigned_num_bits((vt_height-1)-1);
	constant vt_bias         : natural := (division_size/2)*((vt_height/division_size) mod 2);

	signal vt_offset    : std_logic_vector(vt_offsets'length/inputs-1 downto 0);
	signal vt_scale     : std_logic_vector(gain_ids'length/inputs-1 downto 0);

	signal axis_dv      : std_logic := '0';
	signal axis_sel     : std_logic;
	signal axis_scale   : std_logic_vector(4-1 downto 0);
	signal axis_base    : std_logic_vector(max(hz_base'length, vtheight_bits-(vttick_bits+axisy_backscale))-1 downto 0);
	signal axis_voffset : std_logic_vector(0 to vt_offsets'length-1);

	signal y_offset     : std_logic_vector(y'range);

begin

	vt_offset <= word2byte(vt_offsets, vt_chanid, vt_offset'length);
	vt_scale  <= word2byte(gain_ids,   vt_chanid, vt_scale'length);

	y_offset <= std_logic_vector(unsigned(y) - vt_bias);
	grid_b : block
		constant offset_latency : natural := 1;

		signal x_grid : std_logic_vector(x'range);
		signal grid_ena : std_logic;
	begin

		offset_p : process (video_clk)
		begin
			if rising_edge(video_clk) then
				x_grid <= std_logic_vector(unsigned(x) + unsigned(hz_offset(division_bits-1 downto 0)));
				grid_ena <= grid_on;
			end if;
		end process;

		grid_e : entity hdl4fpga.scopeio_grid
		generic map (
			latency => latency-offset_latency,
			division_size => division_size)
		port map (
			clk  => video_clk,
			ena  => grid_ena,
			x    => x_grid,
			y    => y_offset,
			dot  => grid_dot);
	end block;

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if vt_dv='1' or gain_dv='1' then
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
	axis_scale <= word2byte(hz_scale & std_logic_vector(resize(unsigned(vt_scale), axis_scale'length)), axis_sel);

	process (axis_sel, hz_base, vt_offset)
		variable vt_base : std_logic_vector(vt_offset'range);
	begin
		vt_base   := std_logic_vector(shift_right(signed(vt_offset), vttick_bits+axisy_backscale));
		axis_base <= word2byte(hz_base & vt_base(axis_base'range), axis_sel);
	end process;

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		latency       => latency,
		axis_unit     => std_logic_vector(to_unsigned(1,5)),
		vt_height     => vt_height,
		font_size     => font_size,
		division_size => division_size)
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
		video_vcntr => y_offset,

		hz_offset   => hz_offset,
		video_hzon  => hz_on,
		video_hzdot => hz_dot,

		vt_offset   => vt_offset(vttick_bits+axisy_backscale-1 downto 0),
		video_vton  => vt_on,
		video_vtdot => vt_dot);

	trigger_b : block 
		signal row  : unsigned(trigger_level'range);
		signal ena  : std_logic;
		signal hdot : std_logic;
	begin
		row <= resize(unsigned(trigger_level)+(vt_height-1)/2-unsigned(vt_offset), row'length);
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

	trace_b : block
		constant offset_latency  : natural := 1;
		constant tracer_latency  : natural := 4;

		subtype sample is std_logic_vector(samples'length/inputs-1 downto 0);

		signal samples2  : std_logic_vector(samples'range);
		signal trace_ena : std_logic;
	begin

		align_e :entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => input_latency+offset_latency))
		port map (
			clk   => video_clk,
			di(0) => grid_on,
			do(0) => trace_ena);

		offset_p : process (video_clk)
			variable samples1 : unsigned(samples'length-1 downto 0);
			variable offsets  : unsigned(vt_offsets'length-1 downto 0);
		begin
			if rising_edge(video_clk) then
				samples1 := unsigned(samples);
				offsets  := unsigned(vt_offsets);
				for i in 0 to inputs-1 loop
					samples1(sample'range) := samples1(sample'range) - offsets(sample'range);
					samples1 := samples1 ror sample'length;
					offsets  := offsets  ror vt_offset'length;
				end loop;
				samples2 <= std_logic_vector(samples1);
			end if;
		end process;

		tracer_e : entity hdl4fpga.scopeio_tracer
		generic map (
			latency => latency-(input_latency+offset_latency),
			inputs  => inputs,
			vt_height => vt_height)
		port map (
			clk     => video_clk,
			ena     => trace_ena,
			y       => y,
			samples => samples2,
			dots    => traces_dots);
	end block;

end;
