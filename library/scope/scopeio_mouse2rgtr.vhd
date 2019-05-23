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

  dbg_mouse     : out std_logic_vector(7 downto 0);

  mouse_x       : out std_logic_vector(10 downto 0);
  mouse_y       : out std_logic_vector(10 downto 0)
);
end;

architecture def of scopeio_mouse2rgtr is
  constant C_XY_coordinate_bits: integer := 11;
  constant C_XY_max: unsigned(C_XY_coordinate_bits-1 downto 0) := (others => '1');
  signal S_mouse_update : std_logic;
  signal S_mouse_x, S_mouse_dx: std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal S_mouse_y, S_mouse_dy: std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal S_mouse_z, S_mouse_dz: std_logic_vector(9-1 downto 0);
  signal S_mouse_btn    : std_logic_vector(3-1 downto 0); -- 2=middle, 1=right, 0=left
  signal R_mouse_x      : std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal R_mouse_y      : std_logic_vector(C_XY_coordinate_bits-1 downto 0);
  signal R_mouse_btn    : std_logic_vector(3-1 downto 0); -- 2=middle, 1=right, 0=left

  -- output registers that hold data for write cycle to rgtr module
  signal R_rgtr_dv      : std_logic; -- clk synchronous write cycle
  signal R_rgtr_id      : std_logic_vector(7 downto 0); -- register address
  signal R_rgtr_data    : std_logic_vector(31 downto 0); -- register value

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
  constant C_list_box_count: integer := 5; -- how many boxes, including termination record
  type T_list_box is array (0 to C_list_box_count*4-1) of unsigned(C_XY_coordinate_bits-1 downto 0);
  constant C_list_box: T_list_box :=
  (
  -- Xmin, Xmax, Ymin, Ymax,
        0,   99,    0,  259, -- 0: top left window (vertical scale)
      100,  599,    0,  259, -- 1: top center window (the grid)
      600,  799,    0,  259, -- 2: top right window (text)
      100,  599,  260,  269, -- 3: thin window below the grid (horizontal scale)
    0, C_XY_max, 0, C_XY_max -- 4: termination record
  -- termination record has to match always for this algorithm to work
  );
  constant C_box_id_bits: integer := unsigned_num_bits(C_list_box_count);
  -- R_box_id will contain ID of the box where mouse pointer is
  -- when mouse is outside of any box, R_box_id will be equal to C_list_box_count,
  -- (ID of the termination record)
  signal R_box_id: unsigned(C_box_id_bits-1 downto 0); -- ID of the box where cursor is

  -- mouse dragging
  signal R_drag_x, R_drag_y: signed(C_XY_coordinate_bits-1 downto 0);
  signal R_dragging: std_logic := '0'; -- becomes 1 when dragging
  constant C_drag_treshold: integer := 1; -- 0:>2 pixels, 1:>4 pixels, 2:>8 pixels, n:>2*2^n pixels
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
    dx         => S_mouse_dx,
    dy         => S_mouse_dy,
    dz         => S_mouse_dz,
    x          => S_mouse_x,
    y          => S_mouse_y,
    z          => S_mouse_z,
    btn        => S_mouse_btn
  );

  -- registered stage to offload timing
  process(clk)
  begin
    if rising_edge(clk) then
      if S_mouse_update = '1' then
        R_mouse_x <= S_mouse_x;
        R_mouse_y <= S_mouse_y;
        R_mouse_btn <= S_mouse_btn;
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
  --dbg_mouse(7 downto C_box_id_bits) <= (others => '0');
  --dbg_mouse(C_box_id_bits-1 downto 0) <= R_box_id(C_box_id_bits-1 downto 0);

  mouse_drag: block
    signal S_current_x, S_current_y: signed(C_XY_coordinate_bits-1 downto 0);
    signal R_press_x, R_press_y: signed(C_XY_coordinate_bits-1 downto 0);
    signal R_dx, R_dy: signed(C_XY_coordinate_bits-1 downto 0);
  begin
    -- just for conversion to signed
    S_current_x <= R_mouse_x;
    S_current_y <= R_mouse_y;
    process(clk)
    begin
      if rising_edge(clk) then
        if R_mouse_btn(2 downto 0) /= "000" then -- any btn pressed
          -- Simple filter to distinguish click from drag.
          -- If mouse is moved for more than 2*2**treshold pixels
          -- then enter "dragging" state.
          -- Less or equal 2*2**treshold pixels may be XY noise, not a drag.
          if R_dx(C_drag_treshold+2 downto C_drag_treshold+1) & R_dx(0) = "011" -- +3
          or R_dx(C_drag_treshold+2 downto C_drag_treshold+1)           = "10"  -- -3 or -4 or +4 or +5
          or R_dy(C_drag_treshold+2 downto C_drag_treshold+1) & R_dx(0) = "011" -- +3
          or R_dy(C_drag_treshold+2 downto C_drag_treshold+1)           = "10"  -- -3 or -4 or +4 or +5
          then
            R_dragging <= '1';
          end if;
        end if;
        if R_mouse_btn(2 downto 0) = "000" then -- all btn's released
          R_dragging <= '0';
          R_press_x <= S_current_x; -- record mouse position for future drag
          R_press_y <= S_current_y;
        end if;
        R_dx <= S_current_x - R_press_x;
        R_dy <= S_current_y - R_press_y;
        -- for output
        R_drag_x <= R_dx;
        R_drag_y <= R_dy;
      end if;
    end process;
  end block;
  dbg_mouse(4) <= R_dragging;
  dbg_mouse(3 downto 0) <= R_drag_x(3 downto 0);
  
  dispatch_mouse_event: block
    signal R_vertical_scale_offset, S_vertical_scale_offset_next, S_vertical_scale_offset_delta: unsigned(13 downto 0);
    signal S_vertical_scale_offset_sign_expansion: unsigned(S_vertical_scale_offset_delta'length-S_mouse_dy'length-1 downto 0);
    signal R_horizontal_scale_offset, S_horizontal_scale_offset_next, S_horizontal_scale_offset_delta: unsigned(15 downto 0);
    signal S_horizontal_scale_offset_sign_expansion: unsigned(S_horizontal_scale_offset_delta'length-S_mouse_dx'length-1 downto 0);
    signal R_trace_selected, S_trace_selected_next: unsigned(1 downto 0);
    signal R_trigger_level, S_trigger_level_next: unsigned(8 downto 0);
    signal R_trigger_source, S_trigger_source_next: unsigned(1 downto 0);
    -- FIXME trace color list should not be hardcoded
    -- now, it is good only if it matches with the colors
    -- given to the traces
    type T_trace_color is array (0 to 3) of unsigned(2 downto 0);
    constant C_trace_color: T_trace_color :=
    (
      "110", -- yellow
      "011", -- cyan
      "010", -- green
      "100"  -- red
    );
  begin
    S_vertical_scale_offset_sign_expansion <= (others => S_mouse_dy(S_mouse_dy'high));
    S_vertical_scale_offset_delta <= S_vertical_scale_offset_sign_expansion & unsigned(S_mouse_dy);
    S_vertical_scale_offset_next <= R_vertical_scale_offset
                                  + S_vertical_scale_offset_delta
                               when R_dragging = '1' and S_mouse_btn(0) = '1'
                               else R_vertical_scale_offset;
    S_horizontal_scale_offset_sign_expansion <= (others => S_mouse_dx(S_mouse_dx'high));
    S_horizontal_scale_offset_delta <= S_horizontal_scale_offset_sign_expansion & unsigned(S_mouse_dx);
    S_horizontal_scale_offset_next <= R_horizontal_scale_offset
                                    - S_horizontal_scale_offset_delta
                                 when R_dragging = '1' and S_mouse_btn(0) = '1'
                                 else R_horizontal_scale_offset;
    S_trace_selected_next <= R_trace_selected - unsigned(S_mouse_dz(R_trace_selected'range));
    S_trigger_level_next <= R_trigger_level
                          + unsigned(S_mouse_dy(R_trigger_level'range))
                       when R_dragging = '1' -- and S_mouse_btn(2) = '1' -- wheel pressed Y-drag
                       else R_trigger_level - unsigned(S_mouse_dz(R_trigger_level'range)); -- rotate wheel
    S_trigger_source_next <= R_trace_selected when S_mouse_btn(2) = '1' else R_trigger_source;
    process(clk)
    begin
      if rising_edge(clk) then
        case R_box_id is
          when 0 => -- mouse is on the vertical scale window
            R_rgtr_dv <= S_mouse_update;
            R_rgtr_id <= x"14"; -- trace vertical settings
            R_rgtr_data(31 downto 14) <= (others => '0');
            R_rgtr_data(13 downto 0) <= S_vertical_scale_offset_next;
            if S_mouse_update = '1' then
              R_vertical_scale_offset <= S_vertical_scale_offset_next;
            end if;
          when 1 => -- mouse is on the grid
            R_rgtr_dv <= S_mouse_update;
            R_rgtr_id <= x"12"; -- trigger
            R_rgtr_data(31 downto 13) <= (others => '0');
            R_rgtr_data(12 downto 11) <= S_trigger_source_next;
            R_rgtr_data(10 downto 2) <= S_trigger_level_next;
            R_rgtr_data(1) <= S_mouse_btn(1); -- right btn press selects trigger edge
            R_rgtr_data(0) <= '0'; -- when '1' trigger freeze
            if S_mouse_update = '1' then
              -- from rotating wheel or y-dragging
              R_trigger_level <= S_trigger_level_next;
              -- at wheel press apply trigger source
              R_trigger_source <= S_trigger_source_next;
            end if;
          when 2 => -- mouse is on the text window (to the right of the grid)
            -- change color of the frame to indicate
            -- a trace which is "selected".
            R_rgtr_dv <= S_mouse_update;
            R_rgtr_id <= x"11"; -- palette (color)
            R_rgtr_data(31 downto 10) <= (others => '0');
            R_rgtr_data(9 downto 7) <= C_trace_color(to_integer(S_trace_selected_next)); -- moving mouse changes color
            R_rgtr_data(6 downto 4) <= (others => '0');
            R_rgtr_data(3 downto 0) <= x"7"; -- 7 frame color
            -- x"7" frame color (used to indicate selected trace)
            -- x"6" bg color of text window
            -- x"3" bg color of thin window
            if S_mouse_update = '1' then
              R_trace_selected <= S_trace_selected_next;
            end if;
          when 3 => -- mouse is on the thin window below grid
            R_rgtr_dv <= S_mouse_update;
            R_rgtr_id <= x"10"; -- horizontal scale settings
            R_rgtr_data(31 downto 16) <= (others => '0');
            R_rgtr_data(15 downto 0) <= S_horizontal_scale_offset_next;
            if S_mouse_update = '1' then
              R_horizontal_scale_offset <= S_horizontal_scale_offset_next;
            end if;
          when others =>
            R_rgtr_dv <= '0';
        end case;
      end if; -- rising edge
    end process;
  end block;
  -- output
  rgtr_dv <= R_rgtr_dv;
  rgtr_id <= R_rgtr_id;
  rgtr_data <= R_rgtr_data;

  -- example to change trigger level (4-ch scope)
  --rgtr_dv <= S_mouse_update;
  --rgtr_id <= x"12"; -- trigger
  --rgtr_data(31 downto 13) <= (others => '0');
  --rgtr_data(12 downto 11) <= S_mouse_btn(1 downto 0); -- left/right btn select trigger channel
  --rgtr_data(10 downto 2) <= S_mouse_z(8 downto 0); -- rotating wheel changes trigger level
  --rgtr_data(1) <= S_mouse_btn(2); -- wheel press selects trigger edge
  --rgtr_data(0) <= '0'; -- when '1' trigger freeze

  -- example to change grid color with mouse wheel (4-ch scope)
  --rgtr_dv <= mouse_update,
  --rgtr_id <= x"11", -- palette (color)
  --rgtr_data(31 downto 7) <= (others => '0'),
  --rgtr_data(6 downto 4) <= mouse_z(2 downto 0), -- moving mouse wheel changes color
  --rgtr_data(3 downto 0) <= x"0", -- of grid
end;
