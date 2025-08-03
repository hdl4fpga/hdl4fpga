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

package xc5v_profiles is
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

package body xc5v_profiles is

	function sdram_freq(
		constant dcm  : string)
		return real is
		constant freq_in        : real    := dcm**".freq_in=1";
		constant clkfx_multiply : natural := dcm**".clkfbout_mult=0";
		constant clkfx_divide   : natural := dcm**".divclk_divide=1";
	begin
		return (real(clkfx_multiply)*freq_in)/real(clkfx_divide);
	end;

	function video_dcm (
		constant video_id     : string;
		constant videoio_freq : real := 0.0)
		return string is

		constant dcm_db : string := "{"                                               &
			"'100mhz':{"                                                              &
				" '25mhz': { clkfx_multiply: 1, clkfx_divide: 4, freq_in: 100.0e6},"  &
				" '40mhz': { clkfx_multiply: 2, clkfx_divide: 5, freq_in: 100.0e6}}}";

		constant dcm : string  := dcm_db**(video_id&"={}");
	begin
		assert dcm /= "{}"
			report "xc5v_profiles.video_dcm() : video_id " & video_id & " not valid"
			severity failure;
		return dcm;
	end;

	function sdram_dcm (
		constant sdram_id : string)
		return string is
    	constant dcm_db : string := "{" &
			"'100mhz':{"                                                                &
				"'200mhz': { clkfbout_mult:  4, divclk_divide: 2, freq_in: 100.0e6},"   & -- cl => "011"
				"'225mhz': { clkfbout_mult:  9, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "011"
				"'250mhz': { clkfbout_mult:  5, divclk_divide: 2, freq_in: 100.0e6},"   & -- cl => "011"
				"'275mhz': { clkfbout_mult: 11, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "011"
				"'300mhz': { clkfbout_mult:  3, divclk_divide: 1, freq_in: 100.0e6},"   & -- cl => "111"
				"'333mhz': { clkfbout_mult: 10, divclk_divide: 3, freq_in: 100.0e6},"   & -- cl => "111"
				"'350mhz': { clkfbout_mult:  7, divclk_divide: 2, freq_in: 100.0e6},"   & -- cl => "101"
				"'375mhz': { clkfbout_mult: 15, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "110"
				"'400mhz': { clkfbout_mult:  4, divclk_divide: 1, freq_in: 100.0e6}}}";   -- cl => "110"

		constant dcm : string := dcm_db**(sdram_id&"={}");
	begin
		assert dcm/="{}"
			report "xc5v_profiles.sdram_dcm() : sdram speed_id " & sdram_id & " not valid"
			severity failure;
		return dcm;
	end;

end package body;