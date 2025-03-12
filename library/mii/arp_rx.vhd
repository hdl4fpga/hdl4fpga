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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity arp_rx is
	port (
		mii_clk  : in  std_logic;
		arp_frm  : in  std_logic;
		arp_irdy : in  std_logic;
		arp_data : in  std_logic_vector;

		tpa_frm  : out std_logic);
end;

architecture def of arp_rx is
	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(arp4_frame)/arp_data'length-1));
begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if arp_frm='0' then
				cntr := to_unsigned(summation(arp4_frame)/arp_data'length-1, cntr'length);
			elsif cntr(0)='0' and arp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	tpa_frm  <= arp_frm and frame_decode(frm_ptr, reverse(arp4_frame), arp_data'length, arp_tpa);
end;

