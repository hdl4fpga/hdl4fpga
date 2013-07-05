library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture scope of ml505 is
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant col_size  : natural := 6;
	constant data_size : natural := 16;

	constant uclk_period : real := 10.0;
	signal uclk_bufg  : std_logic;

	signal video_lckd : std_logic;
	signal ddrs_lckd  : std_logic;
	signal input_lckd : std_logic;

	signal ddrs_clk0  : std_logic;
	signal ddrs_clk90 : std_logic;
	signal ddr_lp_clk : std_logic;

	signal video_clk : in std_logic;
	signal vga_hsync : in std_logic;
	signal vga_vsync : in std_logic;
	signal vga_blank : in std_logic;
	signal vga_red : in std_logic_vector(8-1 downto 0);
	signal vga_green : in std_logic_vector(8-1 downto 0);
	signal vga_blue  : in std_logic_vector(8-1 downto 0);

	signal sys_rst  : std_logic;

	-------------------------------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 180 Mhz -- 193 Mhz -- 200 Mhz  --
	-- Multiply by --  20     --  25     --   9     --  29     --  10      --
	-- Divide by   --   3     --   3     --   1     --   3     --   1      --
	-------------------------------------------------------------------------

	constant ddr_multiply : natural := 25; --30; --25;
	constant ddr_divide   : natural := 3;  --2; --3;
	constant cas : std_logic_vector(0 to 2) := cas_code(
		tCLK => 50.0,
		multiply => ddr_multiply,
		divide   => ddr_divide);

begin

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => uclk_bufg);

	video_dcm : entity hdl4fpga.dfs
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

	isdbt_dcm : entity hdl4fpga.dfs
	generic map (
		dcm_per => uclk_period,
		dfs_mul => 10,
		dfs_div => 1)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => uclk_ibuf,
		dfs_clk => adc_clkab,
		dcm_lck => adc_lckd);

	process (sys_rst, uclk_bufg)
		variable rst : std_logic_vector(1 to 5);
	begin
		if sys_rst='1' then
			dcm_rst <= '1';
			rst := (others => '1');
		elsif rising_edge(uclk_bufg) then
			if dcm_rst='0' then
				scope_rst <= not (video_lckd and ddrs_lckd and adc_lckd);
			end if;

			rst := rst(1 to rst'right) & '0';
			dcm_rst <= rst(0);
		end if;
	end if;

	input_clk <= adc_clkout;

	vga_iob_e : entity hdl4fpga.vga2ch7301_iob
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
		iob_rxdv => phy_rxdv,
		iob_rxd  => phy_rxd,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => phy_txclk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy_txen,
		iob_txd  => phy_txd);

	-- Differential buffers --
	--------------------------

	diff_clk_b : block
		signal diff_clk : std_logic;
	begin
		oddr_mdq : oddr2
		port map (
			r  => '0',
			s  => '0',
			c0 => ddrs_clk180,
			c1 => ddrs_clk0,
			ce => '1',
			d0 => '1',
			d1 => '0',
			q  => diff_clk);

		ddr_ck_obufds : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => diff_clk,
			o  => ddr_ckp,
			ob => ddr_ckn);
	end block;
end;
