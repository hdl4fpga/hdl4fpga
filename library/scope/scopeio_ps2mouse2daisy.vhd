library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- glued PS/2 mouse -> GUI event -> daisy chain interface

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_ps2mouse2daisy is
generic
(
  vlayout_id     : integer := 0 -- screen geometry
);
port
(
  clk           : in  std_logic;
  -- mouse needs reset after replugging (no hotplug detectin yet)
  ps2m_reset    : in  std_logic := '0'; -- PS/2 mouse core reset
  -- PS/2 interface
  ps2m_clk      : inout std_logic; -- PS/2 mouse clock
  ps2m_dat      : inout std_logic; -- PS/2 mouse data
  -- daisy in
  chaini_frm    : in  std_logic := '0';
  chaini_irdy   : in  std_logic := '1';
  chaini_data   : in  std_logic_vector; -- 8 bit
  -- daisy out
  chaino_frm    : out std_logic;
  chaino_irdy   : out std_logic;
  chaino_data   : out std_logic_vector -- 8 bit
);
end;

architecture def of scopeio_ps2mouse2daisy is
  signal pointer_dv      : std_logic;
  signal pointer_x       : std_logic_vector(11-1 downto 0) := "000" & x"64";
  signal pointer_y       : std_logic_vector(11-1 downto 0) := "000" & x"64";
  signal mouse_rgtr_dv   : std_logic;
  signal mouse_rgtr_id   : std_logic_vector(8-1 downto 0);
  signal mouse_rgtr_data : std_logic_vector(32-1 downto 0);

  signal S_mouse_update: std_logic;
  signal S_mouse_btn: std_logic_vector(2 downto 0); -- 2=middle, 1=right, 0=left
  signal S_mouse_dx: std_logic_vector(7 downto 0);
  signal S_mouse_dy: std_logic_vector(7 downto 0);
  signal S_mouse_dz: std_logic_vector(3 downto 0);
begin
  mouse_e: entity hdl4fpga.mousem
  generic map
  (
    c_x_bits    => S_mouse_dx'length,
    c_y_bits    => S_mouse_dy'length,
    c_z_bits    => S_mouse_dz'length
  )
  port map
  (
    clk         => clk, -- by default made for 25 MHz
    ps2m_reset  => ps2m_reset, -- after replugging mouse, it needs reset
    ps2m_clk    => ps2m_clk,
    ps2m_dat    => ps2m_dat,
    update      => S_mouse_update,
    dx          => S_mouse_dx,
    dy          => S_mouse_dy,
    dz          => S_mouse_dz,
    btn         => S_mouse_btn
  );

  mouse2rgtr_e: entity hdl4fpga.scopeio_mouse2rgtr
  generic map
  (
    vlayout_id  => vlayout_id
  )
  port map
  (
    clk         => clk,

    mouse_update => S_mouse_update,
    mouse_dx    => signed(S_mouse_dx),
    mouse_dy    => signed(S_mouse_dy),
    mouse_dz    => signed(S_mouse_dz),
    mouse_btn   => S_mouse_btn,

    pointer_dv  => pointer_dv,
    pointer_x   => pointer_x,
    pointer_y   => pointer_y,
    rgtr_dv     => mouse_rgtr_dv,
    rgtr_id     => mouse_rgtr_id,
    rgtr_data   => mouse_rgtr_data
  );

  rgtr2daisy_e: entity hdl4fpga.scopeio_rgtr2daisy
  port map
  (
    clk         => clk,
    -- pointer_dv  => pointer_dv,
    pointer_dv  => '0', -- sent together with mouse_rgtr_dv
    pointer_x   => pointer_x,
    pointer_y   => pointer_y,
    rgtr_dv     => mouse_rgtr_dv,
    rgtr_id     => mouse_rgtr_id,
    rgtr_data   => mouse_rgtr_data,
    -- daisy input
    chaini_frm  => chaini_frm,
    chaini_irdy => chaini_irdy,
    chaini_data => chaini_data,
    -- daisy output
    chaino_frm  => chaino_frm,
    chaino_irdy => chaino_irdy,
    chaino_data => chaino_data
  );
end;
