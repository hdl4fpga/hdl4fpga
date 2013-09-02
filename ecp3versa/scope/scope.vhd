library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

library ecp3;
use ecp3.components.all;

architecture scope of ecp3versa is
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant col_size  : natural := 6;
	constant nibble_size : natural := 4;
	constant byte_size : natural := 8;
	constant data_size : natural := 16;

	constant uclk_period : real := 10.0;

	constant uclk : std_logic;
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

	signal gtx_clk  : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(phy1_rx_d'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(phy1_tx_d'range);

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
	signal scope_rst : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant ddr_mul : natural :=11;
	constant ddr_div : natural := 4;

begin

	sys_rst <= not fpga_gsrn;

	uclk_i : ilvds 
	port map (
		a  => clk_p,
		an => clk_n,
		z  => uclk);

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => uclk_period)
	port map (
		sys_rst => sys_rst,
		sys_clk => uclk,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => video_clk,
		video_clk90 => video_clk90,
		gtx_clk => gtx_clk,
		dcm_lckd => dcm_lckd);

	scope_rst <= not dcm_lckd;
	phy1_rst <= dcm_lckd;

	scope_e : entity hdl4fpga.scope
	generic map (
		strobe => "INTERNAL",
		ddr_std => 2,
		xd_len => 8,
		tDDR => (uclk_period*real(ddr_div))/real(ddr_mul))
	port map (
		sys_rst => scope_rst,

		input_clk => input_clk,

		ddr_st_lp_dqs => '0',
		ddrs_clk0  => ddrs_clk0,
		ddrs_clk90 => ddrs_clk90,
		ddr_rst => ddr3_rst,
		ddr_cke => ddr3_cke,
		ddr_cs  => ddr3_cs,
		ddr_ras => ddr3_ras,
		ddr_cas => ddr3_cas,
		ddr_we  => ddr3_we,
		ddr_ba  => ddr3_ba(bank_size-1 downto 0),
		ddr_a   => ddr3_a,
		ddr_dm  => ddr3_dm,
		ddr_dqs => ddr3_dqs_p,
		ddr_dqs_n => ddr3_dqs_n,
		ddr_dq  => ddr3_dq,
		ddr_odt => ddr3_odt,

		mii_rxc  => phy1_rxc,
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

	phy1_mdc <= '0';
	phy1_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		device => "virtex5",
		xd_len => 8)
	port map (
		mii_rxc  => phy_rxclk,
		iob_rxdv => phy_rxctl_rxdv,
		iob_rxd  => phy1_rx_d,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => gtx_clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy_txctl_txen,
		iob_txd  => phy1_tx_d,
		iob_gtxclk => phy_txc_gtxclk);

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

end;
