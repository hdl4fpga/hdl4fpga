library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture beh of ecp3versa is

	signal hdr_data  : std_logic_vector(288-1 downto 0);
	signal pld_data  : std_logic_vector(288-1 downto 0);
	signal pll_data  : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data  : std_logic_vector(32-1 downto 0);

	constant cga_zoom : natural := 0;
	signal cga_we     : std_logic;
	signal cga_row    : std_logic_vector(6-1-cga_zoom downto 0);
	signal cga_col    : std_logic_vector(8-1-cga_zoom downto 0);
	signal cga_code   : std_logic_vector(8-1 downto 0);
	signal char_dot   : std_logic;

	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_frm    : std_logic;
	signal vga_don    : std_logic;
	signal vga_vld    : std_logic;
	signal vga_rgb    : std_logic_vector(3-1 downto 0);
	signal vga_vcntr  : std_logic_vector(11-1 downto 0);
	signal vga_hcntr  : std_logic_vector(11-1 downto 0);

	signal grid_dot   : std_logic;
	signal galign_dot : std_logic;
	signal video_dot  : std_logic;

	signal vga_io    : std_logic_vector(0 to 3-1);
	signal rst : std_logic;
	
	constant sample_size : natural := 11;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(n*(x1-x0+1)-1 downto 0);
	begin
		for i in 0 to x1-x0 loop
			if (i+x0) /= 0 then
				y := sin(real((i+x0))/100.0)/(real((i+x0))/100.0);
			else
				y := 1.0;
			end if;
			aux((i+1)*n-1 downto i*n) := std_logic_vector(to_unsigned(integer(-real(2**(n-2)-1)*y)+2**(n-2),n));
		end loop;
		return aux;
	end;

	constant data : std_logic_vector(sample_size*2048-1 downto 0) := sinctab(-960, 1087, sample_size);
	signal samples_doa : std_logic_vector(sample_size-1 downto 0);
	signal samples_dib : std_logic_vector(sample_size-1 downto 0);
	signal sample      : std_logic_vector(sample_size-1 downto 0);
begin

	rst <= not fpga_gsrn;
	video_b : block
		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKI  of PLL_I : label is "100.000000";
		attribute FREQUENCY_PIN_CLKOP of PLL_I : label is "150.000000";

		signal clkfb : std_logic;
		signal lock  : std_logic;
	begin
		pll_i : ehxpllf
        generic map (
			FEEDBK_PATH  => "INTERNAL", CLKOK_BYPASS=> "DISABLED", 
			CLKOS_BYPASS => "DISABLED", CLKOP_BYPASS=> "DISABLED", 
			CLKOK_INPUT  => "CLKOP", DELAY_PWD=> "DISABLED", DELAY_VAL=>  0, 
			CLKOS_TRIM_DELAY=> 0, CLKOS_TRIM_POL=> "RISING", 
			CLKOP_TRIM_DELAY=> 0, CLKOP_TRIM_POL=> "RISING", 
			PHASE_DELAY_CNTL=> "STATIC", DUTY=>  8, PHASEADJ=> "0.0", 
			CLKOK_DIV=>  2, CLKOP_DIV=>  4, CLKFB_DIV=>  3, CLKI_DIV=>  2, 
			FIN=> "100.000000")
		port map (
			rst         => rst, 
			rstk        => '0',
			clki        => clk,
			wrdel       => '0',
			drpai3      => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3      => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3        => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb    => clkfb,
			clkfb       => clkfb,
			clkop       => vga_clk, 
			clkos       => open,
			clkok       => open,
			clkok2      => open,
			lock        => lock);
	end block;

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => phy1_125clk,
		mii_rxdv => phy1_rx_dv,
		mii_rxd  => phy1_rx_d,
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
	cga_code <= std_logic_vector(resize(unsigned(vga_hcntr(11-1 downto 11-cga_col'length)), cga_code'length)+0);

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
		d => (vga_io'range => 3+9+2))
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

	galign_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => 2+9+2))
	port map (
		clk   => vga_clk,
		di(0) => grid_dot,
		do(0) => galign_dot);

	cga_e : entity hdl4fpga.cga
	generic map (
		bitrom   => psf1cp850x8x16,
		width    =>  8)
	port map (
		sys_clk  => vga_clk, --phy1_125clk,
		sys_we   => '1', --cga_we,
		sys_row  => vga_vcntr(10-1 downto 10-cga_row'length),
		sys_col  => vga_hcntr(11-1 downto 11-cga_col'length),
		sys_code => cga_code,
		vga_clk  => vga_clk,
		vga_row  => vga_vcntr(10-1 downto cga_zoom),
		vga_col  => vga_hcntr(11-1 downto cga_zoom),
		vga_dot  => char_dot);

	samples_e : entity hdl4fpga.bram
	generic map (
		data => data)
	port map (
		clka  => vga_clk,
		addra => (0 to 11-1 => '0'),
		enaa  => '0',
		dia   => (0 to sample_size-1 => '-'),
		doa   => samples_doa,

		clkb  => vga_clk,
		addrb => vga_hcntr,
		dib   => samples_dib,
		dob   => sample);
		
	draw_vline : entity hdl4fpga.draw_vline
	generic map (
		n => 11)
	port map (
		video_clk  => vga_clk,
		video_row1 => vga_vcntr(vga_vcntr'range),
		video_row2 => sample,
		video_dot  => video_dot);


	vga_rgb <= (others => vga_io(2) and char_dot);
	expansionx4io_e : entity hdl4fpga.align
	generic map (
		n => expansionx4'length,
		i => (expansionx4'range => '-'),
		d => (expansionx4'range => 1))
	port map (
		clk   => vga_clk,
		di(0) => vga_rgb(1),
		di(1) => vga_rgb(0),
		di(2) => vga_rgb(2),
		di(3) => vga_io(0),
		di(4) => vga_io(1),
		do    => expansionx4);

end;
