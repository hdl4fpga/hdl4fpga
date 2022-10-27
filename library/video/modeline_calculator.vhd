-- AUTHOR=EMARD
-- LICENSE=BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

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

  function F_find_next_f(f_minimal, f_wanted: natural)
    return natural is
  begin
    if f_wanted < f_minimal then
      for fx in C_possible_freqs'range loop
        if C_possible_freqs(fx)>f_minimal then
          return C_possible_freqs(fx);
        end if;
      end loop;
      -- TODO if we are here then error
    end if;
    return f_wanted;
  end F_find_next_f;

  function F_max(x,y: integer)
    return integer is
  begin
    if x > y then
      return x;
    end if;
    return y;
  end F_max;

  -- by default, call this function with pixel_f_wanted=0
  -- if pixel_f_wanted is less than minimal required for f,
  -- then it will find first highest pixel_f from C_possible_freqs
  function F_video_timing(x,y,f,pixel_f_wanted: natural)
    return T_video_timing is
      constant xminblank   : natural := F_max(x/64,3); -- initial estimate
      constant yminblank   : natural := F_max(y/64,3); -- for minimal blank space
      constant min_pixel_f : natural := f*(x+xminblank)*(y+yminblank);
      constant pixel_f     : natural := F_find_next_f(min_pixel_f,pixel_f_wanted);
      constant yframe      : natural := y+yminblank;
      constant xframe      : natural := pixel_f/(f*yframe);
      constant xblank      : natural := xframe-x;
      constant yblank      : natural := yframe-y;

	  constant hsync_front_porch : natural := xblank/3;
	  constant hsync_pulse_width : natural := xblank/3;
	  constant hsync_back_porch  : natural := xblank-hsync_front_porch-hsync_pulse_width;

	  constant vsync_front_porch : natural := yblank/3;
	  constant vsync_pulse_width : natural := yblank/3;
	  constant vsync_back_porch  : natural := yblank-vsync_front_porch-vsync_pulse_width;

    begin
      return T_video_timing'(
		  x                 => x,
		  hsync_front_porch => hsync_front_porch,
		  hsync_pulse_width => hsync_pulse_width,
		  hsync_back_porch  => hsync_back_porch+xadjustf,
		  y                 => y,
		  vsync_front_porch => vsync_front_porch,
		  vsync_pulse_width => vsync_pulse_width,
		  vsync_back_porch  => vsync_back_porch+yadjustf,
		  f_pixel           => pixel_f);
    end F_video_timing;
    
  function F_modeline (
    constant x,y,hz: natural)
  return natural_vector is
    constant video_timing : T_video_timing := F_video_timing(x,y,hz,0);
  begin
    return natural_vector'(
      0 => video_timing.x,
      1 => video_timing.x+video_timing.hsync_front_porch,
      2 => video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width,
      3 => video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width+video_timing.hsync_back_porch,
      4 => video_timing.y,
      5 => video_timing.y+video_timing.vsync_front_porch,
      6 => video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width,
      7 => video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width+video_timing.vsync_back_porch,
      8 => video_timing.f_pixel);
  end;

  function F_modeline (
    constant x,y,hz,pixel_hz: natural)
  return natural_vector is
    constant video_timing : T_video_timing := F_video_timing(x,y,hz,pixel_hz);
  begin
    return natural_vector'(
      0 => video_timing.x,
      1 => video_timing.x+video_timing.hsync_front_porch,
      2 => video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width,
      3 => video_timing.x+video_timing.hsync_front_porch+video_timing.hsync_pulse_width+video_timing.hsync_back_porch,
      4 => video_timing.y,
      5 => video_timing.y+video_timing.vsync_front_porch,
      6 => video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width,
      7 => video_timing.y+video_timing.vsync_front_porch+video_timing.vsync_pulse_width+video_timing.vsync_back_porch,
      8 => video_timing.f_pixel);
  end;

end;
