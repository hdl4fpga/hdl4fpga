--
-- AUTHOR=EMARD
-- LICENSE=BSD
--

-- VHDL Wrapper

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mousem is
  port
  (
    clk, reset: in std_logic;
    msclk, msdat: inout std_logic;
    dataout: out std_logic_vector(27 downto 0)
  );
end;

architecture syn of mousem is
  component mousem_v -- verilog name and its parameters
  port
  (
    clk, reset: in std_logic;
    msclk, msdat: inout std_logic;
    dataout: out std_logic_vector(27 downto 0)
  );
  end component;

begin
  mousem_v_inst: mousem_v
  port map
  (
    clk => clk, reset => reset,
    msclk => msclk, msdat => msdat,
    dataout => dataout
  );
end syn;
