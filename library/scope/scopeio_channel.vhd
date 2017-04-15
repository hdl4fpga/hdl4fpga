library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_channel is
	generic(
		inputs     : natural;
		width      : natural;
		height     : natural);
	port (
		video_clk  : in  std_logic;
		video_nhl  : in  std_logic;
		input_data : in  std_logic_vector;
		input_addr : out std_logic_vector;
		win_frm    : in  std_logic_vector;
		win_on     : in  std_logic_vector;
		video_dot  : out std_logic_vector);
end;

architecture def of scopeio_channel is
	subtype word_s is std_logic_vector(input_data'length/inputs-1 downto 0);
	type words_vector is array (natural range <>) of word_s;

	signal samples : words_vector(inputs-1 downto 0);

	signal x        : std_logic_vector(unsigned_num_bits(width-1)-1  downto 0);
	signal y        : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal gon      : std_logic;
	signal won      : std_logic;
	signal frm      : std_logic;
	signal plot_dot : std_logic_vector(win_on'range);
	signal grid_dot : std_logic;

begin
	won <= not setif(win_on=(win_on'range => '0'));
	frm <= not setif(win_frm=(win_frm'range => '0'));

	win_b : block
		signal vcntr     : std_logic_vector(0 to unsigned_num_bits(height-1)-1);
		signal dummy_x   : std_logic_vector(0 to 0) := (others => '-');
		signal dummy_don : std_logic_vector(0 to 2-1);
		signal dummy_nhl : std_logic_vector(0 to 2-1);
		signal dummy_wx  : std_logic_vector(0 to 0) := (others => '-');
		signal win_frm   : std_logic_vector(0 to 2-1);
	begin
		main_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_nhl => video_nhl,
			win_frm   => frm,
			win_ena   => won,
			win_x     => x,
			win_y     => vcntr);

		video_win_e : entity hdl4fpga.win_mngr
		generic map (
			synchronous => FALSE,
			tab => (
				0, 0,         0, height-13,
				0, height-13, 0, 16))
		port map (
			video_clk  => video_clk,
			video_x    => dummy_x,
			video_y    => vcntr,
			video_don  => '-',
			video_frm  => frm,
			win_don    => dummy_don,
			win_nhl    => dummy_nhl,
			win_frm    => win_frm);

		channel_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_nhl => video_nhl,
			win_frm   => win_frm(0),
			win_ena   => won,
			win_x     => dummy_wx,
			win_y     => y);

	end block;

	process (input_data)
		variable aux : unsigned(input_data'length-1 downto 0);
	begin
		aux := unsigned(input_data);
		for i in 0 to inputs-1 loop
			samples(i) <= std_logic_vector(aux(word_s'range));
			aux        := aux srl word_s'length;
		end loop;
	end process;

	plot_g : for i in 0 to inputs-1 generate
		signal ena : std_logic;
	begin
		process (video_clk)
		begin
			if rising_edge(video_clk) then
			end if;
		end process;

		draw_vline : entity hdl4fpga.draw_vline
		generic map (
			n => unsigned_num_bits(height-1))
		port map (
			video_clk  => video_clk,
			video_ena  => won,
			video_row1 => y,
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
			don => won,
			row => x,
			col => y,
			dot => dot);

		grid_align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => -1+unsigned_num_bits(height-1)))
		port map (
			clk   => video_clk,
			di(0) => dot,
			do(0) => grid_dot);
	end block;

	video_dot  <= grid_dot & plot_dot;
	input_addr <= x;
end;
