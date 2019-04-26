library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of nuhs3adsp is

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
	signal input_clk : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	adc_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 32,
		dfs_div => 5)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => adc_clk);
	input_clk <= not adc_clk;

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
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
		if sw1='1' then
			ipcfg_req <= '0';
			led7  <= '1';
		elsif rising_edge(mii_txc) then
			led7  <= '0';
			ipcfg_req <= '1';
		end if;
	end process;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		inputs => inputs,
		default_tracesfg => std_logic_vector'(b"11111111_11111111_11111111"),
		default_gridfg   => std_logic_vector'(b"11111111_00000000_00000000"),
		default_gridbg   => std_logic_vector'(b"00000000_00000000_00000000"),
		default_hzfg     => std_logic_vector'(b"11111111_11111111_11111111"),
		default_hzbg     => std_logic_vector'(b"00000000_00000000_11111111"),
		default_vtfg     => std_logic_vector'(b"11111111_11111111_11111111"),
		default_vtbg     => std_logic_vector'(b"00000000_00000000_11111111"),
		default_textbg   => std_logic_vector'(b"00000000_00000000_00000000"),
		default_sgmntbg  => std_logic_vector'(b"00000000_11111111_11111111"),
		default_bg       => std_logic_vector'(b"11111111_11111111_11111111"))
	port map (
		si_clk      => mii_rxc,
		si_dv       => mii_rxdv,
		si_data     => mii_rxd,
		so_clk      => mii_txc, 
		so_dv       => mii_txen,
		so_data     => mii_txd,
		ipcfg_req   => ipcfg_req,
		input_clk   => input_clk,
		input_data  => samples,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank);

	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			red   <= word2byte(vga_rgb, std_logic_vector(to_unsigned(0,2)), 8);
			green <= word2byte(vga_rgb, std_logic_vector(to_unsigned(1,2)), 8);
			blue  <= word2byte(vga_rgb, std_logic_vector(to_unsigned(2,2)), 8);
			blank <= vga_blank;
			hsync <= vga_hsync;
			vsync <= vga_vsync;
			sync  <= not vga_hsync and not vga_vsync;
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
		
	led18 <= '0';
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

	mii_rst  <= '1';
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
