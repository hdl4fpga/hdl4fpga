-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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
