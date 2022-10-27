-- (c)EMARD
-- License=GPL

-- USB-Serial, RXD only

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.usb_cdc_descriptor.all;

entity usbserial_rxd is
generic
(
  ethernet: boolean := false;
  ping: boolean := false; -- echo reply to raw pings
  -- debug for usb_serial in network mode will reply to nping
  -- ifconfig enx00aabbccddee 192.168.99.1
  -- nping -c 100 --privileged -delay 10ms -q1 --send-eth -e enx00aabbccddee --dest-mac 00:11:22:33:44:AA --data 0011223344556677  192.168.99.2
  -- tcpdump -i enx00aabbccddee -e -XX -n icmp
  test: boolean := false
);
port
(
  -- 48 MHz with "usb_rx_phy_48MHz.vhd" or 60 MHz with "usb_rx_phy_60MHz.vhd"
  clk_usb: in std_logic; -- 48 or 60 MHz

  -- FPGA direct USB connector
  usb_fpga_dp: in std_logic; -- differential or single-ended input
  --usb_fpga_dn: in std_logic; -- only for single-ended input
  usb_fpga_bd_dp, usb_fpga_bd_dn: inout std_logic; -- single ended bidirectional
  --usb_fpga_pu_dp, usb_fpga_pu_dn: inout std_logic; -- pull up for slave, down for host mode

  -- UART application
  clk: in std_logic;
  dv: out std_logic;
  byte: out std_logic_vector(7 downto 0);

  -- debug
  phy_rxvalid, phy_rxen,
  sync_err, bit_stuff_err, byte_err: out  std_logic 
);
end;

architecture Behavioral of usbserial_rxd is
  --signal clk_200MHz, clk_100MHz, clk_89MHz, clk_60MHz, clk_48MHz, clk_12MHz, clk_7M5Hz: std_logic;
  -- signal clk_usb: std_logic; -- 48 or 60 MHz
  signal S_led: std_logic;
  signal S_usb_rst: std_logic;
  signal R_rst_btn: std_logic;
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
  -- registers for OLED
  signal R_txdp, R_txdn: std_logic;
  signal R_OPMODE: std_logic_vector(1 downto 0);
  signal R_LINESTATE: std_logic_vector(1 downto 0);
  signal R_TXVALID: std_logic;
  signal R_TXREADY: std_logic;
  signal R_RXVALID: std_logic;
  signal R_RXACTIVE: std_logic;
  signal R_RXERROR: std_logic_vector(3 downto 0);
  signal R_DATAIN: std_logic_vector(7 downto 0);
  signal R_DATAOUT: std_logic_vector(7 downto 0);
  -- UTMI debug error counters
  signal R_sync_err, R_bit_stuff_err, R_byte_err: std_logic_vector(3 downto 0);

    constant RXBUFSIZE_BITS : integer := 11;
    constant TXBUFSIZE_BITS : integer := 10;
    constant BLAST_DUTY_OFF : integer := 7;
    constant BLAST_DUTY_ON :  integer := 5;

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

    function choose_descriptor(z: boolean; a, b: t_byte_array)
        return t_byte_array is
    begin
        if z then return a; else return b; end if;
    end function;

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
  
  phy_rxen <= S_txoe;
  phy_rxvalid <= S_rxvalid;

  -- USB-SERIAL soft-core loopback test
