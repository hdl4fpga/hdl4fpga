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
		clk         : in std_logic := 'Z';

		dip         : in  std_logic_vector(8-1 downto  0) := (others => '0');
		led         : out std_logic_vector(  7 downto  0) := (others => 'Z');
		seg         : out std_logic_vector(  0     to 14) := (others => 'Z');
		
		ddr3_clk    : out std_logic := '0';
		ddr3_rst    : out std_logic := '0';
		ddr3_cke    : out std_logic := '0';
		ddr3_cs     : out std_logic := '1';
		ddr3_ras    : out std_logic := '1';
		ddr3_cas    : out std_logic := '1';
		ddr3_we     : out std_logic := '1';
		ddr3_b      : out std_logic_vector( 3-1 downto 0)   := (others => '1');
		ddr3_a      : out std_logic_vector(13-1 downto 0)   := (others => '1');
		ddr3_dm     : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
		ddr3_dqs    : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
		ddr3_dq     : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt    : out std_logic := '1';


		phy1_125clk : in  std_logic := '-';
		phy1_rst    : out std_logic;
		phy1_coma   : out std_logic := 'Z';
		phy1_mdio   : inout std_logic;
		phy1_mdc    : out std_logic;
		phy1_gtxclk : out std_logic;
		phy1_crs    : out std_logic;
		phy1_col    : out std_logic;
		phy1_txc    : out std_logic := '-';
		phy1_tx_d   : out std_logic_vector(0 to 8-1);
		phy1_tx_en  : out std_logic;
		phy1_rxc    : in  std_logic := '-';
		phy1_rx_er  : in  std_logic := '-';
		phy1_rx_dv  : in  std_logic := '-';
		phy1_rx_d   : in  std_logic_vector(0 to 8-1) := (others => '-');
--
--		phy2_125clk : in std_logic;
--		phy2_rst    : out std_logic;
--		phy2_coma   : out std_logic;
--		phy2_mdio   : inout std_logic;
--		phy2_mdc    : out std_logic;
--		phy2_gtxclk : out std_logic;
--		phy2_crs    : out std_logic;
--		phy2_col    : out std_logic;
--		phy2_txc    : out std_logic;
--		phy2_tx_d   : out std_logic_vector(0 to 8-1);
--		phy2_tx_en  : out std_logic;
--		phy2_rxc    : in std_logic;
--		phy2_rx_er  : in std_logic;
--		phy2_rx_dv  : in std_logic;
--		phy2_rx_d   : in std_logic_vector(0 to 8-1);

		expansionx4 : inout std_logic_vector(3 to 7);
		expansionx3 : inout std_logic_vector(4 to 8);
		fpga_gsrn   : in std_logic := '-');

	constant sys_freq : real := 100.0e6;

	alias d29    : std_logic is led(7);
	alias d28    : std_logic is led(6);
	alias d27    : std_logic is led(5);
	alias d26    : std_logic is led(4);
	alias d21    : std_logic is led(3);
	alias d22    : std_logic is led(2);
	alias d24    : std_logic is led(1);
	alias d25    : std_logic is led(0);

	alias seg_a  : std_logic is seg(0);
	alias seg_b  : std_logic is seg(1);
	alias seg_c  : std_logic is seg(2);
	alias seg_d  : std_logic is seg(3);
	alias seg_e  : std_logic is seg(4);
	alias seg_f  : std_logic is seg(5);
	alias seg_g  : std_logic is seg(13);
	alias seg_h  : std_logic is seg(6);

	alias seg_j  : std_logic is seg(7);
	alias seg_k  : std_logic is seg(8);
	alias seg_l  : std_logic is seg(9);
	alias seg_m  : std_logic is seg(10);
	alias seg_n  : std_logic is seg(11);
	alias seg_p  : std_logic is seg(12);
	alias seg_dp : std_logic is seg(14);

end;
