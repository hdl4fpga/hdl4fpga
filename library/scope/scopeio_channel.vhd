library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_channel is
	generic(
		channels   : natural;
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
	subtype word_x is std_logic_vector(unsigned_num_bits(width-1)-1  downto 0);
	subtype word_y is std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	subtype word_s is std_logic_vector(input_data'length/inputs-1 downto 0);
	type wordx_vector is array (natural range <>) of word_x;
	type wordy_vector is array (natural range <>) of word_y;
	type words_vector is array (natural range <>) of word_s;

	signal win_x   : wordx_vector(win_on'range);
	signal win_y   : wordy_vector(win_on'range);
	signal samples : words_vector(inputs-1 downto 0);

	signal x        : word_x;
	signal y        : word_y;
	signal gon      : std_logic;
	signal won      : std_logic;
	signal plot_dot : std_logic_vector(win_on'range);
	signal grid_dot : std_logic;

begin

	win_g : for i in win_on'range generate
		win_e : entity hdl4fpga.win
		port map (
			video_clk => video_clk,
			video_nhl => video_nhl,
			win_frm   => win_frm(i),
			win_ena   => win_on(i),
			win_x     => win_x(i),
			win_y     => win_y(i));
	end generate;

	process(win_on)
	begin
		x   <= (others => '-');
		y   <= (others => '-');
		won <='0';
		for i in win_on'range loop
			if win_on(i)='1' then
				x   <= win_x(i);
				y   <= win_y(i);
				won <= win_on(i);
			end if;
		end loop;
	end process;
	input_addr <= x;

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

	video_dot <= grid_dot & plot_dot;
end;
