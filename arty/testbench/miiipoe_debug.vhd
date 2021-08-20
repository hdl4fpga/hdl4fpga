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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture arty_miiipoedebug of testbench is

	signal rst   : std_logic := '1';
	signal clk   : std_logic := '1';
	signal ref_clk : std_logic;
	signal ref_clk1 : std_logic;
	signal eth_txd : std_logic_vector(0 to 4-1);
	signal eth_tx_en : std_logic;

	signal btn0   : std_logic := '0';
	signal btn1   : std_logic := '0';

begin

	clk  <= not clk after 5 ns;
	rst  <= '1', '0' after 1000 ns;
	btn0 <= '0', '1' after 2000 ns;
	btn1 <= '0', '1' after 2000 ns;

	du_e : entity work.arty(miiipoe_debug)
	port map (
		resetn => rst,
		eth_tx_clk  => ref_clk ,
		eth_rx_clk  => ref_clk ,
		eth_ref_clk => ref_clk ,
		gclk100 => clk,
		eth_tx_en => eth_tx_en,
		eth_txd => eth_txd,
		sw => "0010",
		btn(0) => '0', --btn0,
		btn(1) => btn1,
		btn(2) => '0', --btn0,
		btn(3) => '0'); --btn1);

	ref_clk1 <= ref_clk;
	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk    => ref_clk1,
		mii_frm    => eth_tx_en,
		mii_irdy   => eth_tx_en,
		mii_data   => eth_txd);


end;
