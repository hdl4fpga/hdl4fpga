-- (c)EMARD
-- License=BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lvds2vga is
port
(
  clk_pixel, clk_shift : in std_logic; -- phases must be adjusted
  lvds_i : in std_logic_vector(3 downto 0); -- cbgr
  r_o, g_o, b_o : out std_logic_vector(5 downto 0);
  hsync_o, vsync_o, de_o : out std_logic
);
end;

architecture mix of lvds2vga is
  type T_pixel is array (3 downto 0) of std_logic_vector(6 downto 0);
  signal R_lvds, R_pixel: T_pixel;
begin
  G_read_bits: for i in 0 to 3 generate
    process(clk_shift)
    begin
      if rising_edge(clk_shift)
      then
        R_lvds(i) <= lvds_i(i) & R_lvds(i)(6 downto 1);
      end if;
    end process;
    process(clk_pixel)
    begin
      if rising_edge(clk_pixel)
      then
        R_pixel(i) <= R_lvds(i);
      end if;
    end process;
  end generate;
  r_o     <= R_pixel(0)(1)&R_pixel(0)(2)&R_pixel(0)(3)&R_pixel(0)(4)&R_pixel(0)(5)&R_pixel(0)(6);
  g_o     <= R_pixel(1)(2)&R_pixel(1)(3)&R_pixel(1)(4)&R_pixel(1)(5)&R_pixel(1)(6)&R_pixel(0)(1);
  b_o     <= R_pixel(2)(3)&R_pixel(2)(4)&R_pixel(2)(5)&R_pixel(2)(6)&R_pixel(1)(0)&R_pixel(1)(1);
  hsync_o <= R_pixel(2)(2);
  vsync_o <= R_pixel(2)(1);
  de_o    <= R_pixel(2)(0);
end mix;
