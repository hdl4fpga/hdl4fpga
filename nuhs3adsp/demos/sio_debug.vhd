--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.cgafonts.all;

library unisim;
use unisim.vcomponents.all;

architecture mii_debug of nuhs3adsp is

	signal sys_clk   : std_logic;
	signal mii_req   : std_logic;
	signal vga_dot   : std_logic;
	signal vga_on    : std_logic;
	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;

	type video_params is record
		timing_id : videotiming_ids;
		dcm_mul   : natural;
		dcm_div   : natural;
	end record;

	type video_modes is (
		mode480p,
		mode600p, 
		mode1080p);

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		mode480p  => (timing_id => pclk25_00m640x480at60,    dcm_mul =>  3, dcm_div => 2),
		mode600p  => (timing_id => pclk40_00m800x600at60,    dcm_mul =>  2, dcm_div => 1),
		mode1080p => (timing_id => pclk140_00m1920x1080at60, dcm_mul => 15, dcm_div => 2));

	constant video_mode : video_modes := mode600p;

	signal mii_clk  : std_logic;
	signal dhcp_req : std_logic := '0';

	signal tp : std_logic_vector(1 to 4);
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => video_tab(video_mode).dcm_mul,
		dfs_div => video_tab(video_mode).dcm_div)
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
		dfs_clk => mii_clk);
	mii_refclk <= not mii_clk;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			dhcp_req <= not sw1;
		end if;
	end process;
	led7 <= dhcp_req;

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if sw1='0' then
				led18 <= '0';
				led8  <= '0';
			elsif mii_rxdv='1' then
				led18 <= '1';
			elsif tp(1)='1' then
				led8 <= '1';
			end if;
		end if;
	end process;

	ipv4acfg_req <= not sw1;
	udpdaisy_e : entity hdl4fpga.sio_dayudp
	generic map (
		default_ipv4a => x"c0_a8_00_0e")
	port map (
		ipv4acfg_req => ipv4acfg_req,

		phy_rxc   => mii_rxc,
		phy_rx_dv => mii_rxdv,
		phy_rx_d  => mii_rxd,

		phy_txc   => mii_txc,
		phy_col   => mii_col,
		phy_crs   => mii_crs,
		phy_tx_en => mii_txen,
		phy_tx_d  => mii_txd,
		txc_rxdv  => txc_rxdv,
	
		sio_clk   => sio_clk,
		si_frm    => sout_frm,
		si_irdy   => sout_irdy,
		si_trdy   => sout_trdy,
		si_data   => sout_data,

		so_frm  => sin_frm,
		so_irdy => sin_irdy,
		so_trdy => '1',
		so_data => sin_data,
		tp => tp(0 to 4-1));
	
	video_lat_e: entity hdl4fpga.align 
	generic map (
		n => 3,
		d => (0 to 3-1 => 4))
	port map (
		clk   => vga_clk,
		di(0) => vga_hsync,
		di(1) => vga_vsync,
		di(2) => vga_on,
		do(0) => hsync,
		do(1) => vsync,
		do(2) => blankn);

	psave <= '1';
	sync  <= 'Z';
	red   <= (others => vga_dot);
	green <= (others => vga_dot);
	blue  <= (others => vga_dot);

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
--	led8  <= '0';
--	led7  <= '0';

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

	adc_clkab <= 'Z';
end;
