library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.cgafonts3.all;
use hdl4fpga.cgafonts4.all;

package cgafonts2 is

	constant psf1cp850x8x16 : std_logic_vector(0 to 256*8*16-1) := 
	
	   psf1cp850x8x16_00_to_F7 
	   
	   & 
	   
	   psf1cp850x8x16_80_to_FF;

end;
