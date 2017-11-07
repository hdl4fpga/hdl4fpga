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
		inputs       : natural;
		num_of_seg   : natural;
		hz_scales    : scale_vector;
		vt_scales    : scale_vector;
		chan_x       : natural;
		chan_width   : natural;
		chan_height  : natural;
		scr_width    : natural;
		height       : natural);
	port (
		video_clk    : in  std_logic;
		video_nhl    : in  std_logic;
		abscisa      : out std_logic_vector;
		ordinates    : in  std_logic_vector;
		offset       : in  std_logic_vector;
		trigger      : in  std_logic_vector;
		hz_scale     : in  std_logic_vector(4-1 downto 0);
		vt_scale     : in  std_logic_vector(4-1 downto 0);
		win_frm      : in  std_logic_vector;
		win_on       : in  std_logic_vector;
		gpannel_on   : out std_logic_vector;
		gpannel_y    : out std_logic_vector;
		gpannel_x    : out std_logic_vector;
		plot_fg      : out std_logic_vector;
		video_fg     : out std_logic_vector;
		video_bg     : out std_logic_vector);
end;

architecture def of scopeio_channel is
	subtype vmword is std_logic_vector(0 to unsigned_num_bits(chan_height-1)+1);
	type vmword_vector is array (natural range <>) of vmword;
	constant delay : natural := (vmword'length+2)+1;

	signal samples : vmword_vector(inputs-1 downto 0);

	signal pwin_y    : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal pwin_x    : std_logic_vector(unsigned_num_bits(scr_width-1)-1 downto 0);
	signal win_x     : std_logic_vector(unsigned_num_bits(scr_width-1)-1  downto 0);
	signal win_y     : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal plot_on   : std_logic;
	signal grid_on   : std_logic;
	signal plot_dot  : std_logic_vector(0 to inputs-1) := (others => '0');
	signal grid_dot  : std_logic_vector(2-1 downto 0);
	signal meter_dot : std_logic;
	signal axisx_on  : std_logic;
	signal axisy_on  : std_logic;
	signal axis_on   : std_logic;
	signal axisx_don : std_logic := '0';
	signal axisy_don : std_logic;
	signal axisx_ena : std_logic := '0';
	signal axisy_ena : std_logic;
	signal axis_don  : std_logic;
	signal axis_fg   : std_logic_vector(0 to 2-1);
	signal axis_bg   : std_logic_vector(0 to 2-1);
	signal axisy_off : std_logic_vector(win_y'range);
	signal vt_offset : std_logic_vector(win_y'range);
	signal axis_sgmt : std_logic_vector(unsigned_num_bits(num_of_seg-1)-1 downto 0);
	signal axis_hztl : std_logic;

	signal trigger_dot : std_logic;

begin

	win_b : block
		signal x    : std_logic_vector(unsigned_num_bits(scr_width-1)-1  downto 0);
		signal phon : std_logic;
		signal pfrm : std_logic;
		signal cfrm : std_logic_vector(0 to 4-1);
		signal cdon : std_logic_vector(0 to 4-1);
		signal wena : std_logic;
		signal wfrm : std_logic;
		signal txon : std_logic_vector(0 to num_of_seg-1);
	begin
		phon <= not setif(win_on=(win_on'range => '0'));
		pfrm <= not setif(win_frm=(win_frm'range => '0'));

		parent_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_nhl => video_nhl,
			win_frm   => pfrm,
			win_ena   => phon,
			win_x     => pwin_x,
			win_y     => pwin_y);

		mngr_e : entity hdl4fpga.win_mngr
		generic map (
			tab => (
				chan_x-(4*8+4+5*8+4)+5*8+0,             0, chan_width+1,   chan_height+1,
				chan_x-(4*8+4+5*8+4)+5*8+0, chan_height+2, chan_width+4*8,             8,
				chan_x-(4*8+4+5*8+4)+  0-1,             0,            5*8, chan_height+1,
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
			video_nhl => video_nhl,
			win_frm   => wfrm,
			win_ena   => wena,
			win_x     => x,
			win_y     => win_y);
		abscisa <= std_logic_vector(resize(unsigned(x),abscisa'length));

		txon <= win_on(0 to num_of_seg-1) and (1 to num_of_seg => cdon(3));
		dondly_e : entity hdl4fpga.align
		generic map (
			n => 4,
			d => (0 => 0, 1 => 2, 2 to 3 => 0))
		port map (
			clk   => video_clk,
			di(0) => cdon(0),
			di(1) => grid_on,
			di(2) => cdon(1),
			di(3) => cdon(2),
			do(0) => grid_on,
			do(1) => plot_on,
			do(2) => axisx_on,
			do(3) => axisy_on);

		gpanneldly_e : entity hdl4fpga.align
		generic map (
			n => num_of_seg,
			d => (1 to num_of_seg => 0))
		port map (
			clk => video_clk,
			di  => txon,
			do  => gpannel_on);

		xdly_e : entity hdl4fpga.align
		generic map (
			n => x'length,
			d => (x'range => 0))
		port map (
			clk => video_clk,
			di  => x,
			do  => win_x);

		gpannel_x <= win_x;
		gpannel_y <= win_y;
	end block;

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			vt_offset <= std_logic_vector(resize(unsigned(offset),win_y'length)+(96+4)+unsigned(win_y));
		end if;
	end process;

	axisy_off <= vt_offset when axisx_on='0' else win_y;

	axis_on <= axisx_on or axisy_on;
	axis_sgmt <= encoder(win_on(0 to num_of_seg-1));

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		fonts          => psf1digit8x8,
		vt_scales      => vt_scales,
		vt_div_per_seg => 2*chan_height/32,
		hz_scales      => hz_scales,
		hz_num_of_seg  => num_of_seg,
		hz_div_per_seg => chan_width/(32*5))
	port map (
		video_clk    => video_clk,
		win_x        => win_x,
		win_y        => axisy_off,
		axis_hztl    => axisx_on,
		axis_sgmt    => axis_sgmt,
		axis_on      => axis_on,
		axis_hzscale => hz_scale,
		axis_vtscale => vt_scale,
		axis_dot     => axis_don);
	axisx_don <= axis_don and axisx_ena;
	axisy_don <= axis_don and axisy_ena;

	align_e : entity hdl4fpga.align
	generic map (
		n => 6,
		d => (
		      0 => 4,
		      1 => 4,
		      2 => delay-4,
		      3 => delay-4,
		      4 => delay-4,
		      5 => delay-4))
	port map (
		clk   => video_clk,
		di(0) => axisx_on,
		di(1) => axisy_on,

		di(2) => axisx_don,
		di(3) => axisy_don,


		di(4) => axisx_ena,
		di(5) => axisy_ena,

		do(0) => axisx_ena,
		do(1) => axisy_ena,

		do(2) => axis_fg(0),
		do(3) => axis_fg(1),

		do(4) => axis_bg(0),
		do(5) => axis_bg(1));

	process (video_clk)
		variable aux : signed(0 to ordinates'length-1);
	begin
		if rising_edge(video_clk) then
			aux := signed(ordinates);
			for i in 0 to inputs-1 loop
				samples(i) <= std_logic_vector(3*chan_height/2-resize(aux(0 to ordinates'length/inputs-1),vmword'length));
				aux        := aux sll (ordinates'length/inputs);
			end loop;
		end if;
	end process;

	plot_g : for i in 0 to inputs-1 generate
		signal row1 : vmword;
	begin
		row1 <= std_logic_vector(unsigned(to_unsigned(2**(win_y'length-1), row1'length)+resize(unsigned(win_y),row1'length)));
		draw_vline : entity hdl4fpga.draw_vline
		generic map (
			n => vmword'length)
		port map (
			video_clk  => video_clk,
			video_ena  => plot_on,
			video_row1 => row1,
			video_row2 => samples(i),
			video_dot  => plot_dot(i));
	end generate;

	grid_b : block
		signal dot : std_logic;
	begin
		grid_e : entity hdl4fpga.grid
		generic map (
			row_div  => "000",
			row_line => "00",
			col_div  => "000",
			col_line => "00")
		port map (
			clk => video_clk,
			don => grid_on,
			row => win_y,
			col => win_x,
			dot => dot);

		grid_align_e : entity hdl4fpga.align
		generic map (
			n => 2,
			d => (
				0 => delay-2,
				1 => delay))
		port map (
			clk   => video_clk,
			di(0) => dot,
			di(1) => grid_on,
			do    => grid_dot);
	end block;

	trigger_b : block
		signal dot : std_logic;
	begin
		dot <= win_x(1) and setif(resize(unsigned(win_y), trigger'length)=unsigned(trigger)) and grid_on;
		align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => delay))
		port map (
			clk   => video_clk,
			di(0) => dot,
			do(0) => trigger_dot);
	end block;

	plot_fg  <= plot_dot;
	video_fg <= axis_fg & grid_dot(1) & trigger_dot;
	video_bg <= axis_bg & grid_dot(0);
end;
