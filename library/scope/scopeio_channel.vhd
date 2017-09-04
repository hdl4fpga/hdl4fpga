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
		input_bias   : real    := 0.0;
		num_of_seg   : natural;
		scaley_start : natural := 1;
		chan_x       : natural;
		chan_width   : natural;
		chan_height  : natural;
		scr_width    : natural;
		height       : natural);
	port (
		video_clk    : in  std_logic;
		video_nhl    : in  std_logic;
		text_clk     : in  std_logic;
		text_we      : in  std_logic := '1';
		text_data    : in  std_logic_vector;
		text_addr    : in  std_logic_vector;
		abscisa      : out std_logic_vector;
		ordinates    : in  std_logic_vector;
		offset       : in  std_logic_vector;
		scale_x      : in  std_logic_vector(4-1 downto 0);
		scale_y      : in  std_logic_vector(4-1 downto 0);
		win_frm      : in  std_logic_vector;
		win_on       : in  std_logic_vector;
		plot_fg      : out std_logic_vector;
		video_fg     : out std_logic_vector;
		video_bg     : out std_logic_vector);
end;

architecture def of scopeio_channel is
	subtype vmword is std_logic_vector(0 to unsigned_num_bits(chan_height-1)+1);
	type vmword_vector is array (natural range <>) of vmword;

	signal samples : vmword_vector(inputs-1 downto 0);

	signal pwin_y    : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal pwin_x    : std_logic_vector(unsigned_num_bits(scr_width-1)-1 downto 0);
	signal win_x     : std_logic_vector(unsigned_num_bits(scr_width-1)-1  downto 0);
	signal win_y     : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal plot_on   : std_logic;
	signal grid_on   : std_logic;
	signal plot_dot  : std_logic_vector(win_on'range) := (others => '0');
	signal grid_dot  : std_logic_vector(2-1 downto 0);
	signal meter_dot : std_logic;
	signal chan_dot  : std_logic_vector(0 to 4-1);
	signal axisx_on  : std_logic;
	signal axisx_don : std_logic := '0';
	signal axisy_on  : std_logic;
	signal axisy_don : std_logic;
	signal axis_don  : std_logic_vector(2-1 downto 0);
	signal axis_dot  : std_logic_vector(2-1 downto 0);
	signal axisy_off : std_logic_vector(win_y'range);
	signal meter_on  : std_logic;

begin

	win_b : block
		signal x     : std_logic_vector(unsigned_num_bits(scr_width-1)-1  downto 0);
		signal phon  : std_logic;
		signal pfrm  : std_logic;
		signal cfrm  : std_logic_vector(0 to 4-1);
		signal cdon  : std_logic_vector(0 to 4-1);
		signal wena  : std_logic;
		signal wfrm  : std_logic;
		signal txon : std_logic;
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
				chan_x-(4*8+4+5*8+4)+5*8+4,             0,     chan_width+1, chan_height+1,
				chan_x-(4*8+4+5*8+4)+5*8+4, chan_height+2, chan_width+4*8+4,             8,
				chan_x-(4*8+4+5*8+4)+    0,             0,              5*8, chan_height+1,
				                         0,             0,             24*8, chan_height+1))
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
		abscisa <= x;

		txon <= setif(win_on(0 to num_of_seg-1)/=(0 to num_of_seg-1 => '0')) and cdon(3);
		dondly_e : entity hdl4fpga.align
		generic map (
			n => 5,
			d => (0 => 1+3, 1 => 0, 2 to 3 => 1+3, 4 => 4+4),
			i => (0 to 4 => '-'))
		port map (
			clk   => video_clk,
			di(0) => cdon(0),
			di(1) => grid_on,
			di(2) => cdon(1),
			di(3) => cdon(2),
			di(4) => txon,
			do(0) => grid_on,
			do(1) => plot_on,
			do(2) => axisx_on,
			do(3) => axisy_on,
			do(4) => meter_on);

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

	axisy_off <= std_logic_vector(resize(unsigned(offset),win_y'length)+unsigned(win_y));
	axisy_e : entity hdl4fpga.scopeio_axisy
	generic map (
		fonts       => psf1digit8x8,
		scale_start => scaley_start,
		input_bias  => input_bias)
	port map (
		video_clk   => video_clk,
		win_x       => win_x,
		win_y       => axisy_off, 
		axis_on     => axisy_on,
		axis_scale  => scale_y,
		axis_dot    => axisy_don);

	axisx_e : entity hdl4fpga.scopeio_axisx
	generic map (
		fonts       => psf1digit8x8,
		num_of_seg  => num_of_seg,
		div_per_seg => chan_width/(32*5))
	port map (
		video_clk  => video_clk,
		win_on     => win_on,
		win_x      => win_x,
		win_y      => win_y,
		axis_on    => axisx_on,
		axis_scale => scale_x,
		axis_dot   => axisx_don);

	axis_don(1) <= axisx_don or axisy_don;
	axis_don(0) <= axisy_on or axisx_on;

	align_e : entity hdl4fpga.align
	generic map (
		n => 2,
		d => (0 to 1 => unsigned_num_bits(height-1)-3))
	port map (
		clk => video_clk,
		di  => axis_don,
		do  => axis_dot);

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

	meter_b : block
		constant font_width  : natural := 8;
		constant font_height : natural := 16;
		constant disp_width  : natural := 32;
		constant disp_height : natural := 16;

		signal vmem_addr : std_logic_vector(10-1 downto 0);
		signal vmem_data : std_logic_vector(8-1 downto 0);
		signal char_code : std_logic_vector(vmem_data'range);
		signal char_line : std_logic_vector(0 to font_width-1);
		signal char_dot  : std_logic_vector(0 to 0);
		signal sel_line  : std_logic_vector(0 to vmem_data'length+unsigned_num_bits(font_height-1)-1);
		signal sel_dot   : std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);
		signal meter_fld  : std_logic_vector(0 to 4-1);

	begin

		mem_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => text_clk,
			wr_ena  => text_we,
			wr_addr => text_addr,
			wr_data => text_data,
			rd_addr => vmem_addr,
			rd_data => vmem_data);

		cgarom : entity hdl4fpga.rom
		generic map (
			bitrom => psf1cp850x8x16)
		port map (
			clk  => video_clk,
			addr => sel_line,
			data => char_line);

		process (video_clk)
			variable row : std_logic_vector(0 to 2*disp_height-1);
		begin
			if rising_edge(video_clk) then
				sel_line <= char_code & win_y(unsigned_num_bits(font_height-1)-1 downto 0); 
				char_code <= vmem_data;
				vmem_addr <= encoder(reverse(win_on(0 to num_of_seg-1))) &
					win_y(unsigned_num_bits(disp_height*font_height-1)-1  downto unsigned_num_bits(font_height-1)) &
					win_x(unsigned_num_bits(disp_width*font_width-1)-1 downto unsigned_num_bits(font_width-1));
				row := reverse(demux(win_y(unsigned_num_bits(disp_height*font_height-1)  downto unsigned_num_bits(font_height-1))));
--				row := reverse(demux("00000"));
				meter_fld(0) <= meter_on and (setif(row(0 to 1)/=(0 to 1 => '0')));
				meter_fld(1) <= meter_on and (setif(row(2 to 3)/=(2 to 3 => '0')));
				meter_fld(2) <= meter_on and (setif(row(5 to 7)/=(5 to 7 => '0')));
				meter_fld(3) <= meter_on and (setif(row(9 to 9)/=(9 to 9 => '0')));
			end if;
		end process;

		char_dot <= word2byte(char_line, not sel_dot) and (char_dot'range => meter_on);

		align_x : entity hdl4fpga.align
		generic map (
			n => sel_dot'length,
			d => (sel_dot'range => 4))
		port map (
			clk => video_clk,
			di  => win_x(sel_dot'range),
			do  => sel_dot);

		align_e : entity hdl4fpga.align
		generic map (
			n => 5,
			d => (0 to 4 => unsigned_num_bits(height-1)+17))
		port map (
			clk   => video_clk,
			di(0) => char_dot(0),
			di(1) => meter_fld(0),
			di(2) => meter_fld(1),
			di(3) => meter_fld(2),
			di(4) => meter_fld(3),
			do(0) => meter_dot,
			do(1) => chan_dot(0),
			do(2) => chan_dot(1),
			do(3) => chan_dot(2),
			do(4) => chan_dot(3));
	end block;

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
			d => (0 to 1 => unsigned_num_bits(height-1)))
		port map (
			clk   => video_clk,
			di(0) => dot,
			di(1) => grid_on,
			do    => grid_dot);
	end block;

	plot_fg  <= plot_dot;
	video_fg <= axis_dot(1) & grid_dot(1) & chan_dot;
	video_bg <= axis_dot(0) & grid_dot(0) & (1 to 4 => meter_dot);
end;
