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
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

package ecp5_profiles is
	function video_dcm (
		constant video_mode : string) is
		return string;

	function sdramparams (
		constant sdram_id : sdram_speeds;
		constant clk_ref  : real)
		return sdramparams_record;

	function sdram_freq(
		constant sdram_params : sdramparams_record;
		constant clk_ref      : real)
		return real;

end;

package body ecp5_profiles is

	function sdram_freq(
		constant sdram_params : sdramparams_record;
		constant clk_ref      : real)
		return real is
	begin
		return 
			real(sdram_params.pll.clkos_div*sdram_params.pll.clkfb_div)*clk_ref/
			real(sdram_params.pll.clki_div*sdram_params.pll.clkop_div);
	end;

	-- SDRAM CLK=clk_ref*clkos_div/clkop_div
	constant ulxsdram_tab : sdramparams_vector := (
		(id => sdram133MHz, pll => (clkos_div => 16, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "010", cwl => "---", wrl => "---"),
		(id => sdram150MHz, pll => (clkos_div => 18, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram166MHz, pll => (clkos_div => 20, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram200MHz, pll => (clkos_div => 16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram225MHz, pll => (clkos_div => 27, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram233MHz, pll => (clkos_div => 28, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram250MHz, pll => (clkos_div => 20, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram262MHz, pll => (clkos_div => 21, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram275MHz, pll => (clkos_div => 22, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),

		(id => sdram325MHz, pll => (clkos_div => 13, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram350MHz, pll => (clkos_div => 14, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram375MHz, pll => (clkos_div => 15, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram400MHz, pll => (clkos_div => 16, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram425MHz, pll => (clkos_div => 17, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram450MHz, pll => (clkos_div => 18, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram475MHz, pll => (clkos_div => 19, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "100"),
		(id => sdram500MHz, pll => (clkos_div => 20, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "100"));

	-- video_clk       = (clk_ref/clki_div)*clkos_div/clkos2_div 
	-- video_shift_clk = (clk_ref/clki_div)*clkos_div/clkop_div 
	-- videoio_clk     = (clk_ref/clki_div)*clkos_div/clkos3_div
	-- clkos2_div      = clkop_div*video_ratio

	constant orangecrabsdram_tab : sdramparams_vector := (
		(id => sdram300MHz,      pll => (clkos_div => 38, clkop_div => 2, clkfb_div => 1, clki_div => 3, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram400MHz,      pll => (clkos_div => 25, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"));

	function video_dcm (
		constant video_id : string)
		return string is

		constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
		constant dcm_db : string := comact("{"                                &
			"25mhz:{"                                                         &
			    " 25mhz : { clkos_div :  25, clkop_div : 5, clki_div : 1 },"  &
			    " 40mhz : { clkos_div :  16, clkop_div : 2, clki_div : 1 },"  &
			    " 64mhz : { clkos_div : 128, clkop_div : 2, clki_div : 5 },"  &
			    " 65mhz : { clkos_div :  26, clkop_div : 2, clki_div : 1 },"  &
			    " 75mhz : { clkos_div :  30, clkop_div : 2, clki_div : 1 },"  &
			    " 98mhz : { clkos_div :  39, clkop_div : 1, clki_div : 2 },"  &
			    "150mhz : { clkos_div :  30, clkop_div : 1, clki_div : 1 },"  &
			    "116mhz : { clkos_div :  23, clkop_div : 1, clki_div : 1 }}," &
			"48mhz:{"
			    " 40mhz : { clkos_div :  25, clkop_div : 2, clki_div : 3 },"  &
			    " 75mhz : { clkos_div :  47, clkop_div : 2, clki_div : 3 },"  &
			    "116mhz : { clkos_div :  12, clkop_div : 1, clki_div : 1 },"  &
			"}");
		constant dcm : string := video**"=none";
		variable vco : real;
	begin
		if dcm="none" then
			assert false 
				report "videoparam{} : video " & video_id
				severity failure;
			return retval;
		else
			vco := 25.0e6;
			vco := vco*dcm**".clkos_div"/dcm**".clki_div";
			return "{" &
				"clkos_div:"   & dcm**".clkos_div" & "," & 
				"clkop_div:"   & dcm**".clkop_div" & "," & 
				"clki_div:"    & dcm**".clki_div"  & "," & 
				"clkfb_div:1," &
				"clkos3_div: 1}";
		end if;
	end;

	function sdramparams (
		constant sdram_id : sdram_speeds;
		constant clk_ref  : real)
		return sdramparams_record is
		variable retval : sdramparams_record;
	begin
		if clk_ref=25.0e6 then
			for i in ulxsdram_tab'range loop
				if sdram_id=ulxsdram_tab(i).id then
					return ulxsdram_tab(i);
				end if;
			end loop;
			retval := ulxsdram_tab(ulxsdram_tab'left);
		elsif clk_ref=48.0e6 then
			for i in orangecrabsdram_tab'range loop
				if sdram_id=orangecrabsdram_tab(i).id then
					return orangecrabsdram_tab(i);
				end if;
			end loop;
			retval := orangecrabsdram_tab(orangecrabsdram_tab'left);
		end if;

		assert false 
		report ">>>sdramparams<<< : sdram speed not enabled"
		severity failure;

		return retval;
	end;

end package body;
