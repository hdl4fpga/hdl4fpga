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

entity ulx4m_ls is
	generic (
		debug : boolean := false);
	port (

		clk_25mhz       : in  std_logic := 'Z';
		btn             : in  std_logic_vector(0 to 7-1) := (others => '-');
		led             : out std_logic_vector(8-1 downto 0) := (others => 'Z');

		sd_clk          : out std_logic := '-';
		sd_enable       : out std_logic := '-';
		sd_cmd          : out std_logic;
		sd_d            : inout std_logic_vector(4-1 downto 0) := (others => 'U'); -- sd_d(0)=MISO (in), sd_d(3)=CSn (out)
		sd_wp           : in  std_logic := '-';
		sd_cdn          : in  std_logic := '-';

		usb_fpga_dp     : inout std_logic := 'Z';
		usb_fpga_dn     : inout std_logic := 'Z';
		usb_fpga_bd_dp  : inout std_logic := 'Z';
		usb_fpga_bd_dn  : inout std_logic := 'Z';
		usb_fpga_pu_dp  : inout std_logic := 'Z';
		usb_fpga_pu_dn  : inout std_logic := 'Z';
		usb_fpga_otg_id : inout std_logic := 'Z';
		n_extrst        : inout std_logic := 'Z';

		eth_nreset      : out std_logic;
		eth_mdio        : inout std_logic := '-';
		eth_mdc         : out std_logic;

		rmii_refclk    : out std_logic;
		rmii_nintclk   : in std_logic := '-';
		rmii_txen      : buffer std_logic;
		rmii_txd       : buffer std_logic_vector(0 to 2-1) := (others => 'Z');
		rmii_rxdv      : in  std_logic := '0';
		rmii_rxd       : in  std_logic_vector(0 to 2-1) := (others => '-');

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
		gpio            : inout std_logic_vector(0 to 28-1) := (others => 'Z');
		ftdi_txden      : out std_logic := '1';

		user_programn   : out std_logic := '1'; -- '0' loads next bitstream from SPI FLASH (e.g. bootloader)
		shutdown        : out std_logic := '0'); -- '1' power off the board, 10uA sleep

	alias cam_sda    : std_logic is gpio(0);
	alias cam_scl    : std_logic is gpio(1);
	alias ftdi_txd   : std_logic is gpio(23);
	alias ftdi_rxd   : std_logic is gpio(24);
	-- alias ftdi_txden : std_logic is gpio(20);

	alias hdmi0_blue  : std_logic is gpdi_d(0);
	alias hdmi0_green : std_logic is gpdi_d(1);
	alias hdmi0_red   : std_logic is gpdi_d(2);
	alias hdmi0_clock : std_logic is gpdi_d(3);

	constant clk25mhz_freq : real := 25.0e6;

end;
