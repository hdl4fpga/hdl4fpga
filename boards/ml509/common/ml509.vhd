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

entity ml509 is
	generic (
		debug : boolean := false);
	port (
		user_clk       : in std_logic;

		-- cfg_addr_out : in std_logic_vector(2-1 downto 0);
		-- cpld_io_1 : in std_logic;

		clk_27mhz_fpga : in std_logic := '-';
		clk_33mhz_fpga : in std_logic := '-';
		clk_fpga_p     : in std_logic := '-';
		clk_fpga_n     : in std_logic := '-';

		ddr2_clk_p     : out std_logic_vector(2-1 downto 0);
		ddr2_clk_n     : out std_logic_vector(2-1 downto 0);
		ddr2_cs        : out std_logic_vector(2-1 downto 0);
		ddr2_cke       : out std_logic_vector(2-1 downto 0);
		ddr2_ras       : out std_logic;
		ddr2_cas       : out std_logic;
		ddr2_we        : out std_logic;
		ddr2_a         : out std_logic_vector(14-1 downto 0);
		ddr2_ba        : out std_logic_vector( 3-1 downto 0);
		ddr2_dqs_p     : inout std_logic_vector(8-1 downto 0);
		ddr2_dqs_n     : inout std_logic_vector(8-1 downto 0);
		ddr2_dm        : inout std_logic_vector(8-1 downto 0);
		ddr2_d         : inout std_logic_vector(64-1 downto 0);
		ddr2_odt       : out std_logic_vector( 2-1 downto 0);
		ddr2_scl       : out std_logic;
		ddr2_sda       : in  std_logic := 'Z';

		bus_error      : out std_logic_vector(2 downto 1);
		gpio_led       : out std_logic_vector(0 to 8-1);
		gpio_led_c     : out std_logic;
		gpio_led_e     : out std_logic;
		gpio_led_n     : out std_logic;
		gpio_led_s     : out std_logic;
		gpio_led_w     : out std_logic;
		gpio_sw_c      : in std_logic;
		gpio_sw_e      : in std_logic;
		gpio_sw_n      : in std_logic;
		gpio_sw_s      : in std_logic;
		gpio_sw_w      : in std_logic;

		phy_reset      : out std_logic;
		phy_col        : in std_logic;
		phy_crs        : in std_logic;
		phy_int        : in std_logic;		-- open drain
		phy_mdc        : out std_logic;
		phy_mdio       : inout std_logic;

		phy_rxclk      : in std_logic;
		phy_rxctl_rxdv : in std_logic;
		phy_rxd        : in std_logic_vector(0 to 8-1);
		phy_rxer       : in std_logic;

		phy_txc_gtxclk : out std_logic;
		phy_txclk      : in std_logic;
		phy_txctl_txen : buffer std_logic;
		phy_txd        : buffer std_logic_vector(0 to 8-1);
		phy_txer       : out std_logic;

		hdr1           : inout std_logic_vector(0 to 5-1) := (others => 'Z');

		iic_sda_video  : inout std_logic;
		iic_scl_video  : out std_logic;
		dvi_xclk_n     : out std_logic;
		dvi_xclk_p     : out std_logic;
		dvi_reset_b    : out std_logic;
		dvi_gpio1      : inout std_logic;
		dvi_de         : out std_logic;
		dvi_d          : out std_logic_vector(12-1 downto 0);
		dvi_v          : inout std_logic;
		dvi_h          : inout std_logic);

	constant clkfpga_freq : real := 200.0e6;
	constant clkfpga_per  : real := 1.0/(clkfpga_freq);

	constant userclk_freq : real := 100.0e6;
	constant userclk_per  : real := 1.0/(userclk_freq);

	attribute loc        : string;
	attribute iostandard : string;
	attribute nodelay    : string;

	attribute loc of user_clk   : signal is "AH15";
	attribute loc of clk_27mhz_fpga : signal is "AG18";
	attribute loc of clk_33mhz_fpga : signal is "AH17";
	attribute loc of clk_fpga_n : signal is "K19";
	attribute loc of clk_fpga_p : signal is "L19";

	attribute loc of bus_error  : signal is "T10 F6";
	attribute loc of gpio_led   : signal is "H18 L18 G15 AD26 G16 AD25 AD24 AE24";
	attribute loc of gpio_led_c : signal is "E8";
	attribute loc of gpio_led_e : signal is "AG23";
	attribute loc of gpio_led_n : signal is "AF13";
	attribute loc of gpio_led_s : signal is "AG12";
	attribute loc of gpio_led_w : signal is "AF23";
	attribute loc of gpio_sw_c  : signal is "AJ6";
	attribute loc of gpio_sw_e  : signal is "AK7";
	attribute loc of gpio_sw_n  : signal is "U8";
	attribute loc of gpio_sw_s  : signal is "V8";
	attribute loc of gpio_sw_w  : signal is "AJ7";

	attribute loc of phy_col    : signal is "B32";
	attribute loc of phy_crs    : signal is "E34";
	attribute loc of phy_int    : signal is "H20";
	attribute loc of phy_mdc    : signal is "H19";
	attribute loc of phy_mdio   : signal is "H13";
	attribute loc of phy_reset  : signal is "J14";
	attribute loc of phy_rxclk  : signal is "H17";
	attribute loc of phy_rxctl_rxdv : signal is "E32";
	attribute loc of phy_rxd    : signal is "A33 B33 C33 C32 D32 C34 D34 F33";
	attribute loc of phy_rxer   : signal is "E33";
	attribute loc of phy_txc_gtxclk : signal is "J16";
	attribute loc of phy_txclk  : signal is "K17";
	attribute loc of phy_txctl_txen : signal is "AJ10";
	attribute loc of phy_txd    : signal is "AF11 AE11 AH9 AH10 AG8 AH8 AG10 AG11";
	attribute loc of phy_txer   : signal is "AJ9";

	attribute loc of hdr1       : signal is "H33 F34 H34 G33 G32 H32 J32 J34";

	attribute loc of ddr2_clk_p : signal is "E28 AK29";
	attribute loc of ddr2_clk_n : signal is "F28 AJ29";
	attribute loc of ddr2_cs    : signal is "J29 L29";
	attribute loc of ddr2_cke   : signal is "U30 T28";
	attribute loc of ddr2_ras   : signal is "H30";
	attribute loc of ddr2_cas   : signal is "E31";
	attribute loc of ddr2_we    : signal is "K29";
	attribute loc of ddr2_odt   : signal is "F30 F31";
	attribute loc of ddr2_a     : signal is "H29 T31 R29 J31 R28 M31 P30 P31 L31 K31 P29 N29 M30 L30";
	attribute loc of ddr2_ba    : signal is "R31 J30 G31";
	attribute loc of ddr2_dqs_p : signal is "G27 H28 E26 Y28 AB31 AK26 AK28 AA29";
	attribute loc of ddr2_dqs_n : signal is "H27 G28 E27 Y29 AA31 AJ27 AK27 AA30";
	attribute loc of ddr2_d     : signal is "L24 L25 M25 J27 L26 J24 M26 G25 G26 H24 K28 K27 H25 F25 L28 M28 N28 P27 N25 T24 P26 N24 P25 R24 V24 W26 W25 V28 W24 Y26 Y27 V29 W27 V27 W29 AC30 V30 W31 AB30 AC29 AA25 AB27 AA24 AB26 AA26 AC27 AB25 AC28 AB28 AG28 AJ26 AG25 AA28 AH28 AF28 AH27 AE29 AD29 AF29 AJ30 AD30 AF31 AK31 AF30";
	attribute loc of ddr2_dm    : signal is "J25 F26 P24 V25 Y31   Y24 AE28 AJ31";
	attribute loc of ddr2_scl : signal is "E29";
	attribute loc of ddr2_sda : signal is "F29";

	attribute nodelay of ddr2_odt : signal is "true";

	attribute loc of iic_sda_video  : signal is "T29";
	attribute loc of iic_scl_video  : signal is "U27";
	attribute loc of dvi_xclk_p     : signal is "AL11";
	attribute loc of dvi_xclk_n     : signal is "AL10";
	attribute loc of dvi_gpio1      : signal is "N30";
	attribute loc of dvi_reset_b    : signal is "AK6";
	attribute loc of dvi_d          : signal is "AN14 AP14 AB10 AA10 AN13 AM13 AA8 AA9 AP12 AN12 AC8 AB8";
	attribute loc of dvi_de         : signal is "AE8";
	attribute loc of dvi_v          : signal is "AM11";
	attribute loc of dvi_h          : signal is "AM12";

end;