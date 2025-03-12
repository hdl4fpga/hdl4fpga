--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

package ecp5_profiles is


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
	constant ulxsdram_tab : sdramparams_vector := (
		(id => sdram133MHz,      pll => (clkos_div => 16, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "010", cwl => "---", wrl => "---"),
		(id => sdram150MHz,      pll => (clkos_div => 18, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram166MHz,      pll => (clkos_div => 20, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram200MHz,      pll => (clkos_div => 16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram225MHz,      pll => (clkos_div => 27, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram233MHz,      pll => (clkos_div => 28, clkop_div => 3, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram250MHz,      pll => (clkos_div => 20, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram262MHz,      pll => (clkos_div => 21, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),
		(id => sdram275MHz,      pll => (clkos_div => 22, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 0), cl => "011", cwl => "---", wrl => "---"),

		(id => sdram325MHz,      pll => (clkos_div => 13, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram350MHz,      pll => (clkos_div => 14, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram375MHz,      pll => (clkos_div => 15, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram400MHz,      pll => (clkos_div => 16, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram425MHz,      pll => (clkos_div => 17, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram450MHz,      pll => (clkos_div => 18, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram475MHz,      pll => (clkos_div => 19, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "011", cwl => "001", wrl => "100"),
		(id => sdram500MHz,      pll => (clkos_div => 20, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => 1,             clkos3_div => 1), cl => "011", cwl => "001", wrl => "100"));

	-- video_clk       = (clk_ref/clki_div)*clkos_div/clkos2_div 
	-- video_shift_clk = (clk_ref/clki_div)*clkos_div/clkop_div 
	-- videoio_clk     = (clk_ref/clki_div)*clkos_div/clkos3_div
	-- clkos2_div      = clkop_div*video_ratio
	constant ulxvideo_tab : videoparams_vector := (
		(id => modedebug,        pll => (clkos_div => 80, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 2, pixel => rgb888, timing => pclk_debug),
		-- (id => modedebug,        pll => (clkos_div => 25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk_debug),
		(id => mode480p16bpp,    pll => (clkos_div =>  25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb565, timing => pclk25_00m640x480at60),
		(id => mode480p24bpp,    pll => (clkos_div =>  25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk25_00m640x480at60),
		(id => mode600p16bpp,    pll => (clkos_div =>  16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb565, timing => pclk40_00m800x600at60),
		(id => mode600p24bpp,    pll => (clkos_div =>  16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode768p24bpp,    pll => (clkos_div =>  26, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode720p16bpp,    pll => (clkos_div =>  30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb565, timing => pclk75_00m1280x720at60),
		(id => mode720p24bpp,    pll => (clkos_div => 128, clkop_div => 2, clkfb_div => 1, clki_div => 5, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk64_00m1280x720at60),
		(id => mode900p24bpp,    pll => (clkos_div =>  39, clkop_div => 1, clkfb_div => 1, clki_div => 2, clkos2_div => video_ratio*1, clkos3_div => 12), gear => 7, pixel => rgb888, timing => pclk97_75m1600x900at60),
		(id => mode1080p16bpp30, pll => (clkos_div =>  30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb565, timing => pclk150_00m1920x1080at60),
		(id => mode1080p24bpp30, pll => (clkos_div =>  30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk150_00m1920x1080at60),
		(id => mode1080p24bpp,   pll => (clkos_div =>  30, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk150_00m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 83, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk138_50m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 80, clkop_div => 1, clkfb_div => 1, clki_div => 3, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk133_32m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 26, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk130_32m1920x1080at60),
		-- (id => mode1080p24bpp,   pll => (clkos_div => 25, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk125_00m1920x1080at60),
		(id => mode1440p24bpp30, pll => (clkos_div => 23, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*1, clkos3_div => 17), gear => 7, pixel => rgb888, timing => pclk115_71m2560x1440at60));

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