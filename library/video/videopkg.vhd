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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

package videopkg is
	type videotiming_ids is (

		user_timingid,            -- user timing
		pclk_debug,               -- For debugging porpouses
		pclk25_00m640x400at60,    -- pclk  25 MHz
		pclk25_00m640x480at60,    -- pclk  25 MHz
		pclk40_00m800x600at60,    -- pclk  40.00MHz
		pclk40_00m1024x600at60,
		pclk65_00m1024x768at60,   -- pclk  65.00MHz
		pclk64_00m1280x720at60,   -- pclk  64.00MHz
		pclk75_00m1280x720at60,   -- pclk  75.00MHz

		pclk108_00m1600x900at60,  -- pclk 100.00MHz
		pclk140_00m1920x1080at60, -- pclk 138.50MHz
		pclk150_00m1920x1080at60, -- pclk 148.50MHz
		pclk138_50m1920x1080at60,
		pclk133_32m1920x1080at60,
		pclk130_32m1920x1080at60,
		pclk125_00m1920x1080at60,
		pclk115_71m2560x1440at60,
		pclk97_75m1600x900at60,

		pclk25_00m480x272at135,   -- pclk  25.00MHz 	Added by emard@github.com for ULX3S kit
		pclk40_00m96x64at60);     -- pclk  40.00MHz 	Added by emard@github.com for ULX3S kit


	type modeline_vector is array (videotiming_ids) of natural_vector(0 to 9-1);

	constant dbg_width  : natural := 64;
	constant dbg_height : natural := 14;
	constant modeline_tab : modeline_vector := (
		pclk_debug               => ( dbg_width,  dbg_width+10,  dbg_width+20,  dbg_width+30,
		                              dbg_height, dbg_height+1,  dbg_height+2,  dbg_height+3, 25000000),

		user_timingid            => (   0,    0,   0,     0,    0,    0,    0,    0,          0),
		pclk25_00m640x400at60    => ( 640,  672,  736,  832,  400,  401,  404,  445,   25000000),
		pclk25_00m640x480at60    => ( 640,  656,  752,  800,  480,  490,  492,  525,   25000000),
		pclk40_00m800x600at60    => ( 800,  840,  968, 1056,  600,  601,  605,  628,   40000000),
		pclk40_00m1024x600at60   => (1024, 1056, 1152, 1280,  600,  603,  613,  621,   40000000),
		pclk65_00m1024x768at60   => (1024, 1048, 1184, 1344,  768,  771,  777,  806,   65000000),
		pclk64_00m1280x720at60   => (1280, 1328, 1360, 1440,  720,  723,  728,  741,   64000000),
		pclk75_00m1280x720at60   => (1280, 1390, 1430, 1650,  720,  725,  730,  750,   75000000),

		pclk108_00m1600x900at60  => (1600, 1624, 1704, 1800,  900,  901,  904, 1000,  108000000),
		pclk140_00m1920x1080at60 => (1920, 1976, 2040, 2104, 1080, 1083, 1088, 1111,  140000000),
		pclk150_00m1920x1080at60 => (1920, 2008, 2052, 2200, 1080, 1084, 1089, 1125,  150000000),
		pclk138_50m1920x1080at60 => (1920, 1968, 2000, 2080, 1080, 1083, 1088, 1111,  133330000),
		pclk133_32m1920x1080at60 => (1920, 1928, 1960, 2000, 1080, 1097, 1105, 1111,  133330000),
		-- pclk133_32m1920x1080at60 => (1920, 1944, 1976, 2000, 1080, 1097, 1105, 1111,  133330000),
		pclk130_32m1920x1080at60 => (1920, 1944, 1976, 2000, 1080, 1083, 1084, 1086,  130330000),
		pclk125_00m1920x1080at60 => (1920, 1924, 1936, 1940, 1080, 1081, 1082, 1083,  125000000),
		pclk115_71m2560x1440at60 => (2560, 2568, 2600, 2640, 1440, 1447, 1455, 1461,  115711000), -- CVT-RBv2
		pclk97_75m1600x900at60   => (1600, 1648, 1680, 1760,  900,  903,  908,  926,   97750000),

		pclk40_00m96x64at60      => (  96, 1999, 2000, 4000,   64,   65,   66,   67,   40000000), -- pclk  40.00MHz
		pclk25_00m480x272at135   => ( 480,  504,  552,  624,  272,  273,  276,  295,   25000000)); -- pclk  25.00MHz

	function to_edges (
		constant data : natural_vector)
		return natural_vector;

end;

package body videopkg is

	function to_edges (
		constant data : natural_vector)
		return natural_vector is
		variable retval : natural_vector(data'range);
	begin
		for i in retval'range loop
			retval(i) := data(i)-1;
		end loop;
		return retval;
	end;

end;
