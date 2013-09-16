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
	signal ddr_dqsz : std_logic_vector(8-1 downto 0);
	signal ddr_dqsi : std_logic_vector(8-1 downto 0);
	signal ddr_dqso : std_logic_vector(8-1 downto 0);
	signal ddr_dm  : std_logic_vector(8-1 downto 0);
	signal ddr_st_dqs : std_logic_vector(8-1 downto 0);

	signal ddr_dqz : std_logic_vector(64-1 downto 0);
	signal ddr_dqi : std_logic_vector(64-1 downto 0);
	signal ddr_dqo : std_logic_vector(64-1 downto 0);

	signal gtx_clk  : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(phy_rxd'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(phy_txd'range);

	signal video_clk : std_logic;
	signal video_clk90 : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

	signal sys_rst   : std_logic;
	signal sys_clk   : std_logic;
	signal scope_rst : std_logic;
	signal iodelay_clk : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant ddr_mul : natural :=10;
	constant ddr_div : natural := 3;

begin

	sys_rst <= gpio_sw_c;

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => uclk_period)
	port map (
		sys_rst => sys_rst,
		sys_clk => sys_clk,
		iodelay_clk => iodelay_clk,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => video_clk,
		video_clk90 => video_clk90,
		gtx_clk => gtx_clk,
		dcm_lckd => dcm_lckd);

	scope_rst <= not dcm_lckd;
	dvi_reset <= dcm_lckd;
	phy_reset <= dcm_lckd;

	scope_e : entity hdl4fpga.scope
	generic map (
		strobe => "INTERNAL",
		ddr_std => 2,
		xd_len => 8,
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
		ddr_dm  => ddr_dm(data_size/byte_size-1 downto 0),
		ddr_dqsz => ddr_dqsz(1 downto 0),
		ddr_dqsi => ddr_dqsi(1 downto 0),
		ddr_dqso => ddr_dqso(1 downto 0),
		ddr_dqz  => ddr_dqz(data_size-1 downto 0),
		ddr_dqi  => ddr_dqi(data_size-1 downto 0),
		ddr_dqo  => ddr_dqo(data_size-1 downto 0),
		ddr_odt => ddr2_odt(0),
		ddr_st_lp_dqs => ddr_st_dqs(1 downto 0),

		mii_rxc  => phy_rxclk,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => gtx_clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,

		vga_clk   => video_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_frm   => vga_frm,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue);

	vga_iob_e : entity hdl4fpga.vga2ch7301c_iob
	port map (
		vga_clk   => video_clk,
		vga_clk90 => video_clk90,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_blank => vga_blank,
		vga_frm   => vga_frm,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue,

		dvi_xclk_p => dvi_xclk_p,
		dvi_xclk_n => dvi_xclk_n,
		dvi_v => dvi_v,
		dvi_h => dvi_h,
		dvi_de => dvi_de,
		dvi_d => dvi_d);

	phy_txer  <= '0';
	phy_mdc <= '0';
	phy_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 8)
	port map (
		mii_rxc  => phy_rxclk,
		iob_rxdv => phy_rxctl_rxdv,
		iob_rxd  => phy_rxd,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => gtx_clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy_txctl_txen,
		iob_txd  => phy_txd,
		iob_gtxclk => phy_txc_gtxclk);

	-- Differential buffers --
	--------------------------

	ddrs_clk180 <= not ddrs_clk0;
	diff_clk_b : block
		signal diff_clk : std_logic;
	begin
		oddr_mdq : entity hdl4fpga.ddro
		port map (
			clk => ddrs_clk0,
			dr => '0',
			df => '1',
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

	ddr_dq_e : for i in data_size-1 downto 0 generate
		idelay_i : idelay 
		port map (
			rst => '0',
			c   => '0',
			ce  => '0',
			inc => '0',
			i => ddr2_d(i),
			o => ddr_dqi(i));

		ddr2_d(i) <= ddr_dqo(i) when ddr_dqz(i)='0' else 'Z';
	end generate;

	ictrl_i : idelayctrl
	port map (
		refclk => iodelay_clk,
		rst => sys_rst);

	ddr2_dqs_g : for i in 2-1 downto 0 generate
		signal dqsi : std_logic;
		signal st   : std_logic;
	begin

		obuf_i : obuf
		port map (
			i => ddr_dm(i),
			o => ddr2_dm(i));

		ibuf_i : ibuf
		port map (
			i => ddr2_dm(i),
			o => st);

		idelay_i : idelay 
		port map (
			rst => '0',
			c   => '0',
			ce  => '0',
			inc => '0',
			i => st,
			o => ddr_st_dqs(i));

		dqsidelay_i : idelay 
		port map (
			rst => '0',
			c   => '0',
			ce  => '0',
			inc => '0',
			i => dqsi,
			o => ddr_dqsi(i));

		obufds : iobufds
		generic map (
			iostandard => "DIFF_SSTL18_II_DCI")
		port map (
			t => ddr_dqsz(i),
			i => ddr_dqso(i),
			o => dqsi,
			io  => ddr2_dqs_p(i),
			iob => ddr2_dqs_n(i));

	end generate;

	ddr2_dqs_g1 : for i in 7 downto 2 generate
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

	dvi_gpio1 <= '1';
	bus_error <= (others => 'Z');
	gpio_led <= (others => '0');
	gpio_led_c <= dcm_lckd;
	gpio_led_e <= '0';
	gpio_led_n <= '0';
	gpio_led_s <= '0';
	gpio_led_w <= '0';
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';

	ddr2_cs(1 downto 1) <= "1";
	ddr2_ba(2 downto 2) <= "0";
   	ddr2_a(13 downto 13) <= "0";
  	ddr2_cke(1 downto 1) <= "0";
	ddr2_odt(1 downto 1) <= (others => 'Z');
	ddr2_dm(7 downto 2)  <= (others => 'Z');
	ddr2_d(63 downto 16) <= (others => '0');


end;
