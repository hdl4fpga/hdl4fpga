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
use hdl4fpga.modeline_calculator.all;

package videopkg is
	type videotiming_ids is (

		pclk_fallback,            -- Fallback timing
		pclk_debug,               -- For debugging porpouses
		pclk25_00m640x400at60,    -- pclk 148.50MHz
		pclk25_00m640x480at60,    -- pclk  23.75MHz
		pclk100_00m1600x900at60,  -- pclk 100.00MHz
		pclk140_00m1920x1080at60, -- pclk 138.50MHz

		pclk25_00m480x272at135,   -- pclk  25.00MHz 	Added by emard@github.com for ULX3S kit
		pclk75_00m1280x768at60,   -- pclk  75.00MHz 	Added by emard@github.com for ULX3S kit
		pclk75_00m1920x1080at30,  -- pclk  75.00MHz 	Added by emard@github.com for ULX3S kit
		pclk40_00m96x64at60,      -- pclk  40.00MHz 	Added by emard@github.com for ULX3S kit
		pclk25_00m800x480at60,    -- pclk  25.00MHz 	Added by emard@github.com for ULX3S kit
		pclk50_00m1024x600at60,   -- pclk  50.00MHz 	Added by emard@github.com for ULX3S kit
		pclk40_00m800x600at60);   -- pclk  40.00MHz 	Added by emard@github.com for ULX3S kit


	type modeline_vector is array (videotiming_ids) of natural_vector(0 to 9-1);

-- modeline calculator https://arachnoid.com/modelines/
--# 1280x1024 @ 30.00 Hz (GTF) hsync: 31.26 kHz; pclk: 50.52 MHz
--Modeline "1280x1024_30.00" 50.52 1280 1320 1448 1616 1024 1025 1028 1042 -HSync +Vsync

	constant modeline_tab : modeline_vector := (
		pclk_fallback            => (   0,    0,   0,     0,    0,    0,    0,    0,          0),
		pclk_debug               => (  10,   16,   19,   21,   22,   26,   27,   30,   25000000),
		pclk25_00m640x400at60    => ( 640,  672,  736,  832,  400,  401,  404,  445,   25000000),
		pclk25_00m640x480at60    => F_modeline(640,480,60),
		pclk100_00m1600x900at60  => (1600, 1608, 1637, 1672,  900,  901,  904, 1000,  100000000),
		pclk140_00m1920x1080at60 => (1920, 1928, 2000, 2088, 1080, 1083, 1088, 1111,  140000000),

		pclk40_00m96x64at60      => (  96, 1999, 2000, 4000,   64,   65,   66,   67,   40000000), -- pclk  40.00MHz
		pclk25_00m480x272at135   => ( 480,  504,  552,  624,  272,  273,  276,  295,   25000000), -- pclk  25.00MHz
		pclk25_00m800x480at60    => F_modeline(800,480,60),                                       -- pclk  25.00MHz
		pclk40_00m800x600at60    => F_modeline(800,600,60),                                       -- pclk  40.00MHz
		pclk50_00m1024x600at60   => F_modeline(1024,600,60),                                      -- pclk  50.00MHz
		pclk75_00m1280x768at60   => F_modeline(1280,768,60),                                      -- pclk  75.00MHz
		pclk75_00m1920x1080at30  => F_modeline(1920,1080,30)                                      -- pclk  75.00MHz
	);

	function to_edges (
		constant data : natural_vector)
		return natural_vector;

	function auto_modeline (
		constant width  : natural;
		constant height : natural;
		constant fps    : real;
		constant pclk   : real)
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

	function auto_modeline (
		constant width  : natural;
		constant height : natural;
		constant fps    : real;
		constant pclk   : real)
		return natural_vector is
	begin
		return F_modeline(x => width, y => height, hz => natural(fps), pixel_hz => natural(pclk));
	end;
end;
