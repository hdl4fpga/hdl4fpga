library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_segment is
	generic(
		input_latency : natural;
		latency       : natural;
		layout        : string);
	port (
		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		hz_dv         : in  std_logic;
		hz_offset     : in  std_logic_vector;
		hz_segment    : in  std_logic_vector;

		gain_dv       : in  std_logic;
		gain_cid      : in  std_logic_vector;
		gain_ids      : in  std_logic_vector;

		trigger_chanid : in std_logic_vector;
		trigger_level  : in  std_logic_vector;

		video_clk     : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;

		grid_on       : in  std_logic;
		hz_on         : in  std_logic;
		vt_on         : in  std_logic;

		sample_dv     : in  std_logic;
		sample_data   : in  std_logic_vector;

		hz_dot        : out std_logic;
		vt_dot        : out std_logic;
		grid_dot      : out std_logic;
		trigger_dot   : out std_logic;
		trace_dots    : out std_logic_vector);

	constant inputs        : natural := hdo(layout)**".inputs";
	constant axis_fontsize : natural := hdo(layout)**".axis.fontsize";
	constant grid_height   : natural := hdo(layout)**".grid.height";
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant vtaxis_tickrotate : string := hdo(layout)**".axis.vertical.rotate";
	constant grid_unit       : natural := hdo(layout)**".grid.unit";

end;

architecture def of scopeio_segment is

	signal vt_ena          : std_logic;
	signal vt_dv           : std_logic;
	signal vt_offsets      : std_logic_vector(inputs*(5+8)-1 downto 0);
	signal vt_offset       : std_logic_vector(vt_offsets'length/inputs-1 downto 0);
	signal vt_chanid       : std_logic_vector(chanid_maxsize-1 downto 0);

	constant division_size : natural := grid_unit;
	constant font_size     : natural := axis_fontsize;
	constant vt_height     : natural := grid_height;

	constant division_bits : natural := unsigned_num_bits(division_size-1);
	constant vttick_bits   : natural := unsigned_num_bits(8*font_size-1);
	constant vtstep_bits   : natural := setif(vtaxis_tickrotate="ccw0", division_bits, vttick_bits);
	constant vtheight_bits : natural := unsigned_num_bits((vt_height-1)-1);

begin

	rgtrvtaxis_e : entity hdl4fpga.scopeio_rgtrvtoffset
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vt_ena,
		vt_dv     => vt_dv,
		vt_chanid => vt_chanid,
		vt_offset => vt_offset);

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			vt_offsets <= replace(vt_offsets, vt_chanid, vt_offset);
		end if;
	end process;

	grid_b : block
		constant offset_latency : natural := 1;

		signal y_grid   : std_logic_vector(y'range);
		signal x_grid   : std_logic_vector(x'range);
		signal grid_ena : std_logic;
	begin

		offset_p : process (video_clk)
			constant bias : natural := (vt_height/2) mod division_size;
		begin
			if rising_edge(video_clk) then
				y_grid   <= std_logic_vector(unsigned(y) + bias);
				x_grid   <= std_logic_vector(unsigned(x) + unsigned(hz_offset(division_bits-1 downto 0)));
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
			y    => y_grid,
			dot  => grid_dot);
	end block;

	axis_b : block
		constant bias : natural := (vt_height/2) mod 2**vtstep_bits;
		signal vt_scale : std_logic_vector(gain_ids'length/inputs-1 downto 0);
		signal g_offset : std_logic_vector(vt_offset'range);
		signal v_offset : std_logic_vector(vt_offset'range);
		signal v_sel    : std_logic;
		signal v_dv     : std_logic;
	begin
		v_sel      <= gain_dv or vt_dv;
		v_dv       <= gain_dv or vt_dv;
		vt_scale   <= multiplex(gain_ids, gain_cid, vt_scale'length);

		g_offset <= multiplex(vt_offsets, gain_cid, vt_offset'length);
		v_offset <= std_logic_vector(unsigned(std_logic_vector'(multiplex(vt_offset & g_offset, gain_dv))) - bias);

		axis_e : entity hdl4fpga.scopeio_axis
		generic map (
			latency       => latency,
			layout        => layout)
		port map (
			rgtr_clk      => rgtr_clk,
			rgtr_dv       => rgtr_dv,
			rgtr_id       => rgtr_id,
			rgtr_data     => rgtr_data,


			video_clk     => video_clk,

			hz_segment    => hz_segment,
			video_hcntr   => x,
			video_hzon    => hz_on,
			video_hzdot   => hz_dot,

			vt_dv         => v_dv,
			vt_scale      => vt_scale,
			vt_offset     => v_offset,
			video_vcntr   => y,
			video_vton    => vt_on,
			video_vtdot   => vt_dot);

	end block;

	trigger_b : block 
		signal offset : unsigned(vt_offsets'length/inputs-1 downto 0);
		signal row  : unsigned(trigger_level'range);
		signal ena  : std_logic;
		signal hdot : std_logic;
	begin
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				offset <= vt_height/2-unsigned(multiplex(vt_offsets, trigger_chanid, offset'length));
			end if;
		end process;

		row <= resize(unsigned(trigger_level)+offset, row'length);
		ena <= grid_on when resize(unsigned(y), row'length)=row else '0';

		hline_e : entity hdl4fpga.draw_line
		port map (
			ena   => ena,
			mask  => b"1",
			x     => x,
			dot   => hdot);

		align_e :entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 => latency))
		port map (
			clk   => video_clk,
			di(0) => hdot,
			do(0) => trigger_dot);

	end block;

	trace_b : block
		constant drawvline_latency : natural := 2;
		constant traceena_latency  : natural := 2;

		signal dots : std_logic_vector(0 to trace_dots'length-1);
		signal vline : std_logic_vector(y'range);
	begin

		delay_y_e :entity hdl4fpga.latency
		generic map (
			n => y'length,
			d => (0 to y'length-1 => input_latency))
		port map (
			clk => video_clk,
			di  => y,
			do  => vline);

		tracer_e : entity hdl4fpga.scopeio_tracer
		generic map (
			vt_height => vt_height)
		port map (
			clk      => video_clk,
			ena      => sample_dv,
			vline    => vline,
			offsets  => vt_offsets,
			ys       => sample_data,
			dots     => dots);

		align_e :entity hdl4fpga.latency
		generic map (
			n => trace_dots'length,
			d => (0 to trace_dots'length-1 => latency-(input_latency+drawvline_latency)))
		port map (
			clk => video_clk,
			di  => dots,
			do  => trace_dots);

	end block;

end;
