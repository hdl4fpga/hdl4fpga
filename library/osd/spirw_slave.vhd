-- VHDL wrapper for spirw_slave_v.v

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity spirw_slave is
  generic
  (
    c_addr_bits        : natural := 16;
    c_sclk_capable_pin : natural := 0 -- 0-sclk is generic pin, 1-sclk is clock capable pin
  );
  port
  (
    clk             : in    std_logic;
    csn, sclk, mosi : in    std_logic;
    miso            : inout std_logic;
    rd, wr          : out   std_logic;
    addr            : out   std_logic_vector(c_addr_bits-1 downto 0);
    data_in         : in    std_logic_vector(7 downto 0);
    data_out        : out   std_logic_vector(7 downto 0)
  );
end;

architecture syn of spirw_slave is
  component spirw_slave_v -- verilog name and its parameters
  generic
  (
    c_addr_bits        : natural;
    c_sclk_capable_pin : natural
  );
  port
  (
    clk             : in    std_logic;
    csn, sclk, mosi : in    std_logic;
    miso            : inout std_logic;
    rd, wr          : out   std_logic;
    addr            : out   std_logic_vector(c_addr_bits-1 downto 0);
    data_in         : in    std_logic_vector(7 downto 0);
    data_out        : out   std_logic_vector(7 downto 0)
  );
  end component;

begin
  spirw_slave_v_inst: spirw_slave_v
  generic map
  (
    c_addr_bits        => c_addr_bits,
    c_sclk_capable_pin => c_sclk_capable_pin
  )
  port map
  (
    clk => clk,              
    csn => csn, sclk => sclk, mosi => mosi,
    miso => miso,
    rd => rd, wr => wr,
    addr => addr,
    data_in => data_in,
    data_out => data_out
  );
end syn;
