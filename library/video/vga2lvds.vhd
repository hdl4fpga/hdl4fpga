--
-- AUTHOR=Goran
-- LICENSE=BSD
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity vga2lvds is 
port
(
  clk_pixel, clk_shift : in std_logic;
  in_red, in_green, in_blue : in std_logic_vector(7 downto 0);
  in_hsync, in_vsync, in_blank : in std_logic;
  out_lvds : out std_logic_vector(3 downto 0)
);
end;

architecture Behavioral of vga2lvds is 
  signal bit_counter: std_logic_vector(2 downto 0);
  signal clk_data: std_logic_vector(6 downto 0) := "1100011"; -- the clock
  signal ch0_data, ch1_data, ch2_data: std_logic_vector(6 downto 0);
  signal R_clk_pixel: std_logic_vector(1 downto 0);
begin
  process(clk_shift)
  begin
    if rising_edge(clk_shift) then
      if bit_counter = "110" then -- 6
        bit_counter <= 0; -- after 6 comes 0
      else
        if R_clk_pixel = "10" and clk_data(5 downto 4) /= "10" then -- clock synchronizer
          clk_data <= clk_data(5 downto 0) & clk_data(6); -- left shift clock (slow it down by 1 cycle)
        end if;
        bit_counter <= bit_counter + 1;
      end if;
      R_clk_pixel <= clk_pixel & R_clk_pixel(1);
    end if;
  end process;

--  process(clk_pixel)
--  begin
--    if rising_edge(clk_pixel) then
      ch2_data <= in_blue(4) & in_blue(5) & in_blue(6) & in_blue(7) & in_hsync & in_vsync & not in_blank;
      ch1_data <= in_green(3) & in_green(4) & in_green(5) & in_green(6) & in_green(7) & in_blue(2) & in_blue(3);
      ch0_data <= in_red(2) & in_red(3) & in_red(4) & in_red(5) & in_red(6) & in_red(7) & in_green(2);
--    end if;
--  end process;

  out_lvds(3) <= clk_data(conv_integer(bit_counter));
  out_lvds(2) <= ch2_data(conv_integer(bit_counter));
  out_lvds(1) <= ch1_data(conv_integer(bit_counter));
  out_lvds(0) <= ch0_data(conv_integer(bit_counter));

end Behavioral;
