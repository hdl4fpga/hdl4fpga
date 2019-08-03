-- AUTHOR=EMARD
-- LICENSE=GPL

-- entity (generic parameters and i/o port map) of the
-- glue for trigger, capture, storage.
-- common for "default" and "1shot" triggering system

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_trigger_capture_storage is
generic
(
  inputs                : natural;
  hz_factors            : natural_vector
);
port
(
  -- clock domain: incoming samples
  input_clk             : in  std_logic;
  resizedsample_dv      : in  std_logic;
  resizedsample_data    : in  std_logic_vector;
  trigger_shot          : in  std_logic; -- TODO: rename to trigger_level_compare

  -- clock domain: GUI (probably any clock domain is acceptable here)
  trigger_freeze        : in  std_logic;
  hz_scale              : in  std_logic_vector;
  hz_slider             : in  std_logic_vector;

  -- clock domain: video system pixel clock
  video_clk             : in  std_logic;
  video_vton            : in  std_logic;
  capture_addr          : in  std_logic_vector;
  capture_av            : in  std_logic;
  capture_dv            : out std_logic;
  capture_data          : out std_logic_vector
);
end; -- of entity
