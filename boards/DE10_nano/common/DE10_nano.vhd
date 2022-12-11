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

entity de10_nano is
	generic (
		debug : boolean := false);
	port (
		FPGA_CLK1_50 : in std_logic;
		FPGA_CLK2_50 : in std_logic;
		FPGA_CLK3_50 : in std_logic;
		HPS_CLK1_25 : in std_logic;
		HPS_CLK2_25 : in std_logic;

		hps_uart_rx      : in std_logic;
		hps_uart_tx      : out std_logic;

		hps_enet_reset_n : in std_logic;
		hps_enet_gtx_clk : in std_logic;
		hps_enet_tx_en   : out std_logic;
		hps_enet_tx_data : out std_logic_vector(0 to 4-1);
		hps_enet_rx_dv   : in std_logic;
		hps_enet_rx_data : in std_logic_vector(0 to 4-1);
		hps_enet_rx_clk  : in std_logic;
		hps_enet_mdio    : inout std_logic;
		hps_enet_mdc     : in std_logic;
		hps_enet_int_n   : in std_logic;

		hps_ddr3_reset_n : out   std_logic := '0';
		hps_ddr3_clk_p   : out   std_logic := '0';
		hps_ddr3_clk_n   : out   std_logic := '0';
		hps_ddr3_cke     : out   std_logic := '0';
		hps_ddr3_cs_n    : out   std_logic := '1';
		hps_ddr3_ras_n   : out   std_logic := '1';
		hps_ddr3_cas_n   : out   std_logic := '1';
		hps_ddr3_we_n    : out   std_logic := '1';
		hps_ddr3_ba      : out   std_logic_vector( 3-1 downto 0) := (others => '1');
		hps_ddr3_a       : out   std_logic_vector(14-1 downto 0) := (others => '1');
		hps_ddr3_dm      : inout std_logic_vector( 4-1 downto 0) := (others => 'Z');
		hps_ddr3_dqs_p   : inout std_logic_vector( 4-1 downto 0) := (others => 'Z');
		hps_ddr3_dqs_n   : inout std_logic_vector( 4-1 downto 0) := (others => 'Z');
		hps_ddr3_dq      : inout std_logic_vector(32-1 downto 0) := (others => 'Z');
		hps_ddr3_odt     : out   std_logic := '1');
	
	attribute chip_pin : string;

	attribute chip_pin of fpga_clk1_50     : signal is "V11";
	attribute chip_pin of fpga_clk2_50     : signal is "Y13";
	attribute chip_pin of fpga_clk3_50     : signal is "E11";
	attribute chip_pin of hps_clk1_25      : signal is "E20";
	attribute chip_pin of hps_clk2_25      : signal is "D20";

	attribute chip_pin of hps_enet_reset_n : signal is "B4";
	attribute chip_pin of hps_enet_gtx_clk : signal is "J15";
	attribute chip_pin of hps_enet_tx_en   : signal is "A12";
	attribute chip_pin of hps_enet_tx_data : signal is "A16 J14 A15 D17";
	attribute chip_pin of hps_enet_rx_dv   : signal is "J13";
	attribute chip_pin of hps_enet_rx_data : signal is "A14 A11 C15 A9";
	attribute chip_pin of hps_enet_rx_clk  : signal is "J12";
	attribute chip_pin of hps_enet_mdio    : signal is "E16";
	attribute chip_pin of hps_enet_mdc     : signal is "A13";
	attribute chip_pin of hps_enet_int_n   : signal is "B14";

	attribute chip_pin of hps_ddr3_reset_n : signal is "V28";
	attribute chip_pin of hps_ddr3_clk_p   : signal is "N21";
	attribute chip_pin of hps_ddr3_clk_n   : signal is "N20";
	attribute chip_pin of hps_ddr3_cke     : signal is "L28";
	attribute chip_pin of hps_ddr3_cs_n    : signal is "L21";
	attribute chip_pin of hps_ddr3_ras_n   : signal is "A25";
	attribute chip_pin of hps_ddr3_cas_n   : signal is "A26";
	attribute chip_pin of hps_ddr3_we_n    : signal is "E25";
	attribute chip_pin of hps_ddr3_ba      : signal is "G25 H25 A27";
	attribute chip_pin of hps_ddr3_a       : signal is "G23 C24 D24 B24 A24 F25 F26 B26 C26 J20 J21 D26 E26 B28 C28";
	attribute chip_pin of hps_ddr3_dm      : signal is "AB28 W28 P28 G28";
	attribute chip_pin of hps_ddr3_dqs_p   : signal is "U19 T19 R19 R17";
	attribute chip_pin of hps_ddr3_dqs_n   : signal is "T20 T18 R18 R16";
	attribute chip_pin of hps_ddr3_dq      : signal is "AA27 Y27 T24 R24 W26 AA28 R25 R26 V27 R27 N27 N26 U28 T28 N25 N24 N28 M28 M26 M27 J28 J27 L25 K25 F28 G27 K26 J26 D27 E28 J24 J25";
	attribute chip_pin of hps_ddr3_odt     : signal is "D28";

end;
