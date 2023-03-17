--
-- AUTHOR=Goran
-- LICENSE=BSD
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga2lvds is 
port
(
  clk_pixel, clk_shift : in std_logic;
  r_i, g_i, b_i : in std_logic_vector(5 downto 0);
  hsync_i, vsync_i, de_i : in std_logic;
  lvds_o : out std_logic_vector(3 downto 0)
);
end;

architecture Behavioral of vga2lvds is 
  signal bit_counter: unsigned(2 downto 0);
  signal clk_data: std_logic_vector(6 downto 0) := "1100011"; -- the clock
  signal ch0_data, ch1_data, ch2_data: std_logic_vector(6 downto 0);
  signal R_clk_pixel: std_logic_vector(1 downto 0);
begin
  process(clk_shift)
  begin
    if rising_edge(clk_shift) then
      if bit_counter = "110" then -- 6
        bit_counter <= (others => '0'); -- after 6 comes 0
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
      ch2_data <= b_i(2) & b_i(3) & b_i(4) & b_i(5) & hsync_i & vsync_i & de_i;
      ch1_data <= g_i(1) & g_i(2) & g_i(3) & g_i(4) & g_i(5) & b_i(0) & b_i(1);
      ch0_data <= r_i(0) & r_i(1) & r_i(2) & r_i(3) & r_i(4) & r_i(5) & g_i(0);
--    end if;
--  end process;

  lvds_o(3) <= clk_data(to_integer(bit_counter));
  lvds_o(2) <= ch2_data(to_integer(bit_counter));
  lvds_o(1) <= ch1_data(to_integer(bit_counter));
  lvds_o(0) <= ch0_data(to_integer(bit_counter));

end Behavioral;
