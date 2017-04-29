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
		input_data : in  std_logic_vector;
		input_addr : out std_logic_vector;
		scale      : in  std_logic_vector(4-1 downto 0);
		win_frm    : in  std_logic_vector;
		win_on     : in  std_logic_vector;
		video_dot  : out std_logic_vector);
end;

architecture def of scopeio_channel is
	subtype word_s is std_logic_vector(input_data'length/inputs-1 downto 0);
	type words_vector is array (natural range <>) of word_s;

	signal samples : words_vector(inputs-1 downto 0);

	signal x         : std_logic_vector(unsigned_num_bits(width-1)-1  downto 0);
	signal y         : std_logic_vector(unsigned_num_bits(height-1)-1 downto 0);
	signal gon       : std_logic;
	signal plot_on   : std_logic;
	signal plot_dot  : std_logic_vector(win_on'range);
	signal grid_dot  : std_logic;
	signal text_x    : std_logic;
	signal text_y    : std_logic;
	signal char_line : std_logic_vector(0 to 8-1);
	signal char_addr : std_logic_vector(8-1 downto 0);
	signal char_dot  : std_logic;
	signal char_code : std_logic_vector(4-1 downto 0);

begin

	win_b : block
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
				4*8+4,         0, width-2*(4*8+4), height-12,
				4*8+4, height-10, width-1*(4*8+4),         8,
				    0,         0,       1*(4*8), height-13))
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
			win_y     => y);

		plot_on <= cdon(0);
		text_x  <= cdon(1);
		text_y  <= cdon(2);

	end block;

	axisy_b: block
		signal aux : std_logic_vector(0 to 0);
		signal dot : std_logic;
		signal ordinate : std_logic_vector(128-1 downto 0);

		signal char_code : std_logic_vector(4-1 downto 0);

		function marks (
			constant step   : real;
			constant num    : natural)
			return std_logic_vector is
			type real_vector is array (natural range <>) of real;
			variable retval : unsigned(4*4*2**unsigned_num_bits(num-1)*4*4-1 downto 0) := (others => '-');
			constant scales : real_vector(0 to 4-1) := (1.0, 2.0, 5.0,0.0);
			variable aux    : real;
		begin
			for i in 0 to 4-1 loop
				for j in 0 to 4-1 loop
					aux := -real(num/2)*scales(j)*step*real(10**i);
					for k in 0 to 2**unsigned_num_bits(num-1)-1 loop
						retval := retval sll 16;
						if j < 3 then
							if i < 3 then
								retval(16-1 downto 0) := unsigned(to_bcd(aux,16, true));
								aux := aux + scales(j)*step*real(10**i);
							end if;
						end if;
					end loop;
				end loop;
			end loop;
			return std_logic_vector(retval);
		end;

	begin
		process (video_clk)
		begin
			if rising_edge(video_clk) then
				ordinate  <= reverse(word2byte(reverse(marks(0.05001, 5)), "0000"));
				char_code <= reverse(word2byte(reverse(ordinate), y(6-1 downto 3) & x(5-1 downto 3)));
			end if;
		end process;
		char_line <= reverse(word2byte(reverse(psf1unitx8x8), char_code & y(3-1 downto 0)));
		aux <= word2byte(reverse(std_logic_vector(unsigned(char_line) ror 1)), x(3-1 downto 0));

		dot <= aux(0) and text_x and setif(y(6-1 downto 0)=(1 to 3 => '0'));

		align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => -1+unsigned_num_bits(height-1)))
		port map (
			clk   => video_clk,
			di(0) => dot,
			do(0) => char_dot);

	end block;

	axisx_b: block
		signal aux : std_logic_vector(0 to 0);
		signal dot : std_logic;
		signal dot_y : std_logic;
		signal dot_x : std_logic;
		signal abscissa : std_logic_vector(128-1 downto 0);

		signal char_code : std_logic_vector(4-1 downto 0);

		function marks (
			constant step   : real;
			constant num    : natural;
			constant sign   : boolean)
			return std_logic_vector is
			variable retval : unsigned(4*4*2**unsigned_num_bits(num-1)*4*4-1 downto 0) := (others => '-');
			type real_vector is array (natural range <>) of real;
			constant scales : real_vector(0 to 3-1) := (1.0, 2.0, 5.0);
			variable aux    : real;
		begin
			for i in 0 to 4-1 loop
				for j in 0 to 4-1 loop
					for k in 0 to 2**unsigned_num_bits(num-1)-1 loop
						retval := retval sll 16;
						if j < 3 then
							if i < 3 then
								if (k mod 8)=0 then
									aux := real((k/8)) * 5.0 * scales(j)*step*real(10**i);
								end if;
								retval(16-1 downto 0) := unsigned(to_bcd(aux,16, sign));
								aux := aux + scales(j)*step*real(10**i);
							end if;
						end if;
					end loop;
				end loop;
			end loop;
			return std_logic_vector(retval);
		end;

		signal seg  : std_logic_vector(4-1 downto 0);
		signal mark : std_logic_vector(3-1 downto 0);
		signal addr : std_logic_vector(5-1 downto 0);
	begin
		process (video_clk)
			variable edge : std_logic;
		begin
			if rising_edge(video_clk) then
				if text_x='0' then
					seg  <= (others => '0');
					mark <= (others => '0');
				elsif (x(5) xor edge)='1' then
					if (seg(3) and seg(0))='1' then
						seg  <= (others => '0');
						mark <= std_logic_vector(unsigned(mark) + 1);
					else
						seg  <= std_logic_vector(unsigned(seg)  + 1);
					end if;
				end if;
				edge := x(5);
			end if;
		end process;

		process (video_clk)
			variable sel  : std_logic_vector(1 downto 0);
		begin
			if rising_edge(video_clk) then
				sel(0)    := win_on(1) or win_on(3);
				sel(1)    := win_on(2) or win_on(3);
				abscissa  <= reverse(word2byte(reverse(marks(0.05001, 25, false)), scale & sel));
				char_code <= reverse(word2byte(reverse(abscissa), mark & addr(4 downto 3)));
				addr      <= x(addr'range);
			end if;
		end process;
		char_line <= reverse(word2byte(reverse(psf1unitx8x8), char_code & y(3-1 downto 0)));
		aux <= word2byte(reverse(std_logic_vector(unsigned(char_line) ror 1)), addr(2 downto 0));

		dot <= aux(0) and text_x and setif(seg=(1 to 4 =>'0'));

		align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => -1+unsigned_num_bits(height-1)))
		port map (
			clk   => video_clk,
			di(0) => dot,
			do(0) => open);
--			do(0) => char_dot);

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
			video_ena  => plot_on,
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
			don => plot_on,
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

	video_dot  <= (grid_dot or char_dot) & plot_dot;
	input_addr <= x;
end;