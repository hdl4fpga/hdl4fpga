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

package ecp3_profiles is
	function video_dcm (
		constant id : string)
		return string;

	function sdram_dcm (
		constant id : string)
		return string;

	function sdram_freq(
		constant dcm  : string)
		return real;
end;

library ieee;
use ieee.math_real.all;

package body ecp3_profiles is

	function sdram_freq(
		constant dcm  : string)
		return real is
		constant freq_in   : real    := dcm**".freq_in=1";
		constant clkop_div : natural := dcm**".clkop_div=1";
		constant clkfb_div : natural := dcm**".clkfb_div=0";
		constant clki_div  : natural := dcm**".clki_div=1";
	begin
		return (real(clkop_div*clkfb_div)*freq_in)/real(clki_div);
	end;

	function video_dcm (
		constant id : string)
		return string is

		constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
		constant dcm_db : string := compact("{"                                 &
			"'100mhz':{"                                                         &
				" '25mhz' : { clkos_div :  25, clkop_div => 25, clki_div : 1, clkok_div => " & natural'image(video_ratio) & ", clkfb_div : " & natural'image(1) & ", freq_in : 100.0e6},"  &
				" '40mhz' : { clkos_div :  16, clkop_div => 16, clki_div : 1, clkok_div => " & natural'image(video_ratio) & ", clkfb_div : " & natural'image(1) & ", freq_in : 100.0e6},"  &
				"'108mhz' : { clkos_div :  16, clkop_div => 22, clki_div : 1, clkok_div => " & natural'image(video_ratio) & ", clkfb_div : " & natural'image(1) & ", freq_in : 100.0e6},"  &
				"'150mhz' : { clkos_div :  12, clkop_div =>  2, clki_div : 4, clkok_div => " & natural'image(video_ratio) & ", clkfb_div : " & natural'image(3*video_ratio) & ", freq_in : 100.0e6}}}");
		constant dcm : string := dcm_db**(id&"={}");
	begin
		assert dcm/="{}"
			report "sdram_dcm() : id " & id & " not valid"
			severity failure;
		return dcm;
	end;

	function sdram_dcm (
		constant id : string)
		return string is
		-- SDRAM CLK=clk_ref*clkos_div/clkop_div
    	constant dcm_db : string := compact("{" &
    		"'100mhz':{"                                                                                                     &
    			"'325mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div : 13, clki_div : 4, freq_in : 100.0e6},"  & -- cl => "010", cwl => "000", wrl => "010"),
    			"'350mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div :  7, clki_div : 2, freq_in : 100.0e6},"  & -- cl => "010", cwl => "000", wrl => "010"),
    			"'375mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div : 15, clki_div : 4, freq_in : 100.0e6},"  & -- cl => "010", cwl => "000", wrl => "010"),
    			"'400mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div :  4, clki_div : 1, freq_in : 100.0e6},"  & -- cl => "010", cwl => "000", wrl => "010"),
    			"'425mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div : 17, clki_div : 4, freq_in : 100.0e6},"  & -- cl => "011", cwl => "001", wrl => "011"),
    			"'450mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div :  9, clki_div : 2, freq_in : 100.0e6},"  & -- cl => "011", cwl => "001", wrl => "011"),
    			"'475mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div : 19, clki_div : 4, freq_in : 100.0e6},"  & -- cl => "011", cwl => "001", wrl => "100"),
    			"'500mhz' : {clkok_div : 2, clkop_div : 1, clkfb_div :  5, clki_div : 1, freq_in : 100.0e6}}}"); -- cl => "011", cwl => "001", wrl => "100"));

		constant dcm : string := dcm_db**(id&"={}");
	begin
		assert dcm/="{}"
			report "sdram_dcm() : sdram speed_id " & id & " not valid"
			severity failure;
		return dcm;
	end;

end package body;