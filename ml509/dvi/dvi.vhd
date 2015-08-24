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

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture dvi of ml509 is
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

	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to nibble_size-1);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to nibble_size-1);

	signal video_clk : std_logic;
	signal video_clk90 : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

	signal sys_rst   : std_logic;
	signal scope_rst : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

begin

	sys_rst <= gpio_sw_c;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		sys_per => uclk_period)
	port map (
		sys_rst => sys_rst,
		sys_clk => user_clk,
		video_clk => video_clk,
		video_clk90 => video_clk90,
		dcm_lckd => dcm_lckd);

	dvi_reset <= dcm_lckd;

	video_vga_e : entity hdl4fpga.video_vga
	generic map (
		n => 12)
	port map (
		clk   => video_clk,
		frm   => vga_frm,
		hsync => vga_hsync,
		vsync => vga_vsync,
		don   => vga_blank);

	vga_iob_e : entity hdl4fpga.vga2ch7301c_iob
	port map (
		vga_clk   => video_clk,
		vga_clk90 => video_clk90,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_frm   => vga_frm,
		vga_blank => vga_blank,
		vga_red   => (others => '1'), --vga_red,
		vga_green => (others => '1'), --vga_green,
		vga_blue  => (others => '1'), --vga_blue,

		dvi_xclk_p => dvi_xclk_p,
		dvi_xclk_n => dvi_xclk_n,
		dvi_v => dvi_v,
		dvi_h => dvi_h,
		dvi_de => dvi_de,
		dvi_d => dvi_d);

	dvi_gpio1 <= '1';
	bus_error <= (others => 'Z');
	gpio_led <= (others => '0');
	gpio_led_c <= dcm_lckd;
	gpio_led_e <= '0';
	gpio_led_n <= '0';
	gpio_led_s <= '0';
	gpio_led_w <= '0';
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';
	ddr2_cs <= (others => '1');
  	ddr2_cke <= (others => '0');
   	ddr2_odt <= (others => 'Z');
	ddr2_dm <= (others => 'Z');
	ddr2_d <= (others => 'Z');
	ddr2_a <= (others => 'Z');
	ddr2_ba <= (others => 'Z');
	ddr2_cas <= 'Z';
	ddr2_ras <= 'Z';
	ddr2_we <= 'Z';
	ddr2_dqs_p <= (others => 'Z');
	ddr2_dqs_n <= (others => 'Z');
	ddr2_clk_n <= (others => 'Z');
	ddr2_clk_p <= (others => 'Z');

	phy_reset <= '0';
	phy_mdc   <= 'Z';
	phy_mdio  <= 'Z';

	phy_txc_gtxclk  <= '0';
	phy_txctl_txen  <= '0';
	phy_txd  <= (others => 'Z');
	phy_txer <= '0';


end;
