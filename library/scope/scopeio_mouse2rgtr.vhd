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

  box_id        : out std_logic_vector(7 downto 0);
  mouse_x       : out std_logic_vector(10 downto 0);
  mouse_y       : out std_logic_vector(10 downto 0)
);
end;

architecture def of scopeio_mouse2rgtr is
  constant C_XY_coordinate_bits: integer := 11;
  constant C_XY_max: unsigned(C_XY_coordinate_bits-1 downto 0) := (others => '1');
  signal S_mouse_update : std_logic;
  signal S_mouse_x      : std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal S_mouse_y      : std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal S_mouse_z      : std_logic_vector(9-1 downto 0);
  signal S_mouse_btn    : std_logic_vector(3-1 downto 0); -- 2=middle, 1=right, 0=left
  signal R_mouse_x      : std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal R_mouse_y      : std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  
  -- search list of rectangular areas on the screen
  -- to find in which box the mouse is. It is to be
  -- used somehow like this:

  -- box 0
  -- 0: C <= C and (A<=B), A<=B,  B<=Y2,  X1,X2,Y1,Y2 <= next_box
  -- 1: C <= C and (A<=B), A<=X1, B<=mouse_x
  -- 2: C <=       (A<=B), A<=B,  B<=X2,  Result <= C
  -- 3: C <= C and (A<=B), A<=Y1, B<=mouse_y
  -- box 1
  -- ...
  -- box n

  -- at box n if Result is 1, then mouse pointer was found in previous box (n-1)
  constant C_list_box_count: integer := 4; -- how many boxes, including termination record
  type T_list_box is array (0 to C_list_box_count*4-1) of unsigned(C_XY_coordinate_bits-1 downto 0);
  constant C_list_box: T_list_box :=
  (
  -- Xmin, Xmax, Ymin, Ymax,
        0,  299,    0,  199, -- 0: upper left quarter of the screen
      400,  799,    0,  199, -- 1: upper right quarter of the screen
        0,  299,  300,  599, -- 2: lower left quarter of the screen
    0, C_XY_max, 0, C_XY_max -- 3: termination record
  -- termination record has to match always for this algorithm to work
  );
  constant C_box_id_bits: integer := unsigned_num_bits(C_list_box_count);
  -- R_box_id will contain ID of the box where mouse pointer is
  -- when mouse is outside of any box, R_box_id will be equal to C_list_box_count,
  -- (ID of the termination record)
  signal R_box_id: unsigned(C_box_id_bits-1 downto 0); -- ID of the box where cursor is
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

  -- for mouse x/y pointer position, find the ID of the box where the pointer is.
  -- ID=-1 means pointer is outside of any of the listed boxes
  -- purity: latch cursor position at each reset of search index
  find_box: block
    signal R_A, R_B, R_list_value, R_latch_x, R_latch_y: unsigned(C_XY_coordinate_bits-1 downto 0);
    signal R_C, S_C_next, S_compare, S_new_box: std_logic;
    signal R_list_addr: unsigned(C_box_id_bits+1 downto 0); -- 2 bits more, we have 4 values for a box
    signal R_matching_id, R_previous_id: unsigned(C_box_id_bits-1 downto 0);
  begin
    S_new_box <= '1' when R_list_addr(1 downto 0) = "10" else '0'; -- 2:
    S_compare <= '1' when R_A <= R_B else '0';
    S_C_next <= S_compare when S_new_box = '1'
           else S_compare and R_C;
    process(clk)
    begin
      if rising_edge(clk) then
        case R_list_addr(1 downto 0) is
          when "01" => -- 1:
            R_A <= R_list_value; -- X1
            R_B <= R_latch_x; -- mouse X
          when "10" => -- 2: S_new_box = '1', R_C contains result now
            R_A <= R_B; -- mouse X
            R_B <= R_list_value; -- X2
            if R_C = '1' then
              R_matching_id <= R_previous_id;
            end if;
            R_previous_id <= R_list_addr(R_list_addr'high downto 2);
          when "11" => -- 3:
            R_A <= R_list_value; -- Y1
            R_B <= R_latch_y; -- mouse Y
          when others => -- 0:
            R_A <= R_B; -- mouse Y
            R_B <= R_list_value; -- Y2
        end case;
        R_C <= S_C_next;
        R_list_value <= C_list_box(to_integer(R_list_addr));
      end if;
    end process;
    process(clk)
    begin
      if rising_edge(clk) then
        if R_list_addr = C_list_box_count*4-1 then
          R_latch_x <= R_mouse_x;
          R_latch_y <= R_mouse_y;
          R_box_id <= R_matching_id; -- stores final result
          R_list_addr <= (others => '0'); -- reset list addr counter
        else
          R_list_addr <= R_list_addr + 1;
        end if;
      end if;
    end process;
  end block;
  box_id(7 downto C_box_id_bits) <= (others => '0');
  box_id(C_box_id_bits-1 downto 0) <= R_box_id(C_box_id_bits-1 downto 0);
end;
