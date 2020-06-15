-- VGA to SPI LCD display
-- supports ST7789 and similar displays

-- AUTHOR=EMARD
-- LICENSE=BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.spi_display_init_pack.all;

entity spi_display is
generic
(
  c_clk_mhz      : natural   := 25;     -- MHz clk freq (125 MHz max for st7789)
  c_reset_us     : natural   := 150000; -- us holding hardware reset
  c_color_bits   : natural   := 16;     -- RGB565
  c_clk_phase    : std_logic := '0';    -- spi_clk phase
  c_clk_polarity : std_logic := '1';    -- spi_clk polarity and idle state 0:normal; 1:inverted (for st7789)
  c_x_size       : natural   := 240;    -- pixel X screen size
  c_y_size       : natural   := 240;    -- pixel Y screen size
  c_x_bits       : natural   := 8;      -- integer(ceil(log2(real(c_x_size)))) -- 240->8
  c_y_bits       : natural   := 8;      -- integer(ceil(log2(real(c_y_size)))) -- 240->8
  c_init_seq     : T_spi_display_init_seq;
  c_nop          : unsigned(7 downto 0) := x"00"   -- NOP command from datasheet
);
port
(
  reset          : in std_logic; -- clk synchronous
  clk            : in std_logic; -- 1-150 MHz clock
  clk_pixel_ena  : in std_logic := '1'; -- input pixel clock ena, same clk ena from VGA generator module
  vsync, blank   : in std_logic;
  color          : in unsigned(C_color_bits-1 downto 0);
  x              : out unsigned(c_x_bits-1 downto 0);
  y              : out unsigned(c_y_bits-1 downto 0);
  next_pixel     : out std_logic; -- '1' when x/y changes
  spi_resn, spi_clk, spi_csn, spi_dc, spi_mosi: out std_logic := '1' -- spi_clk = clk/2
);
end;

