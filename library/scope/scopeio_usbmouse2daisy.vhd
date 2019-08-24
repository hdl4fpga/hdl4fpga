library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- glued USB mouse -> GUI event -> daisy chain interface

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.usbh_setup_pack.all;

entity scopeio_usbmouse2daisy is
generic
(
  C_usb_speed    : std_logic := '0'; -- '0' low speed is most often, '1' full speed very rare
  -- to render things correctly, GUI system needs to know:
  C_inputs       : integer; -- number of inputs
  C_tracesfg     : std_logic_vector; -- colors of traces
  vlayout_id     : integer := 0 -- screen geometry
);
port
(
  clk           : in  std_logic; -- 16-108 MHz usually same as VGA pixel clock
  clk_usb       : in  std_logic; -- 6 MHz for USB1.0
  -- hotplug detection and retry logic should we working
  -- so this reset is not needed
  usb_reset     : in  std_logic := '0'; -- USB mouse core reset
  -- USB interface
  usb_dp        : inout std_logic; -- USB D+ single ended
  usb_dn        : inout std_logic; -- UDB D- single ended
  usb_dif       : in    std_logic; -- USB D+,D- differential pair input
  -- HID report to display (clk_usb domain) - help for unsupported mouse.
  report_data   : out std_logic_vector;
  report_valid  : out std_logic;
  rx_count      : out std_logic_vector(15 downto 0); -- count of received report bytes
  rx_done       : out std_logic; -- take count when RX is done
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

  signal S_hid_report  : std_logic_vector(C_report_length*8-1 downto 0);
  signal S_hid_valid   : std_logic;
  signal S_mouse_btn   : std_logic_vector(2 downto 0); -- BTN state
  signal S_mouse_dx    : std_logic_vector(7 downto 0); -- X axis REL
  signal S_mouse_dy    : std_logic_vector(7 downto 0); -- Y axis REL
  signal S_mouse_dz    : std_logic_vector(7 downto 0); -- Z axis REL (wheel)
  signal S_mouse_update: std_logic;
begin
  usbhid_host_inst: entity hdl4fpga.usbh_host_hid
  generic map
  (
    C_usb_speed => C_usb_speed
  )
  port map
  (
    clk => clk_usb,
    bus_reset => usb_reset,
    usb_dp => usb_dp,
    usb_dn => usb_dn,
    usb_dif => usb_dif,
    rx_count => rx_count,
    rx_done => rx_done,
    hid_report => S_hid_report,
    hid_valid => S_valid
  );
  -- cross clock domain
  process(clk)
  begin
    if rising_edge(clk) then
      R_valid <= S_valid & R_valid(R_valid'high downto 1);
    end if; -- rising_edge clk
  end process;
  S_hid_valid <= '1' when R_valid = "10" else '0'; -- rising edge of S_valid

  report_decoder_e: entity  hdl4fpga.usbh_report_decoder
  port map
  (
    clk => clk,
    hid_report => S_hid_report,
    hid_valid  => S_hid_valid,
    btn        => S_mouse_btn,
    dx         => S_mouse_dx,
    dy         => S_mouse_dy,
    dz         => S_mouse_dz,
    update     => S_mouse_update
  );

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
  report_data   <= S_hid_report;
  report_valid  <= S_valid;
end;
