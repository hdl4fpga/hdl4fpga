-- (c)EMARD
-- License=GPL

-- glued FPGA transiever and USB11 soft core PHY

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;

library hdl4fpga;

entity usb11_phy_transciever is
  generic
  (
    C_usb_speed: std_logic := '0' -- '0':6 MHz low speed '1':48 MHz full speed 
  );
  port
  (
    clk               : in    std_logic;  -- main clock input
    resetn            : in    std_logic;
    -- USB hardware D+/D- direct to FPGA
    usb_dif           : in    std_logic; -- differential or single-ended input
    usb_dp, usb_dn    : inout std_logic; -- single ended bidirectional
    -- UTMI interface
    utmi_txready_o    : out   std_logic;
    utmi_data_o       : out   std_logic_vector(7 downto 0);
    utmi_rxvalid_o    : out   std_logic;
    utmi_rxactive_o   : out   std_logic;
    utmi_rxerror_o    : out   std_logic;
    utmi_linestate_o  : out   std_logic_vector(1 downto 0);
    utmi_linectrl_i   : in    std_logic;
    utmi_data_i       : in    std_logic_vector(7 downto 0);
    utmi_txvalid_i    : in    std_logic;
    -- UTMI debug
    txoe_o, ce_o: out std_logic;
    utmi_sync_err_o, utmi_bit_stuff_err_o, utmi_byte_err_o: out std_logic
  );
end;

architecture Behavioral of usb11_phy_transciever is
  signal S_rxd: std_logic;
  signal S_rxdp, S_rxdn: std_logic;
  signal S_txdp, S_txdn, S_txoe: std_logic;
  begin
  G_usb_full_speed: if C_usb_speed = '1' generate
  -- transciever soft-core
  --usb_fpga_pu_dp <= '0'; -- D+ pulldown for USB host mode
  --usb_fpga_pu_dn <= '0'; -- D- pulldown for USB host mode
  S_rxd <= usb_dif; -- differential input reads D+
  --S_rxd <= usb_dp; -- single-ended input reads D+ may work as well
  S_rxdp <= usb_dp; -- single-ended input reads D+
  S_rxdn <= usb_dn; -- single-ended input reads D-
  usb_dp <= S_txdp when S_txoe = '0' else 'Z';
  usb_dn <= S_txdn when S_txoe = '0' else 'Z';
  end generate;

  G_usb_low_speed: if C_usb_speed = '0' generate
  -- transciever soft-core
  -- for low speed USB, here are swaped D+ and D-
  --usb_fpga_pu_dp <= '0'; -- D+ pulldown for USB host mode
  --usb_fpga_pu_dn <= '0'; -- D- pulldown for USB host mode
  S_rxd <= not usb_dif; -- differential input reads inverted D+ for low speed
  --S_rxd <= not usb_dp; -- single-ended input reads D+ may work as well
  S_rxdp <= usb_dn; -- single-ended input reads D- for low speed
  S_rxdn <= usb_dp; -- single-ended input reads D+ for low speed
  usb_dp <= S_txdn when S_txoe = '0' else 'Z';
  usb_dn <= S_txdp when S_txoe = '0' else 'Z';
  end generate;

  -- USB1.1 PHY soft-core
  usb11_phy: entity hdl4fpga.usb_phy
  generic map
  (
    usb_rst_det => false
  )
  port map
  (
    clk => clk, -- full speed: 48 MHz or 60 MHz, low speed: 6 MHz or 7.5 MHz
    rst => resetn, -- 1-don't reset, 0-hold reset
    phy_tx_mode => '1', -- 1-differential, 0-single-ended
    usb_rst => open, -- USB host requests reset, sending signal to usb-serial core
    -- clock recovery debug
    ce_o => ce_o,
    -- UTMI interface to usb-serial core
    LineCtrl_i => utmi_linectrl_i,
    TxValid_i => utmi_txvalid_i,
    DataOut_i => utmi_data_i, -- 8-bit TX
    TxReady_o => utmi_txready_o,
    RxValid_o => utmi_rxvalid_o,
    DataIn_o => utmi_data_o, -- 8-bit RX
    RxActive_o => utmi_rxactive_o,
    RxError_o => utmi_rxerror_o,
    LineState_o => utmi_linestate_o, -- 2-bit
    -- debug interface
    sync_err_o => utmi_sync_err_o,
    bit_stuff_err_o => utmi_bit_stuff_err_o,
    byte_err_o => utmi_byte_err_o,
    -- transciever interface to hardware
    rxd => S_rxd, -- differential input from D+
    rxdp => S_rxdp, -- single-ended input from D+
    rxdn => S_rxdn, -- single-ended input from D-
    txdp => S_txdp, -- single-ended output to D+
    txdn => S_txdn, -- single-ended output to D-
    txoe => S_txoe  -- 3-state control: 0-output, 1-input
  );
  txoe_o <= S_txoe;
end;
