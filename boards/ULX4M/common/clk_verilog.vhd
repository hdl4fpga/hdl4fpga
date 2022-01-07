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
    phasesel: in std_logic_vector(1 downto 0);
    phasedir: in std_logic;
    phasestep: in std_logic;
    phaseloadreg: in std_logic;
    clkout0: out std_logic;
    clkout1: out std_logic;
    clkout2: out std_logic;
    clkout3: out std_logic;
    locked: out std_logic
  );
end;

architecture syn of clk_verilog is
  component clk_verilog_v -- verilog name and its parameters
  port
  (
    clkin: in std_logic;
    phasesel: in std_logic_vector(1 downto 0);
    phasedir: in std_logic;
    phasestep: in std_logic;
    phaseloadreg: in std_logic;
    clkout0: out std_logic;
    clkout1: out std_logic;
    clkout2: out std_logic;
    clkout3: out std_logic;
    locked: out std_logic
  );
  end component;

begin
  clk_video_cpu_v_inst: clk_verilog_v
  port map
  (
    clkin => clkin,
    phasesel => phasesel,
    phasedir => phasedir,
    phasestep => phasestep,
    phaseloadreg => phaseloadreg,
    clkout0 => clkout0,
    clkout1 => clkout1,
    clkout2 => clkout2,
    clkout3 => clkout3,
    locked => locked
  );
end syn;
