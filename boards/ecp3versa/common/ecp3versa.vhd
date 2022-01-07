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

entity ecp3versa is
	generic (
		debug : boolean := false);
	port (
		clk  : in std_logic := 'Z';
		
		led : out std_logic_vector(7 downto 0) := (others => 'Z');
		seg : out std_logic_vector(0 to 14) := (others => 'Z');
		
		ddr3_clk : out std_logic := '0';
		ddr3_rst : out std_logic := '0';
		ddr3_cke : out std_logic := '0';
		ddr3_cs  : out std_logic := '1';
		ddr3_ras : out std_logic := '1';
		ddr3_cas : out std_logic := '1';
		ddr3_we  : out std_logic := '1';
		ddr3_b   : out std_logic_vector( 2 downto 0) := (others => '1');
		ddr3_a   : out std_logic_vector(12 downto 0) := (others => '1');
		ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt : out std_logic := '1';


		phy1_125clk : in    std_logic := '-';
		phy1_rst    : out   std_logic;
		phy1_coma   : out   std_logic := 'Z';
		phy1_mdio   : inout std_logic;
		phy1_mdc    : out   std_logic;
		phy1_gtxclk : out   std_logic;
		phy1_crs    : out   std_logic;
		phy1_col    : out   std_logic;
		phy1_txc    : in    std_logic := '-';
		phy1_tx_d   : out   std_logic_vector(0 to 8-1);
		phy1_tx_en  : out   std_logic;
		phy1_rxc    : in    std_logic := '-';
		phy1_rx_er  : in    std_logic := '-';
		phy1_rx_dv  : in    std_logic := '-';
		phy1_rx_d   : in    std_logic_vector(0 to 8-1) := (others => '-');
--
--		phy2_125clk : in std_logic;
--		phy2_rst : out std_logic;
--		phy2_coma : out std_logic;
--		phy2_mdio: inout std_logic;
--		phy2_mdc : out std_logic;
--		phy2_gtxclk : out std_logic;
--		phy2_crs : out std_logic;
--		phy2_col : out std_logic;
--		phy2_txc : out std_logic;
--		phy2_tx_d : out std_logic_vector(0 to 8-1);
--		phy2_tx_en : out std_logic;
--		phy2_rxc : in std_logic;
--		phy2_rx_er : in std_logic;
--		phy2_rx_dv : in std_logic;
--		phy2_rx_d : in std_logic_vector(0 to 8-1);

		expansionx4 : inout std_logic_vector(3 to 7);
		expansionx3 : inout std_logic_vector(4 to 8);
		fpga_gsrn : in std_logic := '-');
end;
