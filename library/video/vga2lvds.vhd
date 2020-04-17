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
      clk : in std_logic;
      red, green, blue : in std_logic_vector(7 downto 0);
      hsync, vsync, blank : in std_logic;
      lvds : out std_logic_vector(3 downto 0)
   );
end;

architecture Behavioral of vga2lvds is 
  signal bitSlot: std_logic_vector(2 downto 0);
  constant clk_data: std_logic_vector(6 downto 0) := "1100011"; -- the clock
  signal ch0_data, ch1_data, ch2_data: std_logic_vector(clk_data'range);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if bitSlot = "110" then -- 6
        bitSlot <= 0; -- after 6 comes 0
      else
        bitSlot <= bitSlot + 1;
      end if;
    end if;
  end process;

  ch2_data <= blue(4) & blue(5) & blue(6) & blue(7) & hsync & vsync & not blank;
  ch1_data <= green(3) & green(4) & green(5) & green(6) & green(7) & blue(2) & blue(3);
  ch0_data <= red(2) & red(3) & red(4) & red(5) & red(6) & red(7) & green(2);

  lvds(3) <= clk_data(conv_integer(bitSlot));
  lvds(2) <= ch2_data(conv_integer(bitSlot));
  lvds(1) <= ch1_data(conv_integer(bitSlot));
  lvds(0) <= ch0_data(conv_integer(bitSlot));

end Behavioral;
