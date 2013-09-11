library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture scope of nuhs3dsp is
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
	signal ddr_dqsz : std_logic_vector(ddr_dqs'range);
	signal ddr_dqso : std_logic_vector(ddr_dqs'range);

	signal rxdv : std_logic;
	signal rxd  : std_logic_vector(0 to nibble_size-1);
	signal txen : std_logic;
	signal txd  : std_logic_vector(0 to nibble_size-1);

	signal video_clk : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

	signal sys_rst   : std_logic;
	signal scope_rst : std_logic;

	constant sys_per : real := 50.0;
	constant ddr_mul : natural := 25;
	constant ddr_div : natural :=  3;
begin

	sys_rst <= not sw1;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div,
		sys_per => sys_per)
	port map (
		sys_rst => sys_rst,
		sys_clk => xtal,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => video_clk,
		mii_clk => mii_refclk,
		dcm_lckd => dcm_lckd);
	mii_rst <= dcm_lckd;

	adc_clkab <= input_clk;
	scope_rst <= not dcm_lckd;
	scope_e : entity hdl4fpga.scope
	generic map (
		xd_len => 4,
		tDDR => (real(ddr_div)*sys_per)/real(ddr_mul),
		strobe => "EXTERNAL",
		ddr_std => 1)
	port map (
		sys_rst => scope_rst,

		input_clk => input_clk,

		ddr_rst => open,
		ddrs_clk0  => ddrs_clk0,
		ddrs_clk90 => ddrs_clk90,
		ddr_cke => ddr_cke,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_ba  => ddr_ba(bank_size-1 downto 0),
		ddr_a   => ddr_a(addr_size-1 downto 0),
		ddr_dm  => ddr_dm(data_size/byte_size-1 downto 0),
		ddr_dqsz => ddr_dqsz(1 downto 0),
		ddr_dqsi => ddr_dqs(1 downto 0),
		ddr_dqso => ddr_dqso(1 downto 0),
		ddr_dq  => ddr_dq(data_size-1 downto 0),
		ddr_lp_dqs => ddr_lp_dqs,
		ddr_st_lp_dqs => ddr_st_lp_dqs,

		mii_rxc  => mii_rxc,
		mii_rxdv => rxdv,
		mii_rxd  => rxd,
		mii_txc  => mii_txc,
		mii_txen => txen,
		mii_txd  => txd,

		vga_clk   => video_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue);

	ddr_dqs_e : for i in ddr_dqs'range generate
		ddr_dqs(i) <= ddr_dqso(i) when ddr_dqsz(i)='0' else 'Z';
	end generate;

	vga_iob_e : entity hdl4fpga.adv7125_iob
	port map (
		sys_clk   => video_clk,
		sys_hsync => vga_hsync,
		sys_vsync => vga_vsync,
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
	generic map (
		xd_len => 4)
	port map (
		mii_rxc  => mii_rxc,
		iob_rxdv => mii_rxdv,
		iob_rxd  => mii_rxd(0 to nibble_size-1),
		mii_rxdv => rxdv,
		mii_rxd  => rxd,

		mii_txc  => mii_txc,
		mii_txen => txen,
		mii_txd  => txd,
		iob_txen => mii_txen,
		iob_txd  => mii_txd(0 to nibble_size-1));

	-- Differential buffers --
	--------------------------

	ddrs_clk180 <= not ddrs_clk0;
	diff_clk_b : block
		signal diff_clk : std_logic;
	begin
		oddr_mdq : oddr2
		port map (
			r => '0',
			s => '0',
			c0 => ddrs_clk180,
			c1 => ddrs_clk0,
			ce => '1',
			d0 => '1',
			d1 => '0',
			q => diff_clk);

		ddr_ck_obufds : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => diff_clk,
			o  => ddr_ckp,
			ob => ddr_ckn);
	end block;

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= not sys_rst;

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_mdc  <= '0';
	mii_mdio <= 'Z';


	-- LCD --
	---------

	lcd_e <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

end;
