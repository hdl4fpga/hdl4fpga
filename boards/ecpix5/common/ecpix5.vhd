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

entity ecpix5 is
	generic (
		debug : boolean := false);
	port (
		fpga_sysclk  : in  std_logic;
		refclk100mhz : in  std_logic;
		rgbled       : out std_logic_vector(4*3-1 downto 0);
		uart_txd     : out std_logic;
		uart_rxd     : in  std_logic := 'Z';

		ddr_ck       : out std_logic := 'Z';
		ddr_cke      : out std_logic := 'Z';
		ddr_cas      : out std_logic := 'Z';
		ddr_ras      : out std_logic := 'Z';
		ddr_odt      : out std_logic := 'Z';
		ddr_we       : out std_logic := 'Z';
		ddr_ba       : out std_logic_vector( 3-1 downto 0) := 'Z';
		ddr_a        : out std_logic_vector(14-1 downto 0) := 'Z';
		ddr_d        : inout std_logic_vector(15-1 downto 0) := 'Z';
		ddr_dqs      : inout std_logic_vector(2-1 downto 0) := 'Z';
		ddr_dm       : out std_logic_vector(2-1 downto 0) := 'Z';

		hdmi_pclk    : out std_logic := 'Z';
		hdmi_scl     : out std_logic := 'Z';
		hdmi_sda     : inout std_logic := 'Z';
		hdmi_int     : in std_logic := 'Z';
		hdmi_hsync   : out std_logic := 'Z';
		hdmi_vsync   : out std_logic := 'Z';
		hdmi_de      : out std_logic := 'Z';
		hdmi_rgb     : out std_logic_vector(3*12-1 downto 0) := (others => 'Z');
 
		phy_rxd      : in  std_logic_vector(4-1 downto 0) := (others => 'Z');
		phy_rxdv     : in  std_logic := 'Z';
		phy_rxclk    : in  std_logic := 'Z';
		phy_txd      : out std_logic_vector(4-1 downto 0) := (others => 'Z');
		phy_txen     : out std_logic := 'Z';
		phy_gtxclk   : out std_logic := 'Z';
		phy_intn     : in  std_logic := 'Z';
		phy_mdc      : out std_logic := 'Z';
		phy_mdio     : inout std_logic := 'Z');

	alias rgbled0    is std_logic_vector( 3-1 downto 0) is rgbled(1*3-1 downto 0*3);
	alias rgbled1    is std_logic_vector( 3-1 downto 0) is rgbled(2*3-1 downto 1*3);
	alias rgbled2    is std_logic_vector( 3-1 downto 0) is rgbled(3*3-1 downto 2*3);
	alias rgbled3    is std_logic_vector( 3-1 downto 0) is rgbled(4*3-1 downto 3*3);

	alias hdmi_red   is std_logic_vector(12-1 downto 0) is rgbled(1*12-1 downto 0*12);
	alias hdmi_green is std_logic_vector(12-1 downto 0) is rgbled(2*12-1 downto 1*12);
	alias hdmi_blue  is std_logic_vector(12-1 downto 0) is rgbled(3*12-1 downto 2*12);
end;
