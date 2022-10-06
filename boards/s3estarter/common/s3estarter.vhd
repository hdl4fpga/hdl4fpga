--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--   Nicolas Alvarez                                                          --
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

entity s3estarter is
	generic (
		debug     : boolean := false);
	port (
		xtal      : in std_logic := '0';
		sw0       : in std_logic := '0';
		btn_north : in std_logic := '0';
		btn_east  : in std_logic := '0';
		btn_west  : in std_logic := '0';

		--------------
		-- switches --

		led0 : out std_logic := '0';
		led1 : out std_logic := '0';
		led2 : out std_logic := '0';
		led3 : out std_logic := '0';
		led4 : out std_logic := '0';
		led5 : out std_logic := '0';
		led6 : out std_logic := '0';
		led7 : out std_logic := '0';

		-----------------
		-- Rotary shat --

		rot_a      : in std_logic := '0';
		rot_b      : in std_logic := '0';
		rot_center : in std_logic := '0';

		------------------------------
		-- MII ethernet Transceiver --

		e_txd  	 : out std_logic_vector(0 to 3) := (others => 'Z');
		e_txen   : out std_logic := 'Z';
		e_txd_4  : out std_logic;
		e_tx_clk : in  std_logic := 'Z';

		e_rxd    : in std_logic_vector(0 to 4-1) := (others => 'Z');
		e_rx_dv  : in std_logic := 'Z';
		e_rx_er  : in std_logic := 'Z';
		e_rx_clk : in std_logic := 'Z';

		e_crs    : in std_logic := 'Z';
		e_col    : in std_logic := 'Z';

		e_mdc    : out std_logic := 'Z';
		e_mdio   : inout std_logic := 'Z';

		---------
		-- VGA --

		vga_red   : out std_logic;
		vga_green : out std_logic;
		vga_blue  : out std_logic;
		vga_hsync : out std_logic;
		vga_vsync : out std_logic;

		---------
		-- SPI --

		spi_sck  : out std_logic;
		spi_miso : in  std_logic;
		spi_mosi : out std_logic;

		---------
		-- AMP --

		amp_cs   : out std_logic := '0';
		amp_shdn : out std_logic := '0';
		amp_dout : in  std_logic;

		---------
		-- ADC --

		ad_conv  : out std_logic;

		-- StrataFlash --

		sf_ce0   : out std_logic;
		fpga_init_b : out std_logic;
		spi_ss_b : out std_logic;

		---------
		-- DAC --

		dac_cs  : out std_logic;
		dac_clr : out std_logic;

		-------------
		-- DDR RAM --

		sd_ba         : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => '0');
		sd_a          : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => '0');
		sd_dq         : inout std_logic_vector(16-1 downto 0);
		sd_ras        : out std_logic := '1';
		sd_cas        : out std_logic := '1';
		sd_we         : out std_logic := '0';
		sd_dm         : inout std_logic_vector(2-1 downto 0);
		sd_dqs        : inout std_logic_vector(2-1 downto 0);
		sd_cs         : out std_logic := '1';
		sd_cke        : out std_logic := '1';
		sd_ck_n       : out std_logic := '0';
		sd_ck_p       : out std_logic := '1';
		sd_ck_fb      : in std_logic := '0';

		rs232_dte_rxd : in  std_logic := 'Z';
		rs232_dte_txd : out std_logic := 'Z';
		rs232_dce_rxd : in  std_logic := 'Z';
		rs232_dce_txd : out std_logic := 'Z');

	constant xtal_per : real := 20.0e-9;
	constant sys_per  : real := xtal_per;

	attribute loc        : string;
	attribute iostandard : string;
	attribute fast       : string;
	attribute slew       : string;
	attribute nodelay    : string;
	attribute drive      : string;
	attribute pulldown   : string;
	attribute pullup     : string;

	attribute loc of xtal              : signal is "C9";
	attribute loc of sw0               : signal is "L13";
	attribute loc of btn_north         : signal is "V4";
	attribute loc of btn_east          : signal is "H3";
	attribute loc of btn_west          : signal is "D18";

	attribute iostandard of xtal       : signal is "LVCMOS33";
	attribute iostandard of sw0        : signal is "LVCMOS33";
	attribute iostandard of btn_north  : signal is "LVCMOS33";
	attribute iostandard of btn_east   : signal is "LVCMOS33";
	attribute iostandard of btn_west   : signal is "LVCMOS33";

	attribute pulldown   of xtal       : signal is "YES";
	attribute pulldown   of sw0        : signal is "YES";
	attribute pulldown   of btn_north  : signal is "YES";
	attribute pulldown   of btn_east   : signal is "YES";
	attribute pulldown   of btn_west   : signal is "YES";

	attribute drive      of xtal       : signal is "4";
	attribute slew       of xtal       : signal is "fast";

	attribute loc        of led0       : signal is "F12";
	attribute loc        of led1       : signal is "E12";
	attribute loc        of led2       : signal is "E11";
	attribute loc        of led3       : signal is "F11";
	attribute loc        of led4       : signal is "C11";
	attribute loc        of led5       : signal is "D11";
	attribute loc        of led6       : signal is "E9";
	attribute loc        of led7       : signal is "F9";

	attribute iostandard of led0       : signal is "LVCMOS25";
	attribute iostandard of led1       : signal is "LVCMOS25";
	attribute iostandard of led2       : signal is "LVCMOS25";
	attribute iostandard of led3       : signal is "LVCMOS25";
	attribute iostandard of led4       : signal is "LVCMOS25";
	attribute iostandard of led5       : signal is "LVCMOS25";
	attribute iostandard of led6       : signal is "LVCMOS25";
	attribute iostandard of led7       : signal is "LVCMOS25";

	attribute drive      of led0       : signal is "8";
	attribute drive      of led1       : signal is "8";
	attribute drive      of led2       : signal is "8";
	attribute drive      of led3       : signal is "8";
	attribute drive      of led4       : signal is "8";
	attribute drive      of led5       : signal is "8";
	attribute drive      of led6       : signal is "8";
	attribute drive      of led7       : signal is "8";

	attribute slew       of led0       : signal is "fast";
	attribute slew       of led1       : signal is "fast";
	attribute slew       of led2       : signal is "fast";
	attribute slew       of led3       : signal is "fast";
	attribute slew       of led4       : signal is "fast";
	attribute slew       of led5       : signal is "fast";
	attribute slew       of led6       : signal is "fast";
	attribute slew       of led7       : signal is "fast";

	attribute loc        of rot_a      : signal is "K18";
	attribute loc        of rot_b      : signal is "G18";
	attribute loc        of rot_center : signal is "V16";

	attribute iostandard of rot_a      : signal is "LVTTL";
	attribute iostandard of rot_b      : signal is "LVTTL";
	attribute iostandard of rot_center : signal is "LVTTL";

	attribute pullup     of rot_a      : signal is "yes";
	attribute pullup     of rot_b      : signal is "yes";
	attribute pulldown   of rot_center : signal is "yes";

	--------------------------
	-- Ethernet Transceiver --

	attribute loc        of e_mdc      : signal is "P9";
	attribute loc        of e_mdio     : signal is "U5";
	attribute loc        of e_tx_clk   : signal is "T7";
	attribute loc        of e_txen     : signal is "P15";
	attribute loc        of e_txd      : signal is "R11 T15 R5 T5";
	attribute loc        of e_txd_4    : signal is "R6";
	attribute loc        of e_rxd      : signal is "V8 T11 U11 V14";
	attribute loc        of e_rx_clk   : signal is "V3";
	attribute loc        of e_rx_dv    : signal is "V2";
	attribute loc        of e_rx_er    : signal is "U14";
	attribute loc        of e_crs      : signal is "U13";
	attribute loc        of e_col      : signal is "U6";

	attribute iostandard of e_mdc      : signal is "LVCMOS33";
	attribute iostandard of e_mdio     : signal is "LVCMOS33";
	attribute iostandard of e_tx_clk   : signal is "LVCMOS33";
	attribute iostandard of e_txen     : signal is "LVCMOS33";
	attribute iostandard of e_txd      : signal is "LVCMOS33";
	attribute iostandard of e_txd_4    : signal is "LVCMOS33";
	attribute iostandard of e_rx_clk   : signal is "LVCMOS33";
	attribute iostandard of e_rx_dv    : signal is "LVCMOS33";
	attribute iostandard of e_rxd      : signal is "LVCMOS33";
	attribute iostandard of e_rx_er    : signal is "LVCMOS33";
	attribute iostandard of e_crs      : signal is "LVCMOS33";
	attribute iostandard of e_col      : signal is "LVCMOS33";

	attribute slew       of e_mdc      : signal is "fast";
	attribute slew       of e_mdio     : signal is "fast";
	attribute slew       of e_txen     : signal is "fast";
	attribute slew       of e_txd      : signal is "fast";
	attribute slew       of e_txd_4    : signal is "fast";
	attribute slew       of e_rxd      : signal is "fast";

	-------------
	-- DDR RAM --

	attribute loc        of sd_a	 : signal is "P2 N5 T2 N4 H2 H1 H3 H4 F4 P1 R2 R3 T1";
	attribute loc        of sd_ck_p  : signal is "J5";
	attribute loc        of sd_ck_n  : signal is "J4";
	attribute loc        of sd_dq    : signal is "H5 H6 G5 G6 F2 F1 E1 E2 M6 M5 M4 M3 L4 L3 L1 L2";
	attribute loc        of sd_ras   : signal is "C1";
	attribute loc        of sd_cas   : signal is "C2";
	attribute loc        of sd_we    : signal is "D1";
	attribute loc        of sd_cke   : signal is "K3";
	attribute loc        of sd_cs    : signal is "K4";

	attribute loc        of sd_ck_fb : signal is "B9";
	attribute loc        of sd_ba    : signal is "K6 K5";
	attribute loc        of sd_dm    : signal is "J1 J2";
	attribute loc        of sd_dqs   : signal is "G3 L6";

	attribute iostandard of sd_dqs   : signal is "SSTL2_I";
	attribute iostandard of sd_dq    : signal is "SSTL2_I";
	attribute iostandard of sd_dm    : signal is "SSTL2_I";
	attribute iostandard of sd_we    : signal is "SSTL2_I";
	attribute iostandard of sd_cas   : signal is "SSTL2_I";
	attribute iostandard of sd_ras   : signal is "SSTL2_I";
	attribute iostandard of sd_cs    : signal is "SSTL2_I";
	attribute iostandard of sd_cke   : signal is "SSTL2_I";
	attribute iostandard of sd_ba    : signal is "SSTL2_I";
	attribute iostandard of sd_a     : signal is "SSTL2_I";
	attribute iostandard of sd_ck_p  : signal is "SSTL2_I";
	attribute iostandard of sd_ck_n  : signal is "SSTL2_I";
	attribute iostandard of sd_ck_fb : signal is "SSTL2_I";

	attribute nodelay    of sd_ck_p  : signal is "true";
	attribute nodelay    of sd_ck_n  : signal is "true";
	attribute nodelay    of sd_ck_fb : signal is "true";
	attribute nodelay    of sd_cke   : signal is "true";
	attribute nodelay    of sd_cs    : signal is "true";
	attribute nodelay    of sd_ras   : signal is "true";
	attribute nodelay    of sd_cas   : signal is "true";
	attribute nodelay    of sd_we    : signal is "true";
	attribute nodelay    of sd_ba    : signal is "true";
	attribute nodelay    of sd_a     : signal is "true";
	attribute nodelay    of sd_dm    : signal is "true";
	attribute nodelay    of sd_dqs   : signal is "true";

	attribute loc        of spi_sck      : signal is "U16";
	attribute loc        of spi_miso     : signal is "N10";
	attribute loc        of spi_mosi     : signal is "T4";
	attribute loc        of amp_cs       : signal is "N7";
	attribute loc        of amp_shdn     : signal is "P7";
	attribute loc        of amp_dout     : signal is "E18";
	attribute loc        of dac_cs       : signal is "N8";
	attribute loc        of dac_clr      : signal is "P8";
	attribute loc        of ad_conv      : signal is "P11";
	attribute loc        of sf_ce0       : signal is "D16";
	attribute loc        of fpga_init_b  : signal is "T3";
	attribute loc        of spi_ss_b     : signal is "U3";

	attribute iostandard of spi_sck     : signal is "LVCMOS33";
	attribute iostandard of spi_miso    : signal is "LVCMOS33";
	attribute iostandard of spi_mosi    : signal is "LVCMOS33";
	attribute iostandard of amp_cs      : signal is "LVCMOS33";
	attribute iostandard of amp_shdn    : signal is "LVCMOS33";
	attribute iostandard of amp_dout    : signal is "LVCMOS33";
	attribute iostandard of dac_cs      : signal is "LVCMOS33";
	attribute iostandard of dac_clr     : signal is "LVCMOS33";
	attribute iostandard of ad_conv     : signal is "LVCMOS33";
	attribute iostandard of sf_ce0      : signal is "LVCMOS33";
	attribute iostandard of fpga_init_b : signal is "LVCMOS33";
	attribute iostandard of spi_ss_b    : signal is "LVCMOS33";

	attribute drive      of spi_sck    : signal is "8";
	attribute drive      of spi_mosi   : signal is "8";
	attribute drive      of amp_cs     : signal is "6";
	attribute drive      of amp_shdn   : signal is "6";
	attribute drive      of amp_dout   : signal is "6";
	attribute drive      of dac_cs     : signal is "8";
	attribute drive      of dac_clr    : signal is "8";
	attribute drive      of ad_conv    : signal is "6";
	attribute drive      of sf_ce0     : signal is "4";
	attribute drive      of fpga_init_b : signal is "4";
	attribute drive      of spi_ss_b : signal is "6";

	attribute slew       of spi_sck    : signal is "slow";
	attribute slew       of spi_mosi   : signal is "slow";
	attribute slew       of amp_cs     : signal is "slow";
	attribute slew       of amp_shdn   : signal is "slow";
	attribute slew       of amp_dout   : signal is "slow";
	attribute slew       of dac_cs     : signal is "slow";
	attribute slew       of dac_clr    : signal is "slow";
	attribute slew       of ad_conv    : signal is "slow";
	attribute slew       of sf_ce0     : signal is "slow";
	attribute slew       of fpga_init_b : signal is "slow";
	attribute slew       of spi_ss_b   : signal is "slow";


	attribute loc   of vga_red   : signal is "H14";
	attribute loc   of vga_green : signal is "H15";
	attribute loc   of vga_blue  : signal is "G15";
	attribute loc   of vga_hsync : signal is "F15";
	attribute loc   of vga_vsync : signal is "F14";

	attribute iostandard of vga_red   : signal is "lvttl";
	attribute iostandard of vga_green : signal is "lvttl";
	attribute iostandard of vga_blue  : signal is "lvttl";
	attribute iostandard of vga_hsync : signal is "lvttl";
	attribute iostandard of vga_vsync : signal is "lvttl";

	attribute drive of vga_red   : signal is "8";
	attribute drive of vga_green : signal is "8";
	attribute drive of vga_blue  : signal is "8";
	attribute drive of vga_hsync : signal is "8";
	attribute drive of vga_vsync : signal is "8";

	attribute slew  of vga_red   : signal is "fast";
	attribute slew  of vga_green : signal is "fast";
	attribute slew  of vga_blue  : signal is "fast";
	attribute slew  of vga_hsync : signal is "fast";
	attribute slew  of vga_vsync : signal is "fast";

	attribute loc   of rs232_dte_rxd : signal is "U8";
	attribute loc   of rs232_dte_txd : signal is "M13";
	attribute loc   of rs232_dce_rxd : signal is "R7";
	attribute loc   of rs232_dce_txd : signal is "M14";

	attribute iostandard of rs232_dte_rxd : signal is "lvttl";
	attribute iostandard of rs232_dte_txd : signal is "lvttl";
	attribute iostandard of rs232_dce_rxd : signal is "lvttl";
	attribute iostandard of rs232_dce_txd : signal is "lvttl";

	attribute slew of rs232_dte_rxd : signal is "slow";
	attribute slew of rs232_dte_txd : signal is "slow";
	attribute slew of rs232_dce_rxd : signal is "slow";
	attribute slew of rs232_dce_txd : signal is "slow";

end;
