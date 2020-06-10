-- AUTHOR=EMARD
-- LICENSE=BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

package modeline_calculator is
	function F_modeline (
		constant x,y,hz : natural)
		return natural_vector;
	function F_modeline (
		constant x,y,hz,pixel_hz : natural)
		return natural_vector;
end;

package body modeline_calculator is
  constant xadjustf : integer :=    0; -- adjust -3..3 if no picture
  constant yadjustf : integer :=    0; -- or to fine-tune f

  type T_video_timing is record
    x                  : natural;
    hsync_front_porch  : natural;
    hsync_pulse_width  : natural;
    hsync_back_porch   : natural;
    y                  : natural;
    vsync_front_porch  : natural;
    vsync_pulse_width  : natural;
    vsync_back_porch   : natural;
    f_pixel            : natural;
  end record T_video_timing;
  
  type T_possible_freqs is array (natural range <>) of natural;
  constant C_possible_freqs: T_possible_freqs :=
  (
    25000000,
    27000000,
    40000000,
    50000000,
    54166666,
    60000000,
    65000000,
    75000000,
    80000000,  -- overclock 400MHz
    100000000, -- overclock 500MHz
    108333333, -- overclock 541MHz
    120000000, -- overclock 600MHz
    135000000, -- overclock 675MHz
    140000000  -- overclock 700MHz
  );

  function F_find_next_f(f: natural)
    return natural is
      variable f0: natural := 0;
    begin
      for fx in C_possible_freqs'range loop
        if C_possible_freqs(fx)>f then
          f0 := C_possible_freqs(fx);
          exit;
        end if;
      end loop;
      return f0;
    end F_find_next_f;

  -- by default, call this function with pixel_f_wanted=0
  -- if pixel_f_wanted is less than minimal required for f,
  -- then it will find first highest pixel_f
  -- from a list of possible freqs
  function F_video_timing(x,y,f,pixel_f_wanted: natural)
    return T_video_timing is
      variable video_timing : T_video_timing;
      variable xminblank   : natural := x/64; -- initial estimate
      variable yminblank   : natural := y/64; -- for minimal blank space
      variable min_pixel_f : natural := f*(x+xminblank)*(y+yminblank);
      variable pixel_f     : natural := pixel_f_wanted;
      variable yframe      : natural := y+yminblank;
      variable xframe      : natural := pixel_f/(f*yframe);
      variable xblank      : natural := xframe-x;
      variable yblank      : natural := yframe-y;
    begin
      if pixel_f < min_pixel_f then
        pixel_f := F_find_next_f(min_pixel_f);
      end if;
      video_timing.x                 := x;
      video_timing.hsync_front_porch := xblank/3;
      video_timing.hsync_pulse_width := xblank/3;
      video_timing.hsync_back_porch  := xblank-video_timing.hsync_pulse_width-video_timing.hsync_front_porch+xadjustf;
      video_timing.y                 := y;
      video_timing.vsync_front_porch := yblank/3;
      video_timing.vsync_pulse_width := yblank/3;
      video_timing.vsync_back_porch  := yblank-video_timing.vsync_pulse_width-video_timing.vsync_front_porch+yadjustf;
      video_timing.f_pixel           := pixel_f;

      return video_timing;
    end F_video_timing;
    
  function F_modeline (
    constant x,y,hz: natural)
  return natural_vector is
    variable video_timing : T_video_timing := F_video_timing(x,y,hz,0);
    variable retval : natural_vector(0 to 9-1);
  begin
    retval :=
    (
      video_timing.x,
      video_timing.x+video_timing.hsync_front_porch,
      video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width,
      video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width+video_timing.hsync_back_porch,
      video_timing.y,
      video_timing.y+video_timing.vsync_front_porch,
      video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width,
      video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width+video_timing.vsync_back_porch,
      video_timing.f_pixel
    );
    return retval;
  end;

  function F_modeline (
    constant x,y,hz,pixel_hz: natural)
  return natural_vector is
    variable video_timing : T_video_timing := F_video_timing(x,y,hz,pixel_hz);
    variable retval : natural_vector(0 to 9-1);
  begin
    retval :=
    (
      video_timing.x,
      video_timing.x+video_timing.hsync_front_porch,
      video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width,
      video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width+video_timing.hsync_back_porch,
      video_timing.y,
      video_timing.y+video_timing.vsync_front_porch,
      video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width,
      video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width+video_timing.vsync_back_porch,
      video_timing.f_pixel
    );
    return retval;
  end;

end;
