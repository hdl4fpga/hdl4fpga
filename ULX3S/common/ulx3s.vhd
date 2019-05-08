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

entity ulx3s is
	port (
		clk_25mhz      : in    std_logic;

		ftdi_rxd       : out   std_logic;
		ftdi_txd       : in    std_logic;
		ftdi_nrts      : inout std_logic;
		ftdi_ndtr      : inout std_logic;
		ftdi_txden     : inout std_logic;

		led            : out   std_logic_vector(8-1 downto 0);
		btn            : in    std_logic_vector(7-1 downto 0);
		sw             : in    std_logic_vector(4-1 downto 0);


		oled_clk       : out   std_logic;
		oled_mosi      : out   std_logic;
		oled_dc        : out   std_logic;
		oled_resn      : out   std_logic;
		oled_csn       : out   std_logic;

		flash_csn      : out   std_logic;
		flash_clk      : out   std_logic;
		flash_mosi     : out   std_logic;
		flash_miso     : in    std_logic;
		flash_holdn    : std_logic;
		flash_wpn      : std_logic;

		sd_clk         : in  std_logic;
		sd_cmd         : in  std_logic;
		sd_d           : inout std_logic_vector(4-1 downto 0);
		sd_wp          : std_logic;
		sd_cdn         : std_logic;

		adc_csn        : std_logic;
		adc_mosi       : std_logic;
		adc_miso       : std_logic;
		adc_sclk       : std_logic;

		audio_l        : out   std_logic_vector(4-1 downto 0);
		audio_r        : out   std_logic_vector(4-1 downto 0);
		audio_v        : out   std_logic_vector(4-1 downto 0);

		wifi_en        : inout std_logic;
		wifi_rxd       : out   std_logic;
		wifi_txd       : in    std_logic;
		wifi_gpio0     : inout std_logic;
		wifi_gpio5     : inout std_logic;
		wifi_gpio16    : inout std_logic;
		wifi_gpio17    : inout std_logic;

		ant_433mhz     : std_logic;

		usb_fpga_dp    : in    std_logic;  
		usb_fpga_dn    : in    std_logic;
		usb_fpga_bd_dp : inout std_logic;
		usb_fpga_bd_dn : inout std_logic;
		usb_fpga_pu_dp : inout std_logic;
		usb_fpga_pu_dn : inout std_logic;
					   
		sdram_clk      : out   std_logic;  
		sdram_cke      : out   std_logic;
		sdram_csn      : out   std_logic;
		sdram_wen      : out   std_logic;
		sdram_rasn     : out   std_logic;
		sdram_casn     : out   std_logic;
		sdram_a        : out   std_logic_vector(13-1 downto 0);
		sdram_ba       : out   std_logic_vector(2-1 downto 0);
		sdram_dqm      : out   std_logic_vector(2-1 downto 0);
		sdram_d        : inout std_logic_vector(16-1 downto 0);

		gpdi_dp        : out   std_logic_vector(4-1 downto 0);
		gpdi_dn        : out   std_logic_vector(4-1 downto 0);
		gpdi_ethp      : std_logic;  
		gpdi_ethn      : std_logic;
		gpdi_cec       : std_logic;
		gpdi_sda       : std_logic;
		gpdi_scl       : std_logic;

		gp             : out   std_logic_vector(28-1 downto 0);
		gn             : out   std_logic_vector(28-1 downto 0);

		user_programn  : std_logic;
		shutdown       : out std_logic := '0');
end;
