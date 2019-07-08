library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- glued USB mouse -> GUI event -> daisy chain interface

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_usbmouse2daisy is
generic
(
  -- to render things correctly, GUI system needs to know:
  C_inputs       : integer; -- number of inputs
  C_tracesfg     : std_logic_vector; -- colors of traces
  vlayout_id     : integer := 0 -- screen geometry
);
port
(
  clk           : in  std_logic; -- 16-108 MHz usually same as VGA pixel clock
  clk_usb       : in  std_logic; -- 7.5 MHz for USB1.0
  -- mouse needs reset after replugging (no hotplug detectin yet)
  usb_reset     : in  std_logic := '0'; -- USB mouse core reset
  -- USB interface
  usb_dp        : inout std_logic; -- USB D+ single ended
  usb_dn        : inout std_logic; -- UDB D- single ended
  usb_dif       : in    std_logic; -- USB D+,D- differential pair input
  -- USB core debug
  dbg_step_ps3, dbg_step_cmd: out std_logic_vector(7 downto 0);
  dbg_btn: out std_logic_vector(2 downto 0);
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

architecture def of scopeio_usbmouse2daisy is
  signal pointer_dv      : std_logic;
  signal pointer_x       : std_logic_vector(11-1 downto 0) := "000" & x"64";
  signal pointer_y       : std_logic_vector(11-1 downto 0) := "000" & x"64";
  signal mouse_rgtr_dv   : std_logic;
  signal mouse_rgtr_id   : std_logic_vector(8-1 downto 0);
  signal mouse_rgtr_data : std_logic_vector(32-1 downto 0);
  
  signal S_valid: std_logic;
  signal R_valid: std_logic_vector(1 downto 0);
  signal S_hid_report: std_logic_vector(31 downto 0);
  -- TODO move report decoder to separate module.
  -- this works for one logitech mouse, other models
  -- may have different report structure
  alias A_mouse_btn : std_logic_vector(2 downto 0) is S_hid_report( 2 downto 0);  
  alias A_mouse_dx  : std_logic_vector(7 downto 0) is S_hid_report(15 downto 8);
  alias A_mouse_dy  : std_logic_vector(7 downto 0) is S_hid_report(23 downto 16);
  alias A_mouse_dz  : std_logic_vector(7 downto 0) is S_hid_report(31 downto 24);
  signal S_mouse_update: std_logic;
  signal S_mouse_dy : std_logic_vector(7 downto 0); -- Y axis is negative
  signal S_mouse_dz : std_logic_vector(7 downto 0); -- Z axis is negative
  signal S_dbg_step_ps3, S_dbg_step_cmd: std_logic_vector(7 downto 0);
  signal R_dbg_step_ps3, R_dbg_step_cmd: std_logic_vector(7 downto 0);
  signal R_dbg_btn: std_logic_vector(2 downto 0);
begin
  usbhid_host_inst: entity usbhid_host
  generic map
  (
    C_differential_mode => false, -- try both true/false, one may work
    report_len => 4 -- bytes, don't touch
  )
  port map
  (
    clk => clk_usb,
    reset => usb_reset,
    usb_data(1) => usb_dp,
    usb_data(0) => usb_dn,
    usb_ddata => usb_dif,
    hid_report => S_hid_report(31 downto 0),
    hid_valid => S_valid,
    dbg_step_ps3 => S_dbg_step_ps3, -- debug
    dbg_step_cmd => S_dbg_step_cmd, -- debug
    leds => open -- led/open debug
  );
  -- cross clock domain
  process(clk)
  begin
    if rising_edge(clk) then
      R_valid <= S_valid & R_valid(R_valid'high downto 1);
      R_dbg_step_ps3 <= S_dbg_step_ps3;
      R_dbg_step_cmd <= S_dbg_step_cmd;
      R_dbg_btn <= A_mouse_btn;
    end if; -- rising_edge clk
  end process;
  S_mouse_update <= '1' when R_valid = "10" else '0'; -- rising edge of S_valid
  S_mouse_dy <= std_logic_vector(-signed(A_mouse_dy));
  S_mouse_dz <= std_logic_vector(-signed(A_mouse_dz));

  mouse2rgtr_e: entity hdl4fpga.scopeio_mouse2rgtr
  generic map
  (
    C_inputs    => C_inputs,
    C_tracesfg  => C_tracesfg,
    vlayout_id  => vlayout_id
  )
  port map
  (
    clk         => clk,

    mouse_update => S_mouse_update,
    mouse_dx    => signed(A_mouse_dx),
    mouse_dy    => signed(S_mouse_dy),
    mouse_dz    => signed(S_mouse_dz),
    mouse_btn   => A_mouse_btn,

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

  dbg_step_ps3 <= R_dbg_step_ps3;
  dbg_step_cmd <= R_dbg_step_cmd;
  dbg_btn <= R_dbg_btn;

end;
