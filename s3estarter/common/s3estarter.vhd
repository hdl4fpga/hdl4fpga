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
	port (
		xtal       : in std_logic := '0';
		sw0        : in std_logic := '1';
		hd_t_data  : inout std_logic := '1';
		hd_t_clock : in std_logic := '0';

		--------------
		-- switches --

		dip : in std_logic_vector(3 downto 0) := (others => 'Z');

		led0 : out std_logic := '0';
		led1 : out std_logic := '0';
		led2 : out std_logic := '0';
		led3 : out std_logic := '0';
		led4 : out std_logic := '0';
		led5 : out std_logic := '0';
		led6 : out std_logic := '0';
		led7 : out std_logic := '0';

		---------------
		-- Video DAC --
		
		-- hsync : out std_logic := '0';
		-- vsync : out std_logic := '0';
		-- clk_videodac : out std_logic := '1';
		-- blank : out std_logic := '0';
		-- sync  : out std_logic := '0';
		-- psave : out std_logic := '0';
		-- red   : out std_logic_vector(8-1 downto 0) := (others => '0');
		-- green : out std_logic_vector(8-1 downto 0) := (others => '0');
		-- blue  : out std_logic_vector(8-1 downto 0) := (others => '0');

		---------
		-- ADC --

		adc_clkab  : out std_logic := '0';
		adc_clkout : in std_logic := '0';
		adc_da     : in std_logic_vector(14-1 downto 0) := (others => '0');
		adc_db     : in std_logic_vector(14-1 downto 0) := (others => '0');

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


		-------------
		-- DDR RAM --

		sd_a          : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => '0');
		sd_dq         : inout std_logic_vector(16-1 downto 0);
		sd_ba         : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => '0');
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
		ddr_st_lp_dqs : in std_logic := 'Z';
		ddr_st_dqs    : out std_logic := 'Z';

		---------
		-- LCD --

		lcd_e         : out std_logic;
		lcd_rs        : out std_logic;
		lcd_rw        : out std_logic;
		lcd_data      : inout std_logic_vector(0 to 7);
		lcd_backlight : out std_logic
	
	);
		
	attribute loc : string;
	attribute iostandard : string;
	attribute fast : string;
	attribute slew : string;
	attribute nodelay : string;
	attribute drive : string;
	attribute pullup : string;

	attribute loc of xtal : signal is "C9";
	attribute loc of sw0  : signal is "L13";
	
	attribute iostandard of xtal : signal is "LVCMOS33";
	attribute iostandard of sw0 : signal is "LVCMOS33";

	attribute drive of xtal : signal is "4";

	attribute slew of xtal : signal is "slow";

	attribute loc of led0 : signal is "F12";
	attribute loc of led1 : signal is "E12";
	attribute loc of led2 : signal is "E11";
	attribute loc of led3 : signal is "F11";
	attribute loc of led4 : signal is "C11";
	attribute loc of led5 : signal is "D11";
	attribute loc of led6 : signal is "E9";
	attribute loc of led7 : signal is "F9";

	attribute iostandard of led0 : signal is "LVCMOS25";
	attribute iostandard of led1 : signal is "LVCMOS25";
	attribute iostandard of led2 : signal is "LVCMOS25";
	attribute iostandard of led3 : signal is "LVCMOS25";
	attribute iostandard of led4 : signal is "LVCMOS25";
	attribute iostandard of led5 : signal is "LVCMOS25";
	attribute iostandard of led6 : signal is "LVCMOS25";
	attribute iostandard of led7 : signal is "LVCMOS25";

	attribute drive of led0 : signal is "8";
	attribute drive of led1 : signal is "8";
	attribute drive of led2 : signal is "8";
	attribute drive of led3 : signal is "8";
	attribute drive of led4 : signal is "8";
	attribute drive of led5 : signal is "8";
	attribute drive of led6 : signal is "8";
	attribute drive of led7 : signal is "8";
	
	attribute slew of led0 : signal is "slow";
	attribute slew of led1 : signal is "slow";
	attribute slew of led2 : signal is "slow";
	attribute slew of led3 : signal is "slow";
	attribute slew of led4 : signal is "slow";
	attribute slew of led5 : signal is "slow";
	attribute slew of led6 : signal is "slow";
	attribute slew of led7 : signal is "slow";

	-- ---------------
	-- -- Video DAC --
		
	-- attribute loc of clk_videodac : signal is "M17";
	-- attribute loc of hsync : signal is "M22";
	-- attribute loc of vsync : signal is "N22";
	-- attribute loc of blank : signal is "K20";
	-- attribute loc of sync  : signal is "J20";
	-- attribute loc of psave : signal is "G22";
	-- attribute loc of red   : signal is "R22 T18 U18 U19 AA22 V20 W19 Y21";
	-- attribute loc of green : signal is "T22 U20 U22 N19 N20  W22 Y22 R18";
	-- attribute loc of blue  : signal is "P16 N17 P22 T17 P19  R19 R20 T20";
 
	-- attribute iostandard of clk_videodac : signal is "lvttl";
	-- attribute iostandard of blank : signal is "lvttl";
	-- attribute iostandard of sync  : signal is "lvttl";
	-- attribute iostandard of psave : signal is "lvttl";
	-- attribute iostandard of red   : signal is "lvttl";
	-- attribute iostandard of green : signal is "lvttl";
	-- attribute iostandard of blue  : signal is "lvttl";
	-- attribute iostandard of vsync : signal is "lvttl";
	-- attribute iostandard of hsync : signal is "lvttl";
	
	-- attribute fast of clk_videodac : signal is "true";
	-- attribute fast of red : signal is "true";
	-- attribute fast of blue : signal is "true";
	-- attribute fast of green : signal is "true";
	-- attribute fast of blank : signal is "true";
	-- attribute fast of hsync : signal is "true";
	-- attribute fast of vsync : signal is "true";
	-- attribute fast of sync : signal is "true";


	-- attribute drive of clk_videodac : signal is "24";
	-- attribute drive of vsync : signal is "24";
	-- attribute drive of hsync : signal is "24";
	-- attribute drive of blank : signal is "24";
	-- attribute drive of sync  : signal is "24";
	-- attribute drive of psave : signal is "24";
	-- attribute drive of red   : signal is "24";
	-- attribute drive of green : signal is "24";
	-- attribute drive of blue  : signal is "24";
	
	-- ---------
	-- -- LCD --

	-- attribute loc of lcd_backlight : signal is "D22";
	-- attribute loc of lcd_e : signal is "D20";
	-- attribute loc of lcd_rs : signal is "D21";
	-- attribute loc of lcd_rw : signal is "H17";
	-- attribute loc of lcd_data : signal is "J17 K18 K19 K22 L22 L17 M18 L20";

	-- attribute iostandard of lcd_backlight : signal is "lvttl";
	-- attribute iostandard of lcd_e : signal is "lvttl";
	-- attribute iostandard of lcd_rs : signal is "lvttl";
	-- attribute iostandard of lcd_rw : signal is "lvttl";
	-- attribute iostandard of lcd_data : signal is  "lvttl";

	-- attribute drive of lcd_backlight : signal is "24";
	-- attribute drive of lcd_e : signal is "24";
	-- attribute drive of lcd_rs : signal is "24";
	-- attribute drive of lcd_rw : signal is "24";
	-- attribute drive of lcd_data : signal is  "24";

	-- attribute fast of lcd_backlight : signal is "true";
	-- attribute fast of lcd_e : signal is "true";
	-- attribute fast of lcd_rs : signal is "true";
	-- attribute fast of lcd_rw : signal is "true";
	-- attribute fast of lcd_data : signal is  "true";

	-- ---------
	-- -- ADC --

	-- attribute loc of adc_clkab : signal is "A3";
	-- attribute loc of adc_clkout : signal is "B9";
	-- attribute loc of adc_da : signal is "E6 D6 D7 E7 D9  E8  F8  F9  G8  B4  A5  C5  B6  A6";
	-- attribute loc of adc_db : signal is "C6 A7 C7 C8 C9 A10 C10 A11 B11 D10 E10 A12 C12 F12";
	
	-- attribute iostandard of adc_clkab : signal is "lvttl";	
	-- attribute iostandard of adc_da : signal is "lvttl";
	-- attribute iostandard of adc_db : signal is "lvttl";
	-- attribute drive of adc_clkab : signal is "24";
	-- attribute drive of adc_da : signal is "24";
	-- attribute drive of adc_db : signal is "24";
	-- attribute fast of adc_clkab : signal is "true";

	-- -----------------------
	-- -- RS232 Transceiver --

	-- attribute loc of rs232_dcd : signal is "E17";
	-- attribute loc of rs232_dsr : signal is "F16";
	-- attribute loc of rs232_rd  : signal is "D18";
	-- attribute loc of rs232_rts : signal is "A17";
	-- attribute loc of rs232_td  : signal is "A16";
	-- attribute loc of rs232_cts : signal is "E15";
	-- attribute loc of rs232_dtr : signal is "B20";
	-- attribute loc of rs232_ri  : signal is "F15";

	-- attribute iostandard of rs232_dcd : signal is "lvttl";
	-- attribute iostandard of rs232_dsr : signal is "lvttl";
	-- attribute iostandard of rs232_rd  : signal is "lvttl";
	-- attribute iostandard of rs232_rts : signal is "lvttl";
	-- attribute iostandard of rs232_td  : signal is "lvttl";
	-- attribute iostandard of rs232_cts : signal is "lvttl";
	-- attribute iostandard of rs232_dtr : signal is "lvttl";
	-- attribute iostandard of rs232_ri  : signal is "lvttl";

	-- attribute drive of rs232_dcd : signal is "24";
	-- attribute drive of rs232_dsr : signal is "24";
	-- attribute drive of rs232_rd  : signal is "24";
	-- attribute drive of rs232_rts : signal is "24";
	-- attribute drive of rs232_td  : signal is "24";
	-- attribute drive of rs232_cts : signal is "24";
	-- attribute drive of rs232_dtr : signal is "24";
	-- attribute drive of rs232_ri  : signal is "24";

	--------------------------
	-- Ethernet Transceiver --

	attribute loc of e_mdc    	: signal is "P9";
	attribute loc of e_mdio   	: signal is "U5";
	attribute loc of e_tx_clk	: signal is "T7";
	attribute loc of e_txen		: signal is "P15";
	attribute loc of e_txd    	: signal is "R11 T15 R5 T5";
	attribute loc of e_txd_4	: signal is "R6";
	attribute loc of e_rxd    	: signal is "V8 T11 U11 V14";
	attribute loc of e_rx_clk   : signal is "V3";
	attribute loc of e_rx_dv   	: signal is "V2";
	attribute loc of e_rx_er   	: signal is "U14";
	attribute loc of e_crs    	: signal is "U13";
	attribute loc of e_col    	: signal is "U6";

	attribute iostandard of e_mdc    : signal is "LVCMOS33";
	attribute iostandard of e_mdio   : signal is "LVCMOS33";
	attribute iostandard of e_tx_clk : signal is "LVCMOS33";
	attribute iostandard of e_txen   : signal is "LVCMOS33";
	attribute iostandard of e_txd    : signal is "LVCMOS33";
	attribute iostandard of e_txd_4  : signal is "LVCMOS33";
	attribute iostandard of e_rx_clk : signal is "LVCMOS33";
	attribute iostandard of e_rx_dv  : signal is "LVCMOS33";
	attribute iostandard of e_rxd    : signal is "LVCMOS33";
	attribute iostandard of e_rx_er  : signal is "LVCMOS33";
	attribute iostandard of e_crs    : signal is "LVCMOS33";
	attribute iostandard of e_col    : signal is "LVCMOS33";

	-------------
	-- DDR RAM --

	attribute loc of sd_a	  : signal is "P2 N5 T2 N4 H2 H1 H3 H4 F4 P1 R2 R3 T1";
	attribute loc of sd_ck_p  : signal is "J5";
	attribute loc of sd_ck_n  : signal is "J4";
	attribute loc of sd_dq    : signal is "H5 H6 G5 G6 F2 F1 E1 E2 M6 M5 M4 M3 L4 L3 L1 L2";
	attribute loc of sd_ras   : signal is "C1";
	attribute loc of sd_cas   : signal is "C2";
	attribute loc of sd_we    : signal is "D1";
	attribute loc of sd_cke   : signal is "K3";
	attribute loc of sd_cs    : signal is "K4";

	attribute loc of sd_ck_fb : signal is "B9";
	attribute loc of sd_ba    : signal is "K6 K5";
	attribute loc of sd_dm    : signal is "J1 J2";
	attribute loc of sd_dqs   : signal is "G3 L6";

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
	attribute iostandard of sd_ck_fb : signal is "LVCMOS33";

	attribute nodelay of sd_ck_p  : signal is "true";
	attribute nodelay of sd_ck_n  : signal is "true";
	attribute nodelay of sd_ck_fb : signal is "true";
	attribute nodelay of sd_cke   : signal is "true";
	attribute nodelay of sd_cs    : signal is "true";
	attribute nodelay of sd_ras   : signal is "true";
	attribute nodelay of sd_cas   : signal is "true";
	attribute nodelay of sd_we    : signal is "true";
	attribute nodelay of sd_ba    : signal is "true";
	attribute nodelay of sd_a     : signal is "true";
	attribute nodelay of sd_dm    : signal is "true";
	attribute nodelay of sd_dqs   : signal is "true";

end;
