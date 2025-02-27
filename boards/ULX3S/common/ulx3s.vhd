-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;

entity ulx3s is
	generic (
		debug : boolean := false);
	port (
		clk_25mhz      : in    std_logic;

		ftdi_rxd       : out   std_logic;
		ftdi_txd       : in    std_logic := 'Z';
		ftdi_nrts      : inout std_logic := 'Z';
		ftdi_ndtr      : inout std_logic := 'Z';
		ftdi_txden     : inout std_logic := 'Z';


		btn_pwr_n      : in  std_logic := 'Z';
		fire1          : in  std_logic := 'Z';
		fire2          : in  std_logic := 'Z';
		up             : in  std_logic := 'Z';
		down           : in  std_logic := 'Z';
		left           : in  std_logic := 'Z';
		right          : in  std_logic := 'Z';

		led            : out std_logic_vector(8-1 downto 0);
		sw             : in  std_logic_vector(4-1 downto 0) := (others => 'Z');


		oled_clk       : out   std_logic;
		oled_mosi      : out   std_logic;
		oled_dc        : out   std_logic;
		oled_resn      : out   std_logic;
		oled_csn       : out   std_logic;

		--flash_csn      : out   std_logic;
		--flash_clk      : out   std_logic;
		--flash_mosi     : out   std_logic;
		--flash_miso     : in    std_logic;
		--flash_holdn    : out   std_logic;
		--flash_wpn      : out   std_logic;

		sd_clk         : in    std_logic := 'Z';
		sd_cmd         : out   std_logic; -- sd_cmd=MOSI (out)
		sd_d           : inout std_logic_vector(4-1 downto 0) := (others => 'U'); -- sd_d(0)=MISO (in), sd_d(3)=CSn (out)
		sd_wp          : in    std_logic := 'Z';
		sd_cdn         : in    std_logic := 'Z'; -- card detect not connected

		adc_csn        : out   std_logic;
		adc_mosi       : out   std_logic;
		adc_miso       : in    std_logic := 'Z';
		adc_sclk       : out   std_logic;

		audio_l        : out   std_logic_vector(4-1 downto 0);
		audio_r        : out   std_logic_vector(4-1 downto 0);
		audio_v        : out   std_logic_vector(4-1 downto 0);

		wifi_en        : out   std_logic := '1'; -- '0' disables ESP32
		wifi_rxd       : out   std_logic;
		wifi_txd       : in    std_logic := 'Z';
		wifi_gpio0     : out   std_logic := '1'; -- '0' requests ESP32 to upload "passthru" bitstream
		wifi_gpio5     : inout std_logic := 'Z';
		wifi_gpio16    : inout std_logic := 'Z';
		wifi_gpio17    : inout std_logic := 'Z';

		ant_433mhz     : out   std_logic;

		usb_fpga_dp    : inout std_logic := 'Z';  
		usb_fpga_dn    : inout std_logic := 'Z';  
		usb_fpga_bd_dp : inout std_logic := 'Z';
		usb_fpga_bd_dn : inout std_logic := 'Z';
		usb_fpga_pu_dp : inout std_logic := 'Z';
		usb_fpga_pu_dn : inout std_logic := 'Z';
					   
		sdram_clk      : inout std_logic;  
		sdram_cke      : out   std_logic;
		sdram_csn      : out   std_logic;
		sdram_wen      : out   std_logic;
		sdram_rasn     : out   std_logic;
		sdram_casn     : out   std_logic;
		sdram_a        : out   std_logic_vector(13-1 downto 0);
		sdram_ba       : out   std_logic_vector( 2-1 downto 0);
		sdram_dqm      : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
		sdram_d        : inout std_logic_vector(16-1 downto 0) := (others => 'Z');

		gpdi_d         : out   std_logic_vector(4-1 downto 0);
		gpdi_cec       : inout std_logic := '-';
		gpdi_sda       : inout std_logic := '-';
		gpdi_scl       : inout std_logic := '-';

		gp             : inout std_logic_vector(28-1 downto 0) := (others => 'Z');
		gn             : inout std_logic_vector(28-1 downto 0) := (others => 'Z');
		
		gp_i           : in    std_logic_vector(12 downto 9);

		user_programn  : out   std_logic := '1'; -- '0' loads next bitstream from SPI FLASH (e.g. bootloader)
		shutdown       : out   std_logic := '0'); -- '1' power off the board, 10uA sleep

	alias rmii_tx_en   : std_logic is gn(10);
	alias rmii_tx0     : std_logic is gp(10);
	alias rmii_tx1     : std_logic is gn(9);

	alias rmii_rx0     : std_logic is gn(11);
	alias rmii_rx1     : std_logic is gp(11);

	alias rmii_crsdv   : std_logic is gp(12);

	alias rmii_nintclk : std_logic is gn(12);
	alias rmii_mdio    : std_logic is gn(13);
	alias rmii_mdc     : std_logic is gp(13);

	alias hdmi0_blue   : std_logic is gpdi_d(0);
	alias hdmi0_green  : std_logic is gpdi_d(1);
	alias hdmi0_red    : std_logic is gpdi_d(2);
	alias hdmi0_clock  : std_logic is gpdi_d(3);

	alias hdmiext_eth    : std_logic is gp(13);
	alias hdmiext_blue   : std_logic is gp(9);
	alias hdmiext_green  : std_logic is gp(10);
	alias hdmiext_red    : std_logic is gp(11);
	alias hdmiext_clock  : std_logic is gp(12);

	constant clk25mhz_freq : real := 25.0e6;

end;
