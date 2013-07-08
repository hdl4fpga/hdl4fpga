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
	signal uclk_bufg  : std_logic;

	signal dcm_rst : std_logic;
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

	-------------------------------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 180 Mhz -- 193 Mhz -- 200 Mhz  --
	-- Multiply by --  20     --  25     --   9     --  29     --  10      --
	-- Divide by   --   3     --   3     --   1     --   3     --   1      --
	-------------------------------------------------------------------------

	constant ddr_multiply : natural := 11; --30; --25;
	constant ddr_divide   : natural := 2;  --2; --3;

begin

	sys_rst <= gpio_sw_n;
	scope_e : entity hdl4fpga.scope
	port map (
		sys_rst => scope_rst,

		input_clk => uclk_bufg,

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
		ddr_dqs_p => ddr2_dqs_p(1 downto 0),
		ddr_dqs_n => ddr2_dqs_n(1 downto 0),
		ddr_dq  => ddr2_d(data_size-1 downto 0),
		ddr_lp_dqs => gpio_led_c, --ddr_lp_dqs,
		ddr_st_lp_dqs => gpio_sw_c, --ddr_st_lp_dqs,

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

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => uclk_bufg);

	video_dcm : entity hdl4fpga.dfs1(v5)
	generic map (
		dcm_per => uclk_period,
		dfs_mul => 3,
		dfs_div => 2)
	port map(
		dcm_rst => dcm_rst,
		dcm_clk => uclk_bufg,
		dfs_clk => video_clk,
		dcm_lck => video_lckd);

	ddr_dcm	: entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => uclk_period,
		dfs_mul => ddr_multiply,
		dfs_div => ddr_divide)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => uclk_bufg,
		dfsdcm_clk0  => ddrs_clk0,
		dfsdcm_clk90 => ddrs_clk90,
		dcm_lck => ddrs_lckd);

	isdbt_dcm : entity hdl4fpga.dfs1(v5)
	generic map (
		dcm_per => uclk_period,
		dfs_mul => 2,
		dfs_div => 10)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => uclk_bufg,
		dfs_clk => input_clk,
		dcm_lck => input_lckd);

	process (sys_rst, uclk_bufg)
		variable rst : std_logic_vector(0 to 5);
	begin
		if sys_rst='1' then
			dcm_rst <= '1';
			scope_rst <= '1';
			rst := (others => '1');
		elsif rising_edge(uclk_bufg) then
			if dcm_rst='0' then
				scope_rst <= not (video_lckd and ddrs_lckd and input_lckd);
			end if;

			rst := rst(1 to rst'right) & '0';
			dcm_rst <= rst(0);
		end if;
	end process;

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

	ddr2_cs(1) <= '1';
	ddr2_ba(2) <= '0';
   	ddr2_a(13) <= '0';
  	ddr2_cke(1) <= '0';
   	ddr2_odt(1 downto 0) <= (others => 'Z');
	ddr2_dm(7 downto 0) <= (others => 'Z');
	ddr2_d(63 downto 16) <= (others => '0');
--gpio_led <= (others => '1');
end;
