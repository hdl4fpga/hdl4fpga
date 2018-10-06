library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafonts.all;

entity scopeio_axis is
	generic (
		latency     : natural);
	port (
		video_clk   : in  std_logic;
		video_hcntr : in  std_logic_vector;
		video_vcntr : in  std_logic_vector;
		hz_base   : in  std_logic_vector;
		vt_offset   : in  std_logic_vector;

		in_clk      : in  std_logic;

		axis_from     : in  std_logic_vector;
		axis_unit     : in  std_logic_vector;
		axis_point    : in  std_logic_vector;

		hz_req      : in  std_logic;
		hz_rdy      : out std_logic;
		hz_on       : in  std_logic;

		vt_req      : in  std_logic;
		vt_rdy      : out std_logic;
		vt_on       : in  std_logic;

		vt_dot      : out std_logic;
		hz_dot      : out std_logic);

end;

architecture def of scopeio_axis is

	constant hz_length : unsigned(0 to 3-1) := to_unsigned(7, 3);
	constant vt_length : unsigned(0 to 3-1) := to_unsigned(4, 3);

	signal tick    : std_logic_vector(7-1 downto 0);
	signal value   : std_logic_vector(8*4-1 downto 0);
	signal vt_dv   : std_logic;
	signal hz_dv   : std_logic;
	signal hz_tick : std_logic_vector(13-1 downto 6);
	signal hz_val  : std_logic_vector(value'range);
	signal vt_tick : std_logic_vector(4-1 downto 0);
	signal vt_val  : std_logic_vector(value'range);

begin

	scopeio_axisticks_e : entity work.scopeio_axisticks
	port map (
		clk        => in_clk,

		hz_length  => std_logic_vector(hz_length),
		axis_unit  => axis_unit,
		axis_offset  => axis_offset,
		axis_point => axis_point,
		hz_req     => hz_req,
		hz_rdy     => hz_rdy,
		hz_dv      => hz_dv,

		vt_length  => std_logic_vector(vt_length),
		vt_req     => vt_req,
		vt_rdy     => vt_rdy,
		vt_dv      => vt_dv,

		tick       => tick,
		value      => value);

	hz_mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => in_clk,
		wr_ena  => hz_dv,
		wr_addr => tick(7-1 downto 0),
		wr_data => value,

		rd_addr => hz_tick(13-1 downto 6),
		rd_data => hz_val);

	vt_mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => in_clk,
		wr_ena  => vt_dv,
		wr_addr => tick(4-1 downto 0),
		wr_data => value,

		rd_addr => vt_tick,
		rd_data => vt_val);

	video_b : block
		signal code      : std_logic_vector(4-1 downto 0);
		signal hz_bcd    : std_logic_vector(code'range);
		signal vt_bcd    : std_logic_vector(code'range);
		signal hz_don    : std_logic;
		signal vt_don    : std_logic;
		signal char_dot  : std_logic;
		signal hz_offset : signed(axis_offset'range);
		signal x         : 

		signal hon : std_logic;
		signal von : std_logic;
	begin

		process (in_clk)
		begin
			if rising_edge(in_clk) then
				if hz_req='1' then
					hz_offset <= signed(axis_offset);
				end if;	
				if vt_req='1' then
					vt_offset <= signed(axis_offset);
				end if;	
			end if;
		end process;

		x_p : process (video_clk)
			variable address : signed(hz_base'range);
		begin
			if rising_edge(video_clk) then
				x <= video_hcntr;
				if vt_on='0' then
					x <= postion + video_hcntr;
				end if;
				address := signed(hz_base) + hz_offset;
			end if;
		end process;

		y_p : process (video_clk)
			variable address : signed(hz_base'range);
		begin
			if rising_edge(video_clk) then
				v <= video_vcntr;
				if vt_on='0' then
					x <= postion + video_vcntr;
				end if;
				address := signed(vt_base) + vt_offset;
			end if;
		end process;

		align_e : entity hdl4fpga.align
		generic map (
			n => ons_q'length,
			d => (ons_q'range => 1))
		port map (
			clk   => video_clk,
			di(0) => hz_on,
			di(0) => vt_on,
			do(0) => hon,
			do(1) => von);

		hz_tick <= x(hz_tick'length+6-1 downto 6);
		vt_tick <= y(vt_tick'length+5-1 downto 5)));
		hz_bcd  <= word2byte(hz_val, x(6-1 downto 3), code'length);
		vt_bcd  <= word2byte(vt_val, x(6-1 downto 3), code'length);
		code    <= word2byte(hz_bcd & vt_bcd, vt_on);

		rom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => psf1digit8x8,
			font_height => 2**3,
			font_width  => 2**3)
		port map (
			clk       => video_clk,
			char_col  => x(3-1 downto 0),
			char_row  => video_vcntr(3-1 downto 0),
			char_code => code,
			char_dot  => char_dot);

		romlat_b : block
			signal ons : std_logic_vector(0 to 2-1);
		begin

			ons(0) <= hon;
			ons(1) <= von and y(4) and y(3);
			lat_e : entity hdl4fpga.align
			generic map (
				n => ons'length,
				d => (ons'range => 2))
			port map (
				clk   => video_clk,
				di    => ons,
				do(0) => hz_don,
				do(1) => vt_don);
		end block;

		lat_b : block
			signal dots : std_logic_vector(0 to 2-1);
		begin
			dots(0) <= char_dot and hz_don;
			dots(1) <= char_dot and vt_don;

			lat_e : entity hdl4fpga.align
			generic map (
				n => dots'length,
				d => (dots'range => latency-3))
			port map (
				clk   => video_clk,
				di    => dots,
				do(0) => hz_dot,
				do(1) => vt_dot);
		end block;
	end block;

end;
