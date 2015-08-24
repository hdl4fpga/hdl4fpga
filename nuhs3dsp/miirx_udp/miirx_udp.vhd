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

use work.cgafont.all;
use work.std.all;

architecture miirx_udp of nuhs3dsp is

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

	signal rxd : nibble;
	signal cga_clk : std_logic;
	signal cga_row : std_logic_vector(11-1 downto 11-5);
	signal cga_col : std_logic_vector(6-1 downto 0);
	signal cga_ptr : std_logic_vector(11-1 downto 0);
	signal cga_we  : std_logic;
	signal cga_code : byte;
	signal miixc_lck : std_logic;

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

	mii_dfs_e : entity work.dfs
		generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => xtal_ibufg,
		dfs_clk => mii_refclk,
		dcm_lck => miixc_lck);

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
		sys_clk => cga_clk,
		sys_row => cga_ptr(cga_row'range),
		sys_col => cga_ptr(cga_col'range),
		sys_we  => cga_we,
		sys_code => cga_code,
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

	with rxd select
	cga_code <= 
		x"30" when x"0",
		x"31" when x"1",
		x"32" when x"2",
		x"33" when x"3",
		x"34" when x"4",
		x"35" when x"5",
		x"36" when x"6",
		x"37" when x"7",
		x"38" when x"8",
		x"39" when x"9",
		x"41" when x"a",
		x"42" when x"b",
		x"43" when x"c",
		x"44" when x"d",
		x"45" when x"e",
		x"46" when x"f",
		(others => '-') when others;

	process (cga_clk)
	begin
		if rising_edge(cga_clk) then
			if cga_we='0' then
				cga_ptr <= (others => '1');
			else
				cga_ptr <= std_logic_vector(unsigned(cga_ptr) - 1);
			end if;
		end if;
	end process;

	miirx_udp_e : entity work.miirx_mac
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => cga_clk,
		mii_txen => cga_we,
		mii_txd  => rxd );

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

	mii_rst   <= not miixc_lck; 

	mii_txen <= 'Z';
	mii_txd  <= (others => 'Z');

	--------------
	-- LEDs DAC --
		
	led18 <= 'Z';
	led16 <= 'Z';
	led15 <= 'Z';
	led13 <= miixc_lck;
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
