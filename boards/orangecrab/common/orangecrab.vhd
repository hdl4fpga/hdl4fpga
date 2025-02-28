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

entity orangecrab is
	generic (
		debug           : boolean := false);
	port (
		clk_48MHz       : in  std_logic := 'Z';
		rst_n           : in  std_logic := 'Z';
		usr_btn         : in  std_logic := 'Z';
        rgb_led         : out std_logic_vector(3-1 downto 0);
        gpio            : inout std_logic_vector(14-1 downto 0);
        gpio_a          : inout std_logic_vector( 6-1 downto 0);

		usb_d_p         : inout std_logic := 'Z';
		usb_d_n         : inout std_logic := 'Z';
		usb_pullup      : inout std_logic := 'Z';

		ddram_reset_n   : out std_logic;
		ddram_clk       : out std_logic;
		ddram_cke       : out std_logic;
		ddram_cs_n      : out std_logic;
		ddram_ras_n     : out std_logic;
		ddram_cas_n     : out std_logic;
		ddram_we_n      : out std_logic;
		ddram_odt       : out std_logic;
		ddram_a         : out std_logic_vector(16-1 downto 0);
		ddram_ba        : out std_logic_vector( 3-1 downto 0);
		ddram_dm        : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
		ddram_dq        : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddram_dqs       : inout std_logic_vector( 2-1 downto 0) := (others => 'Z'));

	constant clk48MHz_freq : real := 48.0e6;

    alias rgb_led0_r : std_logic is rgb_led(0);
    alias rgb_led0_g : std_logic is rgb_led(1);
    alias rgb_led0_b : std_logic is rgb_led(2);

    alias gpio_mosi  : std_logic is gpio(2);
    alias gpio_miso  : std_logic is gpio(3);
    alias gpio_sck   : std_logic is gpio(4);
    alias gpio_sda   : std_logic is gpio(7);
    alias gpio_scl   : std_logic is gpio(8);
end;
