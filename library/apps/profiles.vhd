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

package profiles is

	type pll_record is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos2_div : natural;
		clkos3_div : natural;
	end record;

	type video_record is record
		id     : video_modes;
		pll    : pll_record;
		timing : videotiming_ids;
		pixel  : pixel_types;
		gear   : natural;
	end record;

	type videoparams_vector is array (natural range <>) of video_record;
	constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
	function videoparam (
		constant video_id : video_modes;
		constant clk_ref  : real)
		return video_record;

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_record;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
		wrl : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	function sdramparams (
		constant sdram_id : sdram_speeds;
		constant clk_ref  : real)
		return sdramparams_record;

	function sdram_freq(
		constant sdram_params : sdramparams_record;
		constant clk_ref      : real)
		return real;


end package;

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
	constant sdram_db : string := "{"
		"'133' : sdr  : {cl : '010', dcm : {'25' : {clkos_div : 16, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'150' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 18, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'166' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 20, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'200' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 16, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'225' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 27, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'233' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 28, clkop_div : 3, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'250' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 20, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'262' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 21, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'275' : sdr  : {cl : '011', dcm : {'25' : {clkos_div : 22, clkop_div : 2, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 0}}}," &
		"'325' : ddr3 : {cl : '010', cwl : '000', wrl : '010', dcm : {'25' : {clkos_div : 13, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'350' : ddr3 : {cl : '010', cwl : '000', wrl : '010', dcm : {'25' : {clkos_div : 14, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'375' : ddr3 : {cl : '010', cwl : '000', wrl : '010', dcm : {'25' : {clkos_div : 15, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'400' : ddr3 : {cl : '010', cwl : '000', wrl : '010', dcm : {'25' : {clkos_div : 16, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'425' : ddr3 : {cl : '011', cwl : '001', wrl : '011', dcm : {'25' : {clkos_div : 17, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'450' : ddr3 : {cl : '011', cwl : '001', wrl : '011', dcm : {'25' : {clkos_div : 18, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'475' : ddr3 : {cl : '011', cwl : '001', wrl : '100', dcm : {'25' : {clkos_div : 19, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}," &
		"'500' : ddr3 : {cl : '011', cwl : '001', wrl : '100', dcm : {'25' : {clkos_div : 20, clkop_div : 1, clkfb_div : 1, clki_div : 1, clkos2_div : 1, clkos3_div : 1}}}}";

	-- video_clk       = (clk_ref/clki_div)*clkos_div/clkos2_div 
	-- video_shift_clk = (clk_ref/clki_div)*clkos_div/clkop_div 
	-- videoio_clk     = (clk_ref/clki_div)*clkos_div/clkos3_div
	-- clkos2_div      = clkop_div*video_ratio
		-- (id => modedebug,        pll => (clkos_div => 25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk_debug),
	constant ulxvideo_tab : videoparams_vector := (
		modedebug,        { dcm : (clkos_div => 80, clkop_div => 1,  clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 2, pixel => rgb888, timing => pclk_debug),
		mode480p16bpp,    { dcm : (clkos_div =>  25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb565, timing => pclk25_00m640x480at60),
		mode480p24bpp,    { dcm : (clkos_div =>  25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk25_00m640x480at60),
		mode600p16bpp,    { dcm : (clkos_div =>  16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb565, timing => pclk40_00m800x600at60),
		mode600p24bpp,    { dcm : (clkos_div =>  16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		mode768p24bpp,    { dcm : (clkos_div =>  26, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		mode720p16bpp,    { dcm : (clkos_div =>  30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb565, timing => pclk75_00m1280x720at60),
		mode720p24bpp,    { dcm : (clkos_div => 128, clkop_div => 2, clkfb_div => 1, clki_div => 5, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk64_00m1280x720at60),
		mode900p24bpp,    { dcm : (clkos_div =>  39, clkop_div => 1, clkfb_div => 1, clki_div => 2, clkos2_div => video_ratio*1, clkos3_div => 12), gear => 7, pixel => rgb888, timing => pclk97_75m1600x900at60),
		mode1080p16bpp30, { dcm : (clkos_div =>  30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb565, timing => pclk150_00m1920x1080at60),
		mode1080p24bpp30, { dcm : (clkos_div =>  30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk150_00m1920x1080at60),
		mode1080p24bpp,   { dcm : (clkos_div =>  30, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk150_00m1920x1080at60),
		mode1440p24bpp30, { dcm : (clkos_div => 23, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk115_71m2560x1440at60));
		-- (id => mode1080p24bpp,   pll => (clkos_div => 83, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk138_50m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 80, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk133_32m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 26, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk130_32m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 25, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk125_00m1920x1080at60),

	constant orangecrabsdram_tab : sdramparams_vector := (
		(id => sdram300MHz,      pll => (clkos_div => 38, clkop_div => 2, clkfb_div => 1, clki_div => 3, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram400MHz,      pll => (clkos_div => 25, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"));

	constant orangecrabvideo_tab : videoparams_vector := (
		(id => modedebug,        pll => (clkos_div => 25, clkop_div => 2, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*5, clkos3_div => 10), gear => 2, pixel => rgb888, timing => pclk_debug),
		(id => mode600p24bpp,    pll => (clkos_div => 25, clkop_div => 2, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode720p24bpp,    pll => (clkos_div => 47, clkop_div => 2, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk75_00m1280x720at60),
		(id => mode1080p24bpp30, pll => (clkos_div => 47, clkop_div => 2, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk150_00m1920x1080at60),
		(id => mode1440p24bpp30, pll => (clkos_div => 25, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 14), gear => 7, pixel => rgb888, timing => pclk115_71m2560x1440at60));

	function videoparam (
		constant video_id : video_modes;
		constant clk_ref  : real)
		return video_record is
		variable retval : video_record;
	begin
		if clk_ref=25.0e6 then
			for i in ulxvideo_tab'range loop
				if video_id=ulxvideo_tab(i).id then
					return ulxvideo_tab(i);
				end if;
			end loop;
			retval := ulxvideo_tab(ulxvideo_tab'left);
		elsif clk_ref=48.0e6 then
			for i in orangecrabvideo_tab'range loop
				if video_id=orangecrabvideo_tab(i).id then
					return orangecrabvideo_tab(i);
				end if;
			end loop;
			retval := orangecrabvideo_tab(orangecrabvideo_tab'left);
		end if;

		assert false 
		report ">>>videoparam<<< : video id not available"
		severity failure;

		return retval;
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
