-- (c)EMARD
-- License=BSD

-- USB HOST for HID devices
-- drives SIE directly

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.usbh_setup_pack.all;

entity usbh_host_hid is
  generic
  (
    C_usb_speed: std_logic := '0' -- '0':6 MHz low speed '1':48 MHz full speed 
  );
  port
  (
    clk: in std_logic;  -- main clock input
    -- FPGA direct USB connector
    usb_dif: in std_logic; -- differential or single-ended input
    usb_dp, usb_dn: inout std_logic; -- single ended bidirectional
    -- force bus reset and setup (similar to re-plugging USB device)
    bus_reset: in std_logic := '0';
    -- HID report
    hid_report: out std_logic_vector(C_report_length*8-1 downto 0);
    hid_valid: out std_logic
  );
end;

architecture Behavioral of usbh_host_hid is
  signal clk_usb: std_logic; -- 48 or 60 MHz
  signal S_led: std_logic;
  signal S_usb_rst: std_logic;
  signal S_rxd: std_logic;
  signal S_rxdp, S_rxdn: std_logic;
  signal S_txdp, S_txdn, S_txoe: std_logic;
  signal S_oled: std_logic_vector(63 downto 0);
  signal S_dsctyp: std_logic_vector(2 downto 0);
  signal S_DATABUS16_8: std_logic;
  signal S_RESET: std_logic;
  signal S_XCVRSELECT: std_logic_vector(1 downto 0);
  signal S_OPMODE: std_logic_vector(1 downto 0);
  signal S_LINESTATE: std_logic_vector(1 downto 0);
  signal S_LINECTRL: std_logic;
  signal S_TXVALID: std_logic;
  signal S_TXREADY: std_logic;
  signal S_RXVALID: std_logic;
  signal S_RXACTIVE: std_logic;
  signal S_RXERROR: std_logic;
  signal S_DATAIN: std_logic_vector(7 downto 0);
  signal S_DATAOUT: std_logic_vector(7 downto 0);
  signal S_BREAK: std_logic;

  -- UTMI debug
  signal S_sync_err, S_bit_stuff_err, S_byte_err: std_logic;

  signal R_setup_rom_addr, R_setup_rom_addr_acked: std_logic_vector(7 downto 0) := (others => '0');
  constant C_setup_rom_len: std_logic_vector(R_setup_rom_addr'range) := 
    std_logic_vector(to_unsigned(C_setup_rom'length,8));

  --signal S_DATAOUT_reset: std_logic_vector(7 downto 0); -- mixed in reset signal

  signal   R_state:          std_logic_vector(2 downto 0)    := "000";
  constant C_STATE_DETACHED: std_logic_vector(R_state'range) := "000";
  constant C_STATE_RESET:    std_logic_vector(R_state'range) := "001";
  constant C_STATE_SETUP:    std_logic_vector(R_state'range) := "010";
  constant C_STATE_REQUEST:  std_logic_vector(R_state'range) := "011";
  constant C_STATE_RESPONSE: std_logic_vector(R_state'range) := "100";

  signal R_retry: std_logic_vector(C_setup_retry downto 0);
  signal R_slow: std_logic_vector(17 downto 0) := (others => '0'); -- 2**17 clocks = 20 ms interval at 6 MHz
  signal R_reset_pending : std_logic;
  signal R_timeout: std_logic; -- rising edge tracking

  -- sie wires
  signal  rst_i             :  std_logic;
  signal  start_i           :  std_logic := '0';
  signal  in_transfer_i     :  std_logic := '0';
  signal  sof_transfer_i    :  std_logic := '0';
  signal  resp_expected_i   :  std_logic := '0';
  signal  token_pid_i       :  std_logic_vector(7 downto 0) := (others => '0');
  signal  token_dev_i       :  std_logic_vector(6 downto 0) := (others => '0');
  signal  token_ep_i        :  std_logic_vector(3 downto 0) := (others => '0');
  signal  data_len_i        :  std_logic_vector(15 downto 0) := (others => '0');
  signal  data_idx_i        :  std_logic := '0';
  signal  tx_data_i         :  std_logic_vector(7 downto 0) := (others => '0');

  signal  ack_o             :  std_logic;
  signal  tx_pop_o          :  std_logic;
  signal  rx_data_o         :  std_logic_vector(7 downto 0);
  signal  rx_push_o         :  std_logic;
  signal  tx_done_o         :  std_logic;
  signal  rx_done_o         :  std_logic;
  signal  crc_err_o         :  std_logic;
  signal  timeout_o         :  std_logic;
  signal  response_o        :  std_logic_vector(7 downto 0);
  signal  rx_count_o        :  std_logic_vector(15 downto 0);
  signal  idle_o            :  std_logic;
  begin
  G_usb_full_speed: if C_usb_speed = '1' generate
  clk_usb <= clk; -- 48 MHz with "usb_rx_phy_48MHz.vhd" or 60 MHz with "usb_rx_phy_60MHz.vhd"
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
  clk_usb <= clk; -- 6 MHz
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
    usb_rst_det => true
  )
  port map
  (
    clk => clk_usb, -- full speed: 48 MHz or 60 MHz, low speed: 6 MHz or 7.5 MHz
    rst => '1', -- 1-don't reset, 0-hold reset
    phy_tx_mode => '1', -- 1-differential, 0-single-ended
    usb_rst => S_usb_rst, -- USB host requests reset, sending signal to usb-serial core
    -- UTMI interface to usb-serial core
    LineCtrl_i => S_LINECTRL,
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

  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      R_timeout <= timeout_o;
      if sof_transfer_i = '1' then
        R_setup_rom_addr       <= (others => '0');
        R_setup_rom_addr_acked <= (others => '0');
        R_retry                <= (others => '0');
        R_reset_pending <= '0';
      else
        if bus_reset = '1' then
          R_reset_pending <= '1';
        end if;
        if rx_done_o = '1' or (timeout_o = '1' and R_timeout = '0') then
          -- tranmission is over (either rx done or timeout rising edge).
          if R_state = C_STATE_SETUP then
            -- decide to continue with next setup or to retry
            if rx_done_o = '1' and response_o = x"D2" then -- ACK
              -- continue with next setup
              R_setup_rom_addr_acked <= R_setup_rom_addr;
              R_retry <= (others => '0');
            else -- failed, rewind to unacknowledged setup and retry
              R_setup_rom_addr <= R_setup_rom_addr_acked;
              if R_retry(R_retry'high) = '0' then
                R_retry <= R_retry + 1;
              end if;
            end if;
          end if; -- not in SETUP
          if R_state = C_STATE_RESPONSE then
            -- multiple timeouts at waiting for response will detach
            if timeout_o = '1' and R_timeout = '0' then
              if R_retry(R_retry'high) = '0' then
                R_retry <= R_retry + 1;
              end if;
            else
              if rx_done_o = '1' then
                R_retry <= (others => '0');
              end if;
            end if;
          end if;
        else -- transmission is going on
          if tx_pop_o = '1' then
            R_setup_rom_addr <= R_setup_rom_addr + 1;
          end if;
        end if; -- transmission done
      end if; -- reset accepted
    end if; -- rising edge
  end process;
  tx_data_i <= C_setup_rom(conv_integer(R_setup_rom_addr));

  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      case R_state is
        when C_STATE_DETACHED =>
          if S_LINESTATE = "01" then
            if R_slow(R_slow'high) = '0' then
              R_slow <= R_slow + 1;
            else
              R_slow <= (others => '0');
              sof_transfer_i  <= '1';   -- transfer SOF or linectrl
              in_transfer_i   <= '1';   -- 0:SOF, 1:linectrl
              token_pid_i(1 downto 0) <= "11"; -- linectrl: bus reset
              resp_expected_i <= '0';
              start_i         <= '1';
              R_state <= C_STATE_RESET;
            end if;
          else
            start_i <= '0';
            R_slow <= (others => '0');
          end if;
        when C_STATE_RESET =>
          sof_transfer_i <= '0';
          start_i        <= '0';
          if idle_o = '1' then
            if R_slow(C_setup_interval) = '0' then
              R_slow <= R_slow + 1;
            else
              R_slow <= (others => '0');
              R_state <= C_STATE_SETUP;
            end if;
          end if;
        when C_STATE_SETUP =>
          if R_setup_rom_addr /= C_setup_rom_len then
            if idle_o = '1' then
              if R_slow(C_setup_interval) = '0' then
                R_slow <= R_slow + 1;
                if R_retry(R_retry'high) = '1' then
                  R_state <= C_STATE_DETACHED;
                end if;
              else
                R_slow <= (others => '0');
                in_transfer_i   <= '0';
                token_pid_i     <= x"2D";
                token_dev_i     <= (others => '0');
                token_ep_i      <= x"0";
                data_len_i      <= x"0008";
                data_idx_i      <= '0';
                resp_expected_i <= '1';
                start_i         <= '1';
              end if;
            else
              start_i <= '0';
            end if;
          else
            start_i <= '0';
            if idle_o = '1' then
              if R_slow(C_setup_interval) = '0' then
                R_slow <= R_slow + 1;
              else
                R_state <= C_STATE_REQUEST;
              end if;
            end if;
          end if;
        when C_STATE_REQUEST =>
          if idle_o = '1' then
            if R_slow(C_report_interval) = '0' then
                R_slow <= R_slow + 1;
                start_i <= '0';
            else
                R_slow <= (others => '0');
-- HOST: < SYNC ><  IN  ><ADR0>EP1 CRC5
-- D+ ___-_-_-_---_--___-_-_-_-__-_-_--________
-- D- ---_-_-_-___-__---_-_-_-_--_-_-__--__----
--       00000001100101100000000100000101
--       < 0  8 >< 9  6 ><  0  ><1 ><CRC>
                in_transfer_i   <= '1';
                token_pid_i     <= x"69";
                token_dev_i     <= std_logic_vector(to_unsigned(C_device_address,7));
                token_ep_i      <= std_logic_vector(to_unsigned(C_report_endpoint,4));
                data_len_i      <= (others => '0');
                data_idx_i      <= '0';
                resp_expected_i <= '1';
                start_i         <= '1';
                R_state <= C_STATE_RESPONSE;
            end if;
          else
            start_i <= '0';
          end if;
        when others => -- C_STATE_RESPONSE
          start_i <= '0';
          if idle_o = '1' then
            if R_slow(C_report_interval) = '0' then
              R_slow <= R_slow + 1;
            else
              R_slow <= (others => '0');
              if R_reset_pending = '1' or S_LINESTATE = "00" or R_retry(R_retry'high) = '1' then
                R_state <= C_STATE_DETACHED;
              else
                R_state <= C_STATE_REQUEST;
              end if;
            end if;
          end if;
      end case;
    end if;
  end process;

  -- USB SIE-core
  usb_sie_core: entity hdl4fpga.usbh_sie_vhdl
  generic map
  (
    full_speed  => C_usb_speed
  )
  port map
  (
    clk_i             => clk_usb, -- low speed: 6 MHz or 7.5 MHz, high speed: 48 MHz or 60 MHz
    rst_i             => rst_i,
    start_i           => start_i,
    in_transfer_i     => in_transfer_i,
    sof_transfer_i    => sof_transfer_i,
    resp_expected_i   => resp_expected_i,
    token_pid_i       => token_pid_i,
    token_dev_i       => token_dev_i,
    token_ep_i        => token_ep_i,
    data_len_i        => data_len_i,
    data_idx_i        => data_idx_i,
    tx_data_i         => tx_data_i,

    ack_o             => ack_o,
    tx_pop_o          => tx_pop_o,
    rx_data_o         => rx_data_o,
    rx_push_o         => rx_push_o,
    tx_done_o         => tx_done_o,
    rx_done_o         => rx_done_o,
    crc_err_o         => crc_err_o,
    timeout_o         => timeout_o,
    response_o        => response_o,
    rx_count_o        => rx_count_o,
    idle_o            => idle_o,

    utmi_txready_i    => S_TXREADY,
    utmi_data_i       => S_DATAIN,
    utmi_rxvalid_i    => S_RXVALID,
    utmi_rxactive_i   => S_RXACTIVE,
    utmi_linectrl_o   => S_LINECTRL,
    utmi_data_o       => S_DATAOUT,
    utmi_txvalid_o    => S_TXVALID
  );

  B_report_reader: block
    type T_report_buf is array(0 to C_report_length-1) of std_logic_vector(7 downto 0);
    signal R_report_buf: T_report_buf;
    signal R_rx_count: std_logic_vector(rx_count_o'range);
    signal R_hid_valid: std_logic;
  begin
    process(clk_usb)
    begin
      if rising_edge(clk_usb) then
        R_rx_count <= rx_count_o; -- to offload routing (apart from this, "rx_count_o" could be used directly)
        if rx_push_o = '1' then
          R_report_buf(conv_integer(R_rx_count)) <= rx_data_o;
        end if;
        if rx_done_o = '1' and crc_err_o = '0' and timeout_o = '0' 
        and R_state = C_STATE_RESPONSE
        and R_rx_count = std_logic_vector(to_unsigned(C_report_length,rx_count_o'length))
        then
          R_hid_valid <= '1';
        else
          R_hid_valid <= '0';
        end if;
      end if;  
    end process;
    G_report: 
    for i in 0 to C_report_length-1 generate
      hid_report(i*8+7 downto i*8) <= R_report_buf(i);
    end generate;
    hid_valid <= R_hid_valid;
  end block;
end Behavioral;
