-- (c) EMARD
-- License=BSD

library ieee;
use ieee.std_logic_1164.all;

-- OLED initialization sequence
-- next byte after a NOP command encodes delay in ms

package oled_init_pack is
  -- all this are commands and should be send with DC line low
  constant C_OLED_NOP1: std_logic_vector(7 downto 0) := x"BC"; -- 10111100
  constant C_OLED_NOP2: std_logic_vector(7 downto 0) := x"BD"; -- delay nop
  constant C_OLED_NOP3: std_logic_vector(7 downto 0) := x"E3";
  constant C_OLED_SET_DISPLAY_OFF: std_logic_vector(7 downto 0) := x"AE"; -- 10101110
  constant C_OLED_SET_REMAP_COLOR: std_logic_vector(7 downto 0) := x"A0";
  constant C_OLED_ULX3S_REMAP: std_logic_vector(7 downto 0) := "00100010"; -- A[7:6] = 00; 256 color. A[7:6] = 01; 65k color format rotation for ULX3S, A[1] = 1 scan right to left
  constant C_OLED_SET_DISPLAY_START_LINE: std_logic_vector(7 downto 0) := x"A1";
  constant C_OLED_SET_DISPLAY_OFFSET: std_logic_vector(7 downto 0) := x"A1";
  constant C_OLED_SET_DISPLAY_MODE_NORMAL: std_logic_vector(7 downto 0) := x"A4";
  constant C_OLED_SET_MULTIPLEX_RATIO: std_logic_vector(7 downto 0) := x"A8";
  constant C_OLED_SET_MASTER_CONFIGURATION: std_logic_vector(7 downto 0) := x"AD";
  constant C_OLED_SET_POWER_SAVE_MODE: std_logic_vector(7 downto 0) := x"B0";
  constant C_OLED_SET_PHASE_1_AND_2_PERIOD_ADJUSTMENT: std_logic_vector(7 downto 0) := x"B1";
  constant C_OLED_SET_DISPLAY_CLOCK_DIVIDER: std_logic_vector(7 downto 0) := x"F0";
  constant C_OLED_SET_PRECHARGE_A: std_logic_vector(7 downto 0) := x"8A";
  constant C_OLED_SET_PRECHARGE_B: std_logic_vector(7 downto 0) := x"8B";
  constant C_OLED_SET_PRECHARGE_C: std_logic_vector(7 downto 0) := x"8C";
  constant C_OLED_SET_PRECHARGE_LEVEL: std_logic_vector(7 downto 0) := x"BB";
  constant C_OLED_SET_VCOMH: std_logic_vector(7 downto 0) := x"BE";
  constant C_OLED_SET_MASTER_CURRENT_CONTROL: std_logic_vector(7 downto 0) := x"87";
  constant C_OLED_SET_CONTRAST_COLOR_A: std_logic_vector(7 downto 0) := x"81";
  constant C_OLED_SET_CONTRAST_COLOR_B: std_logic_vector(7 downto 0) := x"82";
  constant C_OLED_SET_CONTRAST_COLOR_C: std_logic_vector(7 downto 0) := x"83";
  constant C_OLED_SET_COLUMN_ADDRESS: std_logic_vector(7 downto 0) := x"15";
  constant C_OLED_SET_ROW_ADDRESS: std_logic_vector(7 downto 0) := x"75";
  constant C_OLED_SET_DISPLAY_ON: std_logic_vector(7 downto 0) := x"AF";

  type T_oled_init_seq is array (0 to 44) of std_logic_vector(7 downto 0);
  constant C_oled_init_seq: T_oled_init_seq :=
  (
    C_OLED_NOP1, -- 0, 10111100
    C_OLED_SET_DISPLAY_OFF, -- 1, 10101110
    C_OLED_SET_REMAP_COLOR, C_OLED_ULX3S_REMAP, -- 2
    C_OLED_SET_DISPLAY_START_LINE, x"00", -- 4
    C_OLED_SET_DISPLAY_OFFSET, x"00", -- 6
    C_OLED_SET_DISPLAY_MODE_NORMAL, -- 8
    C_OLED_SET_MULTIPLEX_RATIO, "00111111", -- 9, 15-16
    C_OLED_SET_MASTER_CONFIGURATION, "10001110", -- 11, a[0]=0 Select external Vcc supply, a[0]=1 Reserved(reset)
    C_OLED_SET_POWER_SAVE_MODE, x"00", -- 13, 0-no power save, x"1A"-power save
    C_OLED_SET_PHASE_1_AND_2_PERIOD_ADJUSTMENT, x"74", -- 15
    C_OLED_SET_DISPLAY_CLOCK_DIVIDER, x"F0", -- 17
    C_OLED_SET_PRECHARGE_A, x"64", -- 19, 100
    C_OLED_SET_PRECHARGE_B, x"78", -- 21, 120
    C_OLED_SET_PRECHARGE_C, x"64", -- 23, 100
    C_OLED_SET_PRECHARGE_LEVEL, x"31", -- 25, 49
    C_OLED_SET_CONTRAST_COLOR_A, x"FF", -- 27, 255
    C_OLED_SET_CONTRAST_COLOR_B, x"FF", -- 29, 255
    C_OLED_SET_CONTRAST_COLOR_C, x"FF", -- 31, 255
    C_OLED_SET_VCOMH, x"3E", -- 33, 62
    C_OLED_SET_MASTER_CURRENT_CONTROL, x"06", -- 35, 6
    C_OLED_SET_COLUMN_ADDRESS, x"00", x"5F", -- 37, 96
    C_OLED_SET_ROW_ADDRESS, x"00", x"3F", -- 40, 63
    C_OLED_SET_DISPLAY_ON, -- 43
    C_OLED_NOP1 -- 44 -- during debugging sent as data, counter relodaded in oled.vhd
  );
end;
