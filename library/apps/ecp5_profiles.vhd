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

package ecp5_profiles is
	function video_dcm (
		constant video_id : string)
		return string;

	function sdram_dcm (
		constant sdram_id : string)
		return string;

	function sdram_freq(
		constant dcm  : string;
		constant freq : real)
		return real;
end;

package body ecp5_profiles is

	function sdram_freq(
		constant dcm  : string;
		constant freq : real)
		return real is
		constant clkos_div : natural := dcm**".clkos_div=0";
		constant clkfb_div : natural := dcm**".clkfb_div=0";
		constant clki_div  : natural := dcm**".clki_div=1";
		constant clkop_div : natural := dcm**".clkop_div=1";
	begin
		return real(clkos_div*clkfb_div)*freq/real(clki_div*clkop_div);
	end;

	function video_dcm (
		constant video_id : string)
		return string is

		-- video_clk       = (clk_ref/clki_div)*clkos_div/clkos2_div 
		-- video_shift_clk = (clk_ref/clki_div)*clkos_div/clkop_div 
		-- videoio_clk     = (clk_ref/clki_div)*clkos_div/clkos3_div

		constant dcm_db : string := compact("{"                                 &
			"'25mhz':{"                                                         &
				" '25mhz' : { clkos_div :  25, clkop_div : 5, clki_div : 1 },"  &
				" '40mhz' : { clkos_div :  16, clkop_div : 2, clki_div : 1 },"  &
				" '64mhz' : { clkos_div : 128, clkop_div : 2, clki_div : 5 },"  &
				" '65mhz' : { clkos_div :  26, clkop_div : 2, clki_div : 1 },"  &
				" '75mhz' : { clkos_div :  30, clkop_div : 2, clki_div : 1 },"  &
				" '98mhz' : { clkos_div :  39, clkop_div : 1, clki_div : 2 },"  &
				"'150mhz' : { clkos_div :  30, clkop_div : 1, clki_div : 1 },"  &
				"'116mhz' : { clkos_div :  23, clkop_div : 1, clki_div : 1 }}," &
			"'48mhz':{"                                                         &
				" '40mhz' : { clkos_div :  25, clkop_div : 2, clki_div : 3 },"  &
				" '75mhz' : { clkos_div :  47, clkop_div : 2, clki_div : 3 },"  &
				"'116mhz' : { clkos_div :  12, clkop_div : 1, clki_div : 1 }}}");

		constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
		constant dcm         : string  := dcm_db**(video_id&"={}");
		constant clkos2_div  : natural := video_ratio*dcm**".clkop_div=1";
		variable vco         : real;

	begin
		if dcm /= "{}" then
			vco := 25.0e6;
			vco := vco*dcm**".clkos_div"/dcm**".clki_div";
			return "{" &
				"clkos_div:"  & string'(dcm**".clkos_div") & "," & 
				"clkop_div:"  & string'(dcm**".clkop_div") & "," & 
				"clkos2_div:" & natural'image(clkos2_div) & "," & 
				"clkos3_div:" & "1," &
				"clki_div:"   & string'(dcm**".clki_div") & "," & 
				"clkfb_div:1}";
		end if;
		assert false 
			report "video_dcm() : video_id " & video_id & " not valid"
			severity failure;
		return "{}";
	end;

	function sdram_dcm (
		constant sdram_id : string)
		return string is
		-- SDRAM CLK=clk_ref*clkos_div/clkop_div
    	constant dcm_db : string := compact("{" &
    		"'25mhz':{"                                                                                                     &
    			"'133MHz' : {clkos_div : 16, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'150MHz' : {clkos_div : 18, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'166MHz' : {clkos_div : 20, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'200MHz' : {clkos_div : 16, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'225MHz' : {clkos_div : 27, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'233MHz' : {clkos_div : 28, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'250MHz' : {clkos_div : 20, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'262MHz' : {clkos_div : 21, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'275MHz' : {clkos_div : 22, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'325MHz' : {clkos_div : 13, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'350MHz' : {clkos_div : 14, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'375MHz' : {clkos_div : 15, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'400MHz' : {clkos_div : 16, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'425MHz' : {clkos_div : 17, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'450MHz' : {clkos_div : 18, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'475MHz' : {clkos_div : 19, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1},"  &
    			"'500MHz' : {clkos_div : 20, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}," &
    		"'48mhz':{"                                                                                                     &
    			"'300mhz' : {clkos_div : 38, clkop_div : 2, clkfb_div : 1, clki_div : 3, clkos2_div : 1, clkos3_div : 1},"  &
    			"'400mhz' : {clkos_div : 25, clkop_div : 1, clkfb_div : 1, clki_div : 3, clkos2_div : 1, clkos3_div : 1}}}");

		constant dcm : string := dcm_db**('.'&sdram_id&"={}");
	begin
		if dcm/="{}" then
			return dcm;
		end if;
		assert false 
			report "sdram_dcm() : sdram speed_id " & sdram_id & " not valid"
			severity failure;
		return "{}";
	end;

end package body;