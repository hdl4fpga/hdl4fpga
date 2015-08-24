--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

use work.cgafont.all;

architecture cga of nuhs3dsp is

	signal locked : std_logic;
	signal xtal_ibufg : std_logic;

	signal vga_clk : std_logic;
	signal vga_frm : std_logic;
	signal vga_don : std_logic;
	signal vga_dot : std_logic;
	signal vga_vcntr : std_logic_vector(11-1 downto 0);
	signal vga_hcntr : std_logic_vector(11-1 downto 0);
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;

	signal sys_row : std_logic_vector(6-1 downto 1);
	signal sys_col : std_logic_vector(7-1 downto 1);

	signal pixel : std_logic_vector (8-1 downto 0);

begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => xtal_ibufg);

	ddr_dcm	: entity work.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 15,
		dfs_div => 2)
	port map (
		dcm_rst => '0',
		dcm_clk => xtal_ibufg,
		dfs_clk => vga_clk,
		dcm_lck => locked);

	video_vga_e : entity work.video_vga
	generic map (
		n => 11)
	port map (
		clk   => vga_clk,
		hsync => vga_hsync,
		hcntr => vga_hcntr,
		vsync => vga_vsync,
		vcntr => vga_vcntr,
		frm   => vga_frm,
		don   => vga_don);
	vga_blank <= vga_don and vga_frm;
		
	cga_e : entity work.cga
	generic map (
		bitrom => psf1cp850x8x16,
		height => 16,
		width  => 8,
		row_reverse => true,
		col_reverse => true)
	port map (
		sys_clk => vga_clk,
		sys_row => vga_vcntr(sys_row'range),
		sys_col => vga_hcntr(sys_col'range),
		sys_we  => '0',
		sys_code => x"41",
		vga_clk => vga_clk,
		vga_row => vga_vcntr(10-1 downto 1),
		vga_col => vga_hcntr(10-1 downto 1),
		vga_dot => vga_dot);

	pixel <= (others => vga_dot);
	vga_iob_e : entity work.vga_iob
	port map (
		sys_clk   => vga_clk,
		sys_hsync => vga_hsync,
		sys_vsync => vga_vsync,
		sys_sync  => '1',
		sys_psave => '1',
		sys_blank => vga_blank,
		sys_red   => pixel,
		sys_green => pixel,
		sys_blue  => pixel,

		vga_clk => clk_videodac,
		vga_hsync => hsync,
		vga_vsync => vsync,
		dac_blank => blank,
		dac_sync  => sync,
		dac_psave => psave,

		dac_red   => red,
		dac_green => green,
		dac_blue  => blue);

	hd_t_data <= 'Z';

	-------------
	-- DDR RAM --

	ddr_ckp <= 'Z';
	ddr_ckn <= 'Z';
	ddr_lp_dqs <= 'Z'; 
	ddr_cke <= 'Z';  
	ddr_cs  <= 'Z';  
	ddr_ras <= 'Z';
	ddr_cas <= 'Z';
	ddr_cas <= 'Z';
	ddr_we  <= 'Z';
	ddr_a   <= (others => 'Z');
	ddr_ba  <= (others => 'Z');
	ddr_dm  <= (others => 'Z');
	ddr_dqs <= (others => 'Z');
	ddr_dq  <= (others => 'Z');

	-- Ethernet Transceiver --
	--------------------------

	mii_mdc  <= 'Z';
	mii_mdio <= 'Z';

	mii_rst   <= 'Z'; 
	mii_refclk<= 'Z';

	mii_txen <= 'Z';
	mii_txd  <= (others => 'Z');

	--------------
	-- LEDs DAC --
		
	led18 <= 'Z';
	led16 <= 'Z';
	led15 <= 'Z';
	led13 <= 'Z';
	led11 <= 'Z';
	led9  <= 'Z';
	led8  <= 'Z';
	led7  <= 'Z';

	---------------
	-- Video DAC --
		
	hsync <= 'Z';
	vsync <= 'Z';
	clk_videodac <= 'Z';
	blank <= 'Z';
	sync  <= 'Z';
	psave <= 'Z';
	red   <= (others => 'Z');
	green <= (others => 'Z');
	blue  <= (others => 'Z');

	---------
	-- ADC --

	adc_clkab <= 'Z';

	-----------------------
	-- RS232 Transceiver --

	rs232_rts <= 'Z';
	rs232_td  <= 'Z';
	rs232_dtr <= 'Z';

	lcd_e <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';
end;