architecture rtl of spi_display is
  constant c_init_index_bits: natural := integer(ceil(log2(real(c_init_seq'length))));
  constant c_init_size: unsigned(c_init_index_bits+3 downto 4) := to_unsigned(c_init_seq'length,c_init_index_bits);
  signal index: unsigned(c_init_index_bits+3 downto 0);
  signal data: unsigned(7 downto 0) := c_nop;
  signal dc: std_logic := '1';
  signal byte_toggle: std_logic; -- alternates data byte for 16-bit mode
  signal init: std_logic := '1';
  signal num_args: unsigned(4 downto 0);
  constant C_delay_cnt_init: unsigned(27 downto 0) := to_unsigned(c_clk_mhz*c_reset_us,28); -- initial delay fits 1.3s at 100MHz
  signal delay_cnt: unsigned(C_delay_cnt_init'range) := C_delay_cnt_init;
  signal arg: unsigned(5 downto 0);
  signal delay_set: std_logic := '0';
  signal last_cmd: unsigned(7 downto 0);
  signal resn: std_logic := '0';
  signal clken: std_logic := '0';
  signal next_byte: unsigned(7 downto 0);

  signal R_x_in      : unsigned(c_x_bits-1 downto 0);
  signal S_x_in_next : unsigned(c_x_bits-1 downto 0);
  signal S_x_in_inc  : unsigned(c_x_bits-1 downto 0);
  signal R_y_in      : unsigned(c_y_bits-1 downto 0);
  signal S_y_in_next : unsigned(c_y_bits-1 downto 0);
  signal S_y_in_inc  : unsigned(c_y_bits-1 downto 0);

  signal S_color: unsigned(C_color_bits-1 downto 0);
  type T_scanline is array (0 to c_x_size-1) of unsigned(C_color_bits-1 downto 0); -- buffer for one scan line
  signal R_scanline: T_scanline;
begin
  -- track signal's pixel coordinates and buffer one line
  S_x_in_inc  <= R_x_in+1 when R_x_in /= c_x_size else R_x_in;
  S_x_in_next <= S_x_in_inc when blank = '0' else (others => '0');
  S_y_in_inc  <= R_y_in+1 when R_x_in = c_x_size-1 else R_y_in;
  S_y_in_next <= S_y_in_inc when vsync = '0' else (others => '1');
  process(clk)
  begin
    if rising_edge(clk) then
      if clk_pixel_ena = '1' then
        if blank = '0' then
          R_scanline(to_integer(R_x_in)) <= color;
        end if;
        R_x_in <= S_x_in_next;
        R_y_in <= S_y_in_next;
      end if; -- clk_pixel_ena
    end if;
  end process;
  S_color <= R_scanline(to_integer(x));

  -- The next byte in the initialisation sequence
  next_byte <= unsigned(c_init_seq(to_integer(index(c_init_index_bits+3 downto 4))));

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        delay_cnt <= C_delay_cnt_init;
        delay_set <= '0';
        index <= (others => '0');
        init <= '1';
        dc <= '1';
        resn <= '0';
        x <= (others => '0');
        y <= (others => '0');
        byte_toggle <= '0';
        arg <= to_unsigned(1,arg'length); -- after reset, before commands take delay from init sequence
        data <= c_nop;
        clken <= '0';
      elsif delay_cnt(delay_cnt'high) = '0' then
        delay_cnt <= delay_cnt - 1;
        resn <= '1';
      elsif index(c_init_index_bits+3 downto 4) /= c_init_size then
        index <= index + 1;
        if index(3 downto 0) = 0 then
          if init = '1' then -- Still initialisation
            dc <= '0';
            arg <= arg + 1;
            if arg = 0 then -- New command
              data <= c_nop; -- No NOP
              clken <= '0';
              last_cmd <= next_byte;
            elsif arg = 1 then -- numArgs and delay_set
              num_args <= next_byte(4 downto 0);
              delay_set <= next_byte(7);
              if next_byte = 0 then
                arg <= (others => '0'); -- No args or delay
              end if;
              data <= last_cmd;
              clken <= '1';
            elsif arg <= num_args + 1 then -- argument
              data <= next_byte;
              clken <= '1';
              dc <= '1';
              if arg = num_args + 1 and delay_set = '0' then
                arg <= (others => '0');
              end if;
            elsif delay_set = '1' then -- delay
              delay_cnt <= to_unsigned(c_clk_mhz,delay_cnt'length) sll to_integer(next_byte(4 downto 0)); -- shift left 2^n us delay
              data <= c_nop;
              clken <= '0';
              delay_set <= '0';
              arg <= (others => '0');
            end if; -- arg
          else -- not init, draw picture
            if R_y_in = y then -- or c_vga_sync == 0
              dc <= '1';
              byte_toggle <= not byte_toggle;
              if c_color_bits < 12 then
                data <= S_color(7 downto 0);
              else
                if byte_toggle = '1' then
                  data <= S_color(7 downto 0);
                else
                  data <= S_color(15 downto 8);
                end if;
              end if;
              clken <= '1';
              if byte_toggle = '1' or c_color_bits < 12 then
                next_pixel <= '1';
                if x = c_x_size-1 then
                  x <= (others => '0');
                  if y = c_y_size-1 then
                    y <= (others => '0');
                  else
                    y <= y + 1;
                  end if;
                else
                  x <= x + 1;
                end if;
              end if;
            else -- R_y_in /= y
              clken <= '0';
            end if;
          end if; -- init
        else -- index(3 downto 0) /= 0
          next_pixel <= '0';
          if index(0) = '0' then
            data <= data(6 downto 0) & '0'; -- shift
          end if;
        end if; -- index
      else
        init <= '0';
        index(c_init_index_bits+3 downto 4) <= (others => '0');
      end if;
    end if;
  end process;

  spi_resn <= resn; -- high-low-high to reset
  spi_csn <= not clken; -- not used for st7789
  spi_dc <= dc; -- 0 for commands, 1 for command parameters and data
  spi_clk <= ( (index(0) xor not c_clk_phase) or not clken) xor not c_clk_polarity; -- stop clock during arg and delay
  spi_mosi <= data(7);
end rtl;
