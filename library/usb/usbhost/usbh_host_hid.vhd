-- (c)EMARD
-- License=GPL

-- USB HOST for HID devices
-- drives SIE directly

-- suggested reading
-- http://www.usbmadesimple.co.uk/
-- online USB descriptor parser
-- https://eleccelerator.com/usbdescreqparser/

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
    -- HID debugging
    rx_count: out std_logic_vector(15 downto 0); -- rx response length
    rx_done: out std_logic; -- rx done
    -- HID report (filtered with expected length)
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

  signal ctrlin : std_logic;
  signal ctrlout0 : std_logic;
  signal data_phase : std_logic;
  
  signal R_packet_counter : std_logic_vector(15 downto 0);
  
  signal   R_state:           std_logic_vector(1 downto 0)    := "00";
  constant C_STATE_DETACHED : std_logic_vector(R_state'range) := "00";
  constant C_STATE_SETUP    : std_logic_vector(R_state'range) := "01";
  constant C_STATE_REPORT   : std_logic_vector(R_state'range) := "10";
  constant C_STATE_STATUS   : std_logic_vector(R_state'range) := "11";

  signal R_retry: std_logic_vector(C_setup_retry downto 0);
  signal R_slow: std_logic_vector(17 downto 0) := (others => '0'); -- 2**17 clocks = 20 ms interval at 6 MHz
  signal R_reset_pending: std_logic;
  signal R_reset_accepted : std_logic;

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

  signal R_set_address_found:  std_logic;
  signal R_dev_address_requested :  std_logic_vector(token_dev_i'range);
  signal R_dev_address_confirmed :  std_logic_vector(token_dev_i'range);

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

  -- address advance, retry logic, set_address accpetance
  B_address_retry: block
    signal S_transmission_over: std_logic;
    signal R_timeout: std_logic; -- rising edge tracking
  begin
  S_transmission_over <= '1' when rx_done_o = '1' or (timeout_o = '1' and R_timeout = '0') else '0';
  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      R_timeout <= timeout_o;
      if R_reset_accepted = '1' then
        R_setup_rom_addr       <= (others => '0');
        R_setup_rom_addr_acked <= (others => '0');
        R_retry                <= (others => '0');
        R_reset_pending <= '0';
      else
        if bus_reset = '1' then
          R_reset_pending <= '1';
        end if;
        case R_state is
          when C_STATE_DETACHED => -- start from unitialized device
            R_dev_address_confirmed <= (others => '0');
            R_retry <= (others => '0');
          when C_STATE_SETUP =>
            if S_transmission_over = '1' then
              -- decide to continue with next setup or to retry
              if rx_done_o = '1' and response_o = x"D2" and token_pid_i = x"2D" then -- ACK to SETUP
                -- continue with next setup
                R_setup_rom_addr_acked <= R_setup_rom_addr;
                R_retry <= (others => '0');
              else -- failed, rewind to unacknowledged setup and retry
                R_setup_rom_addr <= R_setup_rom_addr_acked;
                if R_retry(R_retry'high) = '0' then
                  R_retry <= R_retry + 1;
                end if;
              end if;
              if rx_done_o = '1' and token_pid_i = x"69" then -- ACK to IN
                R_dev_address_confirmed <= R_dev_address_requested;
              end if;
            else -- transmission is going on -- advance address
              if tx_pop_o = '1' then
                R_setup_rom_addr <= R_setup_rom_addr + 1;
              end if;
            end if;
          when C_STATE_REPORT =>
            if S_transmission_over = '1' then
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
        end case;
      end if; -- reset accepted
    end if; -- rising edge
  end process;
  tx_data_i <= C_setup_rom(conv_integer(R_setup_rom_addr));
  end block;

  B_requested_set_address: block
    signal R_first_byte_0_found: std_logic;
  begin
  -- NOTE: it works only if each setup packet in ROM is 8 bytes
  -- if data is added to ROM, then R_setup_rom_addr should be
  -- replaced with another register that tracks actual offset from
  -- setup packet
  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      if R_setup_rom_addr(2 downto 0) = "000" then -- every 8 bytes, 1st byte
        if tx_data_i = x"00" then
          R_first_byte_0_found <= '1';
        else
          R_first_byte_0_found <= '0';
        end if;
      end if;
      if R_state = C_STATE_DETACHED then -- at reset
        R_dev_address_requested <= (others => '0');
      else
        if R_setup_rom_addr(2 downto 0) = "001" then -- every 8 bytes, 2nd byte
          if tx_data_i = x"05" then
            R_set_address_found <= R_first_byte_0_found;
          end if;
        else
          if R_setup_rom_addr(2 downto 0) = "010" and R_set_address_found = '1' then -- every 8 bytes, 3rd byte
            R_dev_address_requested <= tx_data_i(token_dev_i'range);
          end if;
          R_set_address_found <= '0';
        end if;
      end if;
    end if;
  end process;
  end block;

  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      case R_state is
        when C_STATE_DETACHED => -- start from unitialized device
          R_reset_accepted <= '0';
          if S_LINESTATE = "01" then
            if R_slow(R_slow'high) = '0' then
              R_slow <= R_slow + 1;
            else
              R_slow <= (others => '0');
              sof_transfer_i  <= '1';   -- transfer SOF or linectrl
              in_transfer_i   <= '1';   -- 0:SOF, 1:linectrl
              token_pid_i(1 downto 0) <= "11"; -- linectrl: bus reset
              token_dev_i     <= (others => '0'); -- after reset device address will be 0
              resp_expected_i <= '0';
              ctrlin          <= '0';
              data_phase      <= '0';
              start_i         <= '1';
              R_packet_counter <= (others => '0');
              R_state <= C_STATE_SETUP;
            end if;
          else
            start_i <= '0';
            R_slow <= (others => '0');
          end if;
        when C_STATE_SETUP => -- send setup sequence (enumeration)
            if idle_o = '1' then
              if R_slow(C_setup_interval) = '0' then
                R_slow <= R_slow + 1;
                if R_retry(R_retry'high) = '1' then
                  R_reset_accepted <= '1';
                  R_state <= C_STATE_DETACHED;
                end if;
                if R_slow(11 downto 0) = x"880" then -- keepalive: first at 0.35 ms, then every 0.68 ms
                  -- keepalive signal
                  sof_transfer_i  <= '1';   -- transfer SOF or linectrl
                  in_transfer_i   <= '1';   -- 0:SOF, 1:linectrl
                  token_pid_i(1 downto 0) <= "00"; -- linectrl: keepalive
                  resp_expected_i <= '0';
                  start_i         <= C_keepalive_setup;
                else
                  start_i         <= '0';
                end if;
              else -- time passed, send next setup packet or read status or read response
                R_slow <= (others => '0');
                sof_transfer_i  <= '0';
                token_ep_i      <= x"0";
                resp_expected_i <= '1';
                if data_phase = '1' then
                  data_phase <= '0';
                  if ctrlin = '1' then
                    -- IN phase and then OUT 0-length
                    in_transfer_i   <= '1';
                    token_pid_i     <= x"69";
                    if ctrlout0 = '1' then
                      R_state <= C_STATE_STATUS; -- OUT 0-length
                    end if;
                  else
                    -- OUT phase (currently 0-length only)
                    in_transfer_i   <= '0';
                    token_pid_i     <= x"E1";
                    data_len_i      <= x"0000"; -- TODO allow nonzero data length by parsing setup packet wLength
                    data_idx_i      <= '1';
                  end if;
                  R_packet_counter <= R_packet_counter + 1;
                  start_i         <= '1';
                else -- next setup packet (not status)
                  token_dev_i <= R_dev_address_confirmed;
                  if R_setup_rom_addr = C_setup_rom_len then
                    R_state <= C_STATE_REPORT;
                    start_i <= '0';
                  else
                    data_phase      <= tx_data_i(7);
                    ctrlin          <= tx_data_i(7);
                    ctrlout0        <= '1';
                    in_transfer_i   <= '0';
                    token_pid_i     <= x"2D";
                    data_len_i      <= x"0008";
                    data_idx_i      <= '0';
                    R_packet_counter <= R_packet_counter + 1;
                    start_i         <= '1';
                  end if;
                end if;
              end if;
            else
              if R_set_address_found = '1' then
                -- set address is special:
                -- it should IN data phase (0-length packet response is expected)
                -- it should not OUT 0-length packet after IN
                data_phase <= '1';
                ctrlin     <= '1';
                ctrlout0   <= '0';
              end if;
              start_i <= '0';
            end if;
--          else
--            start_i <= '0';
--            R_state <= C_STATE_REPORT;
 --         end if;
        when C_STATE_REPORT => -- request report (send IN request)
          if idle_o = '1' then
            if R_slow(C_report_interval) = '0' then
              R_slow <= R_slow + 1;
              if R_slow(11 downto 0) = x"880" then -- keepalive: first at 0.35 ms, then every 0.68 ms
                -- keepalive signal
                sof_transfer_i  <= '1';   -- transfer SOF or linectrl
                in_transfer_i   <= '1';   -- 0:SOF, 1:linectrl
                token_pid_i(1 downto 0) <= "00"; -- linectrl: keepalive
                resp_expected_i <= '0';
                start_i         <= C_keepalive_report;
              else
                start_i         <= '0';
              end if;
            else
              R_slow <= (others => '0');
-- HOST: < SYNC ><  IN  ><ADR0>EP1 CRC5
-- D+ ___-_-_-_---_--___-_-_-_-__-_-_--________
-- D- ---_-_-_-___-__---_-_-_-_--_-_-__--__----
--       00000001100101100000000100000101
--       < 0  8 >< 9  6 ><  0  ><1 ><CRC>
              sof_transfer_i  <= '0';
              in_transfer_i   <= '1';
              token_pid_i     <= x"69";
              token_ep_i      <= std_logic_vector(to_unsigned(C_report_endpoint,token_ep_i'length));
              data_idx_i      <= '0';
--              R_packet_counter <= R_packet_counter + 1;
              resp_expected_i <= '1';
              start_i         <= '1';
              if R_reset_pending = '1' or S_LINESTATE = "00" or R_retry(R_retry'high) = '1' then
                R_reset_accepted <= '1';
                R_state <= C_STATE_DETACHED;
              end if;
            end if;
          else
            start_i <= '0';
          end if;
        when others => -- C_STATE_STATUS send status reponse (send 0-length data packet)
          if idle_o = '1' then
            if R_slow(C_setup_interval) = '0' then
              R_slow <= R_slow + 1;
              if R_slow(11 downto 0) = x"880" then -- keepalive: first at 0.35 ms, then every 0.68 ms
                -- keepalive signal
                sof_transfer_i  <= '1';   -- transfer SOF or linectrl
                in_transfer_i   <= '1';   -- 0:SOF, 1:linectrl
                token_pid_i(1 downto 0) <= "00"; -- linectrl: keepalive
                resp_expected_i <= '0';
                start_i         <= C_keepalive_status;
              else
                start_i         <= '0';
              end if;
            else
              R_slow <= (others => '0');
              sof_transfer_i  <= '0';
              in_transfer_i   <= '0';
              token_pid_i     <= x"E1";
              token_ep_i      <= x"0";
              data_len_i      <= (others => '0');
              data_idx_i      <= '1';
              resp_expected_i <= '1';
              R_packet_counter <= R_packet_counter + 1;
              if R_retry(R_retry'high) = '1' then
                R_reset_accepted <= '1';
                R_state <= C_STATE_DETACHED;
              else
                R_state <= C_STATE_SETUP;
                start_i         <= '1';
              end if;
            end if;
          else
            start_i <= '0';
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
    signal R_crc_err: std_logic;
    signal R_rx_done: std_logic;
  begin
    process(clk_usb)
    begin
      if rising_edge(clk_usb) then
        R_rx_count <= rx_count_o; -- to offload routing (apart from this, "rx_count_o" could be used directly)
        if rx_push_o = '1' then
          R_report_buf(conv_integer(R_rx_count)) <= rx_data_o;
        end if;
        -- rx_done_o is '1' for several clocks...
        -- action on falling edge
        R_rx_done <= rx_done_o;
        if R_rx_done = '1' and rx_done_o = '0' then
          R_crc_err <= '0';
        else
          if crc_err_o = '1' then
            R_crc_err <= '1';
          end if;
        end if;
        -- at falling edge of rx_done it should not accumulate any crc error
        if R_rx_done = '1' and rx_done_o = '0' and R_crc_err = '0' and timeout_o = '0'
        and R_state = C_STATE_REPORT
        -- and R_rx_count = std_logic_vector(to_unsigned(C_report_length,rx_count_o'length)) -- strict
        and R_rx_count /= x"0000" -- more flexible
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
    rx_count <= rx_count_o; -- report byte count directly from SIE
    --rx_count <= R_packet_counter; -- debugging setup problems
    --rx_count(R_retry'range) <= R_retry; -- debugging report problems
    rx_done <= rx_done_o;
  end block;
end Behavioral;
