
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