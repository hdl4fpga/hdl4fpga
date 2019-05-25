-- AUTHOR = EMARD
-- LICENSE = BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_mouse2rgtr is
generic
(
  -- mouse drag sensitivity treshold:
  -- 0:>2 pixels, 1:>4 pixels, 2:>8 pixels, n:>2^(n+1) pixels
  C_drag_treshold: integer := 0;
  vlayout_id     : integer := 0
);
port
(
  clk           : in  std_logic;

  ps2m_reset    : in  std_logic := '0'; -- PS/2 mouse core reset
  ps2m_clk      : inout std_logic; -- PS/2 mouse clock
  ps2m_dat      : inout std_logic; -- PS/2 mouse data
  
  mouse_update  : in std_logic; -- mouse data valid
  mouse_btn     : in std_logic_vector(2 downto 0); -- 2=middle, 1=right, 0=left
  mouse_dx      : in signed; -- 8 bits
  mouse_dy      : in signed; -- 8 bits
  mouse_dz      : in signed; -- 4 bits

  rgtr_dv       : out std_logic; -- clk synchronous write cycle
  rgtr_id       : out std_logic_vector(7 downto 0); -- register address
  rgtr_data     : out std_logic_vector(31 downto 0); -- register value

  pointer_dv    : out std_logic;
  pointer_x     : out std_logic_vector(10 downto 0);
  pointer_y     : out std_logic_vector(10 downto 0)
);
end;

