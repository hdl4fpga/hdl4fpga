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
    -- USB UTMI interface
    utmi_txready_i  : in  std_logic;
    utmi_data_i     : in  std_logic_vector(7 downto 0);
    utmi_rxvalid_i  : in  std_logic;
    utmi_rxactive_i : in  std_logic;
    utmi_linestate_i: in  std_logic_vector(1 downto 0);
    utmi_linectrl_o : out std_logic;
    utmi_data_o     : out std_logic_vector(7 downto 0);
    utmi_txvalid_o  : out std_logic;
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
  signal S_led: std_logic;
  signal S_usb_rst: std_logic;
  signal S_rxd: std_logic;
  signal S_rxdp, S_rxdn: std_logic;
  signal S_txdp, S_txdn, S_txoe: std_logic;
  signal S_oled: std_logic_vector(63 downto 0);
  signal S_dsctyp: std_logic_vector(2 downto 0);

  -- UTMI debug
  signal S_sync_err, S_bit_stuff_err, S_byte_err: std_logic;

  signal R_setup_rom_addr, R_setup_rom_addr_acked: std_logic_vector(7 downto 0) := (others => '0');
  constant C_setup_rom_len: std_logic_vector(R_setup_rom_addr'range) := 
    std_logic_vector(to_unsigned(C_setup_rom'length,8));
  signal R_setup_byte_counter: std_logic_vector(2 downto 0) := (others => '0');

  signal ctrlin : std_logic;
  signal datastatus : std_logic := '0';
  constant C_datastatus_enable : std_logic := '0';

  signal R_packet_counter : std_logic_vector(15 downto 0);
  
  signal   R_state:           std_logic_vector(1 downto 0)    := "00";
  constant C_STATE_DETACHED : std_logic_vector(R_state'range) := "00";
  constant C_STATE_SETUP    : std_logic_vector(R_state'range) := "01";
  constant C_STATE_REPORT   : std_logic_vector(R_state'range) := "10";
  constant C_STATE_DATA   : std_logic_vector(R_state'range) := "11";

  signal R_retry: std_logic_vector(C_setup_retry downto 0);
  signal R_slow: std_logic_vector(17 downto 0) := (others => '0'); -- 2**17 clocks = 22 ms interval at 6 MHz
  signal R_reset_pending: std_logic;
  signal R_reset_accepted : std_logic;

  constant C_sof_pid: std_logic_vector(7 downto 0) := x"A5";
  signal R_sof_counter: std_logic_vector(10 downto 0);
  signal S_sof_dev: std_logic_vector(6 downto 0);
  signal S_sof_ep: std_logic_vector(3 downto 0);

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
  
  signal R_stored_response: std_logic_vector(7 downto 0);
  signal R_wLength        : std_logic_vector(15 downto 0);
  signal R_bytes_remaining: std_logic_vector(15 downto 0);
  signal S_expected_response: std_logic_vector(7 downto 0);
  
  signal R_advance_data : std_logic := '0';

  begin

  -- address advance, retry logic, set_address accpetance
  B_address_retry: block
    signal S_transmission_over: std_logic;
    signal R_timeout: std_logic; -- rising edge tracking
  begin
  S_transmission_over <= '1' when rx_done_o = '1' or (timeout_o = '1' and R_timeout = '0') else '0';
  process(clk)
  begin
    if rising_edge(clk) then
      R_timeout <= timeout_o;
      if R_reset_accepted = '1' then
        R_setup_rom_addr       <= (others => '0');
        R_setup_rom_addr_acked <= (others => '0');
        R_setup_byte_counter   <= (others => '0');
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
              case token_pid_i is
                when x"2D" =>
                  if rx_done_o = '1' and response_o = x"D2" then -- ACK to SETUP
                    -- continue with next setup
                    R_setup_rom_addr_acked <= R_setup_rom_addr;
                    R_retry <= (others => '0');
                  else -- failed, rewind to unacknowledged setup and retry
                    R_setup_rom_addr <= R_setup_rom_addr_acked;
                    if R_retry(R_retry'high) = '0' then
                      R_retry <= R_retry + 1;
                    end if;
                  end if;
              end case;
            else -- transmission is going on -- advance address
              if tx_pop_o = '1' then
                R_setup_rom_addr <= R_setup_rom_addr + 1;
                R_setup_byte_counter <= R_setup_byte_counter + 1;
              end if;
            end if;
            R_stored_response <= x"00";
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
          when others => -- C_STATE_DATA =>
            if S_transmission_over = '1' then
              case token_pid_i is
                when x"E1" =>
                  if rx_done_o = '1' and response_o = x"D2" then -- ACK to DATA OUT
                    R_stored_response <= response_o;
                    -- continue with next setup
                    R_setup_rom_addr_acked <= R_setup_rom_addr;
                    R_retry <= (others => '0');
                  else -- failed, rewind to unacknowledged setup and retry
                    R_setup_rom_addr <= R_setup_rom_addr_acked;
                    if R_retry(R_retry'high) = '0' then
                      R_retry <= R_retry + 1;
                    end if;
                  end if;
                when others => -- x"69"
                  if timeout_o = '1' and R_timeout = '0' then
                    if R_retry(R_retry'high) = '0' then
                      R_retry <= R_retry + 1;
                    end if;
                  else
                    if rx_done_o = '1' then
                      R_stored_response <= response_o;
                      -- SIE quirk: set address returns 4B = PID_DATA1 instead of D2 = ACK
                      if response_o = x"4B" then
                        R_retry <= (others => '0');
                        R_dev_address_confirmed <= R_dev_address_requested;
                      else -- set address failed
                        R_retry <= R_retry + 1;
                      end if;
                    end if;
                  end if;
              end case;
            else -- transmission is going on -- advance address but only data, not setup counter
              if tx_pop_o = '1' then
                R_setup_rom_addr <= R_setup_rom_addr + 1;
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
  process(clk)
  begin
    if rising_edge(clk) then
      case R_state is
        when C_STATE_DETACHED =>
          R_dev_address_requested <= (others => '0');
          R_set_address_found <= '0';
          R_wLength <= x"0000";
        when C_STATE_SETUP =>
          case R_setup_byte_counter(2 downto 0) is
            when "000" => -- every 8 bytes, 1st byte
              if tx_data_i = x"00" then
                R_first_byte_0_found <= '1';
              else
                R_first_byte_0_found <= '0';
              end if;
            when "001" => -- every 8 bytes, 2nd byte
              if tx_data_i = x"05" then
                R_set_address_found <= R_first_byte_0_found;
              end if;
              R_wLength <= x"0000";
            when "010" => -- every 8 bytes, 3rd byte
              if R_set_address_found = '1' then -- every 8 bytes, 3rd byte
                R_dev_address_requested <= tx_data_i(token_dev_i'range);
              end if;
            when "110" => -- every 8 bytes, 7th byte
              R_wLength(7 downto 0) <= tx_data_i;
            when "111" => -- every 8 bytes, 8th byte wLength high byte currently forced to 0
              R_wLength(15 downto 8) <= x"00"; -- tx_data_i;
          end case;
        when others =>
          R_wLength <= x"0000";
          R_set_address_found <= '0';
      end case;
    end if;
  end process;
  end block;

  -- NOTE: not sure is this bit order correct
  S_sof_dev <= R_sof_counter(10 downto 4); -- 7 bits
  S_sof_ep  <= R_sof_counter( 3 downto 0); -- 4 bits

  S_expected_response <= x"4B" when data_idx_i = '1' else x"C3";
  process(clk)
  begin
    if rising_edge(clk) then
      R_advance_data <= '0'; -- default
      case R_state is
        when C_STATE_DETACHED => -- start from unitialized device
          R_reset_accepted <= '0';
          if utmi_linestate_i = "01" then
            if R_slow(17) = '0' then -- 22 ms
              R_slow <= R_slow + 1;
            else
              R_slow <= (others => '0');
              sof_transfer_i  <= '1';   -- transfer SOF or linectrl
              in_transfer_i   <= '1';   -- 0:SOF, 1:linectrl
              token_pid_i(1 downto 0) <= "11"; -- linectrl: bus reset
              token_dev_i     <= (others => '0'); -- after reset device address will be 0
              resp_expected_i <= '0';
              ctrlin          <= '0';
              start_i         <= '1';
              R_packet_counter <= (others => '0');
              R_sof_counter   <= (others => '0');
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
              if R_slow(C_keepalive_phase'range) = C_keepalive_phase and C_keepalive_setup = '1' then -- keepalive: first at 0.35 ms, then every 0.68 ms
                -- keepalive signal
                sof_transfer_i  <= '1';   -- transfer SOF or linectrl
                in_transfer_i   <= C_keepalive_type;   -- 0:SOF, 1:linectrl
                if C_keepalive_type = '1' then
                  token_pid_i(1 downto 0) <= "00"; -- linectrl: keepalive
                else
                  token_pid_i <= C_sof_pid;
                  token_dev_i <= S_sof_dev;
                  token_ep_i  <= S_sof_ep;
                  data_len_i  <= (others => '0');
                  R_sof_counter <= R_sof_counter + 1;
                end if;
                resp_expected_i <= '0';
                start_i         <= '1';
              else
                start_i         <= '0';
              end if;
            else -- time passed, send next setup packet or read status or read response
              R_slow <= (others => '0');
              sof_transfer_i  <= '0';
              token_dev_i     <= R_dev_address_confirmed;
              token_ep_i      <= x"0";
              resp_expected_i <= '1';
              if R_setup_rom_addr = C_setup_rom_len then
                data_len_i <= x"0000";
                start_i <= '0';
                R_state <= C_STATE_REPORT;
              else
                in_transfer_i   <= '0';
                token_pid_i     <= x"2D";
                data_len_i      <= x"0008";
                if R_set_address_found = '1' or ctrlin = '1' or R_wLength /= x"0000" then
                  R_bytes_remaining <= R_wLength;
--                  R_bytes_remaining <= x"0000";
                  if R_set_address_found = '1' then
                    ctrlin  <= '1';
                    datastatus <= '0';
                  else
                    datastatus <= C_datastatus_enable; -- after IN send status OUT
                  end if;
                  data_idx_i <= '1'; -- next sending as DATA1
                  R_state <= C_STATE_DATA;
                else
                  data_idx_i <= '0'; -- send as DATA0
                  ctrlin           <= tx_data_i(7);
                  R_packet_counter <= R_packet_counter + 1;
                  start_i          <= '1';
                end if;
              end if;
            end if;
          else -- not idle
            start_i <= '0';
          end if;
        when C_STATE_REPORT => -- request report (send IN request)
          if idle_o = '1' then
            if R_slow(C_report_interval) = '0' then
              R_slow <= R_slow + 1;
              if R_slow(C_keepalive_phase'range) = C_keepalive_phase and C_keepalive_report = '1' then -- keepalive: first at 0.35 ms, then every 0.68 ms
                -- keepalive signal
                sof_transfer_i  <= '1';   -- transfer SOF or linectrl
                in_transfer_i   <= C_keepalive_type;   -- 0:SOF, 1:linectrl
                if C_keepalive_type = '1' then
                  token_pid_i(1 downto 0) <= "00"; -- linectrl: keepalive
                else
                  token_pid_i <= C_sof_pid;
                  token_dev_i <= S_sof_dev;
                  token_ep_i  <= S_sof_ep;
                  data_len_i  <= (others => '0');
                  R_sof_counter <= R_sof_counter + 1;
                end if;
                resp_expected_i <= '0';
                start_i         <= '1';
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
              if C_keepalive_type = '0' then
                token_dev_i     <= R_dev_address_confirmed;
              end if;
              token_ep_i      <= std_logic_vector(to_unsigned(C_report_endpoint,token_ep_i'length));
              data_idx_i      <= '0';
--              R_packet_counter <= R_packet_counter + 1;
              resp_expected_i <= '1';
              start_i         <= '1';
              if R_reset_pending = '1' or utmi_linestate_i = "00" or R_retry(R_retry'high) = '1' then
                R_reset_accepted <= '1';
                R_state <= C_STATE_DETACHED;
              end if;
            end if;
          else -- not idle
            start_i <= '0';
          end if;
        when others => -- C_STATE_DATA receive or send data phase
          if idle_o = '1' then
            if R_slow(C_setup_interval) = '0' then
              R_slow <= R_slow + 1;
              if R_retry(R_retry'high) = '1' then
                R_reset_accepted <= '1';
                R_state <= C_STATE_DETACHED;
              end if;
              if R_slow(C_keepalive_phase'range) = C_keepalive_phase and C_keepalive_status = '1' then -- keepalive: first at 0.35 ms, then every 0.68 ms
                -- keepalive signal
                sof_transfer_i  <= '1';   -- transfer SOF or linectrl
                in_transfer_i   <= C_keepalive_type;   -- 0:SOF, 1:linectrl
                if C_keepalive_type = '1' then
                  token_pid_i(1 downto 0) <= "00"; -- linectrl: keepalive
                else
                  token_pid_i <= C_sof_pid;
                  token_dev_i <= S_sof_dev;
                  token_ep_i  <= S_sof_ep;
                  data_len_i  <= (others => '0');
                  R_sof_counter <= R_sof_counter + 1;
                end if;
                resp_expected_i <= '0';
                start_i         <= '1';
              else
                start_i         <= '0';
              end if;
            else -- time to send request
              R_slow <= (others => '0');
              sof_transfer_i  <= '0';
              in_transfer_i   <= ctrlin;
              if ctrlin = '1' then
                token_pid_i     <= x"69"; -- 69=IN
              else
                token_pid_i     <= x"E1"; -- E1=OUT
              end if;
              if C_keepalive_type = '0' then
                token_dev_i     <= R_dev_address_confirmed;
              end if;
              token_ep_i      <= x"0";
              resp_expected_i <= '1';
              if R_bytes_remaining /= x"0000" then
                if R_bytes_remaining(R_bytes_remaining'high downto 3) /= x"000" & '0' then -- 8 or more remaining bytes
                  data_len_i <= x"0008"; -- transmit 8 bytes in a packet
                else -- less than 8 remaining
                  data_len_i <= x"000" & '0' & R_bytes_remaining(2 downto 0); -- transmit remaining bytes (less than 8)
                end if;
              else
                data_len_i <= x"0000";
              end if;
              if ctrlin = '1' then
                if R_stored_response = x"4B" or R_stored_response = x"C3" then -- SIE quirk: 4B is returned for 0-len packet instead of D2 ACK
                  R_advance_data  <= '1';
                  if R_bytes_remaining(R_bytes_remaining'high downto 3) = x"000" & '0' then
                    ctrlin  <= '0';
                    if datastatus = '0' then
                      R_state <= C_STATE_SETUP;
                    end if;
                    -- after all IN packets, send 0-length OUT packet as confirmation.
                    -- TODO: see standard what is correct data_idx_i = 0 or 1
                  else
                    R_advance_data  <= '1';
                    R_packet_counter <= R_packet_counter + 1;
                    start_i          <= '1';
                  end if;
                else
                  R_packet_counter <= R_packet_counter + 1;
                  start_i          <= '1';
                end if;
              else -- ctrlin = 0
                if R_stored_response = x"D2" then
                  R_advance_data   <= '1';
                  if datastatus = '1' then
                    R_state <= C_STATE_SETUP;
                  else
                    if R_bytes_remaining = x"0000" then
                      ctrlin <= '1'; -- OUT phase will finish with IN 0-length packet
                    end if;
                  end if;
                else
                  R_packet_counter <= R_packet_counter + 1;
                  start_i <= '1';
                end if;
              end if;
            end if;
          else
            start_i <= '0';
          end if;
          -- always during C_STATE_DATA
          -- counts bytes required for DATA state, then exit
          if R_advance_data = '1' then
              if R_bytes_remaining /= x"0000" then
                if R_bytes_remaining(R_bytes_remaining'high downto 3) /= x"000" & '0' then -- 8 or more remaining bytes
                  R_bytes_remaining(R_bytes_remaining'high downto 3) <= R_bytes_remaining(R_bytes_remaining'high downto 3) - 1;
                else -- less than 8 remaining
                  R_bytes_remaining(2 downto 0) <= "000";
                end if;
                data_idx_i <= not data_idx_i; -- alternates DATA 0/1
              else
                if ctrlin = '1' then
                  data_idx_i <= '1'; -- always DATA1 at last IN
                end if;
              end if;
          end if;
      end case;
    end if;
  end process;

  -- USB SIE-core
  usb_sie_core: entity hdl4fpga.usbh_sie_vhdl
  port map
  (
    clk_i             => clk, -- low speed: 6 MHz or 7.5 MHz, high speed: 48 MHz or 60 MHz
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

    utmi_txready_i    => utmi_txready_i,
    utmi_data_i       => utmi_data_i,
    utmi_rxvalid_i    => utmi_rxvalid_i,
    utmi_rxactive_i   => utmi_rxactive_i,
    utmi_linectrl_o   => utmi_linectrl_o,
    utmi_data_o       => utmi_data_o,
    utmi_txvalid_o    => utmi_txvalid_o
  );

  B_report_reader: block
    type T_report_buf is array(0 to C_report_length-1) of std_logic_vector(7 downto 0);
    signal R_report_buf: T_report_buf;
    signal R_rx_count: std_logic_vector(rx_count_o'range);
    signal R_hid_valid: std_logic;
    signal R_crc_err: std_logic;
    signal R_rx_done: std_logic;
  begin
    process(clk)
    begin
      if rising_edge(clk) then
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
    --rx_count(7 downto 0) <= R_stored_response;
    --rx_count(7 downto 0) <= R_E1_response;
    --rx_count(R_retry'range) <= R_retry; -- debugging report problems
    rx_done <= rx_done_o;
    --rx_done <= utmi_linestate_i(0);
  end block;
end Behavioral;
