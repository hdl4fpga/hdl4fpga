-- (c) EMARD
-- License=BSD

library ieee;
use ieee.std_logic_1164.all;

-- MAX1112x initialization sequence
-- next byte after a NOP command encodes delay in ms

package max1112x_init_pack is
  -- all this are commands and should be send with DC line low
  constant C_MAX1112x_RESET: std_logic_vector(15 downto 0) := x"0040"; -- reset all registers to defaults
  constant C_MAX1112x_CONFIG_SETUP: std_logic_vector(15 downto 0) := x"8404"; -- echo on
  constant C_MAX1112x_UNIPOLAR_A: std_logic_vector(15 downto 0) := x"9000"; -- all ch unipolar
  constant C_MAX1112x_UNIPOLAR_B: std_logic_vector(15 downto 0) := x"8804"; -- all ch unipolar, REF-
  constant C_MAX1112x_MODE_CONTROL: std_logic_vector(15 downto 0) := x"1B82"; -- 8-ch mode
  constant C_MAX1112x_SAMPLE_SET: std_logic_vector(15 downto 0) := x"B020"; -- 8-ch mode
  constant C_MAX1112x_NULL: std_logic_vector(15 downto 0) := x"0000"; -- for reading after mode control

  type T_max1112x_init_seq is array (0 to 14) of std_logic_vector(15 downto 0);
  constant C_max1112x_init_seq: T_max1112x_init_seq :=
  (
    C_MAX1112x_RESET, -- 0
    C_MAX1112x_RESET, -- 1
    C_MAX1112x_CONFIG_SETUP, -- 2
    C_MAX1112x_UNIPOLAR_A, -- 3
    C_MAX1112x_UNIPOLAR_B, -- 4
    C_MAX1112x_MODE_CONTROL, -- 5
    C_MAX1112x_NULL, -- 6
    C_MAX1112x_MODE_CONTROL, -- 7
    C_MAX1112x_NULL, -- 8
    C_MAX1112x_NULL, -- 9
    C_MAX1112x_NULL, -- 10
    C_MAX1112x_NULL, -- 11
    C_MAX1112x_NULL, -- 12
    C_MAX1112x_NULL, -- 13
    C_MAX1112x_NULL  -- 14
  );
  
  constant C_max1112x_seq_repeat: integer := 7; -- after last word of seqence, restart from this position (mode control)
end;
