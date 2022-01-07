-- (c) EMARD
-- License=BSD

library ieee;
use ieee.std_logic_1164.all;

-- MAX1112x initialization sequence

package max1112x_init_pack is
  -- for bipolar (differntial) mode, every 2nd channel should be enabled
  -- because 2 consecutive channels return the same value in bipolar mode
  constant C_MAX1112x_channels_enabled: std_logic_vector(7 downto 0) := "01010101"; -- enabled channels for output
  -- bipolar (differential) pair range sensitivity (gain)
  -- note - bit to channel mapping is reversed
  -- MSB ch 0/1 ... LSB ch 14/15
  -- 0:+-VREF/2 more sensitive, 1:+-VREF less sensitive
  --constant C_MAX1112x_bipolar_range: std_logic_vector(7 downto 0) := "00000000"; -- ch0-7 more sensitive
  constant C_MAX1112x_bipolar_range: std_logic_vector(7 downto 0) := "11110000"; -- ch0-7 less sensitive

  constant C_MAX1112x_RESET: std_logic_vector(15 downto 0) := x"0040"; -- reset all registers to defaults
  constant C_MAX1112x_CONFIG_SETUP: std_logic_vector(15 downto 0) := x"8404"; -- echo on
  constant C_MAX1112x_UNIPOLAR_SINGLE_ENDED: std_logic_vector(15 downto 0) := x"8800"; -- all ch unipolar, REF-
  constant C_MAX1112x_BIPOLAR_ALL_FALSE: std_logic_vector(15 downto 0) := x"9000"; -- all ch unipolar
  constant C_MAX1112x_BIPOLAR_ALL_TRUE: std_logic_vector(15 downto 0) := x"97F8"; -- all ch bipolar
  constant C_MAX1112x_RANGE: std_logic_vector(15 downto 0) := "10011" & C_MAX1112x_bipolar_range & "000"; -- bipolar sensitivity
  constant C_MAX1112x_CUSTOM_SCAN0_NONE: std_logic_vector(15 downto 0) := "10100" & x"00" & "000"; -- skip inputs 15..8 bin 1010 0eee eeee e000
  constant C_MAX1112x_CUSTOM_SCAN1_ENABLED: std_logic_vector(15 downto 0) := "10101" & C_MAX1112x_channels_enabled & "000"; -- scan enabled inputs 7..0 bin 1010 1eee eeee e000
  constant C_MAX1112x_MODE_CONTROL_STANDARD_INT: std_logic_vector(15 downto 0) := x"1B82"; -- 8-ch mode 0001 1011 1000 0010 standard_int clock
  constant C_MAX1112x_MODE_CONTROL_STANDARD_EXT: std_logic_vector(15 downto 0) := x"2386"; -- 8-ch mode 0010 0011 1000 0110 standard_ext clock
  constant C_MAX1112x_MODE_CONTROL_CUSTOM_EXT: std_logic_vector(15 downto 0) := x"4006"; -- mode 0100 0000 0000 0110 custom_ext clock
  constant C_MAX1112x_NULL: std_logic_vector(15 downto 0) := x"0000"; -- for reading after mode control

  type T_max1112x_init_seq is array (natural range <>) of std_logic_vector(15 downto 0);
  constant C_max1112x_init_seq: T_max1112x_init_seq :=
  (
    C_MAX1112x_RESET, -- 0
    C_MAX1112x_RESET, -- 1
    C_MAX1112x_CONFIG_SETUP, -- 2
    C_MAX1112x_UNIPOLAR_SINGLE_ENDED, -- 3
    C_MAX1112x_BIPOLAR_ALL_TRUE, -- 4 bipolar mode
    --C_MAX1112x_BIPOLAR_ALL_FALSE, -- 4 unipolar mode
    C_MAX1112x_RANGE, -- 5
    C_MAX1112x_CUSTOM_SCAN0_NONE, -- 6
    C_MAX1112x_CUSTOM_SCAN1_ENABLED, -- 7
    C_MAX1112x_MODE_CONTROL_CUSTOM_EXT, -- 8
    C_MAX1112x_NULL, -- 9
    C_MAX1112x_NULL, -- 10
    C_MAX1112x_NULL  -- 11
    -- number_of_NULLs = number_of_channels_enabled-1
  );

  constant C_max1112x_seq_repeat: integer := 8; -- after last NULL, restart from MODE_CONTROL command
end;
