-- (c)EMARD
-- License=GPL

-- USB-Ethernet MII

-- difference from wired MII:
-- do not send or expect to receive 8-byte preamble at beginning of the packet
-- do not send or expect to receive 4-byte CRC at the end of packet

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.usb_cdc_descriptor.all;

entity usb_mii is
port
(
  -- 48 MHz with "usb_rx_phy_48MHz.vhd" or 60 MHz with "usb_rx_phy_60MHz.vhd"
  clk_usb: in std_logic; -- 48 or 60 MHz

  -- FPGA direct USB connector
  usb_fpga_dp: in std_logic; -- differential or single-ended input
  --usb_fpga_dn: in std_logic; -- only for single-ended input
  usb_fpga_bd_dp, usb_fpga_bd_dn: inout std_logic; -- single ended bidirectional
  --usb_fpga_pu_dp, usb_fpga_pu_dn: inout std_logic; -- pull up for slave, down for host mode

  -- MII ethernet application
  mii_clk     : in  std_logic;
  mii_txvalid : in  std_logic;
  mii_txdata  : in  std_logic_vector(7 downto 0);
  mii_rxvalid : out std_logic;
  mii_rxdata  : out std_logic_vector(7 downto 0);

  -- debug
  sync_err, bit_stuff_err, byte_err:  out std_logic 
);
end;

architecture Behavioral of usb_mii is
  signal S_usb_rst: std_logic;
  signal R_phy_txmode: std_logic;
  signal S_rxd: std_logic;
  signal S_rxdp, S_rxdn: std_logic;
  signal S_txdp, S_txdn, S_txoe: std_logic;
  signal S_dsctyp: std_logic_vector(2 downto 0);
  signal S_DATABUS16_8: std_logic;
  signal S_RESET: std_logic;
  signal S_XCVRSELECT: std_logic;
  signal S_TERMSELECT: std_logic;
  signal S_OPMODE: std_logic_vector(1 downto 0);
  signal S_LINESTATE: std_logic_vector(1 downto 0);
  signal S_TXVALID: std_logic;
  signal S_TXREADY: std_logic;
  signal S_RXVALID: std_logic;
  signal S_RXACTIVE: std_logic;
  signal S_RXERROR: std_logic;
  signal S_DATAIN: std_logic_vector(7 downto 0);
  signal S_DATAOUT: std_logic_vector(7 downto 0);
  signal S_BREAK: std_logic;
  --signal S_ulpi_data_out_i, S_ulpi_data_in_o: std_logic_vector(7 downto 0);
  --signal S_ulpi_dir_i: std_logic;
  -- UTMI debug
  signal S_sync_err, S_bit_stuff_err, S_byte_err: std_logic;

    constant RXBUFSIZE_BITS : integer := 11; -- 2KB
    constant TXBUFSIZE_BITS : integer := 11; -- 2KB

    -- USB interface signals
    signal usb_devreset :   std_logic;
    signal usb_busreset :   std_logic;
    signal usb_highspeed :  std_logic;
    signal usb_suspend :    std_logic;
    signal usb_online :     std_logic;
    signal usb_rxval :      std_logic;
    signal usb_rxdat :      std_logic_vector(7 downto 0);
    signal usb_rxrdy :      std_logic;
    signal usb_rxlen :      std_logic_vector(RXBUFSIZE_BITS-1 downto 0);
    signal usb_txval :      std_logic;
    signal usb_txdat :      std_logic_vector(7 downto 0);
    signal usb_txrdy :      std_logic;
    signal usb_txroom :     std_logic_vector(TXBUFSIZE_BITS-1 downto 0);
    signal usb_txcork :     std_logic := '0';

