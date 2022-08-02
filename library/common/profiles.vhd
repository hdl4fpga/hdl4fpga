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

package profiles is

	type fpga_devices is (
		ecp3,
		ecp5,
		xc3s,
		xc5v,
		xc7a);

	type drams is (
		sdram,
		ddr,
		ddr2,
		ddr3);

	type video_modes is (
		modedebug,
		mode480p,
		mode600p,
		mode720p,
		mode900p,
		mode1080p);

	type dram_speeds is (
		dram_133MHz,
		dram_145MHz,
		dram_150MHz,
		dram_166MHz,
		dram_200MHz,
		dram_225MHz,
		dram_233MHz,
		dram_250MHz,
		dram_262MHz,
		dram_275MHz,
		dram_300MHz,
		dram_333MHz,
		dram_350MHz,
		dram_375MHz,
		dram_400MHz,
		dram_425MHz,
		dram_450MHz,
		dram_475MHz,
		dram_500MHz,
		dram_525MHz,
		dram_550MHz,
		dram_575MHz,
		dram_600MHz);

	type io_iface is (
		io_hdlc,
		io_ipoe);

end package;

package body profiles is
end package body;