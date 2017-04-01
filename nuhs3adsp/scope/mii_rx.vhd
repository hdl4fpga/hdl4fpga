library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture beh of nuhs3adsp is

	signal hdr_data  : std_logic_vector(288-1 downto 0);
	signal pld_data  : std_logic_vector(288-1 downto 0);
	signal pll_data  : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data  : std_logic_vector(32-1 downto 0);

	constant cga_zoom : natural := 0;
	signal cga_we    : std_logic;
	signal cga_row   : std_logic_vector(7-1-cga_zoom downto 0);
	signal cga_col   : std_logic_vector(8-1-cga_zoom downto 0);
	signal cga_code  : std_logic_vector(8-1 downto 0);
	signal char_dot  : std_logic;

	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_frm   : std_logic;
	signal vga_don   : std_logic;
	signal vga_vld   : std_logic;
	signal vga_rgb   : std_logic_vector(3-1 downto 0);
	signal vga_vcntr : std_logic_vector(11-1 downto 0);
	signal vga_hcntr : std_logic_vector(11-1 downto 0);

	signal grid_dot   : std_logic;
	signal ga_dot     : std_logic;
	signal ca_dot     : std_logic;
	signal video_dot  : std_logic;

	signal vga_io    : std_logic_vector(0 to 3-1);
	
	constant sample_size : natural := 11;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			if (i+x0) /= 0 then
				y := sin(real((i+x0))/100.0)/(real((i+x0))/100.0);
			else
				y := 1.0;
			end if;
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(-real(2**(n-2)-1)*y)+2**(n-2),n));
		end loop;
		return aux;
	end;

	signal samples_doa : std_logic_vector(sample_size-1 downto 0);
	signal samples_dib : std_logic_vector(sample_size-1 downto 0);
	signal sample      : std_logic_vector(sample_size-1 downto 0);

	signal sys_clk : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_refclk);

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		pll_data => pll_data,
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
	--	cga_code <= std_logic_vector(data(cga_code'range));
		data     := data srl cga_code'length;
		cga_row  <= std_logic_vector(data(cga_row'range));
		data     := data srl cga_row'length;
		cga_col  <= std_logic_vector(data(cga_col'range));
	end process;
	cga_code <= std_logic_vector(resize(unsigned(vga_hcntr(11-1 downto 11-cga_col'length)), cga_code'length)+unsigned(vga_vcntr(11-1 downto 11-cga_row'length)));

	vga_e : entity hdl4fpga.video_vga
	generic map (
		n => 11)
	port map (
		clk   => vga_clk,
		hsync => vga_hsync,
		vsync => vga_vsync,
		hcntr => vga_hcntr,
		vcntr => vga_vcntr,
		don   => vga_don,
		frm   => vga_frm);

	vga_vld <= vga_don and vga_frm;

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => vga_io'length,
		i => (vga_io'range => '-'),
		d => (vga_io'range => 13))
	port map (
		clk   => vga_clk,
		di(0) => vga_hsync,
		di(1) => vga_vsync,
		di(2) => vga_vld,
		do    => vga_io);

	grid_e : entity hdl4fpga.grid
	generic map (
		row_div  => "000",
		row_line => "00",
		col_div  => "000",
		col_line => "00")
	port map (
		clk => vga_clk,
		row => vga_vcntr,
		col => vga_hcntr,
		dot => grid_dot);

	grid_align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => -2+13))
	port map (
		clk   => vga_clk,
		di(0) => grid_dot,
		do(0) => ga_dot);

	cga_e : entity hdl4fpga.cga
	generic map (
		bitrom     => psf1cp850x8x16,
		cga_width  => 240,
		cga_height => 68,
		char_width => 8)
	port map (
		sys_clk  => vga_clk, --phy1_125clk,
		sys_we   => vga_don, --cga_we,
		sys_row  => vga_vcntr(11-1 downto 11-cga_row'length),
		sys_col  => vga_hcntr(11-1 downto 11-cga_col'length),
		sys_code => cga_code,
		vga_clk  => vga_clk,
		vga_row  => vga_vcntr(11-1 downto cga_zoom),
		vga_col  => vga_hcntr(11-1 downto cga_zoom),
		vga_dot  => char_dot);

	cga_align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => -4+13))
	port map (
		clk   => vga_clk,
		di(0) => char_dot,
		do(0) => ca_dot);

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-960, 1087, sample_size))
	port map (
		clk  => vga_clk,
		addr => vga_hcntr,
		data => sample);
  	
	draw_vline : entity hdl4fpga.draw_vline
	generic map (
		n => 11)
	port map (
		video_clk  => vga_clk,
		video_row1 => vga_vcntr(vga_vcntr'range),
		video_row2 => sample,
		video_dot  => video_dot);


	vga_rgb <= (others => vga_io(2) and (video_dot xor ga_dot xor ca_dot));
	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			red   <= (others => vga_rgb(2));
			green <= (others => vga_rgb(1));
			blue  <= (others => vga_rgb(0));
			blank <= vga_io(2);
			hsync <= vga_io(0);
			vsync <= vga_io(1);
			sync  <= not vga_io(1) and not vga_io(0);
		end if;
	end process;
	psave <= '1';


	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => vga_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

	adc_clkab <= '0';
	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rst  <= '1';
	mii_txen <= 'Z';
	mii_txd  <= (others => 'Z');
	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => ddr_ckp,
		ob => ddr_ckn);

	ddr_st_dqs <= 'Z';
	ddr_cke    <= 'Z';
	ddr_cs     <= 'Z';
	ddr_ras    <= 'Z';
	ddr_cas    <= 'Z';
	ddr_we     <= 'Z';
	ddr_ba     <= (others => 'Z');
	ddr_a      <= (others => 'Z');
	ddr_dm     <= (others => 'Z');
	ddr_dqs    <= (others => 'Z');
	ddr_dq     <= (others => 'Z');

end;
