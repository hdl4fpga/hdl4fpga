--
-- AUTHOR=EMARD
-- LICENSE=BSD
--

-- VHDL Wrapper

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity clk_verilog is
  port
  (
    clkin: in std_logic;
    clkout: out std_logic_vector(3 downto 0);
    locked: out std_logic
  );
end;

architecture syn of clk_verilog is
  component clk_verilog_v -- verilog name and its parameters
  port
  (
    clkin: in std_logic;
    clkout: out std_logic_vector(3 downto 0);
    locked: out std_logic
  );
  end component;

begin
  clk_video_cpu_v_inst: clk_verilog_v
  port map
  (
    clkin => clkin,
    clkout => clkout,
    locked => locked
  );
end syn;
