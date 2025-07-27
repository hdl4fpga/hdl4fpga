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

package xc3s_profiles is
	function video_dcm (
		constant video_id     : string;
		constant videoio_freq : real := 0.0)
		return string;

	function sdram_dcm (
		constant sdram_id : string)
		return string;

	function sdram_freq(
		constant dcm  : string)
		return real;
end;

library hdl4fpga;
use hdl4fpga.hdo.all;

package body xc3s_profiles is

	function sdram_freq(
		constant dcm  : string)
		return real is
		constant freq_in        : real    := dcm**".freq_in=1";
		constant clkfx_multiply : natural := dcm**".clkfx_multiply=0";
		constant clkfx_divide   : natural := dcm**".clkfx_divide=1";
	begin
		return (real(clkfx_multiply)*freq_in)/real(clkfx_divide);
	end;

	function video_dcm (
		constant video_id     : string;
		constant videoio_freq : real := 0.0)
		return string is

		constant dcm_db : string := "{"                                               &
			"'20mhz':{"                                                               &
				" '25mhz': { clkfx_multiply:  5, clkfx_divide: 4, freq_in: 20.0e6},"  &
				" '40mhz': { clkfx_multiply:  2, clkfx_divide: 1, freq_in: 20.0e6},"  &
				" '75mhz': { clkfx_multiply: 15, clkfx_divide: 4, freq_in: 20.0e6},"  &
				"'108mhz': { clkfx_multiply: 27, clkfx_divide: 5, freq_in: 20.0e6},"  &
				"'150mhz': { clkfx_multiply: 15, clkfx_divide: 2, freq_in: 20.0e6}}," &
			"'50mhz':{"                                                               &
				" '25mhz': { clkfx_multiply: 4, clkfx_divide: 2, freq_in: 50.0e6},"   &
				" '40mhz': { clkfx_multiply: 5, clkfx_divide: 4, freq_in: 50.0e6},"   &
				" '75mhz': { clkfx_multiply: 2, clkfx_divide: 3, freq_in: 50.0e6},"   &
				"'150mhz': { clkfx_multiply: 1, clkfx_divide: 3, freq_in: 50.0e6}}}";

		constant dcm : string  := dcm_db**(video_id&"={}");
	begin
		assert dcm /= "{}"
			report "video_dcm() : video_id " & video_id & " not valid"
			severity failure;
		return "{}";
	end;

	function sdram_dcm (
		constant sdram_id : string)
		return string is
    	constant dcm_db : string := "{" &
			"'20mhz':{"                                                                &
				"'133mhz': { clkfx_multiply: 20, clkfx_divide: 3, freq_in: 20.0e6},"   & -- cl => "010"
				"'145mhz': { clkfx_multiply: 29, clkfx_divide: 4, freq_in: 20.0e6},"   & -- cl => "110"
				"'166mhz': { clkfx_multiply: 15, clkfx_divide: 2, freq_in: 20.0e6},"   & -- cl => "110"
				"'170mhz': { clkfx_multiply: 25, clkfx_divide: 3, freq_in: 20.0e6},"   & -- cl => "110"
				"'200mhz': { clkfx_multiply: 10, clkfx_divide: 1, freq_in: 20.0e6}}}";   -- cl => "011"
			"'50mhz':{"                                                                &
				"'133mhz': { clkfx_multiply: 3, clkfx_divide:  8, freq_in: 50.0e6},"   & -- cl => "010"
				"'166mhz': { clkfx_multiply: 3, clkfx_divide: 10, freq_in: 50.0e6},"   & -- cl => "110"
				"'170mhz': { clkfx_multiply: 5, clkfx_divide: 17, freq_in: 50.0e6},"   & -- cl => "110"
				"'200mhz': { clkfx_multiply: 1, clkfx_divide:  4, freq_in: 50.0e6}}}";   -- cl => "011"

		constant dcm : string := dcm_db**(sdram_id&"={}");
	begin
		assert dcm/="{}"
			report "sdram_dcm() : sdram speed_id " & sdram_id & " not valid"
			severity failure;
		return dcm;
	end;

end package body;