architecture def of scopeio_mouse2rgtr is
  constant C_XY_coordinate_bits: integer := 11;
  constant C_XY_max: unsigned(C_XY_coordinate_bits-1 downto 0) := (others => '1');

  signal R_mouse_update: std_logic; -- data valid signal

  signal R_mouse_dx     : signed(mouse_dx'range);
  signal R_mouse_dy     : signed(mouse_dy'range);
  signal R_mouse_dz     : signed(mouse_dz'range);

  signal R_mouse_x      : signed(C_XY_coordinate_bits-1 downto 0);
  signal R_mouse_y      : signed(C_XY_coordinate_bits-1 downto 0);
  signal R_mouse_z      : signed(9-1 downto 0);
  signal R_mouse_btn    : std_logic_vector(3-1 downto 0); -- 2=middle, 1=right, 0=left
  signal R_prev_mouse_btn    : std_logic_vector(3-1 downto 0); -- 2=middle, 1=right, 0=left

  signal R_pointer_dv: std_logic; -- for output

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
  type T_vlayout_list_boxes is array (0 to 3) of T_list_box;
  constant C_vlayout_list_boxes: T_vlayout_list_boxes :=
  (
    ( -- 1920x1080
  -- Xmin, Xmax, Ymin, Ymax,
        2,   49,    2,  258, -- 0: top left window (vertical scale)
       51, 1651,    2,  258, -- 1: top center window (the grid)
     1653, 1916,    2,  258, -- 2: top right window (text)
       51, 1651,  260,  267, -- 3: thin window below the grid (horizontal scale)
    0, C_XY_max, 0, C_XY_max -- 4: termination record
  -- termination record has to match always for this algorithm to work
    ),
    ( -- 800x600
  -- Xmin, Xmax, Ymin, Ymax,
        2,   49,    2,  258, -- 0: top left window (vertical scale)
       51,  531,    2,  258, -- 1: top center window (the grid)
      533,  796,    2,  258, -- 2: top right window (text)
       51,  531,  260,  267, -- 3: thin window below the grid (horizontal scale)
    0, C_XY_max, 0, C_XY_max -- 4: termination record
  -- termination record has to match always for this algorithm to work
    ),
    ( -- 1920x1080
  -- Xmin, Xmax, Ymin, Ymax,
        2,   49,    2,  258, -- 0: top left window (vertical scale)
       51, 1651,    2,  258, -- 1: top center window (the grid)
     1653, 1916,    2,  258, -- 2: top right window (text)
       51, 1651,  260,  267, -- 3: thin window below the grid (horizontal scale)
    0, C_XY_max, 0, C_XY_max -- 4: termination record
  -- termination record has to match always for this algorithm to work
    ),
    ( -- 1280x768
  -- Xmin, Xmax, Ymin, Ymax,
        2,   49,    2,  258, -- 0: top left window (vertical scale)
       51, 1011,    2,  258, -- 1: top center window (the grid)
     1013, 1276,    2,  258, -- 2: top right window (text)
       51, 1011,  260,  267, -- 3: thin window below the grid (horizontal scale)
    0, C_XY_max, 0, C_XY_max -- 4: termination record
  -- termination record has to match always for this algorithm to work
    )
  );
  constant C_list_box: T_list_box := C_vlayout_list_boxes(vlayout_id);
  constant C_box_id_bits: integer := unsigned_num_bits(C_list_box_count);
  -- R_box_id will contain ID of the box where mouse pointer is
  -- when mouse is outside of any box, R_box_id will be equal to C_list_box_count,
  -- (ID of the termination record)
  signal R_box_id, R_clicked_box_id: unsigned(C_box_id_bits-1 downto 0); -- ID of the box where cursor is

  -- mouse dragging
  signal R_dragging: std_logic := '0'; -- becomes 1 when dragging
begin
  -- register stage to sum mouse deltas and offload timing
  process(clk)
  begin
    if rising_edge(clk) then
      R_mouse_update <= mouse_update;
      if mouse_update = '1' then
        R_mouse_dx <= mouse_dx;
        R_mouse_dy <= mouse_dy;
        R_mouse_dz <= mouse_dz;
        R_mouse_x <= std_logic_vector(signed(R_mouse_x) + mouse_dx);
        R_mouse_y <= std_logic_vector(signed(R_mouse_y) - mouse_dy);
        R_mouse_z <= std_logic_vector(signed(R_mouse_z) + mouse_dz);
        R_mouse_btn <= mouse_btn;
        R_prev_mouse_btn <= R_mouse_btn;
        if mouse_dx /= 0 or mouse_dy /= 0 then
          R_pointer_dv <= '1';
        end if;
      else
        R_pointer_dv <= '0';
      end if;
    end if;
  end process;
  -- output for updating pointer on display
  pointer_dv <= R_pointer_dv;
  pointer_x  <= std_logic_vector(R_mouse_x);
  pointer_y  <= std_logic_vector(R_mouse_y);

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
          R_latch_x <= unsigned(R_mouse_x);
          R_latch_y <= unsigned(R_mouse_y);
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
    signal R_press_x, R_press_y: signed(C_XY_coordinate_bits-1 downto 0);
    signal R_dx, R_dy: signed(C_XY_coordinate_bits-1 downto 0);
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if R_mouse_btn(2 downto 0) = "000" then -- all btn's released
          R_dragging <= '0';
          R_clicked_box_id <= R_box_id;
          R_press_x <= R_mouse_x; -- record mouse position for future drag
          R_press_y <= R_mouse_y;
        else -- R_mouse_btn(2 downto 0) /= "000" -- any btn pressed
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
        R_dx <= R_mouse_x - R_press_x;
        R_dy <= R_mouse_y - R_press_y;
      end if;
    end process;
  end block;
  
  dispatch_mouse_event: block
    signal R_vertical_scale_offset, S_vertical_scale_offset_next: signed(13 downto 0);
    signal R_vertical_scale_gain, S_vertical_scale_gain_next: signed(1 downto 0);
    signal R_horizontal_scale_offset, S_horizontal_scale_offset_next: signed(15 downto 0);
    signal R_horizontal_scale_timebase, S_horizontal_scale_timebase_next: signed(3 downto 0);
    signal R_trace_selected, S_trace_selected_next: signed(1 downto 0);
    signal R_trigger_level, S_trigger_level_next: signed(8 downto 0);
    signal R_trigger_source, S_trigger_source_next: signed(1 downto 0);
    signal R_trigger_edge, S_trigger_edge_next: std_logic;
    signal R_trigger_freeze, S_trigger_freeze_next: std_logic;
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
    -- TODO reduce amount of arithmetic adders
    -- by using registers like in "find_box" block above,
    -- see "R_A" and "R_B".
    -- Keep this code simple and readable.
    S_vertical_scale_offset_next <= R_vertical_scale_offset + R_mouse_dy
                               when R_dragging = '1' and R_mouse_btn(0) = '1'
                               else R_vertical_scale_offset;
    S_vertical_scale_gain_next <= R_vertical_scale_gain + R_mouse_dz(R_vertical_scale_gain'range);
    S_horizontal_scale_offset_next <= R_horizontal_scale_offset - R_mouse_dx
                                 when R_dragging = '1' and R_mouse_btn(0) = '1'
                                 else R_horizontal_scale_offset;
    S_horizontal_scale_timebase_next <= R_horizontal_scale_timebase + R_mouse_dz;
    S_trace_selected_next <= R_trace_selected - R_mouse_dz(R_trace_selected'range);
    S_trigger_level_next <= R_trigger_level + R_mouse_dy
                       when R_dragging = '1' -- and R_mouse_btn(2) = '1' -- wheel pressed Y-drag
                       else R_trigger_level - R_mouse_dz; -- rotate wheel
    S_trigger_source_next <= R_trace_selected when R_mouse_btn(2 downto 0) /= "000" else R_trigger_source;
    S_trigger_edge_next <= not R_trigger_edge when R_mouse_btn(2) = '1' and R_prev_mouse_btn(2) = '0' else R_trigger_edge;
    S_trigger_freeze_next <= not R_trigger_freeze when R_mouse_btn(1) = '1' and R_prev_mouse_btn(1) = '0' else R_trigger_freeze;
    process(clk)
    begin
      if rising_edge(clk) then
        case R_clicked_box_id is
          when 0 => -- mouse has clicked on the vertical scale window
            R_rgtr_dv <= R_mouse_update;
            if R_dragging = '1' then
              -- drag mouse to change vertical scale offset
              R_rgtr_id <= x"14"; -- trace vertical settings
              R_rgtr_data(31 downto 18) <= (others => '0');
              R_rgtr_data(17 downto 16) <= (others => '0'); -- R_trace_selected; -- ??
              R_rgtr_data(15 downto 14) <= (others => '0'); -- R_trace_selected; -- ??
              R_rgtr_data(13 downto 0) <= S_vertical_scale_offset_next;
            else
              -- rotate wheel to change vertical scale gain
              R_rgtr_id <= x"13"; -- vertical gain settings
              R_rgtr_data(31 downto 8) <= (others => '0');
              R_rgtr_data(7 downto 6) <= S_vertical_scale_gain_next;
              R_rgtr_data(4 downto 2) <= (others => '0');
              R_rgtr_data(1 downto 0) <= R_trace_selected;
            end if;
            if R_mouse_update = '1' then
              R_vertical_scale_offset <= S_vertical_scale_offset_next;
              R_vertical_scale_gain <= S_vertical_scale_gain_next;
            end if;
          when 1 => -- mouse has clicked on the grid
            -- click to apply trigger to selected input channel
            -- drag mouse up-down or rotate wheel to change trigger level
            -- press wheel to change trigger edge
            -- click right to freeze
            R_rgtr_dv <= R_mouse_update;
            R_rgtr_id <= x"12"; -- trigger
            R_rgtr_data(31 downto 13) <= (others => '0');
            R_rgtr_data(12 downto 11) <= S_trigger_source_next;
            R_rgtr_data(10 downto 2) <= std_logic_vector(S_trigger_level_next);
            R_rgtr_data(1) <= S_trigger_edge_next; -- when '1' falling edge
            R_rgtr_data(0) <= S_trigger_freeze_next; -- when '1' trigger freeze
            if R_mouse_update = '1' then
              -- press wheel
              R_trigger_edge <= S_trigger_edge_next;
              -- click right btn
              R_trigger_freeze <= S_trigger_freeze_next;
              -- from rotating wheel or y-dragging
              R_trigger_level <= S_trigger_level_next;
              -- at wheel press apply trigger source
              R_trigger_source <= S_trigger_source_next;
            end if;
          when 2 => -- mouse has clicked on the text window (to the right of the grid)
            -- rotate wheel to select the input channel
            -- frame will change color to indicate
            -- a color of trace which is "selected".
            R_rgtr_dv <= R_mouse_update;
            R_rgtr_id <= x"11"; -- palette (color)
            R_rgtr_data(31 downto 10) <= (others => '0');
            R_rgtr_data(9 downto 7) <= C_trace_color(to_integer(S_trace_selected_next));
            R_rgtr_data(6 downto 4) <= (others => '0');
            R_rgtr_data(3 downto 0) <= x"7"; -- 7: frame color indicates selected channel/trace
            if R_mouse_update = '1' then
              R_trace_selected <= S_trace_selected_next;
            end if;
          when 3 => -- mouse has clicked on the thin window below grid
            -- drag mouse left-right to move horizontal scale offset
            -- rotate mouse wheel to change timebase scale
            R_rgtr_dv <= R_mouse_update;
            R_rgtr_id <= x"10"; -- horizontal scale settings
            R_rgtr_data(31 downto 20) <= (others => '0');
            R_rgtr_data(19 downto 16) <= S_horizontal_scale_timebase_next;
            R_rgtr_data(15 downto 0) <= S_horizontal_scale_offset_next;
            if R_mouse_update = '1' then
              R_horizontal_scale_offset <= S_horizontal_scale_offset_next;
              R_horizontal_scale_timebase <= S_horizontal_scale_timebase_next;
            end if;
          when others =>
            R_rgtr_dv <= R_mouse_update; -- help rgtr2daisy to update mouse alwyas
            R_rgtr_id <= (others => '0'); -- no register
            R_rgtr_data <= (others => '0'); -- no data
        end case;
      end if; -- rising edge
    end process;
  end block;

  -- pointer will not be rgtr'd
  -- rgtr2daisy should serialize pointer
  rgtr_dv <= R_rgtr_dv;
  rgtr_id <= R_rgtr_id;
  rgtr_data <= R_rgtr_data;

  -- simple example for mouse pointer
  --rgtr_dv <= R_mouse_update;
  --rgtr_id <= x"15"; -- mouse pointer
  --rgtr_data(31 downto 22) <= (others => '0');
  --rgtr_data(21 downto 11) <= R_mouse_y;
  --rgtr_data(10 downto 0)  <= R_mouse_x;

  -- simple example to change trigger level (4-ch scope)
  --rgtr_dv <= R_mouse_update;
  --rgtr_id <= x"12"; -- trigger
  --rgtr_data(31 downto 13) <= (others => '0');
  --rgtr_data(12 downto 11) <= R_mouse_btn(1 downto 0); -- left/right btn select trigger channel
  --rgtr_data(10 downto 2) <= R_mouse_z(8 downto 0); -- rotating wheel changes trigger level
  --rgtr_data(1) <= R_mouse_btn(2); -- wheel press selects trigger edge
  --rgtr_data(0) <= '0'; -- when '1' trigger freeze

  -- simple example to change grid color with mouse wheel (4-ch scope)
  --rgtr_dv <= R_mouse_update;
  --rgtr_id <= x"11"; -- palette (color)
  --rgtr_data(31 downto 10) <= (others => '0');
  --rgtr_data(9 downto 7) <= R_mouse_z(2 downto 0); -- moving mouse wheel changes color
  --rgtr_data(6 downto 4) <= (others => '0');
  --rgtr_data(3 downto 0) <= x"0"; -- of grid
  -- x"7" frame color
  -- x"6" bg color of text window
  -- x"3" bg color of thin window
end;
