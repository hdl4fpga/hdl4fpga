-- (c) EMARD
-- License=BSD

library ieee;
use ieee.std_logic_1164.all;

use work.spi_display_init_pack.all;

-- LCD ST7789 initialization sequence
-- next byte after a NOP command encodes delay in ms

package ssd1331_init_pack is
  constant C_ssd1331_init_seq: T_spi_display_init_seq :=
  (
-- after reset, delay 2^10 us = 1ms before sending commands
x"80",
x"0A",
-- NOP
x"BC",
x"00",
-- Set display off
x"AE",
x"00",
-- Set data format
-- A0 20 normal 8bpp
-- A0 60 normal 16bpp
-- A0 22 X-flip 8bpp
-- A0 62 X-flip 16bpp
-- A0 32 Y-flip 8bpp
x"A0",
x"00",
x"60",
x"00",
-- Set display start line
x"A1",
x"00",
x"00",
x"00",
-- Set display offset
x"A2",
x"00",
x"00",
x"00",
-- Set display mode normal
x"A4",
x"00",
-- Set multiplex ratio
x"A8",
x"00",
x"3F",
x"00",
-- Set master configuration
x"AD",
x"00",
x"8E",
x"00",
-- Set power save mode
x"B0",
x"00",
x"00",
x"00",
-- Phase 1/2 period adjustment
x"B1",
x"00",
x"74",
x"00",
-- Set display clock divider
x"B3",
x"00",
x"F0",
x"00",
-- Set precharge A
x"8A",
x"00",
x"64",
x"00",
-- Set precharge B
x"8B",
x"00",
x"78",
x"00",
-- Set precharge C
x"8C",
x"00",
x"64",
x"00",
-- Set precharge voltage
x"BB",
x"00",
x"31",
x"00",
-- Set contrast A
x"81",
x"00",
x"FF",
x"00",
-- Set contrast B
x"82",
x"00",
x"FF",
x"00",
-- Set contrast C
x"83",
x"00",
x"FF",
x"00",
-- Set Vcomh voltage
x"BE",
x"00",
x"3E",
x"00",
-- Master current control
x"87",
x"00",
x"06",
x"00",
-- Set column address
x"15",
x"00",
x"00",
x"00",
x"5F",
x"00",
-- Set row address
x"75",
x"00",
x"00",
x"00",
x"3F",
x"00",
-- Set display on
x"AF",
x"00"
  );
end;
