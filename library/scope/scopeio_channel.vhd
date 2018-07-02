library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio_channel is
	generic(
		lat         : natural := 4;
		inputs      : natural;
		chan_x      : natural;
		chan_width  : natural;
		chan_height : natural;
		scr_width   : natural;
		height      : natural);
	port (
		video_clk   : in  std_logic;
		video_hzl   : in  std_logic;
		win_frm     : in  std_logic_vector;
		win_on      : in  std_logic_vector;
		vt_off      : in  std_logic_vector;
		vt_pos      : in  std_logic_vector;
		trg_lvl     : in  std_logic_vector;
		samples     : in  std_logic_vector;
		grid_pxl    : out std_logic_vector;
		trigger_pxl : out std_logic_vector;
		trace_pxls  : out std_logic_vector);
end;

architecture def of scopeio_channel is

	signal win_x      : std_logic_vector(unsigned_num_bits(scr_width-1)-1  downto 0);
	signal win_y      : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);

	signal tracer_on  : std_logic;
	signal grid_on    : std_logic;

begin

	win_b : block
		signal pwin_y : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
		signal pwin_x : std_logic_vector(unsigned_num_bits(scr_width-1)-1 downto 0);

		signal x      : std_logic_vector(unsigned_num_bits(scr_width-1)-1  downto 0);
		signal phon   : std_logic;
		signal pfrm   : std_logic;
		signal cfrm   : std_logic_vector(0 to 4-1);
		signal cdon   : std_logic_vector(0 to 4-1);
		signal wena   : std_logic;
		signal wfrm   : std_logic;
	begin
		phon <= not setif(win_on=(win_on'range => '0'));
		pfrm <= not setif(win_frm=(win_frm'range => '0'));

		parent_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_hzl => video_hzl,
			win_frm   => pfrm,
			win_ena   => phon,
			win_x     => pwin_x,
			win_y     => pwin_y);

		mngr_e : entity hdl4fpga.win_mngr
		generic map (
			tab => (
				chan_x-(8*8+4+5*8+4)+5*8+0,             0, chan_width+1,   chan_height+1,
				chan_x-(8*8+4+5*8+4)+5*8+0, chan_height+2, chan_width+8*8,             8,
				chan_x-(8*8+4+5*8+4)+  0-1,             0,            5*8, chan_height+1,
				                         0,             0,           24*8, chan_height+1))
		port map (
			video_clk  => video_clk,
			video_x    => pwin_x,
			video_y    => pwin_y,
			video_don  => phon,
			video_frm  => pfrm,
			win_don    => cdon,
			win_frm    => cfrm);

		wena <= not setif(cdon=(cdon'range => '0'));
		wfrm <= not setif(cfrm=(cfrm'range => '0'));

		win_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_hzl => video_hzl,
			win_frm   => wfrm,
			win_ena   => wena,
			win_x     => x,
			win_y     => win_y);

		dondly_e : entity hdl4fpga.align
		generic map (
			n => 2,
			d => (0 => 0, 1 => 2+lat, 2 to 3 => 0))
		port map (
			clk   => video_clk,
			di(0) => cdon(0),
			di(1) => grid_on,
			do(0) => grid_on,
			do(1) => tracer_on);

		xdly_e : entity hdl4fpga.align
		generic map (
			n => x'length,
			d => (x'range => 0))
		port map (
			clk => video_clk,
			di  => x,
			do  => win_x);

	end block;

	grid_e : entity hdl4fpga.scopeio_grid
	generic map (
		lat => lat)
	port map (
		clk   => video_clk,
		ena   => grid_on,
		x     => win_x,
		y     => win_y,
		pixel => grid_pxl);

	trigger_e : entity hdl4fpga.scopeio_hline
	generic map (
		lat   => lat)
	port map (
		row   => trg_lvl,
		clk   => video_clk,
		ena   => grid_on,
		x     => win_x,
		y     => win_y,
		pixel => trigger_pxl);

	tracer_e : entity hdl4fpga.scopeio_tracer
	generic map (
		inputs  => inputs)
	port map (
		clk     => video_clk,
		ena     => tracer_on,
		y       => win_y,
		vt_pos  => vt_pos,
		samples => samples,
		pixels  => trace_pxls);

end;
