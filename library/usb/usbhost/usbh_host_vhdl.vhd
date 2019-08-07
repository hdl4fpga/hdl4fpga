--
-- AUTHOR=EMARD
-- LICENSE=BSD
--

-- VHDL Wrapper for usb_host

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity usbh_host_vhdl is
  generic
  (
    full_speed        : std_logic := '0';
    clk_freq_hz       : integer := 48000000; -- MHz clk_i frequency Full Speed: 48MHz, Low Speed 6MHz
    clk_div           : integer := 4         -- Full Speed: 4@48MHz, Low Speed: 4@6MHz, 5@7.5MHz, 32@48MHz
  );
  port
  (
    clk_i             : in  std_logic;
    rst_i             : in  std_logic;
    cfg_awvalid_i     : in  std_logic;
    cfg_awaddr_i      : in  std_logic_vector(31 downto 0);
    cfg_wvalid_i      : in  std_logic;
    cfg_wdata_i       : in  std_logic_vector(31 downto 0);
    cfg_wstrb_i       : in  std_logic_vector(3 downto 0);
    cfg_bready_i      : in  std_logic;
    cfg_arvalid_i     : in  std_logic;
    cfg_araddr_i      : in  std_logic_vector(31 downto 0);
    cfg_rready_i      : in  std_logic;
    utmi_data_in_i    : in  std_logic_vector(7 downto 0);
    utmi_txready_i    : in  std_logic;
    utmi_rxvalid_i    : in  std_logic;
    utmi_rxactive_i   : in  std_logic;
    utmi_rxerror_i    : in  std_logic;
    utmi_linestate_i  : in  std_logic_vector(1 downto 0);

    keepalive_o       : out std_logic;

    cfg_awready_o     : out std_logic;
    cfg_wready_o      : out std_logic;
    cfg_bvalid_o      : out std_logic;
    cfg_bresp_o       : out std_logic_vector(1 downto 0);
    cfg_arready_o     : out std_logic;
    cfg_rvalid_o      : out std_logic;
    cfg_rdata_o       : out std_logic_vector(31 downto 0);
    cfg_rresp_o       : out std_logic_vector(1 downto 0);
    intr_o            : out std_logic;
    utmi_linectrl_o   : out std_logic;
    utmi_data_out_o   : out std_logic_vector(7 downto 0);
    utmi_txvalid_o    : out std_logic;
    utmi_op_mode_o    : out std_logic_vector(1 downto 0);
    utmi_xcvrselect_o : out std_logic_vector(1 downto 0);
    utmi_termselect_o : out std_logic;
    utmi_dppulldown_o : out std_logic;
    utmi_dmpulldown_o : out std_logic
  );
end;

architecture syn of usbh_host_vhdl is
component usbh_host -- verilog name and its parameters
  generic
  (
    full_speed        : std_logic;
    clk_freq_hz       : integer;
    clk_div           : integer
  );
  port (
    clk_i             : in  std_logic;
    rst_i             : in  std_logic;
    cfg_awvalid_i     : in  std_logic;
    cfg_awaddr_i      : in  std_logic_vector(31 downto 0);
    cfg_wvalid_i      : in  std_logic;
    cfg_wdata_i       : in  std_logic_vector(31 downto 0);
    cfg_wstrb_i       : in  std_logic_vector(3 downto 0);
    cfg_bready_i      : in  std_logic;
    cfg_arvalid_i     : in  std_logic;
    cfg_araddr_i      : in  std_logic_vector(31 downto 0);
    cfg_rready_i      : in  std_logic;
    utmi_data_in_i    : in  std_logic_vector(7 downto 0);
    utmi_txready_i    : in  std_logic;
    utmi_rxvalid_i    : in  std_logic;
    utmi_rxactive_i   : in  std_logic;
    utmi_rxerror_i    : in  std_logic;
    utmi_linestate_i  : in  std_logic_vector(1 downto 0);

    keepalive_o       : out std_logic;

    cfg_awready_o     : out std_logic;
    cfg_wready_o      : out std_logic;
    cfg_bvalid_o      : out std_logic;
    cfg_bresp_o       : out std_logic_vector(1 downto 0);
    cfg_arready_o     : out std_logic;
    cfg_rvalid_o      : out std_logic;
    cfg_rdata_o       : out std_logic_vector(31 downto 0);
    cfg_rresp_o       : out std_logic_vector(1 downto 0);
    intr_o            : out std_logic;
    utmi_linectrl_o   : out std_logic;
    utmi_data_out_o   : out std_logic_vector(7 downto 0);
    utmi_txvalid_o    : out std_logic;
    utmi_op_mode_o    : out std_logic_vector(1 downto 0);
    utmi_xcvrselect_o : out std_logic_vector(1 downto 0);
    utmi_termselect_o : out std_logic;
    utmi_dppulldown_o : out std_logic;
    utmi_dmpulldown_o : out std_logic
  );
end component;

begin
  usbh_host_inst: usbh_host
  generic map (
    full_speed        => full_speed,
    clk_freq_hz       => clk_freq_hz,
    clk_div           => clk_div
  )
  port map (
    clk_i             => clk_i,
    rst_i             => rst_i,
    cfg_awvalid_i     => cfg_awvalid_i,
    cfg_awaddr_i      => cfg_awaddr_i,
    cfg_wvalid_i      => cfg_wvalid_i,
    cfg_wdata_i       => cfg_wdata_i,
    cfg_wstrb_i       => cfg_wstrb_i,
    cfg_bready_i      => cfg_bready_i,
    cfg_arvalid_i     => cfg_arvalid_i,
    cfg_araddr_i      => cfg_araddr_i,
    cfg_rready_i      => cfg_rready_i,
    utmi_data_in_i    => utmi_data_in_i,
    utmi_txready_i    => utmi_txready_i,
    utmi_rxvalid_i    => utmi_rxvalid_i,
    utmi_rxactive_i   => utmi_rxactive_i,
    utmi_rxerror_i    => utmi_rxerror_i,
    utmi_linestate_i  => utmi_linestate_i,

    keepalive_o       => keepalive_o,

    cfg_awready_o     => cfg_awready_o,
    cfg_wready_o      => cfg_wready_o,
    cfg_bvalid_o      => cfg_bvalid_o,
    cfg_bresp_o       => cfg_bresp_o,
    cfg_arready_o     => cfg_arready_o,
    cfg_rvalid_o      => cfg_rvalid_o,
    cfg_rdata_o       => cfg_rdata_o,
    cfg_rresp_o       => cfg_rresp_o,
    intr_o            => intr_o,
    utmi_linectrl_o   => utmi_linectrl_o,
    utmi_data_out_o   => utmi_data_out_o,
    utmi_txvalid_o    => utmi_txvalid_o,
    utmi_op_mode_o    => utmi_op_mode_o,
    utmi_xcvrselect_o => utmi_xcvrselect_o,
    utmi_termselect_o => utmi_termselect_o,
    utmi_dppulldown_o => utmi_dppulldown_o,
    utmi_dmpulldown_o => utmi_dmpulldown_o
  );
end syn;
