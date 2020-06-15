-- (c)EMARD
-- License=BSD

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

use work.st7789_init_pack.all;

entity top_vgatest is
  generic
  (
    x        : natural :=  240; -- pixels
    y        : natural :=  240; -- pixels
    f        : natural :=   50; -- Hz
    xadjustf : integer :=    0; -- adjust -3..3 if no picture
    yadjustf : integer :=    0; -- or to fine-tune f
    C_ddr    : natural :=    1  -- 0:SDR 1:DDR
  );
  port
  (
    clk_25mhz: in std_logic;  -- main clock input from 25MHz clock source

    -- Onboard blinky
    led: out std_logic_vector(7 downto 0);
    btn: in std_logic_vector(6 downto 0);

    -- GPIO (some are shared with wifi and adc)
    gp, gn: inout std_logic_vector(27 downto 0) := (others => 'Z');

    -- Digital Video (differential outputs)
    gpdi_dp: out std_logic_vector(3 downto 0);
    oled_resn, oled_clk, oled_csn, oled_dc, oled_mosi: out std_logic := '1' -- oled_clk = clk/2
  );
end;

architecture Behavioral of top_vgatest is
  type T_video_timing is record
    x                  : natural;
    hsync_front_porch  : natural;
    hsync_pulse_width  : natural;
    hsync_back_porch   : natural;
    y                  : natural;
    vsync_front_porch  : natural;
    vsync_pulse_width  : natural;
    vsync_back_porch   : natural;
    f_pixel            : natural;
  end record T_video_timing;
  
  type T_possible_freqs is array (natural range <>) of natural;
  constant C_possible_freqs: T_possible_freqs :=
  (
    25000000,
    27000000,
    40000000,
    50000000,
    54000000,
    60000000,
    65000000,
    75000000,
    80000000,  -- overclock 400MHz
    100000000, -- overclock 500MHz
    108000000, -- overclock 540MHz
    120000000  -- overclock 600MHz
  );

  function F_find_next_f(f: natural)
    return natural is
    begin
      for fx in C_possible_freqs'range loop
        if C_possible_freqs(fx)>f then
          return C_possible_freqs(fx);
        end if;
      end loop;
      return C_possible_freqs(0);
    end F_find_next_f;
  
  function F_max(x,y: integer)
    return integer is
  begin
    if x > y then
      return x;
    end if;
    return y;
  end F_max;
  
  function F_video_timing(x,y,f: integer)
    return T_video_timing is
      variable video_timing : T_video_timing;
      variable xminblank   : natural := F_max(x/64,3); -- initial estimate
      variable yminblank   : natural := F_max(y/64,3); -- for minimal blank space
      variable min_pixel_f : natural := f*(x+xminblank)*(y+yminblank);
      variable pixel_f     : natural := F_find_next_f(min_pixel_f);
      variable yframe      : natural := y+yminblank;
      variable xframe      : natural := pixel_f/(f*yframe);
      variable xblank      : natural := xframe-x;
      variable yblank      : natural := yframe-y;
    begin
      video_timing.x                 := x;
      video_timing.hsync_front_porch := xblank/3;
      video_timing.hsync_pulse_width := xblank/3;
      video_timing.hsync_back_porch  := xblank-video_timing.hsync_pulse_width-video_timing.hsync_front_porch+xadjustf;
      video_timing.y                 := y;
      video_timing.vsync_front_porch := yblank/3;
      video_timing.vsync_pulse_width := yblank/3;
      video_timing.vsync_back_porch  := yblank-video_timing.vsync_pulse_width-video_timing.vsync_front_porch+yadjustf;
      video_timing.f_pixel           := pixel_f;

      return video_timing;
    end F_video_timing;
    
  constant video_timing : T_video_timing := F_video_timing(x,y,f);
  constant C_clk_shift_hz: natural := video_timing.f_pixel*4; -- *4 minimum

  signal clocks: std_logic_vector(3 downto 0);
  signal clk_pixel, clk_shift: std_logic;
  signal vga_hsync, vga_vsync, vga_blank, vga_de: std_logic;
  signal vga_r, vga_g, vga_b: std_logic_vector(7 downto 0);
  signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);
  signal beam_x, beam_y: std_logic_vector(12 downto 0);
  
  signal S_pixel: unsigned(15 downto 0);
  signal R_clk_pixel: std_logic_vector(1 downto 0);
  signal S_clk_pixel_edge: std_logic;

  component ODDRX1F
    port (D0, D1, SCLK, RST: in std_logic; Q: out std_logic);
  end component;

begin
  clk_single_pll: entity work.ecp5pll
  generic map
  (
      in_Hz => natural(25.0e6),
    out0_Hz => C_clk_shift_hz,
    out1_Hz => video_timing.f_pixel
  )
  port map
  (
    clk_i => clk_25MHz,
    clk_o => clocks
  );
  clk_shift <= clocks(0);
  clk_pixel <= clocks(1);
  
  vga_instance: entity work.vga
  generic map
  (
    C_resolution_x      => video_timing.x,
    C_hsync_front_porch => video_timing.hsync_front_porch,
    C_hsync_pulse       => video_timing.hsync_pulse_width,
    C_hsync_back_porch  => video_timing.hsync_back_porch,
    C_resolution_y      => video_timing.y,
    C_vsync_front_porch => video_timing.vsync_front_porch,
    C_vsync_pulse       => video_timing.vsync_pulse_width,
    C_vsync_back_porch  => video_timing.vsync_back_porch,

    C_bits_x       =>  12,
    C_bits_y       =>  8
  )
  port map
  (
      clk_pixel  => clk_pixel,
      clk_pixel_ena => '1', -- R_slow_ena(R_slow_ena'high),
      test_picture => '1',
      --beam_x     => beam_x,
      --beam_y     => beam_y,
      vga_r      => vga_r,
      vga_g      => vga_g,
      vga_b      => vga_b,
      vga_hsync  => vga_hsync,
      vga_vsync  => vga_vsync,
      vga_blank  => vga_blank
      --vga_de     => vga_de
  );
  
  led(0) <= vga_hsync;
  led(1) <= vga_vsync;
  led(7) <= vga_blank;

  process(clk_shift)
  begin
    if rising_edge(clk_shift) then
      R_clk_pixel <= clk_pixel & R_clk_pixel(1); -- shift
    end if;
  end process;
  S_clk_pixel_edge <= '1' when R_clk_pixel = "10" else '0';

  S_pixel <= unsigned(vga_r(7 downto 3) & vga_g(7 downto 2) & vga_b(7 downto 3));
  spi_display_instance: entity work.spi_display
  generic map
  (
    c_clk_mhz      => C_clk_shift_hz/1000000,
    c_reset_us     => 1,
    c_color_bits   => 16,
    c_clk_phase    => '0',
    c_clk_polarity => '1',
    c_x_size       => 240,
    c_y_size       => 240,
    c_init_seq     => c_st7789_init_seq,
    c_nop          => x"00"
  )
  port map
  (
    reset          => not btn(0),
    clk            => clk_shift, -- 125 MHz
    clk_pixel_ena  => S_clk_pixel_edge,
    vsync          => vga_vsync,
    blank          => vga_blank,
    color          => S_pixel,
    spi_resn       => oled_resn,
    spi_clk        => oled_clk,
    --spi_csn        => oled_csn,
    spi_dc         => oled_dc,
    spi_mosi       => oled_mosi
  );
  oled_csn <= '1';

end Behavioral;
