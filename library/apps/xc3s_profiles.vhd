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

		-- video_clk       = (clk_ref/clki_div)*clkos_div/clkos2_div 
		-- video_shift_clk = (clk_ref/clki_div)*clkos_div/clkop_div 
		-- videoio_clk     = (clk_ref/clki_div)*clkos_div/clkos3_div

		constant dcm_db : string := "{"                                               &
			"'50mhz':{"                                                               &
				" '25mhz': { clkfx_divide: 2, clkfx_multiply: 4, freq_in: 50.0e6},"   &
				" '40mhz': { clkfx_divide: 4, clkfx_multiply: 5, freq_in: 50.0e6},"   &
				" '75mhz': { clkfx_divide: 3, clkfx_multiply: 2, freq_in: 50.0e6},"   &
				"'150mhz': { clkfx_divide: 3, clkfx_multiply: 1, freq_in: 50.0e6}}}";

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
		-- SDRAM CLK=clk_ref*clkos_div/clkop_div
    	constant dcm_db : string := "{" &
			"'50mhz':{"                                                                &
				"'133mhz': { clkfx_divide:  8, clkfx_multiply: 3, freq_in: 50.0e6},"   & -- cl => "010"
				"'166mhz': { clkfx_divide: 10, clkfx_multiply: 3, freq_in: 50.0e6},"   & -- cl => "110"
				"'170mhz': { clkfx_divide: 17, clkfx_multiply: 5, freq_in: 50.0e6},"   & -- cl => "110"
				"'200mhz': { clkfx_divide:  4, clkfx_multiply: 1, freq_in: 50.0e6}}}";   -- cl => "011"

		constant dcm : string := dcm_db**(sdram_id&"={}");
	begin
		assert dcm/="{}"
			report "sdram_dcm() : sdram speed_id " & sdram_id & " not valid"
			severity failure;
		return dcm;
	end;

end package body;