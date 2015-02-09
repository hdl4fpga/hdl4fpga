library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
--use hdl4fpga.cgafont.all;

library ecp3;
use ecp3.components.all;

architecture scope of ecp3versa is
	constant data_phases : natural := 1;
	constant cmmd_phases : natural := 2;
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant line_size : natural := 4*ddr3_dq'length;
	constant word_size : natural := ddr3_dq'length;
	constant byte_size : natural := ddr3_dq'length/ddr3_dqs'length;

	constant ns : natural := 1000;
	constant uclk_period : natural := 10*ns;

	signal uclk : std_logic;
	signal dcm_rst  : std_logic;
	signal dcm_lckd : std_logic;
	signal video_lckd : std_logic;
	signal ddrs_lckd  : std_logic;
	signal input_lckd : std_logic;

	signal input_clk : std_logic;

	signal ddrs_clks  : std_logic_vector(0 to 2-1);
	signal ddr_lp_clk : std_logic;
	signal tpo : std_logic_vector(0 to 4-1) := (others  => 'Z');

	signal sto : std_logic;
	signal sto1 : std_logic;
	signal ddrphy_rst : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_cke : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_cs : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_ras : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_cas : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_we : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_odt : std_logic_vector(cmmd_phases-1 downto 0);
	signal ddrphy_b : std_logic_vector(cmmd_phases*ddr3_b'length-1 downto 0);
	signal ddrphy_a : std_logic_vector(cmmd_phases*ddr3_a'length-1 downto 0);
	signal ddrphy_dqsi : std_logic_vector(ddr3_dqs'length-1 downto 0);
	signal ddrphy_dqst : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqso : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmi : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmt : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmo : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqi : std_logic_vector(line_size-1 downto 0);
	signal ddrphy_dqt : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqo : std_logic_vector(line_size-1 downto 0);
	signal ddrphy_sto : std_logic_vector(data_phases*line_size/word_size-1 downto 0);
	signal ddrphy_sti : std_logic_vector(data_phases*line_size/word_size-1 downto 0);
	signal ddrphy_cfgo : std_logic_vector(2+4-1 downto 0);

	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(phy1_rx_d'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(phy1_tx_d'range);

	signal vga_clk : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

	signal sys_rst   : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant ddr_mul : natural := 4;
	constant ddr_div : natural := 2;
	constant r : natural := 0;
	constant f : natural := 1;
	signal ddr_sclk : std_logic;
	signal ddr_sclk2x : std_logic;
	signal ddr_eclk  : std_logic;

	signal input_rst : std_logic;
	signal ddrs_rst : std_logic;
	signal mii_rst : std_logic;
	signal vga_rst : std_logic;
begin

	sys_rst <= not fpga_gsrn;
	uclk <= clk;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => real(uclk_period/ns))
	port map (
		sys_rst => sys_rst,
		sys_clk => uclk,
		input_clk => input_clk,
		ddr_eclkph =>ddrphy_cfgo(5 downto 2),
		ddr_eclk =>ddr_eclk,
		ddr_sclk => ddr_sclk, 
		ddr_sclk2x => ddr_sclk2x, 
		video_clk0 => vga_clk,
		dcms_lckd => dcm_lckd);

	rsts_b : block
		port (
			grst : in  std_logic;
			clks : in  std_logic_vector(0 to 3);
			rsts : out std_logic_vector(0 to 3));
		port map (
			grst => dcm_lckd,
			clks(0) => input_clk,
			clks(1) => ddr_sclk,
			clks(2) => phy1_125clk,
			clks(3) => vga_clk,
			rsts(0) => input_rst,
			rsts(1) => ddrs_rst,
			rsts(2) => mii_rst,
			rsts(3) => vga_rst);
	begin
		rsts_g: for i in clks'range generate
			process (clks(i))
				variable rsta : std_logic;
			begin
				if rising_edge(clks(i)) then
					rsts(i) <= rsta;
					rsta    := not grst;
				end if;
			end process;
		end generate;
	end block;

	ddrs_clks <= (others => ddr_sclk);
	ddrphy_sti <= (others => ddrphy_cfgo(0));
	scope_e : entity hdl4fpga.scope
	generic map (
		DDR_tCP => uclk_period*ddr_div/ddr_mul,
		DDR_STD => 3,
		DDR_STROBE => "INTERNAL",
		DDR_DATAPHASES => 1,
		DDR_BANKSIZE => ddr3_b'length,
		DDR_ADDRSIZE => ddr3_a'length,
		DDR_CLMNSIZE => 7,
		DDR_LINESIZE => line_size,
		DDR_WORDSIZE => word_size,
		DDR_BYTESIZE => byte_size,
		xd_len  => 8)
	port map (

--		input_rst => input_rst,
		input_clk => input_clk,

		ddrs_rst => ddrs_rst,
		ddrs_clks => ddrs_clks,
		ddr_rst  => ddrphy_rst(0),
		ddr_cke  => ddrphy_cke(0),
		ddr_cs   => ddrphy_cs(0),
		ddr_ras  => ddrphy_ras(0),
		ddr_cas  => ddrphy_cas(0),
		ddr_we   => ddrphy_we(0),
		ddr_b    => ddrphy_b(ddr3_b'length-1 downto 0),
		ddr_a    => ddrphy_a(ddr3_a'length-1 downto 0),
		ddr_dmi  => ddrphy_dmi,
		ddr_dmt  => ddrphy_dmt,
		ddr_dmo  => ddrphy_dmo,
		ddr_dqst => ddrphy_dqst,
		ddr_dqsi => ddrphy_dqsi,
		ddr_dqso => ddrphy_dqso,
		ddr_dqi  => ddrphy_dqi,
		ddr_dqt  => ddrphy_dqt,
		ddr_dqo  => ddrphy_dqo,
		ddr_odt  => ddrphy_odt(0),
		ddr_sto  => ddrphy_sto,
		ddr_sti  => ddrphy_sti,

--		mii_rst  => mii_rst,
		mii_rxc  => phy1_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => phy1_125clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,

--		vga_rst   => vga_rst,
		vga_clk   => vga_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_frm   => vga_frm,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue,
		tpo => tpo);

	ddrphy_rst(1) <= ddrphy_rst(0);
	process (ddr_sclk)
	begin
		if rising_edge(ddr_sclk) then
			sto <= not ddrphy_sto(0) and sto1;
			sto1 <= not ddrphy_sto(0);
		end if;
	end process;

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		BANK_SIZE => ddr3_b'length,
		ADDR_SIZE => ddr3_a'length,
		LINE_SIZE => line_size,
		WORD_SIZE => word_size,
		BYTE_SIZE => byte_size)
	port map (
		sys_sclk => ddr_sclk,
		sys_sclk2x => ddr_sclk2x, 
		sys_eclk => ddr_eclk,
		phy_rst => ddrs_rst,

		sys_rw => sto,
		sys_rst => ddrphy_rst, 
		sys_cfgi => (others => '-'),
		sys_cfgo => ddrphy_cfgo,
		sys_cke => ddrphy_cke,
		sys_cs  => ddrphy_cs,
		sys_ras => ddrphy_ras,
		sys_cas => ddrphy_cas,
		sys_we  => ddrphy_we,
		sys_b   => ddrphy_b,
		sys_a   => ddrphy_a,
		sys_dqsi => ddrphy_dqsi,
		sys_dqst => ddrphy_dqst,
		sys_dqso => ddrphy_dqso,
		sys_dmi => ddrphy_dmo,
		sys_dmt => ddrphy_dmt,
		sys_dmo => ddrphy_dmi,
		sys_dqi => ddrphy_dqi,
		sys_dqt => ddrphy_dqt,
		sys_dqo => ddrphy_dqo,
		sys_odt => ddrphy_odt,

		ddr_rst => ddr3_rst,
		ddr_ck  => ddr3_clk,
		ddr_cke => ddr3_cke,
		ddr_odt => ddr3_odt,
		ddr_cs => ddr3_cs,
		ddr_ras => ddr3_ras,
		ddr_cas => ddr3_cas,
		ddr_we  => ddr3_we,
		ddr_b   => ddr3_b,
		ddr_a   => ddr3_a,

		ddr_dm  => ddr3_dm,
		ddr_dq  => ddr3_dq,
		ddr_dqs => ddr3_dqs);

	phy1_rst  <= dcm_lckd;
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

	process (phy1_rxc,fpga_gsrn)
	begin
		if fpga_gsrn='0' then
			led(0) <= '1';
			led(1) <= '1';
			led(2) <= '1';
		elsif rising_edge(phy1_rxc) then
			if tpo(0)='1'then
				led(0) <= '0';
			end if;
			if phy1_rx_dv='1'then
				led(1) <= '0';
			end if;
			if mii_txen='1'then
				led(2) <= '0';
			end if;
		end if;
	end process;

	led(4) <= not tpo(0);
	led(5) <= not phy1_rx_dv;
	led(6) <= not mii_txen;

end;
