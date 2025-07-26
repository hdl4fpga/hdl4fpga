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
library hdl4fpga;
use hdl4fpga.hdo.all;

package videopkg is
	constant timings_db : string := compact("{"                                                                 &
		"'80x272':{"                                                                                    &
			"'@60':{"                                                                                   &
				"'10mhz':{"                                                                             &
					"clk : 9.643e6,"                                                                    &
					"hz  : { active :  480, sync_s :  488, sync_e :  520, total :  560, pol : '+'},"    &
					"vt  : { active :  272, sync_s :  273, sync_e :  281, total :  287, pol : '-'}}}}," &
		"'640x400':{"                                                                                   &
			"'@60':{"                                                                                   &
				"'20mhz':{"                                                                             &
					"clk : 20.0e6,"                                                                     &
					"hz  : { active :  640, sync_s :  656, sync_e :  720, total :  800, pol : '-'},"    &
					"vt  : { active :  400, sync_s :  403, sync_e :  409, total :  417, pol : '+'}}}}," &
		"'640x480':{"                                                                                   &
			"'@60':{"                                                                                   &
				"'25mhz':{"                                                                             &
					"clk : 25.175e6,"                                                                   &
					"hz  : { active :  640, sync_s :  648, sync_e :  744, total :  800, pol : '-'},"    &
					"vt  : { active :  480, sync_s :  490, sync_e :  492, total :  525, pol : '-'}}}}," &
		"'800x600':{"                                                                                   &
			"'@60':{"                                                                                   &
				"'40mhz':{"                                                                             &
					"clk : 40.0e6,"                                                                     &
					"hz  : { active :  800, sync_s :  840, sync_e :  968, total : 1056, pol : '+'},"    &
					"vt  : { active :  600, sync_s :  601, sync_e :  605, total :  628, pol : '+'}}}}," &
		"'1024x768':{"                                                                                  &
			"'@60':{"                                                                                   &
    			"'65mhz':{"                                                                             &
    				"clk : 65.0e6,"                                                                     &
    				"hz : { active : 1024, sync_st: 1048, sync_en: 1184, total : 1344, pol : '-'},"     &
    				"vt : { active :  768, sync_st:  771, sync_en:  777, total :  806, pol : '-'}}}},"  &
		"'1280x720':{"                                                                                  &
			"'@60':{"                                                                                   &
    			"'64mhz':{"                                                                             &
    				"clk : 64.0e6,"                                                                     &
    				"hz  : { active : 1280, sync_s : 1328, sync_e : 1360, total : 1440, pol : '+'},"    &
    				"vt  : { active :  720, sync_s :  723, sync_e :  728, total :  741, pol : '-'}}},"  &
    			"'75mhz':{"                                                                             &
    				"clk : 74.250e6,"                                                                   &
    				"hz  : { active : 1280, sync_s : 1390, sync_e : 1430, total : 1650, pol : '+'},"    &
    				"vt  : { active :  720, sync_s :  725, sync_e :  730, total :  750, pol : '+'}}},"  &
		"'1600x900':{"                                                                                  &
			"'@60':{"                                                                                   &
    			"'98mhz':{"                                                                             &
    				"clk : 97.75e6,"                                                                    &
    				"hz  : { active : 1600, sync_s : 1648, sync_e : 1680, total : 1760, pol : '+'},"    &
    				"vt  : { active :  900, sync_s :  903, sync_e :  908, total :  926, pol : '-'}},"   &
    			"'108mhz':{"                                                                            &
    				"clk : 108.0e6,"                                                                    &
    				"hz  : { active : 1600, sync_s : 1624, sync_e : 1704, total : 1800, pol : '+'},"    &
    				"vt  : { active :  900, sync_s :  901, sync_e :  904, total : 1000, pol : '+'}}}}," &
		"'1920x1080':{"                                                                                 &
			"'@60':{"                                                                                   &
    			"'130mhz':{"                                                                           &
    				"clk : 130.32e6,"                                                                   &
    				"hz  : { active : 1920, sync_s : 1944, sync_e : 1976, total : 2000},"               &
    				"vt  : { active : 1080, sync_s : 1083, sync_e : 1084, total : 1086}},"              &
    			"'133mhz':{"                                                                            &
    				"clk : 133.32e6,"                                                                   &
    				"hz  : { active : 1920, sync_s : 1928, sync_e : 1960, total : 2000, pol : '+'},"    &
    				"vt  : { active : 1080, sync_s : 1097, sync_e : 1105, total : 1111, pol : '-'}},"   &
    			"'138mhz':{"                                                                            &
    				"clk : 138.5e6,"                                                                    &
    				"hz  : { active : 1920, sync_s : 1968, sync_e : 2000, total : 2080, pol : '+'},"    &
    				"vt  : { active : 1080, sync_s : 1083, sync_e : 1088, total : 1111, pol : '-'}},"   &
    			"'150mhz':{"                                                                            &
    				"clk : 148.5e6,"                                                                    &
    				"hz  : { active : 1920, sync_s : 2008, sync_e : 2052, total : 2200, pol : '+'},"    &
    				"vt  : { active : 1080, sync_s : 1084, sync_e : 1089, total : 1125, pol : '+'}}}}," &
		"'2560x1140':{"                                                                                 &
			"'@30':{"                                                                                   &
    			"'116mhz':{"                                                                            &
    				"clk : 115.711e6,"                                                                  &
    				"hz  : { active : 2560, sync_s : 2568, sync_e : 2600, total : 2640, pol : '+'},"    &
    				"vt  : { active : 1440, sync_s : 1447, sync_e : 1455, total : 1461, pol : '-'}}}}}");
end;
