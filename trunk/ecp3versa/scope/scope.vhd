library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
--use hdl4fpga.cgafont.all;

library ecp3;
use ecp3.components.all;

architecture scope of ecp3versa is
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant col_size  : natural := 6;
	constant nibble_size : natural := 4;
	constant byte_size : natural := 8;
	constant data_bytes : natural := 2;
	constant data_size : natural := data_bytes*byte_size;

	constant uclk_period : time := 10.0 ns;

	signal uclk : std_logic;
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

	signal ddrphy_rst : std_logic;
	signal ddrphy_cke : std_logic;
	signal ddrphy_cs : std_logic;
	signal ddrphy_ras : std_logic;
	signal ddrphy_cas : std_logic;
	signal ddrphy_we : std_logic;
	signal ddrphy_odt : std_logic;
	signal ddrphy_b : std_logic_vector(ddr3_b'length-1 downto 0);
	signal ddrphy_a : std_logic_vector(ddr3_a'length-1 downto 0);
	signal ddrphy_dqsi : std_logic_vector(ddr3_dqs'length-1 downto 0);
	signal ddrphy_dqst : std_logic_vector(ddr3_dqs'length-1 downto 0);
	signal ddrphy_dqso : std_logic_vector(ddr3_dqs'length-1 downto 0);
	signal ddrphy_dmi : std_logic_vector(ddr3_dm'length-1 downto 0);
	signal ddrphy_dmt : std_logic_vector(ddr3_dm'length-1 downto 0);
	signal ddrphy_dmo : std_logic_vector(ddr3_dm'length-1 downto 0);
	signal ddrphy_dqi : std_logic_vector(ddr3_dq'length-1 downto 0);
	signal ddrphy_dqt : std_logic_vector(ddr3_dq'length-1 downto 0);
	signal ddrphy_dqo : std_logic_vector(ddr3_dq'length-1 downto 0);

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

	constant r : natural := 0;
	constant f : natural := 1;
begin

	sys_rst <= not fpga_gsrn;

	uclk_i : entity hdl4fpga.idbuf 
	port map (
		i_p => clk,
		i_n => clk_n,
		o   => uclk);
--	uclk <= clk;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => real(uclk_period/1 ns))
	port map (
		sys_rst => sys_rst,
		sys_clk => uclk,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk0 => video_clk,
		video_clk90 => video_clk90,
		dcms_lckd => dcm_lckd);

	scope_rst <= not dcm_lckd;
	phy1_rst <= dcm_lckd;

	scope_e : entity hdl4fpga.scope
	generic map (
		bank_size => ddr3_b'length,
		addr_size => ddr3_a'length,
		line_size => ddr3_dq'length*2*4,
		word_size => ddr3_dq'length*2,
		byte_size => ddr3_dq'length,
		strobe  => "INTERNAL",
		dstd => 3,
		xd_len  => 8,
		tCP    => (uclk_period*real(ddr_div))/real(ddr_mul))
	port map (
		sys_rst => scope_rst,

		input_clk => input_clk,

		ddr_sti => (others => '0'),
		ddrs_clk0  => ddrs_clk0,
		ddrs_clk90 => ddrs_clk90,
		ddr_rst => ddrphy_rst,
		ddr_cke => ddrphy_cke,
		ddr_cs  => ddrphy_cs,
		ddr_ras => ddrphy_ras,
		ddr_cas => ddrphy_cas,
		ddr_we  => ddrphy_we,
		ddr_ba  => ddrphy_b,
		ddr_a   => ddrphy_a,
		ddr_dm  => ddrphy_dm,
		ddr_dqst => ddrphy_dqst,
		ddr_dqsi => ddrphy_dqsi,
		ddr_dqso => ddrphy_dqso,
		ddr_dqi  => ddrphy_dq,
		ddr_dqo  => ddrphy_dq,
		ddr_odt => ddrphy_odt,

		mii_rxc  => phy1_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => phy1_125clk,
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

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		bank_size => ddr3_b'length,
		addr_size => ddr3_a'length,
		line_size => ddr3_dq'length*2*4,
		word_size => ddr3_dq'length*2,
		byte_size => ddr3_dq'length)
	port map (
		sys_rst  
		sys_sclk,
		sys_sclk2x, 
		sys_eclk,

		sys_cfgi => (others => '-'),
		sys_cfgo => (others => open),
		ddrs_clk0  => ddrs_clk0,
		ddrs_clk90 => ddrs_clk90,
		sys_rst => ddrphy_rst,
		sys_cke => ddrphy_cke,
		sys_cs  => ddrphy_cs,
		sys_ras => ddrphy_ras,
		sys_cas => ddrphy_cas,
		sys_we  => ddrphy_we,
		sys_b   => ddrphy_ba,
		sys_a   => ddrphy_a,
		sys_dqsi => ddrphy_dqsi,
		sys_dqst => ddrphy_dqst,
		sys_dqso => ddrphy_dqso,
		sys_dmi => ddrphy_dmi,
		sys_dmt => ddrphy_dmt,
		sys_dmo => ddrphy_dmo
		sys_dqi  => ddrphy_dqi,
		sys_dqt  => ddrphy_dqt,
		sys_dqo  => ddrphy_dqo,
		sys_odt => ddrphy_odt,

		ddr_rst => ddr3_rst,
		ddr_ck  => ddr3_clk,
		ddr_cke => ddr3_cke,
		ddr_odt => ddr3_odr,
		ddr_ras => ddr3_ras,
		ddr_cas => ddr3_cas,
		ddr_we  => ddr3_we,
		ddr_b   => ddr3_b,
		ddr_a   => ddr3_a,

		ddr_dm  => ddr3_dm,
		ddr_dq  => ddr3_dq,
		ddr_dqs => ddr3_dqs);

	phy1_mdc  <= '0';
	phy1_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 8)
	port map (
		mii_rxc  => phy1_rxc,
		iob_rxdv => phy1_rx_dv,
		iob_rxd  => phy1_rx_d,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => phy1_125clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy1_tx_en,
		iob_txd  => phy1_tx_d,
		iob_gtxclk => phy1_gtxclk);

	-- Differential buffers --
	--------------------------

end;
