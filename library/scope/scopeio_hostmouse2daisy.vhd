library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- glued host mouse -> GUI event -> daisy chain interface
-- host mouse packets are sent over serial as 0x0F rgtr commands.

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_hostmouse2daisy is
generic
(
  -- to render things correctly, GUI system needs to know:
  C_reverse_chaini_data : boolean := false;
  C_inputs       : integer; -- number of inputs
  C_tracesfg     : std_logic_vector; -- colors of traces
  vlayout_id     : integer := 0 -- screen geometry
);
port
(
  clk           : in  std_logic; -- usually same as VGA pixel clock
  -- daisy in
  chaini_frm    : in  std_logic := '0';
  chaini_irdy   : in  std_logic := '1';
  chaini_data   : in  std_logic_vector; -- 8 bit
  -- daisy out
  chaino_frm    : out std_logic;
  chaino_irdy   : out std_logic;
  chaino_data   : out std_logic_vector  -- 8 bit
);
end;

architecture def of scopeio_hostmouse2daisy is
  signal sin_data        : std_logic_vector(chaini_data'range);

  signal pointer_dv      : std_logic;
  signal pointer_x       : std_logic_vector(11-1 downto 0) := "000" & x"64";
  signal pointer_y       : std_logic_vector(11-1 downto 0) := "000" & x"64";
  signal mouse_rgtr_dv   : std_logic;
  signal mouse_rgtr_id   : std_logic_vector(8-1 downto 0);
  signal mouse_rgtr_data : std_logic_vector(32-1 downto 0);

  -- input rgtr interface
  signal S_rgtr_id  : std_logic_vector(7 downto 0);
  signal S_rgtr_dv  : std_logic;
  signal S_rgtr_data: std_logic_vector(31 downto 0);

  alias A_mouse_btn : std_logic_vector(2 downto 0) is S_rgtr_data( 2 downto 0);  
  alias A_mouse_dx  : std_logic_vector(7 downto 0) is S_rgtr_data(15 downto 8);
  alias A_mouse_dy  : std_logic_vector(7 downto 0) is S_rgtr_data(23 downto 16);
  alias A_mouse_dz  : std_logic_vector(7 downto 0) is S_rgtr_data(31 downto 24);

  signal S_mouse_update: std_logic;
begin
  G_yes_reverse: if C_reverse_chaini_data generate
    sin_data <= reverse(chaini_data);
  end generate;

  G_not_reverse: if not C_reverse_chaini_data generate
    sin_data <= chaini_data;
  end generate;

  E_scopeio_hostmouse_sin_e: entity hdl4fpga.scopeio_sin
  port map (
    sin_clk   => clk,
    sin_frm   => chaini_frm,
    sin_irdy  => chaini_irdy,
    sin_data  => sin_data,
    rgtr_dv   => S_rgtr_dv,
    rgtr_id   => S_rgtr_id,
    rgtr_data => S_rgtr_data
  );

  S_mouse_update <= '1' when S_rgtr_id = x"0F" and S_rgtr_dv = '1' else '0'; -- listen only to 0x0F input rgtr commands

  mouse2rgtr_e: entity hdl4fpga.scopeio_mouse2rgtr
  generic map
  (
    C_inputs   => C_inputs,
    C_tracesfg => C_tracesfg,
    vlayout_id => vlayout_id
  )
  port map
  (
    clk          => clk,

    mouse_update => S_mouse_update,
    mouse_dx     => signed(A_mouse_dx),
    mouse_dy     => signed(A_mouse_dy),
    mouse_dz     => signed(A_mouse_dz),
    mouse_btn    => A_mouse_btn,

    pointer_dv   => pointer_dv,
    pointer_x    => pointer_x,
    pointer_y    => pointer_y,
    rgtr_dv      => mouse_rgtr_dv,
    rgtr_id      => mouse_rgtr_id,
    rgtr_data    => mouse_rgtr_data
  );

  rgtr2daisy_e: entity hdl4fpga.scopeio_rgtr2daisy
  port map
  (
    clk         => clk,
    --pointer_dv  => pointer_dv,
    pointer_dv  => '0', -- sent together with mouse_rgtr_dv
    pointer_x   => pointer_x,
    pointer_y   => pointer_y,
    rgtr_dv     => mouse_rgtr_dv,
    --rgtr_dv     => '0',
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
