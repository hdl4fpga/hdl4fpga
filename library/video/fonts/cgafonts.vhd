--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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

