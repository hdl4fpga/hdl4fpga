library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.videopkg.all;

architecture beh of nuhs3adsp is

	constant sys_per  : real := 50.0;
	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3*8-1);
	signal vga_blank  : std_logic;

	constant inputs : natural := 2;
	signal samples_doa : std_logic_vector(adc_da'length-1 downto 0);
	signal samples_dib : std_logic_vector(adc_da'length-1 downto 0);
	signal samples     : std_logic_vector(inputs*adc_da'length-1 downto 0);
	signal adc_clk     : std_logic;

	signal ipcfg_req : std_logic;
	signal txen      : std_logic;

	signal input_clk : std_logic;

	constant baudrate : natural := 115200;

	signal uart_rxc  : std_logic;
	signal uart_sin  : std_logic;
	signal uart_ena  : std_logic;
	signal uart_rxdv : std_logic;
	signal uart_rxd  : std_logic_vector(8-1 downto 0);

	signal toudpdaisy_clk  : std_logic;
	signal toudpdaisy_frm  : std_logic;
	signal toudpdaisy_irdy : std_logic;
	signal toudpdaisy_data : std_logic_vector(mii_rxd'range);

	signal si_clk    : std_logic;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(mii_rxd'range);

	signal so_clk    : std_logic;
	signal so_frm    : std_logic;
	signal so_trdy   : std_logic;
	signal so_irdy   : std_logic;
	signal so_data   : std_logic_vector(mii_txd'range);

	type display_param is record
		timing_id : videotiming_ids;
		layout    : display_layout;
		dcm_mul   : natural;
		dcm_div   : natural;
	end record;

	type display_modes is (
		mode480p,
		mode600p, 
		mode600px16,
		mode1080p);

	type displayparam_vector is array (display_modes) of display_param;
	constant display_tab : displayparam_vector := (
		mode480p    => (timing_id => pclk25_00m640x480at60,    layout => displaylayout_tab(sd480),  dcm_mul => 5, dcm_div => 4),
		mode600p    => (timing_id => pclk40_00m800x600at60,    layout => displaylayout_tab(sd600),  dcm_mul => 2, dcm_div => 1),
		mode600px16 => (timing_id => pclk40_00m800x600at60,    layout => displaylayout_tab(sd600),  dcm_mul => 2, dcm_div => 1),
		mode1080p   => (timing_id => pclk140_00m1920x1080at60, layout => displaylayout_tab(hd1080), dcm_mul => 7, dcm_div => 1));

	constant video_mode : display_modes := mode1080p;

begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	adc_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 32,
		dfs_div => 5)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => adc_clk);
	input_clk <= not adc_clk;

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => display_tab(video_mode).dcm_mul,
		dfs_div => display_tab(video_mode).dcm_div)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_refclk);

	process (input_clk)
		variable ff : std_logic_vector(samples'range);
	begin
		if rising_edge(input_clk) then
			samples <= ff;
			ff     := (adc_da xor (1 => '1', 2 to adc_da'length => '0')) & (adc_db xor (1 => '1', 2 to adc_db'length => '0'));
		end if;
	end process;

	process (sw1, mii_txc)
	begin
		if rising_edge(mii_txc) then
			if sw1='0' then
				ipcfg_req <= '1';
			elsif txen='0'  then
				ipcfg_req <= '0';
			end if;
		end if;
	end process;
	led18  <= ipcfg_req;

	process (mii_rxc)
		constant max_count : natural := (25*10**6+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(mii_rxc) then
			if cntr >= max_count-1 then
				uart_ena <= '1';
				cntr := (others => '0');
			else
				uart_ena <= '0';
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	uart_sin <= rs232_rd;
	uart_rxc <= mii_rxc;
	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_rxc  => uart_rxc,
		uart_sin  => uart_sin,
		uart_ena  => uart_ena,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

--	istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
--	generic map (
--		istream_esc => std_logic_vector(to_unsigned(character'pos('\'), 8)),
--		istream_eos => std_logic_vector(to_unsigned(character'pos(NUL), 8)))
--	port map (
--		stream_clk  => uart_rxc,
--		stream_dv   => uart_rxdv,
--		stream_ena  => uart_ena,
--		stream_data => uart_rxd,
--
--		chaini_data => uart_rxd,
--
--		chaino_frm  => toudpdaisy_frm, 
--		chaino_irdy => toudpdaisy_irdy,
--		chaino_data => toudpdaisy_data);

	udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
	port map (
		ipcfg_req   => ipcfg_req,

		phy_rxc     => mii_rxc,
		phy_rx_dv   => mii_rxdv,
		phy_rx_d    => mii_rxd,

		phy_txc     => mii_txc, 
		phy_tx_en   => txen,
		phy_tx_d    => mii_txd,
		ipcfg_vld   => led7,
	
		chaini_sel  => '0',

		chaini_frm  => toudpdaisy_frm,
		chaini_irdy => toudpdaisy_irdy,
		chaini_data => toudpdaisy_data,

		chaino_frm  => si_frm,
		chaino_irdy => si_irdy,
		chaino_data => si_data);
	mii_txen <= txen;
	
	si_clk <= mii_rxc;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		timing_id        => display_tab(video_mode).timing_id,
		layout           => display_tab(video_mode).layout,
		inputs           => inputs,
--		input_names      => (
--			hdl4fpga.textboxpkg.text(id => "vt(0).text", content => "channel 1"),
--			hdl4fpga.textboxpkg.text(id => "vt(1).text", content => "channel 2")),
		hz_unit          => 250.0*nano,
		vt_unit          => 2.0*milli,
		vt_steps         => (0 to inputs-1 => 1000.0*milli/2.0**14),
		default_tracesfg => b"1_11111111_11111111_00000000" & b"1_00000000_11111111_11111111",
		default_gridfg   => b"1_11111111_00000000_00000000",
		default_gridbg   => b"1_00000000_00000000_00000000",
		default_hzfg     => b"1_11111111_11111111_11111111",
		default_hzbg     => b"1_00000000_00000000_11111111",
		default_vtfg     => b"1_11111111_11111111_11111111",
		default_vtbg     => b"1_00000000_00000000_11111111",
		default_textfg   => b"1_11111111_11111111_11111111",
		default_textbg   => b"1_00000000_00000000_00000000",
		default_sgmntbg  => b"1_00000000_11111111_11111111",
		default_bg       => b"1_11111111_11111111_11111111")
	port map (
		si_clk      => si_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_irdy     => so_irdy,
		so_data     => so_data,
		input_clk   => input_clk,
		input_data  => samples,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank);

	process (vga_clk)
		variable vga_rgb1   : std_logic_vector(vga_rgb'range);
		variable vga_hsync1 : std_logic;
		variable vga_vsync1 : std_logic;
		variable vga_blank1 : std_logic;
	begin
		if rising_edge(vga_clk) then
			red        <= word2byte(vga_rgb1, std_logic_vector(to_unsigned(0,2)), 8);
			green      <= word2byte(vga_rgb1, std_logic_vector(to_unsigned(1,2)), 8);
			blue       <= word2byte(vga_rgb1, std_logic_vector(to_unsigned(2,2)), 8);
			blankn     <= not vga_blank1;
			hsync      <= vga_hsync1;
			vsync      <= vga_vsync1;
			sync       <= not vga_hsync1 and not vga_vsync1;
			vga_rgb1   := vga_rgb;
            vga_hsync1 := vga_hsync;
            vga_vsync1 := vga_vsync;
            vga_blank1 := vga_blank;
		end if;
	end process;
	psave <= '1';

	adcclkab_e : entity hdl4fpga.ddro
	port map (
		clk => adc_clk,
		dr  => '1',
		df  => '0',
		q   => adc_clkab);

	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => vga_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
--	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= '1';
	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => ddr_ckp,
		ob => ddr_ckn);

	ddr_st_dqs <= 'Z';
	ddr_cke    <= 'Z';
	ddr_cs     <= 'Z';
	ddr_ras    <= 'Z';
	ddr_cas    <= 'Z';
	ddr_we     <= 'Z';
	ddr_ba     <= (others => 'Z');
	ddr_a      <= (others => 'Z');
	ddr_dm     <= (others => 'Z');
	ddr_dqs    <= (others => 'Z');
	ddr_dq     <= (others => 'Z');

end;
