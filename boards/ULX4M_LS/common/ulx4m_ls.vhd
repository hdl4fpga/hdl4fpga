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

entity ulx4m_ls is
	generic (
		debug : boolean := false);
	port (

		clk_25mhz       : in  std_logic := 'Z';
		btn             : in  std_logic_vector(1 to 7) := (others => '-');
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
