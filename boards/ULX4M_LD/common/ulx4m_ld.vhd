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

library ecp5u;
use ecp5u.components.all;

entity ulx4m_ld is
	generic (
		debug           : boolean := false);
	port (

		clk_25mhz       : in  std_logic := 'Z';
		btn             : in  std_logic_vector(1 to 3) := (others => '-');
		led             : out std_logic_vector(8-1 downto 0) := (others => 'Z');

		sd_clk          : in  std_logic := '-';
		sd_cmd          : out std_logic; -- sd_cmd=MOSI (out)
		sd_d            : inout std_logic_vector(4-1 downto 0) := (others => 'U'); -- sd_d(0)=MISO (in), sd_d(3)=CSn (out)
		sd_wp           : in  std_logic := '-';
		sd_cdn          : in  std_logic := '-'; -- card detect not connected

		usb_fpga_dp     : inout std_logic := 'Z';
		usb_fpga_dn     : inout std_logic := 'Z';
		usb_fpga_bd_dp  : inout std_logic := 'Z';
		usb_fpga_bd_dn  : inout std_logic := 'Z';
		usb_fpga_pu_dp  : inout std_logic := 'Z';
		usb_fpga_pu_dn  : inout std_logic := 'Z';
		usb_fpga_otg_dp : inout std_logic := 'Z';
		usb_fpga_otg_dn : inout std_logic := 'Z';
		n_extrst        : inout std_logic := 'Z';

		eth_resetn      : out std_logic;
		-- eth_intn        : in  std_logic := 'Z';
		eth_mdio        : inout std_logic := 'Z';
		eth_mdc         : out std_logic := 'Z';

		rgmii_tx_clk    : out std_logic := '-';
		rgmii_tx_en     : buffer std_logic;
		rgmii_txd       : buffer std_logic_vector(0 to 4-1);
		rgmii_rx_clk    : in  std_logic := '-';
		rgmii_rx_dv     : in  std_logic := '-';
		rgmii_rxd       : in  std_logic_vector(0 to 4-1) := (others => '-');

		ddram_clk       : out std_logic;
		ddram_reset_n   : out std_logic;
		ddram_cke       : out std_logic;
		ddram_cs_n      : out std_logic;
		ddram_ras_n     : out std_logic;
		ddram_cas_n     : out std_logic;
		ddram_we_n      : out std_logic;
		ddram_odt       : out std_logic;
		ddram_a         : out std_logic_vector(16-1 downto 0);
		ddram_ba        : out std_logic_vector(3-1 downto 0);
		ddram_dm        : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddram_dq        : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddram_dqs       : inout std_logic_vector(2-1 downto 0) := (others => 'Z');

		ftdi_txd        : in std_logic;
		ftdi_txden      : out std_logic;
		ftdi_rxd        : out std_logic;

		gpdi_d          : out std_logic_Vector(8-1 downto 0);
		gpdi_cec        : out std_logic;

		gpio_scl        : out std_logic;
		cam_scl         : out std_logic;

		user_programn   : out std_logic := '1'; -- '0' loads next bitstream from SPI FLASH (e.g. bootloader)
		shutdown        : out std_logic := '0'); -- '1' power off the board, 10uA sleep


	constant clk25mhz_freq : real := 25.0e6;

	alias hdmi0_blue  : std_logic is gpdi_d(0);
	alias hdmi0_green : std_logic is gpdi_d(1);
	alias hdmi0_red   : std_logic is gpdi_d(2);
	alias hdmi0_clock : std_logic is gpdi_d(3);
	alias hdmi0_gpdi  : std_logic_vector(4-1 downto 0) is gpdi_d(4-1 downto 0);

	alias hdmi1_blue  : std_logic is gpdi_d(4);
	alias hdmi1_green : std_logic is gpdi_d(5);
	alias hdmi1_red   : std_logic is gpdi_d(6);
	alias hdmi1_clock : std_logic is gpdi_d(7);
	alias hdmi1_gpdi  : std_logic_vector(4-1 downto 0) is gpdi_d(8-1 downto 4);

end;





