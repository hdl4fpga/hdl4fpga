--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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

	signal capture_clk : std_logic;
	signal ncapture_clk : std_logic;
	signal capture_dat : std_logic_vector(adc_db'range);

	signal ddrs_clk0  : std_logic;
	signal ddrs_clk90 : std_logic;
	signal ddrs_clk180 : std_logic;
	signal ddr_dqsz : std_logic_vector(ddr_dqs'range);
	signal ddr_dqso : std_logic_vector(ddr_dqs'range);
	signal ddr_dqz : std_logic_vector(ddr_dq'range);
	signal ddr_dqo : std_logic_vector(ddr_dq'range);
	signal ddr_st : std_logic_vector(ddr_dqs'range);
	signal ddr_lp : std_logic_vector(ddr_dqs'range);

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
	constant ddr_div : natural := 3;
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
		input_clk => capture_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => video_clk,
		mii_clk => mii_refclk,
		dcm_lckd => dcm_lckd);
	mii_rst <= dcm_lckd;

	scope_rst <= not dcm_lckd;
	ddr_st_dqs <= ddr_st(0);
	ncapture_clk <= not capture_clk;
	ddr_lp <= (others => ddr_st_lp_dqs);
	adc_clk : oddr2
	port map (
		r => '0',
		s => '0',
		c0 => capture_clk,
		c1 => ncapture_clk,
		ce => '1',
		d0 => '0',
		d1 => '1',
		q => adc_clkab);

	process (capture_clk)
	begin
		if rising_edge(capture_clk) then
			capture_dat <= std_logic_vector(shift_right(signed(not adc_db(adc_db'left) & adc_db(adc_db'left-1 downto 0)), adc_db'length-9));
		end if;
	end process;
--	capture_dat <= adc_db;

	scope_e : entity hdl4fpga.scope
	generic map (
		videoon => true,
		captureon =>  true,
		xd_len => 4,
		tDDR => (real(ddr_div)*sys_per)/real(ddr_mul),
		strobe => "EXTERNAL",
		ddr_std => 1)
	port map (
		sys_rst => scope_rst,

		capture_clk => capture_clk,
		capture_dat => capture_dat,

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
		ddr_dqi  => ddr_dq(data_size-1 downto 0),
		ddr_dqz  => ddr_dqz(data_size-1 downto 0),
		ddr_dqo  => ddr_dqo(data_size-1 downto 0),
		ddr_st_dqs => ddr_st,
		ddr_st_lp_dqs => ddr_lp,

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

	ddr_dq_e : for i in data_size-1 downto 0 generate
		ddr_dq(i) <= ddr_dqo(i) when ddr_dqz(i)='0' else 'Z';
	end generate;

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
