-- AUTHOR=EMARD
-- LICENSE=GPL

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library hdl4fpga;

entity ulpi_wrapper_vhdl is
  port
  (
    ulpi_clk60_i      : in  std_logic;
    ulpi_rst_i        : in  std_logic;
    ulpi_data_out_i   : in  std_logic_vector(7 downto 0);
    ulpi_data_in_o    : out std_logic_vector(7 downto 0);
    ulpi_dir_i        : in  std_logic;
    ulpi_nxt_i        : in  std_logic;
    ulpi_stp_o        : out std_logic;

    utmi_txvalid_i    : in  std_logic;
    utmi_txready_o    : out std_logic;
    utmi_rxvalid_o    : out std_logic;
    utmi_rxactive_o   : out std_logic;
    utmi_rxerror_o    : out std_logic;
    utmi_data_in_o    : out std_logic_vector(7 downto 0);
    utmi_data_out_i   : in  std_logic_vector(7 downto 0);
    utmi_xcvrselect_i : in  std_logic_vector(1 downto 0);
    utmi_termselect_i : in  std_logic;
    utmi_op_mode_i    : in  std_logic_vector(1 downto 0);
    utmi_dppulldown_i : in  std_logic;
    utmi_dmpulldown_i : in  std_logic;
    utmi_linestate_o  : out std_logic_vector(1 downto 0)
  );
end;

architecture syn of ulpi_wrapper_vhdl is
component ulpi_wrapper -- verilog name and its parameters
  port (
    ulpi_clk60_i      : in  std_logic;
    ulpi_rst_i        : in  std_logic;
    ulpi_data_out_i   : in  std_logic_vector(7 downto 0);
    ulpi_data_in_o    : out std_logic_vector(7 downto 0);
    ulpi_dir_i        : in  std_logic;
    ulpi_nxt_i        : in  std_logic;
    ulpi_stp_o        : out std_logic;

    utmi_txvalid_i    : in  std_logic;
    utmi_txready_o    : out std_logic;
    utmi_rxvalid_o    : out std_logic;
    utmi_rxactive_o   : out std_logic;
    utmi_rxerror_o    : out std_logic;
    utmi_data_in_o    : out std_logic_vector(7 downto 0);
    utmi_data_out_i   : in  std_logic_vector(7 downto 0);
    utmi_xcvrselect_i : in  std_logic_vector(1 downto 0);
    utmi_termselect_i : in  std_logic;
    utmi_op_mode_i    : in  std_logic_vector(1 downto 0);
    utmi_dppulldown_i : in  std_logic;
    utmi_dmpulldown_i : in  std_logic;
    utmi_linestate_o  : out std_logic_vector(1 downto 0)
  );
end component;

begin
  ulpi_wrapper_inst: ulpi_wrapper
  port map (
    ulpi_clk60_i       => ulpi_clk60_i,
    ulpi_rst_i         => ulpi_rst_i,
    ulpi_data_out_i    => ulpi_data_out_i,
    ulpi_data_in_o     => ulpi_data_in_o,
    ulpi_dir_i         => ulpi_dir_i,
    ulpi_nxt_i         => ulpi_nxt_i,
    ulpi_stp_o         => ulpi_stp_o,

    utmi_txvalid_i     => utmi_txvalid_i,
    utmi_txready_o     => utmi_txready_o,
    utmi_rxvalid_o     => utmi_rxvalid_o,
    utmi_rxactive_o    => utmi_rxactive_o,
    utmi_rxerror_o     => utmi_rxerror_o,
    utmi_data_in_o     => utmi_data_in_o,
    utmi_data_out_i    => utmi_data_out_i,
    utmi_xcvrselect_i  => utmi_xcvrselect_i,
    utmi_termselect_i  => utmi_termselect_i,
    utmi_op_mode_i     => utmi_op_mode_i,
    utmi_dppulldown_i  => utmi_dppulldown_i,
    utmi_dmpulldown_i  => utmi_dmpulldown_i,
    utmi_linestate_o   => utmi_linestate_o
  );
end syn;
