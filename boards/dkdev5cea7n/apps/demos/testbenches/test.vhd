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

architecture dk_dev_5cea7n_test of testbench is

	component dk_dev_5cea7n
		generic (
			debug                : boolean := false);
		port (
			clkin_50_fpga_top    : in std_logic := '0';
			clkin_50_fpga_right  : in std_logic := '0';
			diff_clkin_top_125_p : in std_logic := '0';
			diff_clkin_top_125_n : in std_logic := '0';
			diff_clkin_bot_125_p : in std_logic := '0';
			diff_clkin_bot_125_n : in std_logic := '0';

			uart_txd             : out std_logic;
			uart_rts             : out std_logic;
			uart_rxd             : in std_logic := '0';
			uart_cts             : in std_logic := '0';

			eneta_resetn         : in std_logic := '0';
			eneta_gtx_clk        : in std_logic := '0';
			eneta_tx_en          : out std_logic;
			eneta_tx_data        : out std_logic_vector(0 to 4-1);
			eneta_rx_dv          : in std_logic := '0';
			eneta_rx_data        : in std_logic_vector(0 to 4-1) := (others => '0');
			eneta_rx_clk         : in std_logic := '0';
			eneta_mdio           : inout std_logic := '0';
			eneta_mdc            : in std_logic := '0';
			eneta_intn           : in std_logic := '0';

			ddr3_resetn          : out   std_logic := '0';
			ddr3_clk_p           : out   std_logic := '0';
			ddr3_clk_n           : out   std_logic := '0';
			ddr3_cke             : out   std_logic := '0';
			ddr3_csn             : out   std_logic := '1';
			ddr3_rasn            : out   std_logic := '1';
			ddr3_casn            : out   std_logic := '1';
			ddr3_wen             : out   std_logic := '1';
			ddr3_ba              : out   std_logic_vector( 3-1 downto 0) := (others => '1');
			ddr3_a               : out   std_logic_vector(14-1 downto 0) := (others => '1');
			ddr3_dm              : inout std_logic_vector( 4-1 downto 0) := (others => 'Z');
			ddr3_dqs_p           : inout std_logic_vector( 4-1 downto 0) := (others => 'Z');
			ddr3_dqs_n           : inout std_logic_vector( 4-1 downto 0) := (others => 'Z');
			ddr3_dq              : inout std_logic_vector(32-1 downto 0) := (others => 'Z');
			ddr3_odt             : out   std_logic := '1');
	end component;
	
	signal clk : std_logic := '0';
	signal rst : std_logic;
begin

	clk <= not clk after 10 ns;
	rst <= '1', '0' after 1 us;
	du_e : dk_dev_5cea7n 
	port map (
		eneta_resetn => rst,
		clkin_50_fpga_top => clk);
end;

