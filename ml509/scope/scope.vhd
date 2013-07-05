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

	signal sys_rst : std_logic;

	signal ddrs_clk0   : std_logic;
	signal ddrs_clk90  : std_logic;
	signal ddr_lp_clk : std_logic;

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

	type ddr_tac is record 
		cl  : real;
		bl  : natural;
		wr  : natural;
		cwl : natural;
--	end record;
--	type ddr_tac is record 
		tMRD : real;
		tRCD : real;
		tREFI : real;
		tRFC : real;
		tRP  : real;
--		tRPA : real;	-- DDR2 only
		tWR  : real;
	end record;

	type ddr_actab is array (natural range <>) of ddr_tac;
	constant ddr_acdb : ddr_actab(1 to 3) := (
		1 => (cl => 2.5, bl => 8, wr => 0, cwl => 0, tMRD => 12.0, tRCD => 15.0, tREFI => 7.8e3, tRFC =>  72.0, tRP => 15.0, tWR => 15.0),
		2 => (cl => 7.0, bl => 8, wr => 7, cwl => 7, tMRD => 12.0, tRCD => 15.0, tREFI => 7.8e3, tRFC => 127.5, tRP => 15.0, tWR => 15.0),
		3 => (cl => 9.0, bl => 8, wr => 9, cwl => 9, tMRD => 12.0, tRCD => 15.0, tREFI => 7.8e3, tRFC =>  72.0, tRP => 15.0, tWR => 15.0));

begin

	input_clk <= adc_clkout;

	vga_iob_e : entity hdl4fpga.vga_iob
	port map (
		sys_clk   => video_clk,
		sys_hsync => vga_hsync,
		sys_vsync => vga_vsync,
		sys_sync  => '1',
		sys_psave => '1',
		sys_blank => vga_blank,
		sys_red   => vga_red,
		sys_green => vga_green,
		sys_blue  => vga_blue,

		vga_clk => clk_videodac,
		vga_hsync => hsync,
		vga_vsync => vsync,
		dac_blank => blank,
		dac_sync  => sync,
		dac_psave => psave,

		dac_red   => red,
		dac_green => green,
		dac_blue  => blue);

	mii_iob_e : entity hdl4fpga.mii_iob
	port map (
		mii_rxc  => mii_rxc,

		iob_rxdv => mii_rxdv,
		iob_rxd  => mii_rxd,

		mii_rxdv => rxdv,
		mii_rxd  => rxd,


		mii_txc  => mii_txc,
		mii_txen => txen,
		mii_txd  => txd,

		iob_txen => mii_txen,
		iob_txd  => mii_txd);

	usm: block
		signal xtal_ibufg : std_logic;
		signal rst    : std_logic_vector(0 to 32);
		signal clk0   : std_logic;
		signal clk90  : std_logic;
		signal locked : std_logic; 

		signal miixc_lckd : std_logic;
		signal video_lckd : std_logic;
		signal ddrs_lckd  : std_logic;
		signal adc_lckd   : std_logic;

	begin

		clkin_ibufg : ibufg
		port map (
			I => xtal,
			O => xtal_ibufg);

		video_dcm : entity hdl4fpga.dfs
		generic map (
			dcm_per => 50.0,
			dfs_mul => 15,
			dfs_div => 2)
		port map(
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfs_clk => video_clk,
			dcm_lck => video_lckd);

		mii_dfs_e : entity hdl4fpga.dfs
		generic map (
			dcm_per => 50.0,
			dfs_mul => 5,
			dfs_div => 4)
		port map (
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfs_clk => mii_refclk,
			dcm_lck => miixc_lckd);

		ddr_dcm	: entity hdl4fpga.dfsdcm
		generic map (
			dcm_per => 50.0,
			dfs_mul => ddr_multiply,
			dfs_div => ddr_divide)
		port map (
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfsdcm_clk0  => clk0,
			dfsdcm_clk90 => clk90,
			dcm_lck => ddrs_lckd);

		isdbt_dcm : entity hdl4fpga.dfs
		generic map (
			dcm_per => 50.0,
			dfs_mul => 1,
			dfs_div => 1)
		port map (
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfs_clk => adc_clkab,
			dcm_lck => adc_lckd);

--		isdbt_dcm: entity hdl4fpga.dcmisdbt
--		port map (
--			dcm_rst => rst(0),
--			dcm_clk => xtal_ibufg,
--			dfs_clk => adc_clkab,
--			dcm_lck => adc_lckd);

		locked <= adc_lckd and ddrs_lckd and miixc_lckd and video_lckd;
		ddr_rst_p : process (xtal_ibufg,sw1)
		begin
			if sw1='0' then
				rst <= (others => '1');
			elsif rising_edge(xtal_ibufg) then
				rst <= rst(1 to rst'right) & '0';
			end if;
		end process;

		ddrs_clk0   <= clk0;
		ddrs_clk90  <= clk90;
		ddrs_clk180 <= not clk0;
		sys_rst <= not locked;
	end block;

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

	ddr_lp_ck_obufds : ibufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_lp_ckp,
		ib => ddr_lp_ckn,
		o  => ddr_lp_clk);

end;
