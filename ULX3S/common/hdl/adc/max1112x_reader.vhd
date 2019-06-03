-- MAX1112x ADC init and read core, work in progress
-- AUTHOR=EMARD
-- LICENSE=BSD

-- TODO: unhardcode list of enabled channels

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

use work.max1112x_init_pack.all;
library hdl4fpga;
use hdl4fpga.std.all; -- for unsigned_num_bits()

entity max1112x_reader is
generic
(
  C_timing_exact: integer range 0 to 1 := 0; -- 0:not exact clk_spi=clk/2, 1:exact clk_spi=clk/4
  C_channels: integer := 4; -- don't touch
  C_bits: integer range 1 to 12 := 12 -- output bits width
);
port
(
  -- clk with clken should provide
  -- 64 MHz max with C_timing_exact=1
  -- 32 MHz max with C_timing_exact=0
  clk: in std_logic;
  clken: in std_logic := '1';
  reset: in std_logic := '0';
  spi_csn, spi_clk, spi_mosi: out std_logic := '1';
  spi_miso: in std_logic;
  dv: out std_logic; -- data valid 1-cycle '1' pulse when data is valid
  data: out std_logic_vector(C_channels*C_bits-1 downto 0)
);
end;

architecture rtl of max1112x_reader is
  type T_data is array (0 to C_channels-1) of unsigned(C_bits-1 downto 0);
  signal R_data_array: T_data;
  -- 6 LSB BITS: timing exact by datasheet,  CLK_SPI = CLK/4
  -- 5 LSB BITS: timing not exact but works, CLK_SPI = CLK/2
  constant C_lsb_bits: integer range 5 to 6 := 5+C_timing_exact; -- LSB bits of counter (for clocking one 16-bit word)
  constant C_end_seq_divider: integer := 2**(6-C_lsb_bits); -- with 5 LSB divide end condition by 2
  constant C_lsb0: std_logic_vector(C_lsb_bits-1 downto 0) := (others => '0');
  signal S_init_cnt_lsb_eq_0: std_logic;
  constant C_shift_condition: std_logic_vector(C_lsb_bits-5 downto 0) := (others => '0');
  -- initialization sequence replay counter
  constant C_word_bits: integer := 4; -- to address one bit in a 16-bit word
  constant C_init_seq_bits: integer := unsigned_num_bits(C_max1112x_init_seq'high); -- to address one word in init sequence
  signal R_init_cnt: std_logic_vector(C_init_seq_bits+C_word_bits+C_lsb_bits-1 downto 0) := (others => '0');
  signal R_bus_data: std_logic_vector(15 downto 0) := x"0000"; -- one bit more?
  -- (15 downto 5) -- word address of the config sequence
  -- (4 downto 1) -- bit address 16 bits of each word
  -- (0) SPI clock cycle
  signal R_dv: std_logic := '0'; -- data valid (all channels)
  signal R_csn: std_logic := '1';
begin
  S_init_cnt_lsb_eq_0 <= '1' when R_init_cnt(C_lsb_bits-1 downto 0) = C_lsb0 else '0';
  process(clk)
  begin
    if rising_edge(clk) then
      if clken = '1' then
        if reset = '1' then
          R_init_cnt <= (others => '0');
        else
          if R_init_cnt(R_init_cnt'high downto C_lsb_bits)
             /= conv_std_logic_vector(C_max1112x_init_seq'high, R_init_cnt'length-C_lsb_bits)
          or R_init_cnt(C_lsb_bits-1 downto 0) /= (not C_lsb0)
          then
            if S_init_cnt_lsb_eq_0 = '1' then -- load new word from init sequence
              -- R_bus_data(15 downto 12) contains channel ID.
              -- HACK:: (14 downto 13) works for 4ch when every 2nd ADC channel
              -- is enabled, as always is for bipolar (differential) mode.
              -- for unipolar 8ch (single-ended) mode, (14 downto 12) should be used.
              R_data_array(conv_integer(R_bus_data(14 downto 13))) <= R_bus_data(11 downto 12-C_bits);
              R_bus_data <= C_max1112x_init_seq(conv_integer(R_init_cnt(R_init_cnt'high downto C_lsb_bits)));
            elsif R_init_cnt(C_shift_condition'range) = C_shift_condition then -- shift one bit to the right
              R_bus_data <= R_bus_data(R_bus_data'high-1 downto 0) & spi_miso;
            end if;
            R_init_cnt <= R_init_cnt+1;
          else
            -- reset counter: last N words sent repeatedly
            R_init_cnt(R_init_cnt'high downto C_lsb_bits) <= conv_std_logic_vector(C_max1112x_seq_repeat, R_init_cnt'length-C_lsb_bits);
            R_init_cnt(C_lsb_bits-1 downto 0) <= (others => '0');
          end if;
          -- csn at 60-62 is exact by datasheet
          -- csn at 59-61 is not exact but works, good to simplify code
          -- having clk and mosi in phase and clk/2 instead of clk/4
          if R_init_cnt(C_lsb_bits-1 downto 0) = conv_std_logic_vector(60/C_end_seq_divider,C_lsb_bits) then
            R_csn <= '1';
          end if;
          if R_init_cnt(C_lsb_bits-1 downto 0) = conv_std_logic_vector(62/C_end_seq_divider,C_lsb_bits) then
            R_csn <= '0';
          end if;
        end if; -- reset
      end if; -- clken
    end if; -- rising edge
  end process;
  process(clk)
  begin
    if rising_edge(clk) then
      if R_init_cnt(R_init_cnt'high downto C_lsb_bits) = conv_std_logic_vector(C_max1112x_seq_repeat+1, R_init_cnt'length-C_lsb_bits)
      and S_init_cnt_lsb_eq_0 = '1'
      and clken = '1' then
        R_dv <= '1';
      else
        R_dv <= '0';
      end if;
    end if;
  end process;
  spi_csn <= R_csn; -- CS = inverted reset
  spi_clk <= R_init_cnt(C_lsb_bits-5); -- clk/4 counter LSB to clock only during CSn=0
  spi_mosi <= R_bus_data(R_bus_data'high); -- data MSB always to MOSI output
  dv <= R_dv;
  G_output: for i in 0 to C_channels-1 generate
    data(C_bits*(i+1)-1 downto C_bits*i) <= R_data_array(i);
  end generate G_output;
end rtl;
