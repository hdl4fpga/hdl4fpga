-- AUTHOR = EMARD
-- LICENSE = BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_mouse2rgtr is
generic
(
  -- 0:no debug (normal use), 1:debug pointer, 2:debug trigger, 3:debug grid color
  C_simple_debug_mode: integer range 0 to 3 := 0;
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

  -- screen geometry functions, imported from scopeiopkg
  constant layout : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);
  -- screen y-coordinate of Y=0 on the grid
  constant C_grid_y0: signed(C_XY_coordinate_bits-1 downto 0) := 
    to_signed(grid_y(layout) + grid_height(layout)/2 + sgmnt_margin(layout),C_XY_coordinate_bits);
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
     -- 0: top left window (vertical scale) C_window_vtaxis
     to_unsigned( vtaxis_x(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Xmin
     to_unsigned( vtaxis_x(layout)+sgmnt_margin(layout)+ vtaxis_width(layout),   C_XY_coordinate_bits), -- Xmax
     to_unsigned( vtaxis_y(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Ymin
     to_unsigned( vtaxis_y(layout)+sgmnt_margin(layout)+ vtaxis_height(layout),  C_XY_coordinate_bits), -- Ymax

     -- 1: C_window_grid top center window (the grid) C_window_grid
     to_unsigned(   grid_x(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Xmin
     to_unsigned(   grid_x(layout)+sgmnt_margin(layout)+   grid_width(layout) -1,C_XY_coordinate_bits), -- Xmax
     to_unsigned(   grid_y(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Ymin
     to_unsigned(   grid_y(layout)+sgmnt_margin(layout)+   grid_height(layout)-1,C_XY_coordinate_bits), -- Ymax

     -- 2: top right window (text) C_window_textbox
     to_unsigned(textbox_x(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Xmin
     to_unsigned(textbox_x(layout)+sgmnt_margin(layout)+textbox_width(layout),   C_XY_coordinate_bits), -- Xmax
     to_unsigned(textbox_y(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Ymin
     to_unsigned(textbox_y(layout)+sgmnt_margin(layout)+textbox_height(layout),  C_XY_coordinate_bits), -- Ymax

     -- 3: thin window below the grid (horizontal scale) C_window_hzaxis
     to_unsigned( hzaxis_x(layout)+sgmnt_margin(layout),                         C_XY_coordinate_bits), -- Xmin
     to_unsigned( hzaxis_x(layout)+sgmnt_margin(layout)+ hzaxis_width(layout),   C_XY_coordinate_bits), -- Xmax
     to_unsigned( hzaxis_y(layout)+sgmnt_margin(layout)- 1,                      C_XY_coordinate_bits), -- Ymin
     to_unsigned( hzaxis_y(layout)+sgmnt_margin(layout)+ hzaxis_height(layout),  C_XY_coordinate_bits), -- Ymax

     -- 4: termination record
     -- Xmin, Xmax, Ymin, Ymax
     0, C_XY_max, 0, C_XY_max
     -- termination record has to match always (any pointer location) for this algorithm to work
  );
  constant C_box_id_bits: integer := unsigned_num_bits(C_list_box_count);
  -- R_box_id will contain ID of the box where mouse pointer is
  -- when mouse is outside of any box, R_box_id will be equal to C_list_box_count,
  -- (ID of the termination record)
  signal R_box_id, R_clicked_box_id: unsigned(C_box_id_bits-1 downto 0); -- ID of the box where cursor is

  -- named constants for box_id
  constant C_window_vtaxis:  unsigned(C_box_id_bits-1 downto 0) := 0;
  constant C_window_grid:    unsigned(C_box_id_bits-1 downto 0) := 1;
  constant C_window_textbox: unsigned(C_box_id_bits-1 downto 0) := 2;
  constant C_window_hzaxis:  unsigned(C_box_id_bits-1 downto 0) := 3;

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
        R_mouse_x <= std_logic_vector(R_mouse_x + mouse_dx);
        R_mouse_y <= std_logic_vector(R_mouse_y - mouse_dy);
        R_mouse_z <= std_logic_vector(R_mouse_z + mouse_dz);
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
  find_box: block
    signal R_A, R_B, R_list_value, R_latch_x, R_latch_y: unsigned(C_XY_coordinate_bits-1 downto 0);
    signal R_C, S_C_next, S_compare, S_new_box: std_logic;
    signal R_list_addr: unsigned(C_box_id_bits+1 downto 0); -- 2 bits more, we have 4 values for a box
    signal R_matching_id, R_previous_id: unsigned(C_box_id_bits-1 downto 0);
  begin
    S_new_box <= '1' when R_list_addr(1 downto 0) = "10" else '0'; -- 2:
    S_compare <= '1' when R_A <= R_B else '0'; -- arithmetic compare function unit
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
    -- pipelined stage for rgtr update arithmetic
    signal R_A, R_B, S_APB: signed(15 downto 0); -- for register arithmetic function unit
    constant C_action_nop: integer := 0;
    constant C_action_trace_select: integer := 1;
    constant C_action_pointer_update: integer := 2;
    constant C_action_vertical_scale_offset_change: integer := 3;
    constant C_action_vertical_scale_gain_change: integer := 4;
    constant C_action_trigger_level_change: integer := 5;
    constant C_action_horizontal_scale_offset_change: integer := 6;
    constant C_action_horizontal_scale_timebase_change: integer := 7;
    constant C_action_pointer_last: integer := C_action_horizontal_scale_timebase_change;
    signal R_action_id: integer range C_action_nop to C_action_pointer_last := 0; -- which action to take

    signal R_vertical_scale_offset: signed(13 downto 0);
    signal R_vertical_scale_gain: signed(1 downto 0);
    signal R_horizontal_scale_offset: signed(15 downto 0);
    signal R_horizontal_scale_timebase: signed(3 downto 0);
    signal R_trace_selected: signed(1 downto 0);
    signal R_trigger_level: signed(8 downto 0);
    signal R_trigger_source: signed(1 downto 0);
    signal R_trigger_edge: std_logic;
    signal R_trigger_freeze: std_logic;
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
    -- 1st pipeline stage: decode mouse event and fill arithmetic registers A, B
    process(clk)
    begin
      if rising_edge(clk) then
            if R_mouse_update = '1' then
              case R_clicked_box_id is
                when C_window_vtaxis => -- mouse clicked on the vertical scale window
                  if R_dragging = '1' then -- drag Y to change vertical scale offset
                    R_A(R_vertical_scale_offset'range) <= R_vertical_scale_offset;
                    R_B(R_vertical_scale_offset'range) <= resize(R_mouse_dy, R_vertical_scale_offset'length);
                    R_action_id <= C_action_vertical_scale_offset_change;
                  else -- rotate wheel to change vertical gain
                    R_A(R_vertical_scale_gain'range) <= R_vertical_scale_gain;
                    R_B(R_vertical_scale_gain'range) <= resize(R_mouse_dz, R_vertical_scale_gain'length);
                    R_action_id <= C_action_vertical_scale_gain_change;
                  end if;
                when C_window_grid => -- mouse clicked on the grid window
                  if R_dragging = '1' then -- drag Y to change trigger level
                    R_A(R_trigger_level'range) <= R_trigger_level;
                    R_B(R_trigger_level'range) <= resize(R_mouse_dy, R_trigger_level'length);
                    R_action_id <= C_action_trigger_level_change;
                  else  -- not dragging: clicking or wheel rotation
                    if R_mouse_btn(0) = '1' and R_prev_mouse_btn(0) = '0' then
                      -- left click to directy set the trigger level
                      R_A(R_trigger_level'range) <= resize(C_grid_y0, R_trigger_level'length);
                      R_B(R_trigger_level'range) <= resize(-R_mouse_y, R_trigger_level'length);
                    else
                      -- rotate wheel to change trigger level
                      R_A(R_trigger_level'range) <= R_trigger_level;
                      R_B(R_trigger_level'range) <= resize(-R_mouse_dz, R_trigger_level'length);
                    end if;
                    -- click wheel to change edge, right click to freeze
                    -- HACK: using free bits in the adder to toggle 0/1
                    R_A(R_A'high)   <= R_trigger_edge;
                    R_A(R_A'high-1) <= '0'; -- space bit to avoid carry going higher
                    R_A(R_A'high-2) <= R_trigger_freeze;
                    R_A(R_A'high-3) <= '0'; -- space bit to avoid carry going higher
                    R_B(R_B'high)   <= R_mouse_btn(2) and not R_prev_mouse_btn(2); -- wheel click
                    R_B(R_B'high-1) <= '0'; -- space bit to avoid carry going higher
                    R_B(R_B'high-2) <= R_mouse_btn(1) and not R_prev_mouse_btn(1); -- right click
                    R_B(R_B'high-3) <= '0'; -- space bit to avoid carry going higher
                    R_action_id <= C_action_trigger_level_change;
                  end if;
                when C_window_textbox => -- mouse clicked on the text window (to the right of the grid)
                  -- rotate wheel to change trigger source (indicated by frame color)
                  R_A(R_trace_selected'range) <= R_trace_selected;
                  R_B(R_trace_selected'range) <= resize(-R_mouse_dz, R_trace_selected'length);
                  R_action_id <= C_action_trace_select;
                when C_window_hzaxis => -- mouse clicked on the thin window below grid
                  if R_dragging = '1' then -- drag X to change level
                    R_A(R_horizontal_scale_offset'range) <= R_horizontal_scale_offset;
                    R_B(R_horizontal_scale_offset'range) <= resize(-R_mouse_dx, R_horizontal_scale_offset'length);
                    R_action_id <= C_action_horizontal_scale_offset_change;
                  else -- rotate wheel to change trigger level
                    R_A(R_horizontal_scale_timebase'range) <= R_horizontal_scale_timebase;
                    R_B(R_horizontal_scale_timebase'range) <= resize(R_mouse_dz, R_horizontal_scale_timebase'length);
                    R_action_id <= C_action_horizontal_scale_timebase_change;
                  end if;
                when others => -- help rgtr2daisy to update mouse always
                  R_action_id <= C_action_pointer_update;
              end case;
            else -- R_mouse_update = '0'
              R_action_id <= C_action_nop;
            end if;
      end if; -- rising edge
    end process;

    S_APB <= R_A + R_B; -- "A plus B" arithmetic function unit

    -- 2nd pipeline stage: send RGTR command and update local register value
    process(clk)
    begin
      if rising_edge(clk) then
        case R_action_id is
          when C_action_vertical_scale_offset_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"14"; -- trace vertical settings
            R_rgtr_data(31 downto 18) <= (others => '0');
            R_rgtr_data(17 downto 16) <= (others => '0'); -- R_trace_selected; -- ??
            R_rgtr_data(15 downto 14) <= (others => '0'); -- R_trace_selected; -- ??
            R_rgtr_data(R_vertical_scale_offset'range) <= S_APB(R_vertical_scale_offset'range);
            R_vertical_scale_offset <= S_APB(R_vertical_scale_offset'range);
          when C_action_vertical_scale_gain_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"13"; -- trace vertical settings
            R_rgtr_data(31 downto 8) <= (others => '0');
            R_rgtr_data(7 downto 6) <= S_APB(R_vertical_scale_gain'range);
            R_rgtr_data(4 downto 2) <= (others => '0');
            R_rgtr_data(1 downto 0) <= R_trace_selected;
            R_vertical_scale_gain <= S_APB(R_vertical_scale_gain'range);
          when C_action_trigger_level_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"12"; -- trigger level
            R_rgtr_data(31 downto 13) <= (others => '0');
            R_rgtr_data(12 downto 11) <= R_trace_selected;
            R_rgtr_data(10 downto 2) <= S_APB(R_trigger_level'range);
            R_rgtr_data(1) <= S_APB(S_APB'high); -- when '1' falling edge
            R_rgtr_data(0) <= S_APB(S_APB'high-2); -- when '1' trigger freeze
            R_trigger_level <= S_APB(R_trigger_level'range);
            R_trigger_edge <= S_APB(S_APB'high);
            R_trigger_freeze <= S_APB(S_APB'high-2);
          when C_action_horizontal_scale_offset_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"10"; -- horizontal scale settings
            R_rgtr_data(31 downto 20) <= (others => '0');
            R_rgtr_data(19 downto 16) <= R_horizontal_scale_timebase;
            R_rgtr_data(15 downto 0) <= S_APB(R_horizontal_scale_offset'range);
            R_horizontal_scale_offset <= S_APB(R_horizontal_scale_offset'range);
          when C_action_horizontal_scale_timebase_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"10"; -- horizontal scale settings
            R_rgtr_data(31 downto 20) <= (others => '0');
            R_rgtr_data(19 downto 16) <= S_APB(R_horizontal_scale_timebase'range);
            R_rgtr_data(15 downto 0) <= R_horizontal_scale_offset;
            R_horizontal_scale_timebase <= S_APB(R_horizontal_scale_timebase'range);
          when C_action_trace_select =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"11"; -- palette (color)
            R_rgtr_data(31 downto 10) <= (others => '0');
            R_rgtr_data(9 downto 7) <= C_trace_color(to_integer(S_APB(R_trace_selected'range)));
            R_rgtr_data(6 downto 4) <= (others => '0');
            R_rgtr_data(3 downto 0) <= x"7"; -- 7: frame color indicates selected channel/trace
            R_trace_selected <= S_APB(R_trace_selected'range);
          when C_action_pointer_update =>
            R_rgtr_dv <= '1'; -- help rgtr2daisy to update mouse always
            R_rgtr_id <= (others => '0'); -- no register
            R_rgtr_data <= (others => '0'); -- no data
          when others => -- NOP
            R_rgtr_dv <= '0';
            R_rgtr_id <= (others => '0'); -- no register
            R_rgtr_data <= (others => '0'); -- no data
        end case;
      end if; -- rising edge
    end process;
  end block;

  G_normal: if C_simple_debug_mode = 0 generate
  -- pointer will not be rgtr'd
  -- rgtr2daisy should serialize pointer
  rgtr_dv <= R_rgtr_dv;
  rgtr_id <= R_rgtr_id;
  rgtr_data <= R_rgtr_data;
  end generate;

  G_debug_pointer: if C_simple_debug_mode = 1 generate
  -- simple example for mouse pointer
  rgtr_dv <= R_mouse_update;
  rgtr_id <= x"15"; -- mouse pointer
  rgtr_data(31 downto 22) <= (others => '0');
  rgtr_data(21 downto 11) <= R_mouse_y;
  rgtr_data(10 downto 0)  <= R_mouse_x;
  end generate;

  G_debug_trigger: if C_simple_debug_mode = 2 generate
  -- simple example to change trigger level (4-ch scope)
  rgtr_dv <= R_mouse_update;
  rgtr_id <= x"12"; -- trigger
  rgtr_data(31 downto 13) <= (others => '0');
  rgtr_data(12 downto 11) <= R_mouse_btn(1 downto 0); -- left/right btn select trigger channel
  rgtr_data(10 downto 2) <= R_mouse_z(8 downto 0); -- rotating wheel changes trigger level
  rgtr_data(1) <= R_mouse_btn(2); -- wheel press selects trigger edge
  rgtr_data(0) <= '0'; -- '1' = trigger freeze
  end generate;

  G_debug_color: if C_simple_debug_mode = 3 generate
  -- simple example to change grid color with mouse wheel (4-ch scope)
  rgtr_dv <= R_mouse_update;
  rgtr_id <= x"11"; -- palette (color)
  rgtr_data(31 downto 10) <= (others => '0');
  rgtr_data(9 downto 7) <= R_mouse_z(2 downto 0); -- rotating wheel changes color
  rgtr_data(6 downto 4) <= (others => '0');
  rgtr_data(3 downto 0) <= x"0"; -- grid color
  -- x"7" frame color
  -- x"6" bg color of text window
  -- x"3" bg color of thin window
  end generate;
end;
