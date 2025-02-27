-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

package app_profiles is

	type video_modes is (
		modedebug,
		mode480p16bpp,
		mode480p24bpp,
		mode600p16bpp,
		mode600p24bpp,
		mode720p16bpp,
		mode720p24bpp,
		mode768p24bpp,
		mode900p24bpp,
		mode90024bpp,
		mode1080r24bpp,
		mode1080p16bpp30,
		mode1080p24bpp30,
		mode1080p24bpp,
		mode1440p24bpp25,
		mode1440p24bpp30);

	type pixel_types is (
		rgb565,
		rgb888);

	type sdram_speeds is (
		sdram133MHz,
		sdram145MHz,
		sdram150MHz,
		sdram166MHz,
		sdram170MHz,
		sdram200MHz,
		sdram225MHz,
		sdram233MHz,
		sdram250MHz,
		sdram262MHz,
		sdram275MHz,
		sdram300MHz,
		sdram325MHz,
		sdram333MHz,
		sdram350MHz,
		sdram375MHz,
		sdram400MHz,
		sdram425MHz,
		sdram450MHz,
		sdram475MHz,
		sdram500MHz,
		sdram525MHz,
		sdram550MHz,
		sdram575MHz,
		sdram600MHz);

	type io_comms is (
		io_none,
		io_hdlc,
		io_ipoe,
		io_usb);

	type profile_params is record
		comms       : io_comms;
		sdram_speed : sdram_speeds;
		video_mode  : video_modes;
	end record;

	function setdebug (
		constant expr : boolean;
		constant mode : video_modes)
		return video_modes;

end package;

package body app_profiles is

	function setdebug (
		constant expr : boolean;
		constant mode : video_modes)
		return video_modes is
	begin
		if expr then
			return modedebug;
		end if;
		return mode;
	end;

