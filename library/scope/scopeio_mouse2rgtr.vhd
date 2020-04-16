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

  -- to render things correctly, GUI system needs to know:
  C_inputs       : integer range 1 to 63; -- number of input channels (traces)
  C_tracesfg     : std_logic_vector; -- colors of traces
  vlayout_id     : integer := 0 -- video geometry
);
port
(
  clk           : in  std_logic;

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
  -- screen geometry functions, imported from scopeiopkg
  constant layout : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);

  constant C_XY_coordinate_bits: integer := unsigned_num_bits(
    max(integer(layout.display_width), integer(layout.display_height)) - 1);

  signal R_mouse_update: std_logic; -- data valid signal

  signal R_mouse_dx     : signed(mouse_dx'range);
  signal R_mouse_dy     : signed(mouse_dy'range);
  signal R_mouse_dz     : signed(mouse_dz'range);
  
  constant C_mouse_dz0   : signed(mouse_dz'range) := (others => '0');

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
  
  function F_if
  (
    constant condition: boolean;
    constant value_true, value_false: natural
  )
  return natural is
  begin
    if condition then
      return value_true;
    else
      return value_false;
    end if;
  end;


  -- at box n if Result is 1, then mouse pointer was found in previous box (n-1)
  constant C_XY_min: unsigned(C_XY_coordinate_bits-1 downto 0) := (others => '0');
  constant C_XY_max: unsigned(C_XY_coordinate_bits-1 downto 0) := (others => '1');

  constant C_screen_x_offset: natural := layout.main_margin(left);
  constant C_screen_y_offset: natural := layout.main_margin(top);

  constant C_left_x:   natural := C_screen_x_offset+vtaxis_x(layout);
  constant C_upper_y:  natural := C_screen_y_offset+vtaxis_y(layout);

  constant C_middle_x: natural := C_screen_x_offset+vtaxis_x(layout)+vtaxis_width(layout);
  constant C_middle_y: natural := C_screen_y_offset+hzaxis_y(layout)-2;

  constant C_right_x:  natural := C_screen_x_offset+hzaxis_x(layout)+hzaxis_width(layout)-1;
  constant C_lower_y:  natural := C_screen_y_offset+hzaxis_y(layout)+hzaxis_height(layout)-1;

  type T_list_box1 is array (natural range <>) of unsigned(C_XY_coordinate_bits-1 downto 0);
  constant C_list_box1: T_list_box1 :=
  (
     -- 0: top left window (vertical scale) C_window_vtaxis
     to_unsigned(   C_left_x,    C_XY_coordinate_bits), -- Xmin
     to_unsigned(   C_middle_x-1,C_XY_coordinate_bits), -- Xmax
     to_unsigned(   C_upper_y,   C_XY_coordinate_bits), -- Ymin
     to_unsigned(   C_middle_y-1,C_XY_coordinate_bits), -- Ymax

     -- 1: C_window_grid top center window (the grid) C_window_grid
     to_unsigned(   C_middle_x,  C_XY_coordinate_bits), -- Xmin
     to_unsigned(   C_right_x-1, C_XY_coordinate_bits), -- Xmax
     to_unsigned(   C_upper_y,   C_XY_coordinate_bits), -- Ymin
     to_unsigned(   C_middle_y-1,C_XY_coordinate_bits), -- Ymax

     -- 2: tiny color box below vtscale and left of hzscale
     to_unsigned(   C_left_x,    C_XY_coordinate_bits), -- Xmin
     to_unsigned(   C_middle_x-1,C_XY_coordinate_bits), -- Xmax
     to_unsigned(   C_middle_y,  C_XY_coordinate_bits), -- Ymin
     to_unsigned(   C_lower_y,   C_XY_coordinate_bits), -- Ymax

     -- 3: thin window below the grid (horizontal scale) C_window_hzaxis
     to_unsigned(   C_middle_x,  C_XY_coordinate_bits), -- Xmin
     to_unsigned(   C_right_x,   C_XY_coordinate_bits), -- Xmax
     to_unsigned(   C_middle_y,  C_XY_coordinate_bits), -- Ymin
     to_unsigned(   C_lower_y,   C_XY_coordinate_bits), -- Ymax

     -- 4: termination record
     -- Xmin, Xmax, Ymin, Ymax
     C_XY_min, C_XY_max, C_XY_min, C_XY_max
     -- termination record has to match always (any pointer location) for this algorithm to work
  );

  -- C_list_box1 will be copied to C_list_box
  -- with layout repeated to make all segments clickable.
  -- To save LUTs, set C_num_segments=1, then only first
  -- segment will be clickable.
  constant C_num_segments: integer range 1 to layout.num_of_segments := layout.num_of_segments; -- 1 to save LUTs
  constant C_max_boxes_bits: integer := 3; -- There can be 2^n-1 clickable boxes, last box is for termination
  constant C_max_boxes: integer := 2**C_max_boxes_bits; -- must be power of 2 for the code to work
  type T_list_box is array (0 to (C_num_segments-1)*C_max_boxes*4+C_list_box1'length-1) of unsigned(C_XY_coordinate_bits-1 downto 0);
  function F_repeat_segment_boxes
  (
    constant C_list1: T_list_box1;
    constant C_segment_step: integer;
    constant C_max_boxes: integer;
    constant C_num_segments: integer
  )
  return T_list_box is
    constant C_num_boxes: integer := C_list1'length/4-1; -- -1 to not count in the termination record
    variable V_list: T_list_box;
  begin
    for k in 0 to C_num_segments-1 loop
      for i in 0 to C_num_boxes-1 loop
        V_list(C_max_boxes*4*k+4*i+0) := C_list1(4*i+0); -- Xmin
        V_list(C_max_boxes*4*k+4*i+1) := C_list1(4*i+1); -- Xmax
        V_list(C_max_boxes*4*k+4*i+2) := C_list1(4*i+2) + k*C_segment_step; -- Ymin
        V_list(C_max_boxes*4*k+4*i+3) := C_list1(4*i+3) + k*C_segment_step; -- Ymax
      end loop; -- one segment
      if C_num_boxes < C_max_boxes and k < C_num_segments-1 then -- don't do this for the last segment
      for i in C_num_boxes to C_max_boxes-1 loop
        -- fill the rest records with never-matching boxes
        V_list(C_max_boxes*4*k+4*i+0) := C_XY_max; -- Xmin
        V_list(C_max_boxes*4*k+4*i+1) := C_XY_min; -- Xmax
        V_list(C_max_boxes*4*k+4*i+2) := C_XY_max; -- Ymin
        V_list(C_max_boxes*4*k+4*i+3) := C_XY_min; -- Ymax
      end loop; -- one segment
      end if;
    end loop; -- segments
    -- termination record is an always-matching box
    V_list(C_max_boxes*4*(C_num_segments-1)+4*C_num_boxes+0) := C_XY_min; -- Xmin
    V_list(C_max_boxes*4*(C_num_segments-1)+4*C_num_boxes+1) := C_XY_max; -- Xmax
    V_list(C_max_boxes*4*(C_num_segments-1)+4*C_num_boxes+2) := C_XY_min; -- Ymin
    V_list(C_max_boxes*4*(C_num_segments-1)+4*C_num_boxes+3) := C_XY_max; -- Ymax
    return V_list;
  end; -- function

  constant C_segment_step: integer := layout.sgmnt_margin(top)+grid_height(layout)+F_if(layout.hzaxis_within,0,1)*hzaxis_height(layout)+layout.sgmnt_margin(bottom)+layout.main_gap(vertical);
  constant C_list_box: T_list_box := F_repeat_segment_boxes(
    C_list_box1,
    C_segment_step, C_max_boxes, C_num_segments);
  constant C_list_box_count: integer := C_list_box'length/4; -- how many boxes, including termination record
  constant C_box_id_bits: integer := unsigned_num_bits(C_list_box_count);
  -- R_box_id will contain ID of the box where mouse pointer is
  -- when mouse is outside of any box, R_box_id will be equal to C_list_box_count,
  -- (ID of the termination record)
  signal R_box_id, R_clicked_box_id: unsigned(C_box_id_bits-1 downto 0); -- ID of the box where cursor is
  
  -- generate click to trigger ROM
  -- +2 compensates
  -- "not R_mouse_y" used instead of "-R_mouse_y" in 1st pipeline stage
  -- and similar use of "not" in the arithmetic helper for click to trigger
  type T_click_to_trigger is array (0 to C_num_segments-1) of signed(C_XY_coordinate_bits-1 downto 0);
  function F_click_to_trigger
  (
    constant C_base_y0: integer;
    constant C_segment_step: integer;
    constant C_num_segments: integer;
    constant C_bits: integer
  )
  return T_click_to_trigger is
    variable V_click_to_trigger: T_click_to_trigger;
  begin
    for i in 0 to C_num_segments-1 loop
      V_click_to_trigger(i) := to_signed(C_base_y0 + i*C_segment_step + 2, C_bits);
    end loop; -- segments
    return V_click_to_trigger;
  end; -- function
  constant C_click_to_trigger: T_click_to_trigger := F_click_to_trigger
  (
    grid_y(layout) + grid_height(layout)/2 + layout.main_margin(top),
    C_segment_step, C_num_segments, C_XY_coordinate_bits
  );
-- example what would this function do for 3 segments:
--  constant C_click_to_trigger: T_click_to_trigger :=
--  (
--    to_signed(grid_y(layout) + grid_height(layout)/2 + layout.main_margin(top) + 0*C_segment_step, C_XY_coordinate_bits), 
--    to_signed(grid_y(layout) + grid_height(layout)/2 + layout.main_margin(top) + 1*C_segment_step, C_XY_coordinate_bits),
--    to_signed(grid_y(layout) + grid_height(layout)/2 + layout.main_margin(top) + 2*C_segment_step, C_XY_coordinate_bits)
--  );

  -- named constants for box_id
  constant C_window_vtaxis:  natural := 0;
  constant C_window_grid:    natural := 1;
  --constant C_window_textbox: natural := 2;
  constant C_window_below_vtaxis: natural := 2;
  constant C_window_hzaxis:  natural := 3;

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
        R_mouse_x <= R_mouse_x + resize(mouse_dx, R_mouse_x'length);
        R_mouse_y <= R_mouse_y - resize(mouse_dy, R_mouse_y'length);
        R_mouse_z <= R_mouse_z + resize(mouse_dz, R_mouse_z'length);
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
  pointer_x  <= std_logic_vector(resize(unsigned(R_mouse_x), pointer_x'length));
  pointer_y  <= std_logic_vector(resize(unsigned(R_mouse_y), pointer_y'length));

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
          R_clicked_box_id <= R_box_id(R_clicked_box_id'range);
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
    constant C_max_inputs_bits: integer := chanid_maxsize;

    -- pipelined stage for rgtr update arithmetic
    signal R_A, R_B, S_APB: signed(19 downto 0); -- for register arithmetic function unit
    constant C_action_nop: integer := 0;
    constant C_action_trace_select: integer := 1;
    constant C_action_set_color: integer := 2;
    constant C_action_pointer_update: integer := 3;
    constant C_action_vertical_scale_offset_change: integer := 4;
    constant C_action_vertical_scale_gain_change: integer := 5;
    constant C_action_trigger_level_change: integer := 6;
    constant C_action_horizontal_scale_offset_change: integer := 7;
    constant C_action_vertical_scale_color_change: integer := 8;
    constant C_action_horizontal_scale_timebase_change: integer := 9;
    constant C_action_pointer_last: integer := C_action_horizontal_scale_timebase_change;
    signal R_action_id: integer range C_action_nop to C_action_pointer_last := 0; -- which action to take
    constant C_vertical_scale_offset: signed(vtoffset_bf(vtoffset_id)-1 downto 0) := (others => '0');
    type T_vertical_scale_offset is array (0 to C_inputs-1) of signed(C_vertical_scale_offset'range);
    signal R_vertical_scale_offset: T_vertical_scale_offset;
    signal S_vertical_scale_offset: signed(C_vertical_scale_offset'range);
    signal S_vertical_scale_offset_snapped: signed(C_vertical_scale_offset'range);
    signal R_snap_to_vertical_grid: std_logic_vector(C_inputs-1 downto 0);
    constant C_snap_to_grid_bits: integer := unsigned_num_bits(layout.division_size)-1;
    signal R_after_trace_select: unsigned(9 downto 0);
    signal R_after_trigger_level: unsigned(7 downto 0);
    signal C_vertical_scale_gain: signed(gainid_maxsize-1 downto 0) := (others => '0');
    type T_vertical_scale_gain is array (0 to C_inputs-1) of signed(C_vertical_scale_gain'range);
    signal R_vertical_scale_gain: T_vertical_scale_gain;
    signal R_horizontal_scale_offset: signed(hzoffset_bf(hzoffset_id)-1 downto 0);
    signal R_horizontal_scale_timebase: signed(hzoffset_bf(hzscale_id)-1 downto 0);
    signal R_trace_selected: signed(unsigned_num_bits(C_inputs)-1 downto 0); -- FIXME for C_inputs = 64
    constant C_trigger_level: signed(triggerlevel_maxsize-1 downto 0) := (others => '0');
    type T_trigger_level is array (0 to C_inputs-1) of signed(C_trigger_level'range);
    signal R_trigger_level: T_trigger_level;
    signal R_trigger_edge: std_logic_vector(C_inputs-1 downto 0);
    signal R_trigger_freeze: std_logic;
    signal R_trigger_on_screen: signed(C_trigger_level'range);
    -- FIXME trace color list should not be hardcoded
    -- It is used to set frame color to the same (or visually similar)
    -- color of selected trace (input channel).
    -- it is good only if it matches with the colors given to the traces.
    constant C_color_bits: integer := C_tracesfg'length / C_inputs -1;
    type T_trace_color is array (0 to C_inputs-1) of unsigned(C_color_bits-1 downto 0);
    function F_convert_tracesfg_to_trace_color
    (
      constant C_inputs: integer;
      constant C_tracesfg: std_logic_vector
    )
    return T_trace_color is
      constant C_color_bits: integer := C_tracesfg'length / C_inputs;
      variable V_trace_color: T_trace_color;
    begin
      for i in 0 to C_inputs-1 loop
        V_trace_color(i) := unsigned(C_tracesfg(C_color_bits*i+1 to C_color_bits*(i+1)-1));
      end loop;
      return V_trace_color;
    end; -- function
    constant C_trace_color: T_trace_color :=
      F_convert_tracesfg_to_trace_color(C_inputs, C_tracesfg);
    -- example what it would return for 4 inputs and 6 color bits:
    --(
    --  C_tracesfg(6*0 to 6*1-1), -- yellow
    --  C_tracesfg(6*1 to 6*2-1), -- cyan
    --  C_tracesfg(6*2 to 6*3-1), -- green
    --  C_tracesfg(6*3 to 6*4-1)  -- red
    --);
    type T_bitfield_range is array (1 downto 0) of integer;
    function F_bitfield
    (
      bitfield_descriptor: natural_vector;
      bitfield_id: integer
    )
    return T_bitfield_range is
      variable V_bitfield_range: T_bitfield_range;
      variable V_bit_position, V_bit_position_high: integer := 0;
    begin
      if bitfield_id > 0 then
        for i in 0 to bitfield_id-1 loop
          V_bit_position := V_bit_position + integer(bitfield_descriptor(i));
        end loop;
      end if;
      V_bit_position_high := integer(bitfield_descriptor(bitfield_id))+V_bit_position-1;
      V_bitfield_range := (V_bit_position_high, V_bit_position);
      return V_bitfield_range;
    end; -- function
  begin
    -- arithmetic helper for click to set vertical trigger
    S_vertical_scale_offset <= R_vertical_scale_offset(to_integer(R_trace_selected));
    S_vertical_scale_offset_snapped(C_vertical_scale_offset'high downto C_snap_to_grid_bits) <=
      S_vertical_scale_offset(C_vertical_scale_offset'high downto C_snap_to_grid_bits);
    G_single_segment: if C_num_segments = 1 generate
      S_vertical_scale_offset_snapped(C_snap_to_grid_bits-1 downto 0) <= (others => '0')
        when R_snap_to_vertical_grid(to_integer(R_trace_selected)) = '1'
        else S_vertical_scale_offset(C_snap_to_grid_bits-1 downto 0);
      R_trigger_on_screen <= resize(C_click_to_trigger(0) + not S_vertical_scale_offset_snapped, R_trigger_on_screen'length+1)(R_trigger_on_screen'range);
    end generate;
    -- a screen arithmetic required to set trigger with the left click
    -- depending on the segment where the cursor is we have different y offsets
    G_multiple_segments: if C_num_segments > 1 generate
    S_vertical_scale_offset_snapped(C_snap_to_grid_bits-1 downto 0) <= (others => '0')
      when R_snap_to_vertical_grid(to_integer(R_trace_selected)) = '1'
      else S_vertical_scale_offset(C_snap_to_grid_bits-1 downto 0);
    process(clk)
    begin
      if rising_edge(clk) then
        -- for the arithmetic to work when clicked
        -- anyhere high or low, first resize to one bit more
        -- and then slice to required number of bits
        R_trigger_on_screen <= resize(
          -- segment number converted to Y offset:
          -- HACK: bitwise arithmetic to calculate segment number from box ID:
          -- C_max_boxes_bits is for the step of repeating segments
          C_click_to_trigger(to_integer(R_clicked_box_id(R_clicked_box_id'high downto C_max_boxes_bits)))
          + not S_vertical_scale_offset_snapped, -- current trigger setting
          R_trigger_on_screen'length+1)(R_trigger_on_screen'range);
      end if;
    end process;
    end generate;

    -- 1st pipeline stage: decode mouse event and fill arithmetic registers A, B
    process(clk)
    begin
      if rising_edge(clk) then
            if R_mouse_update = '1' then
              case to_integer(R_clicked_box_id(C_max_boxes_bits-1 downto 0)) is -- HACK: limit to C_max_boxes different windows to be clicked
                when C_window_vtaxis => -- mouse clicked on the vertical scale window
                  if R_dragging = '1' then -- drag Y to change vertical scale offset
                    R_A(C_vertical_scale_offset'range) <= R_vertical_scale_offset(to_integer(R_trace_selected));
                    R_B(C_vertical_scale_offset'range) <= resize(R_mouse_dy, C_vertical_scale_offset'length);
                    R_action_id <= C_action_vertical_scale_offset_change;
                    if R_mouse_btn(0) = '1' then
                      R_snap_to_vertical_grid(to_integer(R_trace_selected)) <= '0';
                    else
                      if R_mouse_btn(1) = '1' then
                        R_snap_to_vertical_grid(to_integer(R_trace_selected)) <= '1';
                      end if;
                    end if;
                  else
                    if R_mouse_btn(0) = '0' and R_prev_mouse_btn(0) = '1' then
                      -- after left click, directy set the trigger level
                      R_A(R_A'high)   <= R_trigger_edge(to_integer(R_trace_selected));
                      R_A(R_A'high-1) <= '0'; -- space bit to avoid carry going higher
                      R_A(R_A'high-2) <= R_trigger_freeze;
                      R_A(R_A'high-3) <= '0'; -- space bit to avoid carry going higher
                      R_A(C_trigger_level'range) <= R_trigger_on_screen(C_trigger_level'range);
                      R_B(R_B'high downto R_B'high-3) <= (others => '0'); -- don't change edge/freeze
                      R_B(C_trigger_level'range) <= signed(not resize(unsigned(std_logic_vector(R_mouse_y)), C_trigger_level'length)); -- simplified -R_mouse_y
                      R_action_id <= C_action_trigger_level_change;
                    else -- rotate wheel to change vertical gain
                      R_A(C_vertical_scale_gain'range) <= R_vertical_scale_gain(to_integer(R_trace_selected));
                      R_B(C_vertical_scale_gain'range) <= resize(R_mouse_dz, C_vertical_scale_gain'length);
                      R_action_id <= C_action_vertical_scale_gain_change;
                    end if;
                  end if;
                when C_window_grid => -- mouse clicked on the grid window
                  if R_dragging = '1' then -- drag Y to change trigger level
                    R_A(C_trigger_level'range) <= R_trigger_level(to_integer(R_trace_selected));
                    R_B(C_trigger_level'range) <= resize(R_mouse_dy, C_trigger_level'length);
                    R_action_id <= C_action_trigger_level_change;
                  else  -- not dragging: clicking or wheel rotation
                    if R_mouse_btn(0) = '1' and R_prev_mouse_btn(0) = '0' then
                      -- left click to directy set the trigger level
                      R_A(C_trigger_level'range) <= R_trigger_on_screen(C_trigger_level'range);
                      R_B(C_trigger_level'range) <= signed(not resize(unsigned(std_logic_vector(R_mouse_y)), C_trigger_level'length)); -- simplified -R_mouse_y
                      --R_B(R_trigger_on_screen'range) <= (others => '0'); -- -R_mouse_y;
                    else
                      -- rotate wheel to change trigger level
                      R_A(C_trigger_level'range) <= R_trigger_level(to_integer(R_trace_selected));
                      R_B(C_trigger_level'range) <= resize(-R_mouse_dz, C_trigger_level'length);
                    end if;
                    -- click wheel to change edge, right click to freeze
                    -- HACK: using free bits in the adder to toggle 0/1
                    R_A(R_A'high)   <= R_trigger_edge(to_integer(R_trace_selected));
                    R_A(R_A'high-1) <= '0'; -- space bit to avoid carry going higher
                    R_A(R_A'high-2) <= R_trigger_freeze;
                    R_A(R_A'high-3) <= '0'; -- space bit to avoid carry going higher
                    R_B(R_B'high)   <= R_mouse_btn(2) and not R_prev_mouse_btn(2); -- wheel click
                    R_B(R_B'high-1) <= '0'; -- space bit to avoid carry going higher
                    R_B(R_B'high-2) <= R_mouse_btn(1) and not R_prev_mouse_btn(1); -- right click
                    R_B(R_B'high-3) <= '0'; -- space bit to avoid carry going higher
                    R_action_id <= C_action_trigger_level_change;
                    R_after_trigger_level <= (others => '0'); -- HACK: to change hzscale color when freeze
                  end if;
                --when C_window_textbox => -- mouse clicked on the text window (to the right of the grid)
                when C_window_below_vtaxis => -- tiny color box below vtscale and left of hzscale
                  -- rotate wheel to change trigger source (indicated by frame color)
                  R_A(R_trace_selected'range) <= R_trace_selected;
                  R_B(R_trace_selected'range) <= resize(-R_mouse_dz, R_trace_selected'length);
                  R_action_id <= C_action_trace_select;
                  R_after_trace_select <= (others => '0'); -- HACK: to switch scale
                when C_window_hzaxis => -- mouse clicked on the thin window below grid
                  if R_dragging = '1' then -- drag X to change level
                    R_A(R_horizontal_scale_offset'range) <= R_horizontal_scale_offset;
                    R_B(R_horizontal_scale_offset'range) <= resize(-R_mouse_dx, R_horizontal_scale_offset'length);
                    R_action_id <= C_action_horizontal_scale_offset_change;
                  else -- click to change trigger edge/freeze
                    if R_mouse_btn(1) = '1' or R_mouse_btn(2) = '1' then
                      -- HACK: using free bits in the adder to toggle 0/1
                      R_A(R_A'high)   <= R_trigger_edge(to_integer(R_trace_selected));
                      R_A(R_A'high-1) <= '0'; -- space bit to avoid carry going higher
                      R_A(R_A'high-2) <= R_trigger_freeze;
                      R_A(R_A'high-3) <= '0'; -- space bit to avoid carry going higher
                      R_A(C_trigger_level'range) <= R_trigger_level(to_integer(R_trace_selected));
                      R_B(R_B'high)   <= R_mouse_btn(2) and not R_prev_mouse_btn(2); -- wheel click
                      R_B(R_B'high-1) <= '0'; -- space bit to avoid carry going higher
                      R_B(R_B'high-2) <= R_mouse_btn(1) and not R_prev_mouse_btn(1); -- right click
                      R_B(R_B'high-3) <= '0'; -- space bit to avoid carry going higher
                      R_B(C_trigger_level'range) <= (others => '0'); -- no level change
                      R_action_id <= C_action_trigger_level_change;
                      R_after_trigger_level <= (others => '0'); -- HACK: to change hzscale color when freeze
                    else -- rotate wheel to change timebase
                      R_A(R_horizontal_scale_timebase'range) <= R_horizontal_scale_timebase;
                      R_B(R_horizontal_scale_timebase'range) <= resize(R_mouse_dz, R_horizontal_scale_timebase'length);
                      R_action_id <= C_action_horizontal_scale_timebase_change;
                    end if;
                  end if;
                when others => -- help rgtr2daisy to update mouse always
                  R_action_id <= C_action_pointer_update;
              end case;
            else -- R_mouse_update = '0'
              if R_after_trace_select(R_after_trace_select'high) = '0' then -- counts up to 512
                -- rgtr2daisy must serialize commands - schedule them slowly
                case to_integer(R_after_trace_select(R_after_trace_select'high-1 downto 0)) is
                  when 127 =>
                    -- redraw new channel vertical scale (no value change)
                    R_A(C_vertical_scale_offset'range) <= R_vertical_scale_offset(to_integer(R_trace_selected));
                    R_B(C_vertical_scale_offset'range) <= (others => '0'); -- no change just redraw
                    R_action_id <= C_action_vertical_scale_offset_change;
                  when 255 =>
                    -- trigger on new channel (no value change)
                    R_A(R_A'high)   <= R_trigger_edge(to_integer(R_trace_selected));
                    R_A(R_A'high-1) <= '0'; -- space bit to avoid carry going higher
                    R_A(R_A'high-2) <= R_trigger_freeze;
                    R_A(R_A'high-3) <= '0'; -- space bit to avoid carry going higher
                    R_A(C_trigger_level'range) <= R_trigger_level(to_integer(R_trace_selected));
                    R_B <= (others => '0'); -- no change
                    R_action_id <= C_action_trigger_level_change;
                  when 383 =>
                    -- set lower left corner box color as trace selected
                    R_A(C_color_bits-1 downto 0) <=
                      signed(C_trace_color(to_integer(R_trace_selected))); -- color value
                    R_B(palette_bf(paletteid_id)-1 downto 0) <=
                      signed(to_unsigned(7,palette_bf(paletteid_id))); -- 7: corner box color indicates selected channel/trace
                    R_action_id <= C_action_set_color;
                  when others =>
                    R_action_id <= C_action_nop;
                end case;
                R_after_trace_select <= R_after_trace_select + 1;
              elsif R_after_trigger_level(R_after_trigger_level'high) = '0' then -- counts up to 256
                case to_integer(R_after_trigger_level(R_after_trigger_level'high-1 downto 0)) is
                  when 127 =>
                    -- set hzscale bgcolor blue when trigger freeze
                    R_A(C_color_bits-1 downto 0) <= (0 => R_trigger_freeze, others => '0'); -- color value
                    R_B(palette_bf(paletteid_id)-1 downto 0) <=
                      signed(to_unsigned(4,palette_bf(paletteid_id))); -- 4: hzscale bg color indicates trigger freeze
                    R_action_id <= C_action_set_color;
                  when others =>
                    R_action_id <= C_action_nop;
                end case;
                R_after_trigger_level <= R_after_trigger_level + 1;
              else
                R_action_id <= C_action_nop;
              end if;
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
            --R_rgtr_data(31 downto vtoffset_bf(vtchanid_id)+vtoffset_bf(vtoffset_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(vtoffset_bf,vtchanid_id)(0)+R_trace_selected'high
                 downto F_bitfield(vtoffset_bf,vtchanid_id)(0)) <=
              std_logic_vector(R_trace_selected);
            R_rgtr_data(F_bitfield(vtoffset_bf,vtoffset_id)(1)
                 downto F_bitfield(vtoffset_bf,vtoffset_id)(0) + C_snap_to_grid_bits) <=
              std_logic_vector(S_APB(C_vertical_scale_offset'high downto C_snap_to_grid_bits));
            if R_snap_to_vertical_grid(to_integer(R_trace_selected)) = '1' then
              R_rgtr_data(F_bitfield(vtoffset_bf,vtoffset_id)(0) + C_snap_to_grid_bits-1
                   downto F_bitfield(vtoffset_bf,vtoffset_id)(0)) <= (others => '0'); -- yes snap
            else
              R_rgtr_data(F_bitfield(vtoffset_bf,vtoffset_id)(0) + C_snap_to_grid_bits-1
                   downto F_bitfield(vtoffset_bf,vtoffset_id)(0)) <=
                std_logic_vector(S_APB(C_snap_to_grid_bits-1  downto 0)); -- not snap
            end if;
            R_vertical_scale_offset(to_integer(R_trace_selected)) <= S_APB(C_vertical_scale_offset'range);
          when C_action_vertical_scale_gain_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"13"; -- trace vertical settings
            --R_rgtr_data(31 downto gain_bf(gainchanid_id)+gain_bf(gainid_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(gain_bf,gainchanid_id)(0)+R_trace_selected'high
                 downto F_bitfield(gain_bf,gainchanid_id)(0)) <=
              std_logic_vector(R_trace_selected);
            R_rgtr_data(F_bitfield(gain_bf,gainid_id)(1)
                 downto F_bitfield(gain_bf,gainid_id)(0)) <=
              std_logic_vector(S_APB(C_vertical_scale_gain'range));
            R_vertical_scale_gain(to_integer(R_trace_selected)) <= S_APB(C_vertical_scale_gain'range);
          when C_action_vertical_scale_color_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"11"; -- palette (color)
            --R_rgtr_data(31 downto palette_bf(palettecolor_id)+palette_bf(paletteid_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(palette_bf,palettecolor_id)(0)+C_color_bits-1
                 downto F_bitfield(palette_bf,palettecolor_id)(0)) <=
              std_logic_vector(C_trace_color(to_integer(R_trace_selected)));
            R_rgtr_data(F_bitfield(palette_bf,paletteid_id)(1)
                 downto F_bitfield(palette_bf,paletteid_id)(0)) <=
              std_logic_vector(to_unsigned(4,palette_bf(paletteid_id))); -- 4: vertical scale color indicates selected channel/trace
          when C_action_trigger_level_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"12"; -- trigger level
            --R_rgtr_data(31 downto trigger_bf(trigger_chanid_id)+trigger_bf(trigger_level_id)+trigger_bf(trigger_edge_id)+trigger_bf(trigger_ena_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(trigger_bf,trigger_chanid_id)(0)+R_trace_selected'high
                 downto F_bitfield(trigger_bf,trigger_chanid_id)(0)) <=
              std_logic_vector(R_trace_selected);
            R_rgtr_data(F_bitfield(trigger_bf,trigger_level_id)(1)
                 downto F_bitfield(trigger_bf,trigger_level_id)(0)) <=
              std_logic_vector(S_APB(trigger_bf(trigger_level_id)-1 downto 0));
            R_rgtr_data(F_bitfield(trigger_bf,trigger_slope_id)(0)) <=
              S_APB(S_APB'high);
            R_rgtr_data(F_bitfield(trigger_bf,trigger_freeze_id)(0)) <=
              S_APB(S_APB'high-2);
            R_trigger_level(to_integer(R_trace_selected)) <= S_APB(C_trigger_level'range);
            R_trigger_edge(to_integer(R_trace_selected)) <= S_APB(S_APB'high);
            R_trigger_freeze <= S_APB(S_APB'high-2);
          when C_action_horizontal_scale_offset_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"10"; -- horizontal scale settings
            --R_rgtr_data(31 downto hzoffset_bf(hzscale_id)+hzoffset_bf(hzoffset_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(hzoffset_bf,hzscale_id)(1)
                 downto F_bitfield(hzoffset_bf,hzscale_id)(0)) <=
              std_logic_vector(R_horizontal_scale_timebase);
            R_rgtr_data(F_bitfield(hzoffset_bf,hzoffset_id)(1)
                 downto F_bitfield(hzoffset_bf,hzoffset_id)(0)) <=
              std_logic_vector(S_APB(R_horizontal_scale_offset'range));
            R_horizontal_scale_offset <= S_APB(R_horizontal_scale_offset'range);
          when C_action_horizontal_scale_timebase_change =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"10"; -- horizontal scale settings
            --R_rgtr_data(31 downto hzoffset_bf(hzscale_id)+hzoffset_bf(hzoffset_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(hzoffset_bf,hzscale_id)(1)
                 downto F_bitfield(hzoffset_bf,hzscale_id)(0)) <=
              std_logic_vector(S_APB(R_horizontal_scale_timebase'range));
            R_rgtr_data(F_bitfield(hzoffset_bf,hzoffset_id)(1)
                 downto F_bitfield(hzoffset_bf,hzoffset_id)(0)) <=
              std_logic_vector(R_horizontal_scale_offset);
            R_horizontal_scale_timebase <= S_APB(R_horizontal_scale_timebase'range);
          when C_action_trace_select =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"11"; -- palette (color)
            --R_rgtr_data(31 downto palette_bf(palettecolor_id)+palette_bf(paletteid_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(palette_bf,paletteid_id)(1)
                 downto F_bitfield(palette_bf,paletteid_id)(0)) <=
              std_logic_vector(to_unsigned(1,palette_bf(paletteid_id))); -- 1: vertical scale color indicates selected channel/trace
            if unsigned(S_APB(R_trace_selected'range)) < C_inputs then
              R_rgtr_data(F_bitfield(palette_bf,palettecolor_id)(0)+C_color_bits-1
                   downto F_bitfield(palette_bf,palettecolor_id)(0)) <=
                std_logic_vector(C_trace_color(to_integer(S_APB(R_trace_selected'range))));
              R_trace_selected <= S_APB(R_trace_selected'range);
            else -- reject change
              R_rgtr_data(F_bitfield(palette_bf,palettecolor_id)(0)+C_color_bits-1
                   downto F_bitfield(palette_bf,palettecolor_id)(0)) <=
                std_logic_vector(C_trace_color(to_integer(R_trace_selected)));
            end if;
          when C_action_set_color =>
            R_rgtr_dv <= '1';
            R_rgtr_id <= x"11"; -- palette (color)
            --R_rgtr_data(31 downto palette_bf(palettecolor_id)+palette_bf(paletteid_id)) <= (others => '0');
            R_rgtr_data(F_bitfield(palette_bf,palettecolor_id)(0)+C_color_bits-1
                 downto F_bitfield(palette_bf,palettecolor_id)(0)) <=
              std_logic_vector(R_A(C_color_bits-1 downto 0)); -- color value
            R_rgtr_data(F_bitfield(palette_bf,paletteid_id)(1)
                 downto F_bitfield(palette_bf,paletteid_id)(0)) <=
              std_logic_vector(R_B(palette_bf(paletteid_id)-1 downto 0)); -- element to colorize
			 -- Opacity Added by Miguel Angel
            R_rgtr_data(F_bitfield(palette_bf,paletteopacityena_id)(1)
                 downto F_bitfield(palette_bf,paletteopacityena_id)(0)) <= "0";
            R_rgtr_data(F_bitfield(palette_bf,palettecolorena_id)(1)
                 downto F_bitfield(palette_bf,palettecolorena_id)(0)) <= "1";
            R_rgtr_data(F_bitfield(palette_bf,paletteopacity_id)(1)
                 downto F_bitfield(palette_bf,paletteopacity_id)(0)) <= "-";
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
  rgtr_data(31 downto R_mouse_y'length+12) <= (others => '0');
  rgtr_data(R_mouse_y'length+12-1 downto 12) <= std_logic_vector(R_mouse_y);
  rgtr_data(R_mouse_x'range) <= std_logic_vector(R_mouse_x);
  end generate;

  G_debug_trigger: if C_simple_debug_mode = 2 generate
  -- simple example to change trigger level (4-ch scope)
  rgtr_dv <= R_mouse_update;
  rgtr_id <= x"12"; -- trigger
  rgtr_data(31 downto 13) <= (others => '0');
  rgtr_data(12 downto 11) <= R_mouse_btn(1 downto 0); -- left/right btn select trigger channel
  rgtr_data(10 downto 2) <= std_logic_vector(R_mouse_z(8 downto 0)); -- rotating wheel changes trigger level
  rgtr_data(1) <= R_mouse_btn(2); -- wheel press selects trigger edge
  rgtr_data(0) <= '0'; -- '1' = trigger freeze
  end generate;

  G_debug_color: if C_simple_debug_mode = 3 generate
  -- simple example to change grid color with mouse wheel (4-ch scope)
  rgtr_dv <= R_mouse_update;
  rgtr_id <= x"11"; -- palette (color)
  rgtr_data(31 downto 10) <= (others => '0');
  rgtr_data(9 downto 7) <= std_logic_vector(R_mouse_z(2 downto 0)); -- rotating wheel changes color
  rgtr_data(6 downto 4) <= (others => '0');
  rgtr_data(3 downto 0) <= x"0"; -- grid color
  -- x"4" vertical scale text color
  -- x"7" frame color
  -- x"6" bg color of text window
  -- x"3" bg color of thin window
  end generate;
end;