begin
  -- USB1.1 PHY soft-core
  usb11_phy: entity hdl4fpga.usb_phy
  generic map
  (
    usb_rst_det => true
  )
  port map
  (
    clk => clk_usb, -- 48 MHz or 60 MHz
    rst => '1', -- 1-don't reset, 0-hold reset
    phy_tx_mode => '1', -- 1-differential, 0-single-ended
    usb_rst => S_usb_rst, -- USB host requests reset, sending signal to usb-serial core
    -- UTMI interface to usb-serial core
    TxValid_i => S_TXVALID,
    DataOut_i => S_DATAOUT, -- 8-bit TX
    TxReady_o => S_TXREADY,
    RxValid_o => S_RXVALID,
    DataIn_o => S_DATAIN, -- 8-bit RX
    RxActive_o => S_RXACTIVE,
    RxError_o => S_RXERROR,
    LineState_o => S_LINESTATE, -- 2-bit
    -- debug interface
    sync_err_o => S_sync_err,
    bit_stuff_err_o => S_bit_stuff_err,
    byte_err_o => S_byte_err,
    -- transciever interface to hardware
    rxd => S_rxd, -- differential input from D+
    rxdp => S_rxdp, -- single-ended input from D+
    rxdn => S_rxdn, -- single-ended input from D-
    txdp => S_txdp, -- single-ended output to D+
    txdn => S_txdn, -- single-ended output to D-
    txoe => S_txoe  -- 3-state control: 0-output, 1-input
  );
  -- transciever soft-core
  --usb_fpga_pu_dp <= '1'; -- D+ pullup for USB1.1 device mode
  --usb_fpga_pu_dn <= 'Z'; -- D- no pullup for USB1.1 device mode
  S_rxd <= usb_fpga_dp; -- differential input reads D+
  --S_rxd <= usb_fpga_bd_dp; -- single-ended input reads D+ may work as well
  S_rxdp <= usb_fpga_bd_dp; -- single-ended input reads D+
  S_rxdn <= usb_fpga_bd_dn; -- single-ended input reads D-
  usb_fpga_bd_dp <= S_txdp when S_txoe = '0' else 'Z';
  usb_fpga_bd_dn <= S_txdn when S_txoe = '0' else 'Z';

  -- USB-Serial core with Ethernet descriptor
  E_usb_serial: entity hdl4fpga.usb_serial
        generic map (
            descrom_fscfg   => USBFS_CDC_config_ethernet,
            descrom_hscfg   => USBHS_CDC_config_ethernet,
            VENDORID        => X"fb9a",
            PRODUCTID       => X"fb9a",
            VERSIONBCD      => X"0031",
            VENDORSTR       => "HDL4FPGA",
            PRODUCTSTR      => "Scopeio",
            SERIALSTR       => "00AABBCCDDEE", -- MAC for ethernet
            HSSUPPORT       => false,
            SELFPOWERED     => false,
            RXBUFSIZE_BITS  => RXBUFSIZE_BITS,
            TXBUFSIZE_BITS  => TXBUFSIZE_BITS )
        port map (
            CLK             => mii_clk,
            RESET           => usb_devreset,
            USBRST          => usb_busreset,
            HIGHSPEED       => usb_highspeed,
            SUSPEND         => usb_suspend,
            ONLINE          => usb_online,
            RXVAL           => mii_rxvalid,
            RXDAT           => mii_rxdata,
            RXRDY           => '1', -- eveready
            RXLEN           => usb_rxlen,
            TXVAL           => mii_txvalid,
            TXDAT           => mii_txdata,
            TXRDY           => usb_txrdy,
            TXROOM          => usb_txroom,
            TXCORK          => mii_txvalid, -- to burst buffered data as packet
            -- BREAK           => BREAK,
            -- dsctyp          => dsctyp, -- debugging
            PHY_CLK         => clk_usb,
            PHY_DATAIN      => S_DATAIN,
            PHY_DATAOUT     => S_DATAOUT,
            PHY_TXVALID     => S_TXVALID,
            PHY_TXREADY     => S_TXREADY,
            PHY_RXACTIVE    => S_RXACTIVE,
            PHY_RXVALID     => S_RXVALID,
            PHY_RXERROR     => S_RXERROR,
            PHY_LINESTATE   => S_LINESTATE,
            PHY_OPMODE      => S_OPMODE,
            PHY_XCVRSELECT  => S_XCVRSELECT,
            PHY_TERMSELECT  => S_TERMSELECT,
            PHY_RESET       => S_RESET
        );

end Behavioral;
