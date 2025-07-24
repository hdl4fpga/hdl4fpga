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
use hdl4fpga.hdo.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ecp5_profiles.all;


architecture hdo_tb of testbench is

	constant settings : string := "{"              &
		"io_link: io_usb,"                         &
		"video:{"                                  &
			"dcm:"     & string'(hdl4fpga.ecp5_profiles.video_dcm(".'25mhz'.'40mhz'")) & ',' &
			"gear: 2,"                             &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'") & ',' &
			"pixel:{"                              &
				"R:8,"                             &
				"G:8,"                             &
				"B:8},"                            &
		"sdram:{"                                  &
			"dcm: '133mhz',"                       &
			"cl:  '010'}}}";

begin



	process
	begin
		report compact(settings);
		wait;
	end process;

end;
