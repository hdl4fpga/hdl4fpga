library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture scope of ml509 is
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant col_size  : natural := 6;
	constant nibble_size : natural := 4;
	constant byte_size : natural := 8;
	constant data_size : natural := 16;

	constant uclk_period : real := 10.0;

	signal dcm_rst  : std_logic;
	signal dcm_lckd : std_logic;
	signal video_lckd : std_logic;
	signal ddrs_lckd  : std_logic;
	signal input_lckd : std_logic;

	signal input_clk : std_logic;

	signal ddrs_clk0  : std_logic;
	signal ddrs_clk90 : std_logic;
	signal ddrs_clk180 : std_logic;
	signal ddr_lp_clk : std_logic;

	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to nibble_size-1);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to nibble_size-1);

	signal video_clk : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

	signal sys_rst   : std_logic;
	signal scope_rst : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant ddr_mul : natural := 10;
	constant ddr_div : natural :=  3;

begin

	sys_rst <= gpio_sw_c;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => uclk_period)
	port map (
		sys_rst => sys_rst,
		sys_clk => user_clk,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => video_clk,
		dcm_lckd => dcm_lckd);

	scope_rst <= not dcm_lckd;
	dvi_reset <= dcm_lckd;
	phy_reset <= dcm_lckd;
	phy_txer  <= '0';
	phy_txd(4 to 7) <= (others => '0');
	phy_txc_gtxclk <= '0';
	phy_mdc <= '0';
	phy_mdio <= '0';

	scope_e : entity hdl4fpga.scope
	generic map (
		device => "virtex5",
		ddr_std => 2,
		tDDR => (uclk_period*real(ddr_div))/real(ddr_mul))
	port map (
		sys_rst => scope_rst,

		input_clk => input_clk,

		ddr_rst => open,
		ddrs_clk0  => ddrs_clk0,
		ddrs_clk90 => ddrs_clk90,
		ddr_cke => ddr2_cke(0),
		ddr_cs  => ddr2_cs(0),
		ddr_ras => ddr2_ras,
		ddr_cas => ddr2_cas,
		ddr_we  => ddr2_we,
		ddr_ba  => ddr2_ba(bank_size-1 downto 0),
		ddr_a   => ddr2_a(addr_size-1 downto 0),
		ddr_dm  => ddr2_dm(data_size/byte_size-1 downto 0),
		ddr_dqs => ddr2_dqs_p(1 downto 0),
		ddr_dqs_n => ddr2_dqs_n(1 downto 0),
		ddr_dq  => ddr2_d(data_size-1 downto 0),
		ddr_lp_dqs => open, --gpio_led_e, --ddr_lp_dqs,
		ddr_st_lp_dqs => '-',-- gpio_sw_e, --ddr_st_lp_dqs,

		mii_rxc  => phy_rxclk,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => phy_txclk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,

		vga_clk   => video_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue);

	vga_iob_e : entity hdl4fpga.vga2ch7301c_iob
	port map (
		vga_clk   => video_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue,

		dvi_xclk_p => dvi_xclk_p,
		dvi_xclk_n => dvi_xclk_n,
		dvi_v => dvi_v,
		dvi_h => dvi_h,
		dvi_de => dvi_de,
		dvi_d => dvi_d);

	mii_iob_e : entity hdl4fpga.mii_iob
	port map (
		mii_rxc  => phy_rxclk,
		iob_rxdv => phy_rxctl_rxdv,
		iob_rxd  => phy_rxd(0 to nibble_size-1),
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => phy_txclk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy_txctl_txen,
		iob_txd  => phy_txd(0 to nibble_size-1));

	-- Differential buffers --
	--------------------------

	ddrs_clk180 <= not ddrs_clk0;
	diff_clk_b : block
		signal diff_clk : std_logic;
	begin
		oddr_mdq : oddr
		port map (
			r => '0',
			s => '0',
			c => ddrs_clk180,
			ce => '1',
			d1 => '1',
			d2 => '0',
			q => diff_clk);

		ddr_ck_obufds : obufds
		generic map (
			iostandard => "DIFF_SSTL18_II")
		port map (
			i  => diff_clk,
			o  => ddr2_clk_p(0),
			ob => ddr2_clk_n(0));
	end block;

	ddr_clk1_obufds : obufds
	generic map (
		iostandard => "DIFF_SSTL18_II")
	port map (
		i  => '0',
		o  => ddr2_clk_p(1),
		ob => ddr2_clk_n(1));

	ddr2_dqs_g : for i in 7 downto 2 generate
		obufds : iobufds
		generic map (
			iostandard => "DIFF_SSTL18_II_DCI")
		port map (
			t => '1',
			i => '0',
			o => open,
			io  => ddr2_dqs_p(i),
			iob => ddr2_dqs_n(i));
	end generate;

	bus_error <= (others => 'Z');
	gpio_led <= (others => 'Z');
	gpio_led_c <= 'Z';
	gpio_led_e <= 'Z';
	gpio_led_n <= 'Z';
	gpio_led_s <= 'Z';
	gpio_led_w <= 'Z';
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';
	ddr2_cs(1) <= '1';
	ddr2_ba(2) <= '0';
   	ddr2_a(13) <= '0';
  	ddr2_cke(1) <= '0';
   	ddr2_odt(1 downto 0) <= (others => 'Z');
	ddr2_dm(7 downto 0) <= (others => 'Z');
	ddr2_d(63 downto 16) <= (others => '0');


end;
