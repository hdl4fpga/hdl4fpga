-- SPI OLED SSD1331 display HEX decoder core
-- AUTHOR=EMARD
-- LICENSE=BSD

-- keep en=1 to show OLED screen

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

use work.oled_init_pack.all;
use work.oled_font_pack.all;

entity oled_hex_decoder is
generic
(
  C_debounce: boolean := false;
  -- Useful values of C_data_len: 4,8,16,32,64,128,192,256,320,448,512
  -- Display has 8 lines. Each line has 16 HEX digits or 64 bits.
  -- C_data_len(63 downto 0) is shown on the first line
  -- C_data_len(127 downto 64) is shown on second line etc.
  C_data_len: integer := 8 -- input bits report len
);
port
(
  clk: in std_logic; -- 1-25 MHz clock typical
  en: in std_logic := '1'; -- enable/hold input for button
  data: in std_logic_vector(C_data_len-1 downto 0);
  spi_resn, spi_clk, spi_csn, spi_dc, spi_mosi: out std_logic := '1'
);
end;

architecture rtl of oled_hex_decoder is
  signal R_data: std_logic_vector(data'range);
  -- constant init_seq: T_oled_init_seq := C_oled_init_seq;
  signal R_reset_cnt: std_logic_vector(1 downto 0) := (others => '0'); -- 20 downto 0
  -- initialization sequence replay counter
  signal R_init_cnt: std_logic_vector(15 downto 0) := (others => '0'); -- 4 bits more to indicate stop
  signal R_spi_data: std_logic_vector(7 downto 0) := x"00"; -- one bit more
  -- (15 downto 4) -- byte address of the config sequence
  -- (3 downto 1) -- bit address 8 bits of each byte
  -- (0) spi clock cycle
  signal R_dc: std_logic := '0'; -- 0-command, 1-data
  signal R_holding: std_logic_vector(22 downto 0) := (others => '0'); -- debounce counter
  signal R_go: std_logic := '1';
  signal R_increment: std_logic_vector(9 downto 0) := "0000000001"; -- fitted to start from char index 0
  alias S_column: std_logic_vector(3 downto 0) is R_increment(3 downto 0);
  alias S_scanline: std_logic_vector(2 downto 0) is R_increment(6 downto 4);
  alias S_row: std_logic_vector(2 downto 0) is R_increment(9 downto 7);
  signal R_cpixel: integer range 0 to 5 := 1; -- fitted to start with first pixel
  signal R_char_line: std_logic_vector(4 downto 0) := "01110";
  -- signal R_cpixel: integer range 0 to 6; -- pixel counter
  signal S_pixel: std_logic_vector(7 downto 0);
  type T_screen_line is array(0 to 15) of integer range 0 to 16;
  type T_screen is array(0 to 7) of T_screen_line;
  signal C_screen: T_screen :=
  ( -- example screen during debugging
    (15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0),
    (0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,16,0,0,15,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
  );
  signal R_data_index: std_logic_vector(6 downto 0) := "0000010"; -- tuned to start at 1st hex digit
  signal R_indexed_data, S_indexed_data: std_logic_vector(3 downto 0); -- stored from input
  constant C_last_init_send_as_data: integer := 1;
  -- red   20 40 80
  -- green 04 08 10
  -- blue  01 02
  constant C_color_black:         std_logic_vector(7 downto 0) := x"00";
  constant C_color_dark_red:      std_logic_vector(7 downto 0) := x"40";
  constant C_color_dark_brown:    std_logic_vector(7 downto 0) := x"44";
  constant C_color_dark_yellow:   std_logic_vector(7 downto 0) := x"48";
  constant C_color_dark_green:    std_logic_vector(7 downto 0) := x"08";
  constant C_color_dark_cyan:     std_logic_vector(7 downto 0) := x"05";
  constant C_color_dark_blue:     std_logic_vector(7 downto 0) := x"01";
  constant C_color_dark_violett:  std_logic_vector(7 downto 0) := x"21";
  constant C_color_gray:          std_logic_vector(7 downto 0) := x"45";
  constant C_color_light_red:     std_logic_vector(7 downto 0) := x"80";
  constant C_color_orange:        std_logic_vector(7 downto 0) := x"84";
  constant C_color_light_yellow:  std_logic_vector(7 downto 0) := x"90";
  constant C_color_light_green:   std_logic_vector(7 downto 0) := x"15";
  constant C_color_light_cyan:    std_logic_vector(7 downto 0) := x"0A";
  constant C_color_light_blue:    std_logic_vector(7 downto 0) := x"02";
  constant C_color_light_violett: std_logic_vector(7 downto 0) := x"42";
  type T_color_map is array (0 to 15) of std_logic_vector(7 downto 0);
  constant C_color_map: T_color_map := -- char background color map
  (
    -- 0           1                  2                   3                     4                    5                   6                   7
    C_color_black, C_color_dark_red,  C_color_dark_brown, C_color_dark_yellow,  C_color_dark_green,  C_color_dark_cyan,  C_color_dark_blue,  C_color_dark_violett,
    C_color_gray,  C_color_light_red, C_color_orange,     C_color_light_yellow, C_color_light_green, C_color_light_cyan, C_color_light_blue, C_color_light_violett
  );
  signal R_indexed_color: std_logic_vector(7 downto 0);
begin
  G_yes_debounce: if C_debounce generate
  process(clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        if R_holding(R_holding'high) = '0' then
          R_holding <= R_holding + 1;
        end if;
      else
        R_holding <= (others => '0');
      end if;
      -- filter out single keypress (10 ms) or hold (1 sec)
      if conv_integer(R_holding) = 65536 or R_holding(R_holding'high) = '1' then
        R_go <= '1';
      else
        R_go <= '0';
      end if;
    end if;
  end process;
  end generate;

  G_no_debounce: if not C_debounce generate
    R_go <= en;
  end generate;

  -- S_pixel <= x"FF" when R_char_line(R_char_line'high) = '1' else R_indexed_color; -- scan left to right
  S_pixel <= x"FF" when R_char_line(0) = '1' else R_indexed_color; -- scan right to left (white on color background)
  -- S_pixel <= x"FF" when R_char_line(0) = '1' else x"00"; -- scan right to left (white on black)
  S_indexed_data <= R_data(conv_integer(R_data_index)*4+3 downto conv_integer(R_data_index)*4);
  process(clk)
  begin
    if rising_edge(clk) then
      -- if R_go = '1' then
      if R_reset_cnt(R_reset_cnt'high downto R_reset_cnt'high-1) /= "10" then
        R_reset_cnt <= R_reset_cnt+1;
      elsif conv_integer(R_init_cnt(R_init_cnt'high downto 4)) /= C_oled_init_seq'high+1 then
        R_init_cnt <= R_init_cnt+1;
        -- if conv_integer(R_init_cnt(
        if conv_integer(R_init_cnt(3 downto 0)) = 0 then -- load new byte (either from init sequece or next pixel)
          if R_dc = '0' then
            -- init sequence
            R_spi_data(7 downto 0) <= C_oled_init_seq(conv_integer(R_init_cnt(R_init_cnt'high downto 4)));
          else
            -- pixel data
            R_spi_data(7 downto 0) <= S_pixel;
            if R_cpixel = 3 then
              R_data_index <= S_row & S_column;
            end if;
            if R_cpixel = 4 then
              R_indexed_data <= S_indexed_data;
            end if;
            if R_cpixel = 5 then -- load new hex digit
              R_cpixel <= 0;
              -- this example shows data correctly
              --R_indexed_color <= C_color_map(C_screen(conv_integer(S_row))(conv_integer(S_column)));
              --R_char_line <= C_oled_font(
              --  C_screen(conv_integer(S_row))(conv_integer(S_column))
              --  )(conv_integer(S_scanline));
              -- useable but ugly pixels from signal propagation delays
              R_indexed_color <= C_color_map(conv_integer(R_indexed_data));
              R_char_line <= C_oled_font(
                  conv_integer(R_indexed_data)
                )(conv_integer(S_scanline));
              R_increment <= R_increment+1; -- increment for column and scan line
              if conv_integer(R_increment) = 0 and R_go = '1' then
                R_data <= data; -- sample data
              end if;
            else
              -- R_char_line <= R_char_line(R_char_line'high-1 downto 0) & '0'; -- scan left to right
              R_char_line <= '0' & R_char_line(R_char_line'high downto 1); -- scan right to left
              R_cpixel <= R_cpixel + 1;
            end if;
          end if;
        elsif R_init_cnt(0) = '0' then -- shift one bit to the right
          R_spi_data <= R_spi_data(R_spi_data'high-1 downto 0) & '0';
        end if;
      end if; -- main state machine: reset, init, data
      -- last 4 bytes send as data
      if conv_integer(R_init_cnt(R_init_cnt'high downto 4)) = C_oled_init_seq'high-(C_last_init_send_as_data-1) then
         R_dc <= '1';
      end if;
      if conv_integer(R_init_cnt(R_init_cnt'high downto 4)) = C_oled_init_seq'high then
         R_init_cnt(R_init_cnt'high downto 4) <= conv_std_logic_vector(C_oled_init_seq'high-(C_last_init_send_as_data-1), R_init_cnt'length-4);
      end if;
      -- end if; -- R_go slowdown
    end if; -- rising edge
  end process;
  spi_resn <= not R_reset_cnt(R_reset_cnt'high-1);
  spi_csn <= R_reset_cnt(R_reset_cnt'high-1); -- CS = inverted reset
  spi_dc <= R_dc;
  spi_clk <= not R_init_cnt(0); -- counter LSB always to clock
  spi_mosi <= R_spi_data(R_spi_data'high); -- data MSB always to MOSI output
end rtl;

-- TODO
-- [x] latch input otherwise broken chars will appear
-- [ ] latched datata unreliably displayed, signal propagation delay problem

