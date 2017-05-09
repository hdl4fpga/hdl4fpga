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

	signal rst        : std_logic;
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_red    : std_logic;
	signal vga_green  : std_logic;
	signal vga_blue   : std_logic;

	constant sample_size : natural := 9;

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
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(-real(2**(n-3))*y)+2**(n-3),n));
			if i=1599 then
				aux(i*n to (i+1)*n-1) := (others => '0');
			else
				aux(i*n to (i+1)*n-1) := ('1',others => '0');
			end if;
		end loop;
		return aux;
	end;

	signal samples_doa : std_logic_vector(sample_size-1 downto 0);
	signal samples_dib : std_logic_vector(sample_size-1 downto 0);
	signal sample      : std_logic_vector(sample_size-1 downto 0);

	signal input_addr : std_logic_vector(11-1 downto 0);
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

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-960, 1087, sample_size))
	port map (
		clk  => clk,
		addr => input_addr,
		data => sample);

	phy1_rst <= not rst;
	scopeio_e : entity hdl4fpga.scopeio
	port map (
		mii_rxc     => phy1_rxc,
		mii_rxdv    => phy1_rx_dv,
		mii_rxd     => phy1_rx_d,
		input_clk   => vga_clk,
		input_data  => sample,
		video_clk   => vga_clk,
		video_red   => vga_red,
		video_green => vga_green,
		video_blue  => vga_blue,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => open);

	expansionx4io_e : entity hdl4fpga.align
	generic map (
		n => expansionx4'length,
		i => (expansionx4'range => '-'),
		d => (expansionx4'range => 1))
	port map (
		clk   => clk,
		di(0) => vga_green,
		di(1) => vga_blue,
		di(2) => vga_red,
		di(3) => vga_hsync,
		di(4) => vga_vsync,
		do    => expansionx4);

end;
