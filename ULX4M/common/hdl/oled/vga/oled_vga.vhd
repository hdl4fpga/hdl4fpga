-- SPI OLED SSD1331 display HEX decoder core
-- AUTHOR=EMARD
-- LICENSE=BSD

-- keep en=1 to show OLED screen

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

use work.oled_vga_init_pack.all;

entity oled_vga is
generic
(
  C_bits: integer := 8 -- input pixel color bits
);
port
(
  clk: in std_logic; -- 1-25 MHz clock typical
  clken: in std_logic := '1'; -- OLED clock ena allows for optional clock slowdown
  clk_pixel_ena: in std_logic := '1'; -- input pixel clock ena, same clk ena from VGA generator module
  hsync, vsync, blank: in std_logic;
  pixel: in std_logic_vector(C_bits-1 downto 0);
  spi_resn, spi_clk, spi_csn, spi_dc, spi_mosi: out std_logic := '1' -- spi_clk = clk/2
);
end;

architecture rtl of oled_vga is
  signal R_reset_cnt: std_logic_vector(1 downto 0) := (others => '0'); -- 20 downto 0
  -- initialization sequence replay counter
  signal R_init_cnt: std_logic_vector(15 downto 0) := (others => '0'); -- 4 bits more to indicate stop
  -- (15 downto 4) -- byte address of the config sequence
  -- (3 downto 1) -- bit address 8 bits of each byte
  -- (0) spi clock cycle
  signal R_spi_data: std_logic_vector(7 downto 0) := x"00"; -- one bit more
  signal R_dc: std_logic := '0'; -- 0-command, 1-data
  --signal R_x: std_logic_vector(6 downto 0) := "1011111"; -- adjusted to start at X=0
  signal R_x: std_logic_vector(6 downto 0) := "0000001"; -- adjusted to start at X=0
  signal R_y: std_logic_vector(5 downto 0) :=  "000001"; -- adjusted to start at Y=0
  signal R_x_in: std_logic_vector(6 downto 0); -- adjusted to start at X=0
  signal R_y_in: std_logic_vector(5 downto 0); -- adjusted to start at Y=0
  signal S_pixel: std_logic_vector(7 downto 0);
  constant C_last_init_send_as_data: integer := 1;
  signal R_clk_pixel: std_logic_vector(2 downto 0);
  signal S_clk_pixel_rising_edge: std_logic;
  type T_scanline is array (0 to 95) of std_logic_vector(7 downto 0); -- buffer for one scan line
  signal R_scanline: T_scanline;
begin
  -- track signal's pixel coordinates and buffer one line
  process(clk)
  begin
    if rising_edge(clk) then
      if clk_pixel_ena = '1' then
        if vsync = '1' then
          R_y_in <= (others => '0');
        else
          if hsync = '1' then
            R_x_in <= (others => '0');
          else
            if blank = '0' then
              R_scanline(conv_integer(R_x_in)) <= pixel;
              if R_x_in = "1011111" then -- if R_x_in=95
                R_x_in <= (others => '0');
                R_y_in <= R_y_in + 1;
              else
                R_x_in <= R_x_in + 1;
              end if; -- increment XY
            end if; -- blank
          end if; -- hsynv
        end if; -- vsync
      end if; -- clk_pixel_ena
    end if;
  end process;

  S_pixel <= pixel; -- take pixel from input
  process(clk)
  begin
    if rising_edge(clk) then
     --if clken = '1' then
      if R_reset_cnt(R_reset_cnt'high downto R_reset_cnt'high-1) /= "10" then
        R_reset_cnt <= R_reset_cnt+1;
      elsif conv_integer(R_init_cnt(R_init_cnt'high downto 4)) /= C_oled_init_seq'high+1 then
        if conv_integer(R_init_cnt(3 downto 0)) = 0 then -- load new byte (either from init sequece or next pixel)
          if R_y_in = R_y then
            R_init_cnt <= R_init_cnt + 1;
            if R_dc = '0' then
              -- init sequence
              R_spi_data(7 downto 0) <= C_oled_init_seq(conv_integer(R_init_cnt(R_init_cnt'high downto 4)));
            else
              R_spi_data(7 downto 0) <= R_scanline(conv_integer(R_x)); -- from input
              -- tracks XY pixel coordinates currently written to SPI diplay
              if R_x = "1011111" then -- if R_x=95
                R_x <= (others => '0');
                R_y <= R_y + 1;
              else
                R_x <= R_x + 1;
              end if;
            end if; -- if DC
          end if; -- XY match
        else
          if clken = '1' then
            R_init_cnt <= R_init_cnt + 1;
            if R_init_cnt(0) = '0' then -- shift one bit to the right
              R_spi_data <= R_spi_data(R_spi_data'high-1 downto 0) & '0';
            end if;
          end if;
        end if;
      end if; -- main state machine: reset, init, data
      -- last N bytes send as data
      if conv_integer(R_init_cnt(R_init_cnt'high downto 4)) = C_oled_init_seq'high-(C_last_init_send_as_data-1) then
         R_dc <= '1';
      end if;
      if conv_integer(R_init_cnt(R_init_cnt'high downto 4)) = C_oled_init_seq'high then
         R_init_cnt(R_init_cnt'high downto 4) <= conv_std_logic_vector(C_oled_init_seq'high-(C_last_init_send_as_data-1), R_init_cnt'length-4);
      end if;
     --end if; -- clken (slowdown)
    end if; -- rising edge
  end process;
  spi_resn <= not R_reset_cnt(R_reset_cnt'high-1);
  spi_csn <= R_reset_cnt(R_reset_cnt'high-1); -- CS = inverted reset
  spi_dc <= R_dc;
  spi_clk <= not R_init_cnt(0); -- counter LSB always to clock
  spi_mosi <= R_spi_data(R_spi_data'high); -- data MSB always to MOSI output
end rtl;
