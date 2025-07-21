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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;

package videopkg is
	constant modeline_tab : string := compact("{"                                               &
		"480x272@60:{"                                                                          &
			"10mhz:{"                                                                           &
				"clk : 9.643e6,"                                                                &
				"hz  : { active :  480, start :  488, end :  520, total :  560, pol : '+'},"    &
				"vt  : { active :  272, start :  273, end :  281, total :  287, pol : '-'}}},"  &
		"640x400@60:{"                                                                          &
			"20mhz:{"                                                                           &
				"clk : 20.0e6,"                                                                 &
				"hz  : { active :  640, start :  656, end :  720, total :  800, pol : '-'},"    &
				"vt  : { active :  400, start :  403, end :  409, total :  417, pol : '+'}}},"  &
		"640x480@60:{"                                                                          &
			"25mhz:{"                                                                           &
				"clk : 25.175e6,"                                                               &
				"hz  : { active :  640, start :  648, end :  744, total :  800, pol : '-'},"    &
				"vt  : { active :  480, start :  490, end :  492, total :  525, pol : '-'}}},"  &
		"800x600@60:{"                                                                          &
			"40mhz:{"                                                                           &
				"clk : 40.0e6,"                                                                 &
				"hz  : { active :  800, start :  840, end :  968, total : 1056, pol : '+'},"    &
				"vt  : { active :  600, start :  601, end :  605, total :  628, pol : '+'}}},"  &
		"1024x768@60:{"                                                                         &
			"65mhz:{"                                                                           &
				"clk : 65.0e6,"                                                                 &
				"hz : { active : 1024, start : 1048, end : 1184, total : 1344, pol : '-'},"     &
				"vt : { active :  768, start :  771, end :  777, total :  806, pol : '-'}}},"   &
		"1280x720@60:{"                                                                         &
			"64mhz:{"                                                                           &
				"clk : 64.0e6,"                                                                 &
				"hz  : { active : 1280, start : 1328, end : 1360, total : 1440, pol : '+'},"    &
				"vt  : { active :  720, start :  723, end :  728, total :  741, pol : '-'}},"   &
			"75mhz:{"                                                                           &
				"clk : 74.250e6,"                                                               &
				"hz  : { active : 1280, start : 1390, end : 1430, total : 1650, pol : '+'},"    &
				"vt  : { active :  720, start :  725, end :  730, total :  750, pol : '+'}}},"  &
		"1600x900@60:{"                                                                         &
			"98mhz:{"                                                                           &
				"clk : 97.75e6,"                                                                &
				"hz  : { active : 1600, start : 1648, end : 1680, total : 1760, pol : '+'},"    &
				"vt  : { active :  900, start :  903, end :  908, total :  926, pol : '-'}},"   &
			"108mhz:{"                                                                          &
				"clk : 108.0e6,"                                                                &
				"hz  : { active : 1600, start : 1624, end : 1704, total : 1800},"               &
				"vt  : { active :  900, start :  901, end :  904, total : 1000}}},"             &
		"1920x1080@60:{"                                                                        &
			"130mhz:{"                                                                          &
				"clk : 130.32e6,"                                                               &
				"hz  : { active : 1920, start : 1944, end : 1976, total : 2000},"               &
				"vt  : { active : 1080, start : 1083, end : 1084, total : 1086}},"              &
			"133mhz:{"                                                                          &
				"clk : 133.32e6,"                                                               &
				"hz  : { active : 1920, start : 1928, end : 1960, total : 2000, pol : '+'},"    &
				"vt  : { active : 1080, start : 1097, end : 1105, total : 1111, pol : '-'}},"   &
			"138mhz:{"                                                                          &
				"clk : 138.5e6,"                                                                &
				"hz  : { active : 1920, start : 1968, end : 2000, total : 2080, pol : '+'},"    &
				"vt  : { active : 1080, start : 1083, end : 1088, total : 1111, pol : '-'}},"   &
			"150mhz:{"                                                                          &
				"clk : 148.5e6,"                                                                &
				"hz  : { active : 1920, start : 2008, end : 2052, total : 2200, pol : '+'},"    &
				"vt  : { active : 1080, start : 1084, end : 1089, total : 1125, pol : '+'}}},"  &
		"2560x1140@60:{"                                                                        &
			"116mhz:{"                                                                          &
				"clk : 115.711e6,"                                                              &
				"hz  : { active : 2560, start : 2568, end : 2600, total : 2640, pol : '+'},"    &
				"vt  : { active : 1440, start : 1447, end : 1455, total : 1461, pol : '-'}}}}");

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
