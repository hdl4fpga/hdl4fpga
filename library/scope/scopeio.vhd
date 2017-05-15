library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio is
	generic (
		inputs      : natural := 1);
	port (
		mii_rxc     : in  std_logic;
		mii_rxdv    : in  std_logic;
		mii_rxd     : in  std_logic_vector;
		input_clk   : in  std_logic;
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_red   : out std_logic;
		video_green : out std_logic;
		video_blue  : out std_logic;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);
end;

architecture beh of scopeio is

	signal hdr_data     : std_logic_vector(288-1 downto 0);
	signal pld_data     : std_logic_vector(2*8-1 downto 0);
	signal pll_data     : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data     : std_logic_vector(32-1 downto 0);

	constant cga_zoom  : natural := 0;
	signal cga_we      : std_logic;
	signal scope_cmd   : std_logic_vector(8-1 downto 0);
	signal scope_data  : std_logic_vector(8-1 downto 0);
	signal char_dot    : std_logic;

	signal video_hs    : std_logic;
	signal video_vs    : std_logic;
	signal video_frm   : std_logic;
	signal video_hon   : std_logic;
	signal video_nhl   : std_logic;
	signal video_vld   : std_logic;
	signal video_vcntr : std_logic_vector(11-1 downto 0);
	signal video_hcntr : std_logic_vector(11-1 downto 0);

	signal ca_dot      : std_logic;
	signal video_dot   : std_logic_vector(0 to 19-1);

	signal video_io    : std_logic_vector(0 to 3-1);
	signal abscisa     : std_logic_vector(video_hcntr'range);
	signal ordinates   : std_logic_vector(input_data'range);
	
	signal win_don     : std_logic_vector(0 to 18-1);
	signal win_frm     : std_logic_vector(0 to 18-1);
	signal pll_rdy     : std_logic;

	constant ch_size   : natural := 25*64;
	constant width     : natural := ch_size+1+(4*8+4)+(5*8+4);
	constant height    : natural := 269;

	signal input_addr  : std_logic_vector(0 to unsigned_num_bits(4*ch_size-1));
	signal full_addr   : std_logic_vector(input_addr'range);

	subtype sample_word  is std_logic_vector(ordinates'length/inputs-1 downto 0);
	type sword_vector is array (natural range <>) of sample_word;

	signal scale       : std_logic_vector(4-1 downto 0);
	signal amp         : std_logic_vector(4*inputs-1 downto 0);
	signal offset      : sword_vector(inputs-1 downto 0) := (others => (others => '0'));
	signal trigger_lvl : sword_vector(inputs-1 downto 0);

	signal vm_inputs   : sword_vector(inputs-1 downto 0);
	signal vm_addr     : std_logic_vector(input_addr'range);
	signal vm_data     : std_logic_vector(input_data'range);
begin

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		pll_data => pll_data,
		pll_rdy  => pll_rdy,
		ser_data => ser_data);

	process (ser_data)
		variable data : unsigned(pll_data'range);
	begin
		data     := unsigned(pll_data);
		data     := data sll hdr_data'length;
		pld_data <= reverse(std_logic_vector(data(pld_data'reverse_range)));
	end process;

	process (pld_data)
		variable data : unsigned(pld_data'range);
	begin
		data       := unsigned(pld_data);
		scope_cmd  <= std_logic_vector(data(scope_cmd'range));
		data       := data srl scope_cmd'length;
		scope_data <= std_logic_vector(data(scope_data'range));
	end process;

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if pll_rdy='1' then
				case scope_cmd(3 downto 0) is
				when "0000" =>
					amp            <= scope_data(3 downto 0);
				when "0001" =>
					offset(0)      <= std_logic_vector(resize(unsigned(scope_data), sample_word'length));
				when "0010" =>
					trigger_lvl(0) <= std_logic_vector(resize(unsigned(scope_data), sample_word'length));
				when others =>
				end case;
			end if;
		end if;
	end process;

	video_e : entity hdl4fpga.video_vga
	generic map (
		n => 11)
	port map (
		clk   => video_clk,
		hsync => video_hs,
		vsync => video_vs,
		hcntr => video_hcntr,
		vcntr => video_vcntr,
		don   => video_hon,
		frm   => video_frm,
		nhl   => video_nhl);

	video_vld <= video_hon and video_frm;

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => video_io'length,
		i => (video_io'range => '-'),
		d => (video_io'range => 14))
	port map (
		clk   => video_clk,
		di(0) => video_hs,
		di(1) => video_vs,
		di(2) => video_vld,
		do    => video_io);

	win_mngr_e : entity hdl4fpga.win_mngr
	generic map (
		tab => (
			319-(4*8+4+5*8+4), 0*270, width, height,
			319-(4*8+4+5*8+4), 1*270, width, height,
			319-(4*8+4+5*8+4), 2*270, width, height,
			319-(4*8+4+5*8+4), 3*270, width, height))
	port map (
		video_clk  => video_clk,
		video_x    => video_hcntr,
		video_y    => video_vcntr,
		video_don  => video_hon,
		video_frm  => video_frm,
		win_don    => win_don,
		win_frm    => win_frm);

	process (input_clk)
		type  mword_vector  is array (natural range <>) of signed(1*18-1 downto 0);
		type  mdword_vector is array (natural range <>) of signed(2*18-1 downto 0);

		variable m         : mdword_vector(0 to inputs-1);
		variable a         : mword_vector(0 to inputs-1);
		variable scales    : mword_vector(0 to 16-1)  := (others => (others => '-'));

		variable input_aux : unsigned(input_data'length-1 downto 0);
		variable amp_aux   : unsigned(amp'length-1 downto 0);
		variable chan_aux  : sword_vector(vm_inputs'range) := (others => (others => '-'));
		variable n         : natural;
		variable j         : natural;
	begin
		if rising_edge(input_clk) then
			for i in scale'range loop 
				j := i + 2;
				n := (j - j mod 3) / 3 - 3;
				case j mod 3 is
				when 0 =>           -- 1.0
					scales(i) := to_signed(natural(round(2.0**(scales(0)'length/2) * 5.0**(n+0)*2.0**(n+0))), scales(0)'length);
				when 1 =>           -- 2.0
					scales(i) := to_signed(natural(round(2.0**(scales(0)'length/2) * 5.0**(n+0)*2.0**(n+1))), scales(0)'length);
				when 2 =>           -- 5.0
					scales(i) := to_signed(natural(round(2.0**(scales(0)'length/2) * 5.0**(n+1)*2.0**(n+0))), scales(0)'length);
				when others =>
				end case;
			end loop;

			amp_aux := unsigned(amp);
			for i in 0 to inputs-1 loop
				vm_inputs(i) <= std_logic_vector(unsigned(chan_aux(i))); -- + unsigned(offset(i)));
				m(i)         := a(i)*scales(to_integer(amp_aux(4-1 downto 0)));
				m(i)         := shift_right(m(i), a(0)'length/2);
				--m(i)         := a(i) sll a(0)'length;
				chan_aux(i)  := std_logic_vector(a(i)(sample_word'range));
				a(i)         := b"00_0000_0000_1000_0000"; --resize(signed(input_aux(sample_word'range)), a(0)'length);
				a(i)(sample_word'range) := input_aux(sample_word'range);
				input_aux    := input_aux srl sample_word'length;
				amp_aux      := amp_aux   srl scale'length;
			end loop;
			input_aux := unsigned(input_data);
		end if;
	end process;

	trigger_b  : block
		signal input_level : sample_word;
		signal input_ena   : std_logic;
	begin
		process (input_clk)
			variable input_aux : unsigned(input_data'length-1 downto 0);
		begin
			if rising_edge(input_clk) then
				if input_ena='1' then
					if input_addr(0)='1' then
						if video_frm='0' then
							input_ena <= '0';
						end if;
					end if;
				elsif unsigned(input_aux(sample_word'range)) >= unsigned(trigger_lvl(0)) then
				end if;
				input_aux := unsigned(input_data);
					input_ena <= '1';
			end if;
		end process;

		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if input_ena='0' then
					input_addr <= (others => '0');
				elsif input_addr(0)='0' then
					input_addr <= std_logic_vector(unsigned(input_addr) + 1);
				end if;
			end if;
		end process;

	end block;

	videomem_b : block
		signal wr_addr : std_logic_vector(input_addr'range);
		signal wr_data : std_logic_vector(input_data'range);
		signal rd_addr : std_logic_vector(input_addr'range);
		signal rd_data : std_logic_vector(input_data'range);
	begin

		process (vm_inputs)
			variable aux : unsigned(input_data'length-1 downto 0);
		begin
			aux := (others => '-');
			for i in 0 to inputs-1 loop
				aux := aux sll sample_word'length;
				aux(sample_word'range) := unsigned(vm_inputs(i));
			end loop;
			vm_data <= std_logic_vector(aux);
		end process;


		wr_data <= vm_data;
		wr_addr <= input_addr;

		process (video_clk)
		begin
			if rising_edge(video_clk) then
				rd_addr   <= full_addr;
				ordinates <= rd_data;
			end if;
		end process;

		dpram_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => input_clk,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_addr => rd_addr,
			rd_data => rd_data);
	end block;

	process (video_clk)
		variable base : unsigned(input_addr'range);
	begin
		if rising_edge(video_clk) then
			base := (others => '-');
			for i in win_don'range loop
				if win_don(i)='1' then
					base := to_unsigned(i*ch_size, base'length);
				end if;
			end loop;
			full_addr <= std_logic_vector(resize(unsigned(abscisa),full_addr'length) + base);
		end if;
	end process;

	scopeio_channel_e : entity hdl4fpga.scopeio_channel
	generic map (
		inputs     => inputs,
		width      => width,
		height     => height)
	port map (
		video_clk  => video_clk,
		video_nhl  => video_nhl,
		ordinates  => ordinates,
		abscisa    => abscisa,
		scale      => scale,
		win_frm    => win_frm,
		win_on     => win_don,
		video_dot  => video_dot);

--	cga_e : entity hdl4fpga.cga
--	generic map (
--		bitrom     => psf1cp850x8x16,
--		cga_width  => 240,
--		cga_height => 68,
--		char_width => 8)
--	port map (
--		sys_clk    => mii_rxc,
--		sys_we     => pll_rdy,
--		sys_row    => video_vcntr(11-1 downto 11-cga_row'length),
--		sys_col    => video_hcntr(11-1 downto 11-cga_col'length),
--		sys_code   => cga_code,
--		vga_clk    => video_clk,
--		vga_row    => video_vcntr(11-1 downto cga_zoom),
--		vga_col    => video_hcntr(11-1 downto cga_zoom),
--		vga_dot    => char_dot);

	cga_align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => -4+13))
	port map (
		clk   => video_clk,
		di(0) => char_dot,
		do(0) => ca_dot);

	video_red   <= video_io(2) and (video_dot(1) or video_dot(0));
	video_green <= video_io(2) and (video_dot(1) or video_dot(0));
	video_blue  <= video_io(2) and (not video_dot(1) and video_dot(0));
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
