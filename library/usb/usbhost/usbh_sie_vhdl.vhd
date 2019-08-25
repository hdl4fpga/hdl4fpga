--
-- AUTHOR=EMARD
-- LICENSE=BSD
--

-- VHDL Wrapper for usb_sie
-- reverses bits order of dev addr and ep

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library hdl4fpga;

entity usbh_sie_vhdl is
  port
  (
    clk_i             : in  std_logic;
    rst_i             : in  std_logic;
    start_i           : in  std_logic;
    in_transfer_i     : in  std_logic;
    sof_transfer_i    : in  std_logic;
    resp_expected_i   : in  std_logic;
    token_pid_i       : in  std_logic_vector(7 downto 0);
    token_dev_i       : in  std_logic_vector(6 downto 0);
    token_ep_i        : in  std_logic_vector(3 downto 0);
    data_len_i        : in  std_logic_vector(15 downto 0);
    data_idx_i        : in  std_logic;
    tx_data_i         : in  std_logic_vector(7 downto 0);
    utmi_txready_i    : in  std_logic;
    utmi_data_i       : in  std_logic_vector(7 downto 0);
    utmi_rxvalid_i    : in  std_logic;
    utmi_rxactive_i   : in  std_logic;

    ack_o             : out std_logic;
    tx_pop_o          : out std_logic;
    rx_data_o         : out std_logic_vector(7 downto 0);
    rx_push_o         : out std_logic;
    tx_done_o         : out std_logic;
    rx_done_o         : out std_logic;
    crc_err_o         : out std_logic;
    timeout_o         : out std_logic;
    response_o        : out std_logic_vector(7 downto 0);
    rx_count_o        : out std_logic_vector(15 downto 0);
    idle_o            : out std_logic;
    utmi_linectrl_o   : out std_logic;
    utmi_data_o       : out std_logic_vector(7 downto 0);
    utmi_txvalid_o    : out std_logic
  );
end;

architecture syn of usbh_sie_vhdl is
component usbh_sie -- verilog name and its parameters
  port (
    clk_i             : in  std_logic;
    rst_i             : in  std_logic;
    start_i           : in  std_logic;
    in_transfer_i     : in  std_logic;
    sof_transfer_i    : in  std_logic;
    resp_expected_i   : in  std_logic;
    token_pid_i       : in  std_logic_vector(7 downto 0);
    token_dev_i       : in  std_logic_vector(6 downto 0);
    token_ep_i        : in  std_logic_vector(3 downto 0);
    data_len_i        : in  std_logic_vector(15 downto 0);
    data_idx_i        : in  std_logic;
    tx_data_i         : in  std_logic_vector(7 downto 0);
    utmi_txready_i    : in  std_logic;
    utmi_data_i       : in  std_logic_vector(7 downto 0);
    utmi_rxvalid_i    : in  std_logic;
    utmi_rxactive_i   : in  std_logic;

    ack_o             : out std_logic;
    tx_pop_o          : out std_logic;
    rx_data_o         : out std_logic_vector(7 downto 0);
    rx_push_o         : out std_logic;
    tx_done_o         : out std_logic;
    rx_done_o         : out std_logic;
    crc_err_o         : out std_logic;
    timeout_o         : out std_logic;
    response_o        : out std_logic_vector(7 downto 0);
    rx_count_o        : out std_logic_vector(15 downto 0);
    idle_o            : out std_logic;
    utmi_linectrl_o   : out std_logic;
    utmi_data_o       : out std_logic_vector(7 downto 0);
    utmi_txvalid_o    : out std_logic
  );
end component;

signal reverse_token_dev_i : std_logic_vector(6 downto 0);
signal reverse_token_ep_i  : std_logic_vector(3 downto 0);

begin

  reverse_token_dev_i <=
    token_dev_i(0) & token_dev_i(1) & token_dev_i(2) & token_dev_i(3) &
    token_dev_i(4) & token_dev_i(5) & token_dev_i(6);

  reverse_token_ep_i <=
    token_ep_i(0) & token_ep_i(1) & token_ep_i(2) & token_ep_i(3);

  usbh_sie_verilog_inst: usbh_sie
  port map (
    clk_i             => clk_i,
    rst_i             => rst_i,
    start_i           => start_i,
    in_transfer_i     => in_transfer_i,
    sof_transfer_i    => sof_transfer_i,
    resp_expected_i   => resp_expected_i,
    token_pid_i       => token_pid_i,
    token_dev_i       => reverse_token_dev_i,
    token_ep_i        => reverse_token_ep_i,
    data_len_i        => data_len_i,
    data_idx_i        => data_idx_i,
    tx_data_i         => tx_data_i,
    utmi_txready_i    => utmi_txready_i,
    utmi_data_i       => utmi_data_i,
    utmi_rxvalid_i    => utmi_rxvalid_i,
    utmi_rxactive_i   => utmi_rxactive_i,

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
    utmi_linectrl_o   => utmi_linectrl_o,
    utmi_data_o       => utmi_data_o,
    utmi_txvalid_o    => utmi_txvalid_o
  );
end syn;
