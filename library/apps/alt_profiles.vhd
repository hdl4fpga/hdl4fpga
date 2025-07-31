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
use hdl4fpga.videopkg.all;

package alt_profiles is

	function video_dcm (
		constant video_id : string;
		constant videoio_freq : real)
		return string;

end package;

package body alt_profiles is

	constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
	constant dcm_db : string := '{' &
		"'50mhz':{" &
			"'40mhz':{m: 16, c1: 2, n: 1, c0:" & natural'image(video_ratio*2)  & ", c2: 10}}"; -- ((m => 16, c1 => 2, n => 1, c0 => video_ratio*2, c2 => 10), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60);

	function video_dcm (
		constant video_id : string;
		constant videoio_freq : real)
		return string is
		constant dcm : string  := dcm_db**(video_id&"={}");
	begin
		assert dcm /= "{}"
			report "xc3s_profiles.video_dcm() : video_id " & video_id & " not valid"
			severity failure;
		return dcm;
	end;

end package body;
