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

entity arty is
	generic (
		debug : boolean := false);
	port (
		gclk100      : in     std_logic;
		resetn       : in     std_logic := '1';

		ja           : inout  std_logic_vector(   1 to     10) := (others => 'Z');
		jb           : inout  std_logic_vector(   1 to     10) := (others => 'Z');
		jc           : inout  std_logic_vector(   1 to     10) := (others => 'Z');
		jd           : inout  std_logic_vector(   1 to     10) := (others => 'Z');
		vaux_p       : in     std_logic_vector(16-1 downto  0) := (others => 'Z');
		vaux_n       : in     std_logic_vector(16-1 downto  0) := (others => 'Z');
		v_p          : in     std_logic_vector(    0 to   1-1) := (others => 'Z');
		v_n          : in     std_logic_vector(    0 to   1-1) := (others => 'Z');
		btn          : in     std_logic_vector(  4-1 downto 0) := (others => '0');
		sw           : in     std_logic_vector(  4-1 downto 0) := (others => '0');
		led          : out    std_logic_vector(  4-1 downto 0);
		rgbled       : out    std_logic_vector(4*3-1 downto 0);

		uart_txd_in  : in     std_logic := 'Z';
		uart_rxd_out : out    std_logic;

		eth_rstn     : out    std_logic;
		eth_ref_clk  : out    std_logic;
		eth_mdio     : inout  std_logic := '-';
		eth_mdc      : out    std_logic;
		eth_crs      : in     std_logic := '-';
		eth_col      : in     std_logic := '-';
		eth_tx_clk   : in     std_logic := '-';
		eth_tx_en    : buffer std_logic;
		eth_txd      : buffer std_logic_vector(0 to 4-1);
		eth_rx_clk   : in     std_logic := '-';
		eth_rx_dv    : in     std_logic := '-';
		eth_rxd      : in     std_logic_vector(0 to 4-1) := (others => '-');
		eth_rxerr    : in     std_logic := '-';

		ddr3_reset   : out    std_logic := '0';
		ddr3_clk_p   : out    std_logic := '0';
		ddr3_clk_n   : out    std_logic := '0';
		ddr3_cke     : out    std_logic := '0';
		ddr3_cs      : out    std_logic := '1';
		ddr3_ras     : out    std_logic := '1';
		ddr3_cas     : out    std_logic := '1';
		ddr3_we      : out    std_logic := '1';
		ddr3_ba      : out    std_logic_vector( 3-1 downto 0) := (others => '1');
		ddr3_a       : out    std_logic_vector(14-1 downto 0) := (others => '1');
		ddr3_dm      : inout  std_logic_vector( 2-1 downto 0) := (others => 'Z');
		ddr3_dqs_p   : inout  std_logic_vector( 2-1 downto 0) := (others => 'Z');
		ddr3_dqs_n   : inout  std_logic_vector( 2-1 downto 0) := (others => 'Z');
		ddr3_dq      : inout  std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt     : out    std_logic := '1');

	alias btn0     : std_logic is btn(0);
	alias btn1     : std_logic is btn(1);
	alias btn2     : std_logic is btn(2);
	alias btn3     : std_logic is btn(3);

	alias sw0      : std_logic is sw(0);
	alias sw1      : std_logic is sw(1);
	alias sw2      : std_logic is sw(2);
	alias sw3      : std_logic is sw(3);

	alias led0_rgb : std_logic_vector(3-1 downto 0) is rgbled( 3-1 downto 0);
	alias led1_rgb : std_logic_vector(3-1 downto 0) is rgbled( 6-1 downto 3);
	alias led2_rgb : std_logic_vector(3-1 downto 0) is rgbled( 9-1 downto 6);
	alias led3_rgb : std_logic_vector(3-1 downto 0) is rgbled(12-1 downto 9);

	alias led0_r   : std_logic is rgbled(2);
	alias led0_g   : std_logic is rgbled(1);
	alias led0_b   : std_logic is rgbled(0);

	alias led1_r   : std_logic is rgbled(5);
	alias led1_g   : std_logic is rgbled(4);
	alias led1_b   : std_logic is rgbled(3);

	alias led2_r   : std_logic is rgbled(8);
	alias led2_g   : std_logic is rgbled(7);
	alias led2_b   : std_logic is rgbled(6);

	alias led3_r   : std_logic is rgbled(11);
	alias led3_g   : std_logic is rgbled(10);
	alias led3_b   : std_logic is rgbled(9);

	alias led0     : std_logic is led(0);
	alias led1     : std_logic is led(1);
	alias led2     : std_logic is led(2);
	alias led3     : std_logic is led(3);

	constant gclk100_per  : real := 10.0e-9;
	constant gclk100_freq : real := 1.0/(gclk100_per);

end;
