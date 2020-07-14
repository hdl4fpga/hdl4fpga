library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity spi_osd_vhd is
  generic
  (
    c_addr_enable  : std_logic_vector(7 downto 0) := x"FE"; -- high addr byte of enable byte
    c_addr_display : std_logic_vector(7 downto 0) := x"FD"; -- high addr byte of display data, +0x10000 for inverted
    c_start_x      : natural := 64; -- x1  pixel window h-position
    c_start_y      : natural := 48; -- x1  pixel window v-position
    c_chars_x      : natural := 64; -- x8  pixel window h-size
    c_chars_y      : natural := 24; -- x16 pixel window v-size
    c_init_on      : natural :=  1; -- 0:default OFF, 1:default ON
    c_inverse      : natural :=  1; -- 0:no inverse, 1:inverse chars support
    c_transparency : natural :=  0; -- 0:opaque, 1:see-thru OSD menu
    c_bgcolor      : std_logic_vector(23 downto 0) := x"503020"; -- RRGGBB menu background color
    c_char_file    : string  := "osd.mem"; -- initial window content, 2 ASCII HEX digits per line
    c_font_file    : string  := "font_bizcat8x16.mem" -- font bitmap, 8 ASCII BIN digits per line
  );
  port
  (
    clk_pixel, clk_pixel_ena : in    std_logic;
    i_r, i_g, i_b            : in    std_logic_vector(7 downto 0);
    i_hsync, i_vsync, i_blank: in    std_logic;
    i_csn, i_sclk, i_mosi    : in    std_logic;
    o_miso                   : inout std_logic;
    o_r, o_g, o_b            : out   std_logic_vector(7 downto 0);
    o_hsync, o_vsync, o_blank: out   std_logic
  );
end;

architecture syn of spi_osd_vhd is
  component spi_osd -- verilog name and its parameters
  generic
  (
    c_addr_enable  : std_logic_vector(7 downto 0);
    c_addr_display : std_logic_vector(7 downto 0);
    c_start_x      : natural;
    c_start_y      : natural;
    c_chars_x      : natural;
    c_chars_y      : natural;
    c_init_on      : natural;
    c_inverse      : natural;
    c_transparency : natural;
    c_bgcolor      : std_logic_vector(23 downto 0);
    c_char_file    : string;
    c_font_file    : string
  );
  port
  (
    clk_pixel, clk_pixel_ena : in    std_logic;
    i_r, i_g, i_b            : in    std_logic_vector(7 downto 0);
    i_hsync, i_vsync, i_blank: in    std_logic;
    i_csn, i_sclk, i_mosi    : in    std_logic;
    o_miso                   : inout std_logic;
    o_r, o_g, o_b            : out   std_logic_vector(7 downto 0);
    o_hsync, o_vsync, o_blank: out   std_logic
  );
  end component;

begin
  spi_osd_v_inst: spi_osd
  generic map
  (
    c_addr_enable  => c_addr_enable,
    c_addr_display => c_addr_display,
    c_start_x      => c_start_x,
    c_start_y      => c_start_y,
    c_chars_x      => c_chars_x,
    c_chars_y      => c_chars_y,
    c_init_on      => c_init_on,
    c_inverse      => c_inverse,
    c_transparency => c_transparency,
    c_bgcolor      => c_bgcolor,
    c_char_file    => c_char_file,
    c_font_file    => c_font_file
  )
  port map
  (
    clk_pixel => clk_pixel, clk_pixel_ena => clk_pixel_ena,
    i_r => i_r, i_g => i_g, i_b => i_b,
    i_hsync => i_hsync, i_vsync => i_vsync, i_blank => i_blank,
    i_csn => i_csn, i_sclk => i_sclk, i_mosi => i_mosi, o_miso => o_miso,
    o_r => o_r, o_g => o_g, o_b => o_b,
    o_hsync => o_hsync, o_vsync => o_vsync, o_blank => o_blank
  );
end syn;
