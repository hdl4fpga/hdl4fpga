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
use hdl4fpga.app_profiles.all;

package ecp5_profiles is

	--------------------------------------
	-- Set of profiles                  --
	type app_profiles is (
	--	Interface_SdramSpeed_VideoFormat --

		hdlc_sdr133MHz_480p16bpp,  
		hdlc_sdr133MHz_480p24bpp,
		hdlc_sdr133MHz_600p16bpp,   
		hdlc_sdr133MHz_600p24bpp,   
		hdlc_sdr133MHz_768p24bpp,   
		hdlc_sdr133MHz_720p16bpp,   
		hdlc_sdr133MHz_720p24bpp,   

		hdlc_sdr150MHz_720p24bpp,   

		hdlc_sdr166MHz_480p16bpp,   
		hdlc_sdr166MHz_480p24bpp,   
		hdlc_sdr166MHz_600p16bpp,   
		hdlc_sdr166MHz_600p24bpp,   
		hdlc_sdr166MHz_720p24bpp,   
		hdlc_sdr166MHz_1080p16bpp30,
		hdlc_sdr166MHz_1080p24bpp30,

		hdlc_sdr200MHz_480p16bpp,   
		hdlc_sdr200MHz_480p24bpp,   
		hdlc_sdr200MHz_600p24bpp,   
		hdlc_sdr200MHz_600p16bpp,   
		hdlc_sdr200MHz_720p24bpp,   
		hdlc_sdr200MHz_1080p16bpp30,
		hdlc_sdr200MHz_1080p24bpp30,

		hdlc_sdr225MHz_480p16bpp,   
		hdlc_sdr225MHz_480p24bpp,   
		hdlc_sdr225MHz_600p16bpp,   
		hdlc_sdr225MHz_600p24bpp,   
		hdlc_sdr225MHz_720p24bpp,   
		hdlc_sdr225MHz_1080p16bpp30,
		hdlc_sdr225MHz_1080p24bpp30,
		hdlc_sdr225MHz_1440p24bpp25,
		hdlc_sdr225MHz_1440p24bpp30,

		hdlc_sdr250MHz_480p16bpp,   
		hdlc_sdr250MHz_600p16bpp,   
		hdlc_sdr250MHz_600p24bpp,   
		hdlc_sdr250MHz_720p24bpp,   
		hdlc_sdr250MHz_1080p16bpp30,
		hdlc_sdr250MHz_1080p24bpp30,

		ipoe_sdr166MHz_480p24bpp,   
		ipoe_sdr200MHz_1080p24bpp30,
		ipoe_sdr250MHz_1080p24bpp30,
		hdlc_sdr325MHz_480p24bpp,
		hdlc_sdr350MHz_480p24bpp,
		hdlc_sdr375MHz_480p24bpp,
		hdlc_sdr400MHz_480p24bpp,
		hdlc_sdr425MHz_480p24bpp,
		hdlc_sdr450MHz_480p24bpp,
		hdlc_sdr475MHz_480p24bpp,
		hdlc_sdr500MHz_480p24bpp,

		hdlc_sdr350MHz_600p24bpp,
		hdlc_sdr400MHz_600p24bpp,

		hdlc_sdr350MHz_1080p24bpp30,
		hdlc_sdr375MHz_1080p24bpp30,
		hdlc_sdr400MHz_1080p24bpp30,
		hdlc_sdr425MHz_1080p24bpp30,
		hdlc_sdr450MHz_1080p24bpp30,
		hdlc_sdr475MHz_1080p24bpp30,
		hdlc_sdr500MHz_1080p24bpp30,

		mii_sdr400MHz_480p24bpp,
		mii_sdr425MHz_480p24bpp,
		mii_sdr450MHz_480p24bpp,
		mii_sdr475MHz_480p24bpp,
		mii_sdr500MHz_480p24bpp);
	--------------------------------------

	type profileparams_vector is array (app_profiles) of profile_params;
	constant profile_tab : profileparams_vector := (
		hdlc_sdr133MHz_480p16bpp    => (io_hdlc, sdram133MHz, mode480p16bpp),
		hdlc_sdr133MHz_480p24bpp    => (io_hdlc, sdram133MHz, mode480p24bpp),
		hdlc_sdr133MHz_600p16bpp    => (io_hdlc, sdram133MHz, mode600p16bpp),
		hdlc_sdr133MHz_600p24bpp    => (io_hdlc, sdram133MHz, mode600p24bpp),
		hdlc_sdr133MHz_768p24bpp    => (io_hdlc, sdram133MHz, mode768p24bpp),
		hdlc_sdr133MHz_720p16bpp    => (io_hdlc, sdram133MHz, mode720p16bpp),
		hdlc_sdr133MHz_720p24bpp    => (io_hdlc, sdram133MHz, mode720p24bpp),

		hdlc_sdr150MHz_720p24bpp    => (io_hdlc, sdram150MHz, mode720p24bpp),

		hdlc_sdr166MHz_480p16bpp    => (io_hdlc, sdram166MHz, mode480p16bpp),
		hdlc_sdr166MHz_480p24bpp    => (io_hdlc, sdram166MHz, mode480p24bpp),
		hdlc_sdr166MHz_600p16bpp    => (io_hdlc, sdram166MHz, mode600p16bpp),
		hdlc_sdr166MHz_600p24bpp    => (io_hdlc, sdram166MHz, mode600p24bpp),
		hdlc_sdr166MHz_720p24bpp    => (io_hdlc, sdram166MHz, mode720p24bpp),
		hdlc_sdr166MHz_1080p16bpp30 => (io_hdlc, sdram166MHz, mode1080p16bpp30),
		hdlc_sdr166MHz_1080p24bpp30 => (io_hdlc, sdram166MHz, mode1080p24bpp30),

		hdlc_sdr200MHz_480p16bpp    => (io_hdlc, sdram200MHz, mode480p16bpp),
		hdlc_sdr200MHz_480p24bpp    => (io_hdlc, sdram200MHz, mode480p24bpp),
		hdlc_sdr200MHz_600p16bpp    => (io_hdlc, sdram200MHz, mode600p16bpp),
		hdlc_sdr200MHz_600p24bpp    => (io_hdlc, sdram200MHz, mode600p24bpp),
		hdlc_sdr200MHz_720p24bpp    => (io_hdlc, sdram200MHz, mode720p24bpp),
		hdlc_sdr200MHz_1080p16bpp30 => (io_hdlc, sdram200MHz, mode1080p16bpp30),
		hdlc_sdr200MHz_1080p24bpp30 => (io_hdlc, sdram200MHz, mode1080p24bpp30),

		hdlc_sdr225MHz_480p16bpp    => (io_hdlc, sdram225MHz, mode480p16bpp),
		hdlc_sdr225MHz_480p24bpp    => (io_hdlc, sdram225MHz, mode480p24bpp),
		hdlc_sdr225MHz_600p16bpp    => (io_hdlc, sdram225MHz, mode600p16bpp),
		hdlc_sdr225MHz_600p24bpp    => (io_hdlc, sdram225MHz, mode600p24bpp),
		hdlc_sdr225MHz_720p24bpp    => (io_hdlc, sdram225MHz, mode720p24bpp),
		hdlc_sdr225MHz_1080p16bpp30 => (io_hdlc, sdram225MHz, mode1080p16bpp30),
		hdlc_sdr225MHz_1080p24bpp30 => (io_hdlc, sdram225MHz, mode1080p24bpp30),
		hdlc_sdr225MHz_1440p24bpp25 => (io_hdlc, sdram225MHz, mode1440p24bpp25),
		hdlc_sdr225MHz_1440p24bpp30 => (io_hdlc, sdram225MHz, mode1440p24bpp30),

		hdlc_sdr250MHz_480p16bpp    => (io_hdlc, sdram250MHz, mode480p16bpp),
		hdlc_sdr250MHz_600p16bpp    => (io_hdlc, sdram250MHz, mode600p16bpp),
		hdlc_sdr250MHz_600p24bpp    => (io_hdlc, sdram250MHz, mode600p24bpp),
		hdlc_sdr250MHz_720p24bpp    => (io_hdlc, sdram250MHz, mode720p24bpp),
		hdlc_sdr250MHz_1080p16bpp30 => (io_hdlc, sdram250MHz, mode1080p16bpp30),
		hdlc_sdr250MHz_1080p24bpp30 => (io_hdlc, sdram250MHz, mode1080p24bpp30),

		ipoe_sdr166MHz_480p24bpp    => (io_ipoe, sdram166MHz, mode480p24bpp),
		ipoe_sdr200MHz_1080p24bpp30 => (io_ipoe, sdram200MHz, mode1080p24bpp30),
		ipoe_sdr250MHz_1080p24bpp30 => (io_ipoe, sdram250MHz, mode1080p24bpp30),

		hdlc_sdr325MHz_480p24bpp    => (io_hdlc, sdram325MHz, mode480p24bpp),
		hdlc_sdr350MHz_480p24bpp    => (io_hdlc, sdram350MHz, mode480p24bpp),
		hdlc_sdr375MHz_480p24bpp    => (io_hdlc, sdram375MHz, mode480p24bpp),
		hdlc_sdr400MHz_480p24bpp    => (io_hdlc, sdram400MHz, mode480p24bpp),
		hdlc_sdr425MHz_480p24bpp    => (io_hdlc, sdram425MHz, mode480p24bpp),
		hdlc_sdr450MHz_480p24bpp    => (io_hdlc, sdram450MHz, mode480p24bpp),
		hdlc_sdr475MHz_480p24bpp    => (io_hdlc, sdram475MHz, mode480p24bpp),
		hdlc_sdr500MHz_480p24bpp    => (io_hdlc, sdram500MHz, mode480p24bpp),

		hdlc_sdr350MHz_600p24bpp    => (io_hdlc, sdram350MHz, mode600p24bpp),
		hdlc_sdr400MHz_600p24bpp    => (io_hdlc, sdram400MHz, mode600p24bpp),

		hdlc_sdr350MHz_1080p24bpp30 => (io_hdlc, sdram350MHz, mode1080p24bpp30),
		hdlc_sdr375MHz_1080p24bpp30 => (io_hdlc, sdram375MHz, mode1080p24bpp30),
		hdlc_sdr400MHz_1080p24bpp30 => (io_hdlc, sdram400MHz, mode1080p24bpp30),
		hdlc_sdr425MHz_1080p24bpp30 => (io_hdlc, sdram425MHz, mode1080p24bpp30),
		hdlc_sdr450MHz_1080p24bpp30 => (io_hdlc, sdram450MHz, mode1080p24bpp30),
		hdlc_sdr475MHz_1080p24bpp30 => (io_hdlc, sdram475MHz, mode1080p24bpp30),
		hdlc_sdr500MHz_1080p24bpp30 => (io_hdlc, sdram500MHz, mode1080p24bpp30),
																	
		mii_sdr400MHz_480p24bpp     => (io_ipoe, sdram400MHz, mode480p24bpp),
		mii_sdr425MHz_480p24bpp     => (io_ipoe, sdram425MHz, mode480p24bpp),
		mii_sdr450MHz_480p24bpp     => (io_ipoe, sdram450MHz, mode480p24bpp),
		mii_sdr475MHz_480p24bpp     => (io_ipoe, sdram475MHz, mode480p24bpp),
		mii_sdr500MHz_480p24bpp     => (io_ipoe, sdram500MHz, mode480p24bpp));

	type pll_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos2_div : natural;
		clkos3_div : natural;
	end record;

	type video_params is record
		id     : video_modes;
		pll    : pll_params;
		timing : videotiming_ids;
		pixel  : pixel_types;
		gear   : natural;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
	constant video_tab : videoparams_vector := (
		(id => modedebug,        pll => (clkos_div => 30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 2, pixel => rgb888, timing => pclk_debug),
		(id => mode480p16bpp,    pll => (clkos_div => 25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb565, timing => pclk25_00m640x480at60),
		(id => mode480p24bpp,    pll => (clkos_div => 25, clkop_div => 5, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*5, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk25_00m640x480at60),
		(id => mode600p16bpp,    pll => (clkos_div => 16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb565, timing => pclk40_00m800x600at60),
		(id => mode600p24bpp,    pll => (clkos_div => 16, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 10), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode768p24bpp,    pll => (clkos_div => 26, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 16), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode720p16bpp,    pll => (clkos_div => 30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 2, pixel => rgb565, timing => pclk75_00m1280x720at60),
		(id => mode720p24bpp,    pll => (clkos_div => 30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 2, pixel => rgb888, timing => pclk75_00m1280x720at60),
		(id => mode1080p16bpp30, pll => (clkos_div => 30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb565, timing => pclk150_00m1920x1080at60),
		(id => mode1080p24bpp30, pll => (clkos_div => 30, clkop_div => 2, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 19), gear => 7, pixel => rgb888, timing => pclk150_00m1920x1080at60),
		(id => mode1440p24bpp25, pll => (clkos_div => 19, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 12), gear => 7, pixel => rgb888, timing => pclk115_00m2560x1440at60),
		(id => mode1440p24bpp30, pll => (clkos_div => 23, clkop_div => 1, clkfb_div => 1, clki_div => 1, clkos2_div => video_ratio*2, clkos3_div => 14), gear => 7, pixel => rgb888, timing => pclk115_00m2560x1440at60));

	function videoparam (
		constant id  : video_modes)
		return video_params;

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
		wrl : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
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


	function sdramparams (
		constant id  : sdram_speeds)
		return sdramparams_record;

end package;

package body ecp5_profiles is

	function videoparam (
		constant id  : video_modes)
		return video_params is
		constant tab : videoparams_vector := video_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>videoparam<<< : video id not available"
		severity failure;

		return tab(tab'left);
	end;

	function sdramparams (
		constant id  : sdram_speeds)
		return sdramparams_record is
		constant tab : sdramparams_vector := sdram_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>sdramparams<<< : sdram speed not enabled"
		severity failure;

		return tab(tab'left);
	end;

end package body;