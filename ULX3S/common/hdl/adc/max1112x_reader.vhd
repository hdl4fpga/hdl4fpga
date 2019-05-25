-- MAX1112x ADC init and read core, work in progress
-- AUTHOR=EMARD
-- LICENSE=BSD

-- keep en=1 to show OLED screen

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

use work.max1112x_init_pack.all;

entity max1112x_reader is
generic
(
  C_channels: integer := 8; -- unused, hardcoded in init sequence
  C_bits: integer := 12 -- unused, output bits width
);
port
(
  clk: in std_logic; -- 64 MHz clock max
  clken: in std_logic := '1';
  spi_csn, spi_clk, spi_mosi: out std_logic := '1';
  spi_miso: in std_logic;
  bus_data: out std_logic_vector(15 downto 0);
  update: out std_logic; -- 1-cycle '1' pulse when data is updated
  data: out std_logic_vector(C_channels*C_bits-1 downto 0)
);
end;

architecture rtl of max1112x_reader is
  signal R_data: std_logic_vector(data'range);
  -- constant init_seq: T_max1112x_init_seq := C_max1112x_init_seq;
  signal R_reset_cnt: std_logic_vector(1 downto 0) := (others => '0'); -- 20 downto 0
  -- initialization sequence replay counter
  signal R_init_cnt: std_logic_vector(15 downto 0) := (others => '0'); -- 5 bits more to indicate stop
  signal R_bus_data, R_latch_bus_data: std_logic_vector(15 downto 0) := x"0000"; -- one bit more?
  -- (15 downto 5) -- word address of the config sequence
  -- (4 downto 1) -- bit address 16 bits of each word
  -- (0) spi clock cycle
  signal R_update: std_logic := '0'; -- 0-command, 1-data
  signal R_csn: std_logic := '1';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if clken = '1' then
        if R_reset_cnt(R_reset_cnt'high downto R_reset_cnt'high-1) /= "10" then
          R_reset_cnt <= R_reset_cnt+1;
        else
          if conv_integer(R_init_cnt(R_init_cnt'high downto 6)) /= C_max1112x_init_seq'high
          or R_init_cnt(5 downto 0) /= "111111" then
            if conv_integer(R_init_cnt(5 downto 0)) = 0 then -- load new word init sequece
              R_latch_bus_data <= R_bus_data;
              R_bus_data <= C_max1112x_init_seq(conv_integer(R_init_cnt(R_init_cnt'high downto 6)));
              R_update <= '1';
            elsif R_init_cnt(1 downto 0) = "00" then -- shift one bit to the right
              R_bus_data <= R_bus_data(R_bus_data'high-1 downto 0) & spi_miso;
              R_update <= '0';
            end if;
            R_init_cnt <= R_init_cnt+1;
          else
            -- last N words sent repeatedly
            R_init_cnt(R_init_cnt'high downto 6) <= conv_std_logic_vector(C_max1112x_seq_repeat, R_init_cnt'length-6);
            R_init_cnt(5 downto 0) <= (others => '0');
          end if;
          -- csn at 60-62 is exact by datasheet
          -- csn at 59-61 is not exact but works, good to simpliy code
          -- having clk and mosi in phase and clk/2 instead of clk/4
          if conv_integer(R_init_cnt(5 downto 0)) = 60 then
            R_csn <= '1';
          end if;
          if conv_integer(R_init_cnt(5 downto 0)) = 62 then
            R_csn <= '0';
          end if;
        end if; -- reset
      end if; -- clken
    end if; -- rising edge
  end process;
  spi_csn <= R_csn; -- CS = inverted reset
  spi_clk <= R_init_cnt(1); -- clk/4 counter LSB to clock only during CSn=0
  spi_mosi <= R_bus_data(R_bus_data'high); -- data MSB always to MOSI output
  bus_data <= R_latch_bus_data;
end rtl;
