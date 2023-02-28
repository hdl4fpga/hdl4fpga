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

library ecp5u;
use ecp5u.components.all;

entity ulx4m_ls is
	generic (
		debug : boolean := false);
	port (

		clk_25mhz       : in  std_logic := 'Z';
		btn             : in  std_logic_vector(1 to 3) := (others => '-');
		led             : out std_logic_vector(8-1 downto 0) := (others => 'Z');

		sd_clk          : in  std_logic := '-';
		sd_cmd          : out std_logic; -- sd_cmd=MOSI (out)
		sd_d            : inout std_logic_vector(4-1 downto 0) := (others => 'U'); -- sd_d(0)=MISO (in), sd_d(3)=CSn (out)
		sd_wp           : in  std_logic := '-';
		sd_cdn          : in  std_logic := '-'; -- card detect not connected

		usb_fpga_d      : inout std_logic := 'Z';
		usb_fpga_bd_dp  : inout std_logic := 'Z';
		usb_fpga_bd_dn  : inout std_logic := 'Z';
		usb_fpga_pu_dp  : inout std_logic := 'Z';
		usb_fpga_pu_dn  : inout std_logic := 'Z';
		usb_fpga_otg_dp : inout std_logic := 'Z';
		usb_fpga_otg_dn : inout std_logic := 'Z';
		n_extrst        : inout std_logic := 'Z';

		eth_reset       : out std_logic;
		eth_mdio        : inout std_logic := '-';
		eth_mdc         : out std_logic;

--		rgmii_ref_clk   : in std_logic;

		rgmii_tx_clk    : out std_logic := '-';
		rgmii_tx_en     : buffer std_logic;
		rgmii_txd       : buffer std_logic_vector(0 to 4-1);
		rgmii_rx_clk    : in  std_logic := '-';
		rgmii_rx_dv     : in  std_logic := '-';
		rgmii_rxd       : in  std_logic_vector(0 to 4-1) := (others => '-');

		sdram_clk      : inout std_logic;  
		sdram_cke      : out   std_logic;
		sdram_csn      : out   std_logic;
		sdram_wen      : out   std_logic;
		sdram_rasn     : out   std_logic;
		sdram_casn     : out   std_logic;
		sdram_a        : out   std_logic_vector(13-1 downto 0);
		sdram_ba       : out   std_logic_vector(2-1 downto 0);
		sdram_dqm      : inout std_logic_vector(2-1 downto 0) := (others => 'U');
		sdram_d        : inout std_logic_vector(16-1 downto 0) := (others => 'U');

        gpdi_d          : out std_logic_Vector(4-1 downto 0);
        gpdi_cec        : out std_logic;
		gpio_scl        : out std_logic;

		gpio            : inout std_logic_vector(0 to 28-1)
		cam_scl         : out std_logic;
		cam_sda         : inout std_logic := 'Z';

		user_programn   : out std_logic := '1'; -- '0' loads next bitstream from SPI FLASH (e.g. bootloader)
		shutdown        : out std_logic := '0'); -- '1' power off the board, 10uA sleep

	constant clk25mhz_freq : real := 25.0e6;
	constant sys_freq      : real := clk25mhz_freq;

	alias ftdi_txden  : std_logic is gpio(20);
	alias ftdi_txd    : std_logic is gpio(23);
	alias ftdi_rxd    : std_logic is gpio(24);
	alias ftdi_nrts   : std_logic is gpio(22);
	alias ftdi_ndtr   : std_logic is gpio(5);

	alias rmii_tx_en  : std_logic is gn(10); B4
	alias rmii_tx0    : std_logic is gp(10); C4
	alias rmii_tx1    : std_logic is gn(9);  B1

	alias rmii_rx0    : std_logic is gn(11); E3
	alias rmii_rx1    : std_logic is gp(11); F4

	alias rmii_crs    : std_logic is gp(12); G3

	alias rmii_nint   : std_logic is gn(12); F3
	alias rmii_mdio   : std_logic is gn(13); G5
	alias rmii_mdc    : std_logic is gp(13); H4
	alias rmii_refclk : std_logic is gp(9);  A2

end;
