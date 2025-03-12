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

entity nuhs3adsp is
	generic (
		debug    : boolean := false;
		clk_freq : real    := 20.0e6);
	port (
		clk : in std_logic := '0';

		sw1 : in std_logic := '1';

		hd_t_data  : inout std_logic := '1';
		hd_t_clock : in std_logic := '0';

		--------------
		-- switches --

		dip : in std_logic_vector(0 to 7) := (others => 'Z');

		led18 : out std_logic := '0';
		led16 : out std_logic := '0';
		led15 : out std_logic := '0';
		led13 : out std_logic := '0';
		led11 : out std_logic := '0';
		led9  : out std_logic := '0';
		led8  : out std_logic := '0';
		led7  : out std_logic := '0';

		---------------
		-- Video DAC --

		hsync : out std_logic := '0';
		vsync : out std_logic := '0';
		clk_videodac : out std_logic := '1';
		blankn : out std_logic := '1';
		sync  : out std_logic := '0';
		psave : out std_logic := '0';
		red   : out std_logic_vector(8-1 downto 0) := (others => '0');
		green : out std_logic_vector(8-1 downto 0) := (others => '0');
		blue  : out std_logic_vector(8-1 downto 0) := (others => '0');

		---------
		-- ADC --

		adc_clkab : out std_logic := '0';
		adc_clkout : in std_logic := '0';
		adc_da : in std_logic_vector(14-1 downto 0) := (others => '0');
		adc_db : in std_logic_vector(14-1 downto 0) := (others => '0');
		adc_daac_enable : in std_logic := '-';

		-----------------------
		-- RS232 Transceiver --

		rs232_dcd : in std_logic := '1';
		rs232_dsr : in std_logic := '1';
		rs232_rd  : in std_logic := '1';
		rs232_rts : out std_logic := '1';
		rs232_td  : out std_logic := '1';
		rs232_cts : in std_logic := '1';
		rs232_dtr : out std_logic := '1';
		rs232_ri  : in std_logic := '1';

		------------------------------
		-- MII ethernet Transceiver --

		mii_rstn  : out std_logic := 'Z';
		mii_refclk : out std_logic := '0';
		mii_intrp  : in std_logic := 'Z';

		mii_mdc  : out std_logic := 'Z';
		mii_mdio : inout std_logic := 'Z';

		mii_txc  : in  std_logic := 'Z';
		mii_txen : buffer std_logic := 'Z';
		mii_txd  : buffer std_logic_vector(0 to 4-1) := (others => 'Z');

		mii_rxc  : in std_logic := 'Z';
		mii_rxdv : in std_logic := 'Z';
		mii_rxer : in std_logic := 'Z';
		mii_rxd  : in std_logic_vector(0 to 4-1) := (others => 'Z');

		mii_crs  : in std_logic := '0';
		mii_col  : in std_logic := '0';

		-------------
		-- DDR RAM --

		ddr_ckp : out std_logic := '1';
		ddr_ckn : out std_logic := '0';
		ddr_lp_ckp : in std_logic := '0';
		ddr_lp_ckn : in std_logic := '1';
		ddr_st_lp_dqs : in std_logic := 'Z';
		ddr_st_dqs : out std_logic := 'Z';
		ddr_cke : out std_logic := '1';
		ddr_cs  : out std_logic := '1';
		ddr_ras : out std_logic := '1';
		ddr_cas : out std_logic := '1';
		ddr_we  : out std_logic := '0';
		ddr_ba  : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => '0');
		ddr_a   : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => '0');
		ddr_dm  : inout std_logic_vector(2-1 downto 0);
		ddr_dqs : inout std_logic_vector(2-1 downto 0);
		ddr_dq  : inout std_logic_vector(16-1 downto 0);

		---------
		-- LCD --

		lcd_e  : out std_logic;
		lcd_rs : out std_logic;
		lcd_rw : out std_logic;
		lcd_data : inout std_logic_vector(0 to 7);
		lcd_backlight : out std_logic);

	constant clk_per : real := 1.0/clk_freq;

	attribute loc : string;
	attribute iostandard : string;
	attribute fast : string;
	attribute nodelay : string;
	attribute drive : string;
	attribute pullup : string;
	attribute buffer_type : string;

	attribute loc of clk : signal is "F10";
	attribute loc of sw1  : signal is "A15";
	attribute loc of hd_t_data  : signal is "H22";
	attribute loc of hd_t_clock : signal is "F11";
	attribute loc of dip : signal is "AA6 AB15 W10 Y6 Y7 Y12 V10 AA8";

	attribute loc of led18 : signal is "A13";
	attribute loc of led16 : signal is "B15";
	attribute loc of led15 : signal is "A14";
	attribute loc of led13 : signal is "D13";
	attribute loc of led11 : signal is "E13";
	attribute loc of led9 :  signal is "C16";
	attribute loc of led8 :  signal is "D15";
	attribute loc of led7 :  signal is "A19";

	attribute iostandard of led18 : signal is "lvttl";
	attribute iostandard of led16 : signal is "lvttl";
	attribute iostandard of led15 : signal is "lvttl";
	attribute iostandard of led13 : signal is "lvttl";
	attribute iostandard of led11 : signal is "lvttl";
	attribute iostandard of led9 : signal is "lvttl";
	attribute iostandard of led8 : signal is "lvttl";
	attribute iostandard of led7 : signal is "lvttl";

	attribute drive of led18 : signal is "24";
	attribute drive of led16 : signal is "24";
	attribute drive of led15 : signal is "24";
	attribute drive of led13 : signal is "24";
	attribute drive of led11 : signal is "24";
	attribute drive of led9 : signal is "24";
	attribute drive of led8 : signal is "24";
	attribute drive of led7 : signal is "24";

	attribute fast of led18 : signal is "true";
	attribute fast of led16 : signal is "true";
	attribute fast of led15 : signal is "true";
	attribute fast of led13 : signal is "true";
	attribute fast of led11 : signal is "true";
	attribute fast of led9 : signal is "true";
	attribute fast of led8 : signal is "true";
	attribute fast of led7 : signal is "true";

	---------------
	-- Video DAC --

	attribute loc of clk_videodac : signal is "M17";
	attribute loc of hsync : signal is "M22";
	attribute loc of vsync : signal is "N22";
	attribute loc of blankn : signal is "K20";
	attribute loc of sync  : signal is "J20";
	attribute loc of psave : signal is "G22";
	attribute loc of red   : signal is "R22 T18 U18 U19 AA22 V20 W19 Y21";
	attribute loc of green : signal is "T22 U20 U22 N19 N20  W22 Y22 R18";
	attribute loc of blue  : signal is "P16 N17 P22 T17 P19  R19 R20 T20";

	attribute iostandard of clk_videodac : signal is "lvttl";
	attribute iostandard of blankn : signal is "lvttl";
	attribute iostandard of sync  : signal is "lvttl";
	attribute iostandard of psave : signal is "lvttl";
	attribute iostandard of red   : signal is "lvttl";
	attribute iostandard of green : signal is "lvttl";
	attribute iostandard of blue  : signal is "lvttl";
	attribute iostandard of vsync : signal is "lvttl";
	attribute iostandard of hsync : signal is "lvttl";

	attribute fast of clk_videodac : signal is "true";
	attribute fast of red : signal is "true";
	attribute fast of blue : signal is "true";
	attribute fast of green : signal is "true";
	attribute fast of blankn : signal is "true";
	attribute fast of hsync : signal is "true";
	attribute fast of vsync : signal is "true";
	attribute fast of sync : signal is "true";


	attribute drive of clk_videodac : signal is "24";
	attribute drive of vsync : signal is "24";
	attribute drive of hsync : signal is "24";
	attribute drive of blankn : signal is "24";
	attribute drive of sync  : signal is "24";
	attribute drive of psave : signal is "24";
	attribute drive of red   : signal is "24";
	attribute drive of green : signal is "24";
	attribute drive of blue  : signal is "24";

	---------
	-- LCD --

	attribute loc of lcd_backlight : signal is "D22";
	attribute loc of lcd_e : signal is "D20";
	attribute loc of lcd_rs : signal is "D21";
	attribute loc of lcd_rw : signal is "H17";
	attribute loc of lcd_data : signal is "J17 K18 K19 K22 L22 L17 M18 L20";

	attribute iostandard of lcd_backlight : signal is "lvttl";
	attribute iostandard of lcd_e : signal is "lvttl";
	attribute iostandard of lcd_rs : signal is "lvttl";
	attribute iostandard of lcd_rw : signal is "lvttl";
	attribute iostandard of lcd_data : signal is  "lvttl";

	attribute drive of lcd_backlight : signal is "24";
	attribute drive of lcd_e : signal is "24";
	attribute drive of lcd_rs : signal is "24";
	attribute drive of lcd_rw : signal is "24";
	attribute drive of lcd_data : signal is  "24";

	attribute fast of lcd_backlight : signal is "true";
	attribute fast of lcd_e : signal is "true";
	attribute fast of lcd_rs : signal is "true";
	attribute fast of lcd_rw : signal is "true";
	attribute fast of lcd_data : signal is  "true";

	---------
	-- ADC --

	attribute loc of adc_clkab : signal is "A3";
	attribute loc of adc_clkout : signal is "B9";
	attribute loc of adc_da : signal is "E6 D6 D7 E7 D9  E8  F8  F9  G8  B4  A5  C5  B6  A6";
	attribute loc of adc_db : signal is "C6 A7 C7 C8 C9 A10 C10 A11 B11 D10 E10 A12 C12 F12";
	attribute loc of adc_daac_enable : signal is "A20";

	attribute iostandard of adc_clkab : signal is "lvttl";
	attribute iostandard of adc_da : signal is "lvttl";
	attribute iostandard of adc_db : signal is "lvttl";
	attribute iostandard of adc_daac_enable : signal is "lvttl";
	attribute drive of adc_clkab : signal is "24";
	attribute drive of adc_da : signal is "24";
	attribute drive of adc_db : signal is "24";
	attribute fast of adc_clkab : signal is "true";
	attribute nodelay of adc_da : signal is "true";
	attribute nodelay of adc_db : signal is "true";
