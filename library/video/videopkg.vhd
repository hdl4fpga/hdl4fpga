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
use hdl4fpga.std.all;

package videopkg is

	constant pclk23_75m640x480Cat60    : natural :=  0; -- pclk  23.75MHz
	constant pclk38_25m800x600Cat60    : natural :=  1; -- pclk  38.25MHz
	constant pclk63_50m1024x768Cat60   : natural :=  2; -- pclk  63.50MHz
	constant pclk90_75m1280x1024Rat60  : natural :=  3; -- pclk  90.75MHz
	constant pclk108_00m1280x1024Cat60 : natural :=  4; -- pclk 108.00MHz
	constant pclk119_00m1680x1050Rat60 : natural :=  5; -- pclk 119.00MHz
	constant pclk140_50m1920x1080Rat60 : natural :=  6; -- pclk 138.50MHz
	constant pclk148_50m1920x1080Rat60 : natural :=  7; -- pclk 148.50MHz
	constant pclk173_00m1920x1080Rat60 : natural :=  8; -- pclk 173.00MHz
	constant pclk75_00m1920x1080Rat30  : natural :=  9; -- pclk  75.00MHz 	Added by emard@github.com for ULX3S kit
	constant pclk75_00m1280x768Rat60   : natural := 10; -- pclk  75.00MHz 	Added by emard@github.com for ULX3S kit
	constant pclk38_25m96x64Rat60      : natural := 11; -- pclk  38.25MHz 	Added by emard@github.com for ULX3S kit
	constant pclk30_00m800x480Rat60    : natural := 12; -- pclk  30.00MHz 	Added by emard@github.com for ULX3S kit
	constant pclk50_00m1024x600Rat60   : natural := 13; -- pclk  50.00MHz 	Added by emard@github.com for ULX3S kit
	constant pclk40_00m800x600Rat60    : natural := 14; -- pclk  40.00MHz 	Added by emard@github.com for ULX3S kit
	constant pclk25_00m480x272Rat135   : natural := 15; -- pclk  25.00MHz 	Added by emard@github.com for ULX3S kit
	constant pclk100m1600x900Rat60     : natural := 16; -- pclk 100.00MHz
	constant pclk_debug                : natural := 17; -- For debugging porpouses


	type modeline_vector is array (natural range <>) of natural_vector(0 to 8-1);

-- modeline calculator https://arachnoid.com/modelines/
--# 1280x1024 @ 30.00 Hz (GTF) hsync: 31.26 kHz; pclk: 50.52 MHz
--Modeline "1280x1024_30.00" 50.52 1280 1320 1448 1616 1024 1025 1028 1042 -HSync +Vsync

	constant modeline_data : modeline_vector := (
		pclk38_25m96x64Rat60      => (  96, 1999, 2000, 4000,   64,   65,   66,   67), -- pclk   38.25MHz 	Added by emard@github.com for ULX3S kit
		pclk23_75m640x480Cat60    => ( 640,  664,  720,  800,  480,  483,  487,  500),
		pclk25_00m480x272Rat135   => ( 480,  504,  552,  624,  272,  273,  276,  295), -- emard
		pclk30_00m800x480Rat60    => ( 800,  816,  896,  998,  480,  481,  484,  500),
		pclk38_25m800x600Cat60    => ( 800,  832,  912, 1024,  600,  603,  607,  624),
		pclk40_00m800x600Rat60    => ( 800,  832,  912, 1024,  600,  603,  607,  650),
		pclk50_00m1024x600Rat60   => (1024, 1064, 1168, 1324,  600,  601,  604,  628),
		pclk63_50m1024x768Cat60   => (1024, 1072, 1176, 1328,  768,  771,  775,  798),
		pclk90_75m1280x1024Rat60  => (1280, 1328, 1360, 1440, 1024, 1027, 1034, 1054),
		pclk108_00m1280x1024Cat60 => (1280, 1328, 1440, 1688, 1024, 1025, 1028, 1066),
		pclk119_00m1680x1050Rat60 => (1680, 1728, 1760, 1840, 1050, 1053, 1059, 1080),
		pclk140_50m1920x1080Rat60 => (1920, 1928, 2000, 2088, 1080, 1083, 1088, 1111),
		pclk148_50m1920x1080Rat60 => (1920, 2012, 2068, 2200, 1080, 1082, 1088, 1125),
		pclk173_00m1920x1080Rat60 => (1920, 2048, 2248, 2576, 1080, 1083, 1088, 1120),
		pclk75_00m1920x1080Rat30  => (1920, 2008, 2052, 2185, 1080, 1084, 1089, 1135), -- pclk  75.00MHz 	Added by emard@github.com for ULX3S kit
		pclk75_00m1280x768Rat60   => (1280, 1344, 1536, 1728,  768,  771,  776,  796), -- pclk  75.00MHz 	Added by emard@github.com for ULX3S kit;
		pclk100m1600x900Rat60     => (1600, 1608, 1637, 1672,  900,  901,  904,  1000),
		pclk_debug                => (10,   16,  19,      21,   22,   26,   27,   30)  -- pclk
	);

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
