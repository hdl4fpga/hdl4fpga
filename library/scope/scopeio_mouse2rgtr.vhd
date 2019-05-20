library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_mouse2rgtr is
port
(
  clk           : in  std_logic;
  ps2m_reset    : in  std_logic := '0'; -- PS/2 mouse core reset
  ps2m_clk      : inout std_logic; -- PS/2 mouse clock
  ps2m_dat      : inout std_logic; -- PS/2 mouse data

  rgtr_dv       : out std_logic; -- clk synchronous write cycle
  rgtr_id       : out std_logic_vector(7 downto 0); -- register address
  rgtr_data     : out std_logic_vector(31 downto 0); -- register value
		
  mouse_x       : out std_logic_vector(10 downto 0);
  mouse_y       : out std_logic_vector(10 downto 0)
);
end;

architecture def of scopeio_mouse2rgtr is
  signal S_mouse_update : std_logic;
  signal S_mouse_x      : std_logic_vector(11-1 downto 0);
  signal S_mouse_y      : std_logic_vector(11-1 downto 0);
  signal S_mouse_z      : std_logic_vector(9-1 downto 0);
  signal S_mouse_btn    : std_logic_vector(3-1 downto 0); -- 2=middle, 1=right, 0=left
  signal R_mouse_x      : std_logic_vector(11-1 downto 0);
  signal R_mouse_y      : std_logic_vector(11-1 downto 0);
begin
  mouse_e: entity hdl4fpga.mousem
  generic map
  (
    c_x_bits => S_mouse_x'length,
    c_y_bits => S_mouse_y'length,
    c_z_bits => S_mouse_z'length
  )
  port map
  (
    clk        => clk, -- by default made for 25 MHz
    ps2m_reset => ps2m_reset, -- after replugging mouse, it needs reset
    ps2m_clk   => ps2m_clk,
    ps2m_dat   => ps2m_dat,
    update     => S_mouse_update,
    x          => S_mouse_x,
    y          => S_mouse_y,
    z          => S_mouse_z,
    btn        => S_mouse_btn
  );

  -- example to change trigger level (4-ch scope)
  rgtr_dv <= S_mouse_update;
  rgtr_id <= x"12"; -- trigger
  rgtr_data(31 downto 13) <= (others => '0');
  rgtr_data(12 downto 11) <= S_mouse_btn(1 downto 0); -- left/right btn select trigger channel
  rgtr_data(10 downto 2) <= S_mouse_z(8 downto 0); -- rotating wheel changes trigger level
  rgtr_data(1) <= S_mouse_btn(2); -- wheel press selects trigger edge
  rgtr_data(0) <= '0'; -- when '1' trigger freeze

  -- example to change grid color with mouse wheel (4-ch scope)
  --rgtr_dv <= mouse_update,
  --rgtr_id <= x"11", -- palette (color)
  --rgtr_data(31 downto 7) <= (others => '0'),
  --rgtr_data(6 downto 4) <= mouse_z(2 downto 0), -- moving mouse wheel changes color
  --rgtr_data(3 downto 0) <= x"0", -- of grid
  
  -- registered stage to offload timing
  process(clk)
  begin
    if rising_edge(clk) then
      if S_mouse_update = '1' then
        R_mouse_x <= S_mouse_x;
        R_mouse_y <= S_mouse_y;
      end if;
    end if;
  end process;
  mouse_x <= R_mouse_x;
  mouse_y <= R_mouse_y;

end;
