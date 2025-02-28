-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.cp850x8x8x0to127.all;
use hdl4fpga.cp850x8x8x128to255.all;
use hdl4fpga.cp850x8x16x0to127.all;
use hdl4fpga.cp850x8x16x128to255.all;
use hdl4fpga.bcdfonts.all;

package cgafonts is

	constant psf1cp850x8x8  : std_logic_vector(0 to 256*8*8-1)  := psf1cp850x8x8x0to127  & psf1cp850x8x8x128to255;
	constant psf1cp850x8x16 : std_logic_vector(0 to 256*8*16-1) := psf1cp850x8x16x0to127 & psf1cp850x8x16x128to255;
	constant psf1hex8x16    : std_logic_vector(0 to 16*8*16-1)  := psf1hex8x16 ;

	constant psf1bcd4x4     : std_logic_vector(0 to 16*4*4-1)   := hdl4fpga.bcdfonts.psf1bcd4x4;
	constant psf1bcd8x8     : std_logic_vector(0 to 16*8*8-1)   := hdl4fpga.bcdfonts.psf1bcd8x8;
	constant psf1bcd32x16   : std_logic_vector(0 to 16*32*16-1) := hdl4fpga.bcdfonts.psf1bcd32x16;

	function shuffle_code (
		constant font   : std_logic_vector;
		constant width  : natural;
		constant height : natural)
		return std_logic_vector;
end;

package body cgafonts is

	function shuffle_code (
		constant font   : std_logic_vector;
		constant width  : natural;
		constant height : natural)
		return std_logic_vector is
		variable retval : std_logic_vector(font'range) := (others => '-');
		constant codes  : natural := font'length/(width*height);
	begin
		for k in 0 to codes-1 loop
			for i in 0 to height-1 loop
				for j in 0 to width-1 loop
					retval(codes*(width*i+j)+k) := font(width*(height*k+i)+j);
				end loop;
			end loop;
		end loop;
		return retval;
	end;
end;