--  G_loopback_test: if test generate
--  usb_serial_core: entity hdl4fpga.usbtest
--  port map
--  (
--    CLK => clk_usb, -- application clock, any freq 7.5-200 MHz
--    led => S_led,
--    dsctyp => S_dsctyp, -- debug shows descriptor type
--    BREAK => S_BREAK,
--    PHY_DATABUS16_8 => S_DATABUS16_8,
--    PHY_RESET => S_RESET,
--    PHY_XCVRSELECT => S_XCVRSELECT,
--    PHY_TERMSELECT => S_TERMSELECT,
--    PHY_OPMODE => S_OPMODE,
--    PHY_CLKOUT => clk_usb, -- 48 or 60 MHz
--    PHY_TXVALID => S_TXVALID,
--    PHY_DATAOUT => S_DATAOUT,
--    PHY_TXREADY => S_TXREADY,
--    PHY_RXVALID => S_RXVALID,
--    PHY_DATAIN => S_DATAIN,
--    PHY_RXACTIVE => S_RXACTIVE,
--    PHY_RXERROR => S_RXERROR,
--    PHY_LINESTATE => S_LINESTATE
--  );
--  end generate;

  G_usbserial_normal: if not test generate
    -- Direct interface to serial data transfer component
    E_usb_serial: entity hdl4fpga.usb_serial
        generic map (
            descrom_fscfg   => choose_descriptor(ethernet, USBFS_CDC_config_ethernet, USBFS_CDC_config_serial), -- serial/ethernet
            descrom_hscfg   => choose_descriptor(ethernet, USBHS_CDC_config_ethernet, USBHS_CDC_config_serial), -- serial/ethernet
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
            CLK             => CLK,
            RESET           => usb_devreset,
            USBRST          => usb_busreset,
            HIGHSPEED       => usb_highspeed,
            SUSPEND         => usb_suspend,
            ONLINE          => usb_online,
            RXVAL           => usb_rxval,
            RXDAT           => usb_rxdat,
            RXRDY           => usb_rxrdy,
            RXLEN           => usb_rxlen,
            TXVAL           => usb_txval,
            TXDAT           => usb_txdat,
            TXRDY           => usb_txrdy,
            TXROOM          => usb_txroom,
            TXCORK          => usb_txcork,
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
  end generate;

  -- TODO: make connect output from USB-Serial core
  usb_rxrdy <= '1';
  dv <= usb_rxval;
  byte <= usb_rxdat;

  G_ping_reply: if ping generate
  B_send_ping_packets: block
  signal R_packet_raddr, R_packet_waddr, R_packet_addr_last: std_logic_vector(11 downto 0);
  type T_packet_buffer is array(0 to 2047) of std_logic_vector(7 downto 0);
  signal R_packet_buffer: T_packet_buffer := (others => x"00");
  signal R_usb_rxval: std_logic;
  signal S_start_tx: std_logic;

  -- rom swapper to simulate icmp echo response
  type T_swap_header is array(natural range <>) of integer range 0 to 35;
  constant C_swap_header : T_swap_header :=
  (
    6, 7, 8, 9,10,11, -- swap MAC
    0, 1, 2, 3, 4, 5,

    12,13,14,15,16,17,18,19,20,21,22,23,24,25,

    30,31,32,33, -- swap IP
    26,27,28,29,

    34,34  -- overwrites 0x80 with 0x00 to look like echo reply
  );
  signal S_swap_addr: integer;
  begin
  S_swap_addr <= C_swap_header(conv_integer(R_packet_waddr)) 
            when conv_integer(R_packet_waddr) < C_swap_header'length
            else conv_integer(R_packet_waddr);

  -- packet_receiver
  process(clk)
  begin
    if rising_edge(clk) then
      S_start_tx <= '0';
      if usb_rxval = '1' then
        R_packet_buffer(S_swap_addr) <= usb_rxdat;
        R_packet_waddr <= R_packet_waddr + 1;
      else
        if R_usb_rxval = '1' and usb_rxval = '0' then -- falling edge of rxval
          R_packet_addr_last <= R_packet_waddr - 1;
          R_packet_waddr <= (others => '0');
          S_start_tx <= '1';
        end if;
      end if;
      R_usb_rxval <= usb_rxval; -- for edge detection
    end if;
  end process;

  -- packet sender
  process(clk)
  begin
    if rising_edge(clk) then
      if S_start_tx = '1' and usb_txval = '0' and usb_txrdy = '1' then
        R_packet_raddr <= (others => '0');
        usb_txval <= '1';
      else
        if R_packet_raddr /= R_packet_addr_last then
          R_packet_raddr <= R_packet_raddr + 1;
        else
          usb_txval <= '0';
        end if;
      end if;
    end if;
  end process;
  usb_txcork <= usb_txval; -- after filling buffer, remove cork to burst out the packet
  usb_txdat <= R_packet_buffer(conv_integer(R_packet_raddr));
  end block;
  end generate;

end Behavioral;
