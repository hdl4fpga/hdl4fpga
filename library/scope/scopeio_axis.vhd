library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafonts.all;

entity scopeio_axis is
	port (
		in_clk     : in  std_logic;

		axis_sel    : in std_logic;

		hz_req      : in  std_logic;
		hz_rdy      : out std_logic;
		hz_pnt      : in  std_logic_vector;

		vt_req      : in  std_logic;
		vt_rdy      : out std_logic;
		vt_pnt      : in  std_logic_vector;

		video_clk   : in  std_logic;
		video_hcntr : in  std_logic_vector;
		video_vcntr : in  std_logic_vector;
		video_dot   : out std_logic);

end;

architecture def of scopeio_axis is

	constant hz_len : unsigned(0 to 3-1) := to_unsigned(6, 3);
	constant vt_len : unsigned(0 to 3-1) := to_unsigned(4, 3);

	signal tick    : std_logic_vector(6-1 downto 0);
	signal value   : std_logic_vector(8*4-1 downto 0);
	signal vt_dv   : std_logic;
	signal hz_dv   : std_logic;
	signal hz_step : std_logic_vector(0 to 5);
	signal hz_from : std_logic_vector(0 to 5);
	signal hz_tick : std_logic_vector(6-1 downto 0);
	signal hz_val  : std_logic_vector(value'range);
	signal vt_step : std_logic_vector(0 to 5);
	signal vt_from : std_logic_vector(0 to 5);
	signal vt_tick : std_logic_vector(4-1 downto 0);
	signal vt_val  : std_logic_vector(value'range);

begin

	scopeio_axisticks_e : entity work.scopeio_axisticks
	port map (
		clk     => in_clk,

		hz_len  => std_logic_vector(hz_len),
		hz_step => b"10_0000", --hz_step,
		hz_from => b"00_0000", --hz_from,
		hz_req  => hz_req,
		hz_rdy  => hz_rdy,
		hz_pnt  => hz_pnt,
		hz_dv   => hz_dv,

		vt_len  => std_logic_vector(vt_len),
		vt_step => b"11_0000", --vt_step,
		vt_from => b"00_0000", --vt_from,
		vt_req  => vt_req,
		vt_rdy  => vt_rdy,
		vt_pnt  => vt_pnt,
		vt_dv   => vt_dv,

		tick    => tick,
		value   => value);

	hz_mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => in_clk,
		wr_ena  => hz_dv,
		wr_addr => tick(6-1 downto 0),
		wr_data => value,

		rd_addr => hz_tick,
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
		signal code   : std_logic_vector(4-1 downto 0);
		signal hz_bcd : std_logic_vector(code'range);
		signal vt_bcd : std_logic_vector(code'range);
	begin

		hz_tick <='0' & video_hcntr(11-1 downto 6);
		vt_tick <= video_hcntr(10-1 downto 6);
		hz_bcd <= word2byte(hz_val, video_hcntr(6-1 downto 3), hz_bcd'length);
		vt_bcd <= word2byte(vt_val, video_hcntr(6-1 downto 3), vt_bcd'length);
		code   <= word2byte(hz_bcd & vt_bcd, axis_sel);

		rom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => psf1digit8x8,
			font_height => 2**3,
			font_width  => 2**3)
		port map (
			clk       => video_clk,
			char_col  => video_hcntr(3-1 downto 0),
			char_row  => video_vcntr(3-1 downto 0),
			char_code => code,
			char_dot  => video_dot);

	end block;

end;
