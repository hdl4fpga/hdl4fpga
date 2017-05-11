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
	signal pld_data     : std_logic_vector(3*8-1 downto 0);
	signal pll_data     : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data     : std_logic_vector(32-1 downto 0);

	constant cga_zoom  : natural := 0;
	signal cga_we      : std_logic;
	signal cga_row     : std_logic_vector(7-1-cga_zoom downto 0);
	signal cga_col     : std_logic_vector(8-1-cga_zoom downto 0);
	signal cga_code    : std_logic_vector(8-1 downto 0);
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

	subtype word  is std_logic_vector(ordinates'length/inputs-1 downto 0);
	type word_vector is array (natural range <>) of word;

	signal scale       : std_logic_vector(4-1 downto 0);
	signal amp         : std_logic_vector(4*inputs-1 downto 0);
	signal offset      : word_vector(inputs-1 downto 0);

	signal vm_inputs   : word_vector(inputs-1 downto 0);
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
		data     := unsigned(pld_data);
		cga_code <= reverse(std_logic_vector(data(cga_code'range)));
		data     := data srl cga_code'length;
		cga_row  <= std_logic_vector(data(cga_row'range));
		data     := data srl cga_row'length;
		cga_col  <= std_logic_vector(data(cga_col'range));
	end process;

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if pll_rdy='1' then
				scale <= cga_code(3 downto 0);
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
		subtype dword is unsigned(2*word'length-1 downto 0);

		variable input_aux : unsigned(input_data'length-1 downto 0);
		variable amp_aux   : unsigned(amp'length-1 downto 0);
		variable scales    : word_vector(0 to (8-(-7)))  := (others => (others => '-'));
		variable chan_aux  : word_vector(vm_inputs'range) := (others => (others => '-'));
		variable dword_aux : dword;
		variable aux       : real;
		variable n         : natural;
	begin
		if rising_edge(input_clk) then
			for i in -7 to 8 loop          -- 1, 10, 100
				n := (i - i mod 3) / 3;
				case i mod 3 is
				when 0 =>           -- 1.0
					aux := 5.0**(n+0)*2.0**(n+0);
				when 1 =>           -- 2.0
					aux := 5.0**(n+0)*2.0**(n+1);
				when 2 =>           -- 5.0
					aux := 5.0**(n+1)*2.0**(n+0);
				when others =>
				end case;
				scales(i-(-7)) := std_logic_vector(to_unsigned(natural(round(2.0**(word'length/2)*aux)),word'length));
			end loop;

			amp_aux := unsigned(amp);
			for i in 0 to inputs-1 loop
				vm_inputs(i) <= std_logic_vector(unsigned(chan_aux(i)) + unsigned(offset(i)));
				vm_inputs(i) <= std_logic_vector(input_aux(word'range));
				vm_inputs(i) <= std_logic_vector(unsigned(chan_aux(i)));
				dword_aux    := input_aux(word'range)*unsigned(scales(to_integer(amp_aux(4-1 downto 0))));
				dword_aux    := input_aux(word'range)*unsigned(scales(9));
				dword_aux    := dword_aux srl (word'length/2);
				chan_aux(i)  := std_logic_vector(dword_aux(word'range));
				input_aux    := input_aux srl word'length;
				amp_aux      := amp_aux   srl scale'length;
			end loop;
			input_aux := unsigned(input_data);
		end if;
	end process;

	trigger_b  : block
		signal input_level : word;
		signal input_ena   : std_logic;
	begin
		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if pll_rdy='1' then
					input_level <= std_logic_vector(resize(unsigned(cga_code),input_level'length));
				end if;
			end if;
		end process;

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
				elsif unsigned(input_aux(word'range)) <= unsigned'(b"0_0000_0001") then
					input_ena <= '1';
				end if;
				input_aux := unsigned(input_data);
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
				aux               := aux sll word'length;
				aux(word'range) := unsigned(vm_inputs(i));
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
