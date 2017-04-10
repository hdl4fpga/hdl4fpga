library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
entity scopeio_schannel
	generic(
		channels   : natural;
		inputs     : natural;
		width      : natural;
		height     : natural);
	port (
		video_clk  : in  std_logic;
		input_data : in  std_logic_vector;
		input_addr : out std_logic_vector;
		win_frm    : in  std_logic_vector;
		win_on     : in  std_logic_vector);
end;

architecture def of scopeio_shannel is
	subtype word_x is std_logic_vector(unsigned_num_bits(width-1)-1  downto 0);
	subtype word_y is std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	subtype word_s is std_logic_vector(input_data'length/inputs-1 downto 0);
	type wordx_vector is array of (range <>) of word_x;
	type wordy_vector is array of (range <>) of word_y;
	type words_vector is array of (range <>) of word_s;

	signal win_x   : wordx_vector(win_on'range);
	signal win_y   : wordy_vector(win_on'range);
	signal samples : words_vector(inputs-1 downto 0);

	signal x   : word_x;
	signal y   : word_y;
	signal won : std_logic;
	signal dot : std_logic_vector(win_on'range);

begin

	for i in win_on'range generate
		win_e : entity hdl4fpga.win
		port map (
			video_clk => vga_clk,
			video_nhl => vga_nhl,
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

	process (input_data)
		variable aux : unsigned(input_data'length-1 downto 0);
	begin
		aux := input_data;
		for in 0 to inputs-1 loop
			samples(i) := aux(word_s'range);
			aux        := aux srl word_s'length;
		end loop;
	end process;

	for i in 0 to inputs-1 generate
		draw_vline : entity hdl4fpga.draw_vline
		generic map (
			n => unsigned_num_bits(height-1))
		port map (
			video_clk  => vga_clk,
			video_row1 => y,
			video_row2 => samples(i),
			video_dot  => dot(i));
	generate;
	input_dot <= setif(dot=(dot'range => '0')) and don;

	grid_e : entity hdl4fpga.grid
	generic map (
		row_div  => "000",
		row_line => "00",
		col_div  => "000",
		col_line => "00")
	port map (
		clk => vga_clk,
		don => don,
		row => x,
		col => y,
		dot => grid_dot);

	grid_align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => -3+13))
	port map (
		clk   => vga_clk,
		di(0) => grid_dot,
		do(0) => ga_dot);

end;
