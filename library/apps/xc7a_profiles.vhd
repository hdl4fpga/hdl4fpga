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

package xc7a_profiles is
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

package body xc7a_profiles is

	function sdram_freq(
		constant dcm  : string)
		return real is
		constant freq_in          : real := dcm**".freq_in=1";
		constant clkfx_multiply_f : real := dcm**".clkfbout_mult_f=0";
		constant clkfx_divide     : natural := dcm**".divclk_divide=1";
	begin
		return (clkfx_multiply_f*freq_in)/real(clkfx_divide);
	end;

	function video_dcm (
		constant video_id     : string;
		constant videoio_freq : real := 0.0)
		return string is

		constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
		constant dcm_db : string := "{"                                               &
			"'100mhz':{"                                                              &
				" '64mhz': {clkfbout_mult_f: 6.375, clkout0_divide_f:" & natural'image(2*video_ratio) & ", clkout1_divide: 2, freq_in: 100.0e6}}}";

		constant dcm : string  := dcm_db**(video_id&"={}");
	begin
		assert false 
			report "function video_dcm () : dcm : " & dcm
			severity note;

		assert dcm /= "{}"
			report "xc7a_profiles.video_dcm() : video_id " & video_id & " not valid"
			severity failure;
		return dcm;
	end;

	function sdram_dcm (
		constant sdram_id : string)
		return string is
    	constant dcm_db : string := "{" &
			"'100mhz':{"                                                                    &
				"'333mhz': { clkfbout_mult_f: 10.0, divclk_divide: 3, freq_in: 100.0e6},"   & -- cl => "0010", cwl => "000"
				"'350mhz': { clkfbout_mult_f:  7.0, divclk_divide: 2, freq_in: 100.0e6},"   & -- cl => "0100", cwl => "000"
				"'375mhz': { clkfbout_mult_f: 15.0, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "0100", cwl => "000"
				"'400mhz': { clkfbout_mult_f:  4.0, divclk_divide: 1, freq_in: 100.0e6},"   & -- cl => "0100", cwl => "000"
				"'425mhz': { clkfbout_mult_f: 17.0, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "0110", cwl => "001"
				"'450mhz': { clkfbout_mult_f:  9.0, divclk_divide: 2, freq_in: 100.0e6},"   & -- cl => "0110", cwl => "001"
				"'475mhz': { clkfbout_mult_f: 19.0, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "0110", cwl => "001"
				"'500mhz': { clkfbout_mult_f:  5.0, divclk_divide: 1, freq_in: 100.0e6},"   & -- cl => "0110", cwl => "001"
				"'525mhz': { clkfbout_mult_f: 21.0, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "0110", cwl => "001"
				"'550mhz': { clkfbout_mult_f: 11.0, divclk_divide: 2, freq_in: 100.0e6},"   & -- cl => "1000", cwl => "010"
				"'575mhz': { clkfbout_mult_f: 23.0, divclk_divide: 4, freq_in: 100.0e6},"   & -- cl => "1010", cwl => "010"
				"'600mhz': { clkfbout_mult_f:  6.0, divclk_divide: 1, freq_in: 100.0e6}}}";   -- cl => "1010", cwl => "010"

		constant dcm : string := dcm_db**(sdram_id&"={}");
	begin
		report real'image(real'(dcm**".freq_in"));
		report real'image(real'(dcm**".clkfbout_mult_f"));
		assert dcm/="{}"
			report "xc7a_profiles.sdram_dcm() : sdram speed_id " & sdram_id & " not valid"
			severity failure;
		return dcm;
	end;

end package body;