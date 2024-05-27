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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity icmprply_tx is
	port (
		mii_clk   : in  std_logic;

		pl_frm    : in  std_logic;
		pl_irdy   : in  std_logic;
		pl_trdy   : out std_logic;
		pl_end    : in  std_logic;
		pl_data   : in  std_logic_vector;
		metatx_end  : in std_logic;

		icmpcksm_frm : out std_logic;

		icmp_frm  : out std_logic;
		icmp_irdy : out std_logic := '0';
		icmp_trdy : in  std_logic := '1';
		icmp_end  : out std_logic;
		icmp_data : out std_logic_vector);
end;

architecture def of icmprply_tx is

	signal frm_ptr : std_logic_vector(0 to unsigned_num_bits(summation(icmphdr_frame)/icmp_data'length-1));

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := to_unsigned(summation(icmphdr_frame)/icmp_data'length-1, cntr'length);
			elsif cntr(0)='0' and metatx_end='1' and(pl_irdy and icmp_trdy)='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	icmpcksm_frm <= pl_frm and frame_decode(frm_ptr, reverse(icmphdr_frame), icmp_data'length, icmp_cksm);
	pl_trdy      <= icmp_trdy;

	icmp_frm  <= pl_frm;
	icmp_data <= pl_data;
	icmp_irdy <= pl_irdy;
	icmp_end  <= pl_end;

end;

