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

library hdl4fpga;
use hdl4fpga.std.all;

library ecp3;
use ecp3.components.all;

architecture miitx_dhcp of ecp3versa is
	signal mii_req        : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal eth_rxclk_bufg : std_logic;
	signal video_dot      : std_logic;
	signal video_vs       : std_logic;
	signal video_hs       : std_logic;
	signal video_clk      : std_logic;

	attribute oddrapps : string;
	attribute oddrapps of oddr_i : label is "SCLK_ALIGNED";
	signal en : std_logic;
	signal d  : std_logic_vector(phy1_tx_d'range);

	signal rxc  : std_logic;
	signal rxdv : std_logic;
	signal rxd  : std_logic_vector(phy1_tx_d'range);

	signal txc  : std_logic;
	signal txdv : std_logic;
	signal txd  : std_logic_vector(phy1_tx_d'range);
	signal rst  : std_logic;
	signal expansionx4_d : std_logic_vector(expansionx4'range);
begin

	rst <= fpga_gsrn;
	videodcm_b : block
		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKI  of PLL_I : label is "100.000000";
		attribute FREQUENCY_PIN_CLKOP of PLL_I : label is "150.000000";

		signal clkfb : std_logic;
		signal lock  : std_logic;
	begin
		pll_i : ehxpllf
        generic map (
			FEEDBK_PATH  => "CLKOP", CLKOK_BYPASS=> "DISABLED", 
			CLKOS_BYPASS => "DISABLED", CLKOP_BYPASS=> "DISABLED", 
			CLKOK_INPUT  => "CLKOP", DELAY_PWD=> "DISABLED", DELAY_VAL=>  0, 
			CLKOS_TRIM_DELAY=> 0, CLKOS_TRIM_POL=> "RISING", 
			CLKOP_TRIM_DELAY=> 0, CLKOP_TRIM_POL=> "RISING", 
			PHASE_DELAY_CNTL=> "STATIC", DUTY=>  8, PHASEADJ=> "0.0", 
			CLKOK_DIV=>  2, CLKOP_DIV=>  4, CLKFB_DIV=>  3, CLKI_DIV=>  2, 
			FIN=> "100.000000")
		port map (
			rst         => rst, 
			rstk        => '0',
			clki        => clk,
			wrdel       => '0',
			drpai3      => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3      => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3        => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb    => open,
			clkfb       => video_clk,
			clkop       => video_clk, 
			clkos       => open,
			clkok       => open,
			clkok2      => open,
			lock        => lock);
		led<= (others => lock);
	end block;

	txc <= phy1_125clk;
	process (fpga_gsrn, txc)
	begin
		if rising_edge(txc) then
			if fpga_gsrn='0' then
				mii_req <= '1';
			else
				mii_req <= '1';
			end if;
		end if;
	end process;

	rxc <= not phy1_rxc;
	process (rxc)
	begin
		if rising_edge(rxc) then
			rxdv <= phy1_rx_dv;
			rxd  <= phy1_rx_d;
		end if;
	end process;

	mii_debug_e : entity hdl4fpga.mii_debug
	port map (
		mii_req   => mii_req,
		mii_rxc   => rxc,
		mii_rxd   => rxd,
		mii_rxdv  => rxdv,
--		mii_rxc   => txc,  --rxc,
--		mii_rxd   => txd,  --rxd,
--		mii_rxdv  => txdv, --rxdv,
		mii_txc   => txc,
		mii_txd   => txd,
		mii_txdv  => txdv,

		video_clk => video_clk,
		video_dot => video_dot,
		video_hs  => video_hs,
		video_vs  => video_vs);
	
	process (txc)
	begin
		if rising_edge(txc) then
			phy1_tx_en <= txdv;
			phy1_tx_d  <= txd;
		end if;
	end process;

	oddr_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

	phy1_rst  <= '1';
	phy1_mdc  <= '0';
	phy1_mdio <= '0';

	expansionx4_d(3) <= video_dot;
	expansionx4_d(4) <= video_dot;
	expansionx4_d(5) <= video_dot;
	expansionx4_d(6) <= video_hs;
	expansionx4_d(7) <= video_vs;

	expansion_g : for i in expansionx4'range generate
	begin
		oreg : OFD1S3AX
		port map (
			sclk => video_clk,
			d    => expansionx4_d(i),
			q    => expansionx4(i));
	end generate;

end;
