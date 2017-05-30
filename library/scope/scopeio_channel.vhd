library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio_channel is
	generic(
		inputs     : natural;
		width      : natural;
		height     : natural);
	port (
		video_clk  : in  std_logic;
		video_nhl  : in  std_logic;
		abscisa    : out std_logic_vector;
		ordinates  : in  std_logic_vector;
		offset     : in  std_logic_vector;
		scale      : in  std_logic_vector(4-1 downto 0);
		win_frm    : in  std_logic_vector;
		win_on     : in  std_logic_vector;
		video_dot  : out std_logic_vector);
end;

architecture def of scopeio_channel is
	subtype vmword is std_logic_vector(unsigned_num_bits(height-1)  downto 0);
	type vmword_vector is array (natural range <>) of vmword;

	signal samples : vmword_vector(inputs-1 downto 0);

	signal win_x     : std_logic_vector(unsigned_num_bits(width-1)-1  downto 0);
	signal win_y     : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal plot_on   : std_logic;
	signal grid_on   : std_logic;
	signal plot_dot  : std_logic_vector(win_on'range);
	signal grid_dot  : std_logic;
	signal axisx_on  : std_logic;
	signal axisx_don : std_logic;
	signal axisy_on  : std_logic;
	signal axisy_don : std_logic;
	signal axis_don  : std_logic := '0';
	signal axis_dot  : std_logic;

begin

	win_b : block
		signal x     : std_logic_vector(unsigned_num_bits(width-1)-1  downto 0);
		signal phon  : std_logic;
		signal pfrm  : std_logic;
		signal vcntr : std_logic_vector(0 to unsigned_num_bits(height-1)-1);
		signal hcntr : std_logic_vector(0 to unsigned_num_bits(width-1)-1);
		signal cfrm  : std_logic_vector(0 to 3-1);
		signal cdon  : std_logic_vector(0 to 3-1);
		signal wena  : std_logic;
		signal wfrm  : std_logic;
	begin
		phon <= not setif(win_on=(win_on'range => '0'));
		pfrm <= not setif(win_frm=(win_frm'range => '0'));

		parent_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_nhl => video_nhl,
			win_frm   => pfrm,
			win_ena   => phon,
			win_x     => hcntr,
			win_y     => vcntr);

		mngr_e : entity hdl4fpga.win_mngr
		generic map (
			tab => (
				5*8+4,         0, width-(4*8+4+5*8+4), height-12,
				5*8+4, height-10, width-(5*8+4),       8,
				    0,         0,       (5*8),         height-13))
		port map (
			video_clk  => video_clk,
			video_x    => hcntr,
			video_y    => vcntr,
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
		abscisa <= x;

		dondly_e : entity hdl4fpga.align
		generic map (
			n => 4,
			d => (0 => 1+3, 1 => 0, 2 to 3 => 1+3),
			i => (0 to 3 => '-'))
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

		xdly_e : entity hdl4fpga.align
		generic map (
			n => x'length,
			d => (x'range => 1+3),
			i => (x'range => '-'))
		port map (
			clk => video_clk,
			di  => x,
			do  => win_x);

	end block;

	axisy_e : entity hdl4fpga.scopeio_axisy
	generic map (
		fonts      => psf1unitx8x8)
	port map (
		video_clk  => video_clk,
		win_x      => win_x,
		win_y      => win_y, 
		axis_on    => axisy_on,
		axis_scale => scale,
		axis_dot   => axisy_don);

	axisx_e : entity hdl4fpga.scopeio_axisx
	generic map (
		fonts      => psf1unitx8x8)
	port map (
		video_clk  => video_clk,
		win_on     => win_on,
		win_x      => win_x,
		win_y      => win_y,
		axis_on    => axisx_on,
		axis_scale => scale,
		axis_dot   => axisx_don);

	axis_don <= axisx_don or axisy_don;

	align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => -2+unsigned_num_bits(height-1)))
	port map (
		clk   => video_clk,
		di(0) => axis_don,
		do(0) => axis_dot);

	process (ordinates)
		subtype sample_word is unsigned(ordinates'length/inputs-1 downto 0);
		variable aux : unsigned(ordinates'length-1 downto 0);
	begin
		aux := unsigned(ordinates);
		for i in 0 to inputs-1 loop
			samples(i) <= std_logic_vector(resize(aux(vmword'range),vmword'length));
			aux        := aux srl sample_word'length;
		end loop;
	end process;

	plot_g : for i in 0 to inputs-1 generate
		signal row1 : vmword;
	begin
		row1 <= std_logic_vector(unsigned(to_unsigned(2**(win_y'length-1), row1'length)+resize(unsigned(win_y),row1'length)));
		draw_vline : entity hdl4fpga.draw_vline
		generic map (
			n => unsigned_num_bits(height-1)+1)
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
			row => win_x,
			col => win_y,
			dot => dot);

		grid_align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => unsigned_num_bits(height-1)))
		port map (
			clk   => video_clk,
			di(0) => dot,
			do(0) => grid_dot);
	end block;

	video_dot  <= (grid_dot or axis_dot) & plot_dot;
end;