--	attribute buffer_type of adc_clkout : signal is "ibuf";

	-----------------------
	-- RS232 Transceiver --

	attribute loc of rs232_dcd : signal is "E17";
	attribute loc of rs232_dsr : signal is "F16";
	attribute loc of rs232_rd  : signal is "D18";
	attribute loc of rs232_rts : signal is "A17";
	attribute loc of rs232_td  : signal is "A16";
	attribute loc of rs232_cts : signal is "E15";
	attribute loc of rs232_dtr : signal is "B20";
	attribute loc of rs232_ri  : signal is "F15";

	attribute iostandard of rs232_dcd : signal is "lvttl";
	attribute iostandard of rs232_dsr : signal is "lvttl";
	attribute iostandard of rs232_rd  : signal is "lvttl";
	attribute iostandard of rs232_rts : signal is "lvttl";
	attribute iostandard of rs232_td  : signal is "lvttl";
	attribute iostandard of rs232_cts : signal is "lvttl";
	attribute iostandard of rs232_dtr : signal is "lvttl";
	attribute iostandard of rs232_ri  : signal is "lvttl";

	attribute drive of rs232_dcd : signal is "24";
	attribute drive of rs232_dsr : signal is "24";
	attribute drive of rs232_rd  : signal is "24";
	attribute drive of rs232_rts : signal is "24";
	attribute drive of rs232_td  : signal is "24";
	attribute drive of rs232_cts : signal is "24";
	attribute drive of rs232_dtr : signal is "24";
	attribute drive of rs232_ri  : signal is "24";

	--------------------------
	-- Ethernet Transceiver --

	attribute loc of mii_mdc    : signal is "N21";
	attribute loc of mii_mdio   : signal is "E20";
	attribute loc of mii_txc    : signal is "M20";
	attribute loc of mii_txen   : signal is "E22";
	attribute loc of mii_txd    : signal is "F22 H20 J19 F20";
	attribute loc of mii_rxd    : signal is "J21 J22 H21 G20";
	attribute loc of mii_rxc    : signal is "L21";
	attribute loc of mii_rxdv   : signal is "V22";
	attribute loc of mii_rxer   : signal is "E19";
	attribute loc of mii_crs    : signal is "G19";
	attribute loc of mii_col    : signal is "U21";
	attribute loc of mii_intrp  : signal is "K16";
	attribute loc of mii_rstn   : signal is "G18";
	attribute loc of mii_refclk : signal is "N18";

	attribute iostandard of mii_mdc    : signal is "lvttl";
	attribute iostandard of mii_mdio   : signal is "lvttl";
	attribute iostandard of mii_txc    : signal is "lvttl";
	attribute iostandard of mii_txen   : signal is "lvttl";
	attribute iostandard of mii_txd    : signal is "lvttl";
	attribute iostandard of mii_rxc    : signal is "lvttl";
	attribute iostandard of mii_rxdv   : signal is "lvttl";
	attribute iostandard of mii_rxd    : signal is "lvttl";
	attribute iostandard of mii_rxer   : signal is "lvttl";
	attribute iostandard of mii_crs    : signal is "lvttl";
	attribute iostandard of mii_col    : signal is "lvttl";
	attribute iostandard of mii_intrp  : signal is "lvttl";
	attribute iostandard of mii_rstn   : signal is "lvttl";
	attribute iostandard of mii_refclk : signal is "lvttl";

	-------------
	-- DDR RAM --

	attribute loc of ddr_ckp : signal is "AB13";
	attribute loc of ddr_ckn : signal is "AA14";
	attribute loc of ddr_lp_ckp : signal is "U4";
	attribute loc of ddr_lp_ckn : signal is "U5";
	attribute loc of ddr_st_lp_dqs : signal is "AB5";
	attribute loc of ddr_st_dqs : signal is "AB6";
	attribute loc of ddr_cke : signal is "V11";
	attribute loc of ddr_cs  : signal is "Y9";
	attribute loc of ddr_ras : signal is "Y8";
	attribute loc of ddr_cas : signal is "AA10";
	attribute loc of ddr_we  : signal is "AB10";
	attribute loc of ddr_ba  : signal is "AA15 U10";
	attribute loc of ddr_a   : signal is "U14 U15 Y19 Y18 AA20 AB20 Y15 AB18 AB17 W14 Y13 U13 AB14";
	attribute loc of ddr_dm  : signal is "R6 U1";
	attribute loc of ddr_dqs : signal is "N1 V1";
	attribute loc of ddr_dq  : signal is "M2 L3 N7 M6 N5 P1 P2 P6 T5 T6 R5 T1 T4 R3 W1 Y1";
	-- attribute buffer_type of ddr_dqs : signal is "none";

	attribute iostandard of ddr_st_dqs : signal is "SSTL2_I";
	attribute iostandard of ddr_st_lp_dqs : signal is "SSTL2_I";
	attribute iostandard of ddr_dqs : signal is "SSTL2_I";
	attribute iostandard of ddr_dq  : signal is "SSTL2_I";
	attribute iostandard of ddr_dm  : signal is "SSTL2_I";
	attribute iostandard of ddr_we  : signal is "SSTL2_I";
	attribute iostandard of ddr_cas : signal is "SSTL2_I";
	attribute iostandard of ddr_ras : signal is "SSTL2_I";
	attribute iostandard of ddr_cs  : signal is "SSTL2_I";
	attribute iostandard of ddr_cke : signal is "SSTL2_I";
	attribute iostandard of ddr_ba  : signal is "SSTL2_I";
	attribute iostandard of ddr_a   : signal is "SSTL2_I";
	attribute iostandard of ddr_ckp : signal is "SSTL2_I";
	attribute iostandard of ddr_ckn : signal is "SSTL2_I";
	attribute iostandard of ddr_lp_ckp : signal is "SSTL2_I";
	attribute iostandard of ddr_lp_ckn : signal is "SSTL2_I";

	attribute nodelay of ddr_ckp : signal is "true";
	attribute nodelay of ddr_ckn : signal is "true";
	attribute nodelay of ddr_lp_ckp : signal is "true";
	attribute nodelay of ddr_lp_ckn : signal is "true";
	attribute nodelay of ddr_st_lp_dqs : signal is "true";
	attribute nodelay of ddr_st_dqs : signal is "true";
	attribute nodelay of ddr_cke : signal is "true";
	attribute nodelay of ddr_cs  : signal is "true";
	attribute nodelay of ddr_ras : signal is "true";
	attribute nodelay of ddr_cas : signal is "true";
	attribute nodelay of ddr_we  : signal is "true";
	attribute nodelay of ddr_ba  : signal is "true";
	attribute nodelay of ddr_a   : signal is "true";
	attribute nodelay of ddr_dm  : signal is "true";
	attribute nodelay of ddr_dqs : signal is "true";

--	attribute nodelay of ddr_dq  : signal is "true";

end;
