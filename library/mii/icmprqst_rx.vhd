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
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity icmprqst_rx is
	port (
		mii_clk     : in  std_logic;
		icmp_frm    : in  std_logic;
		icmp_data   : in  std_logic_vector;
		icmp_irdy   : in  std_logic;

		icmpcksm_irdy : out std_logic;
		icmpid_irdy  : out std_logic;
		icmpseq_irdy : out std_logic;
		icmppl_irdy  : out std_logic);
end;

architecture def of icmprqst_rx is

	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(eth_frame)/icmp_data'length-1));
	signal icmpcksm_frm : std_logic;
	signal icmpid_frm   : std_logic;
	signal icmpseq_frm  : std_logic;
	signal icmppl_frm   : std_logic;

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if icmp_frm='0' then
				cntr := to_unsigned(summation(eth_frame)-1, cntr'length);
			elsif cntr(0)='0' and icmp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	icmpcksm_frm <= icmp_frm and frame_decode(frm_ptr, reverse(icmphdr_frame & icmprqst_frame), icmp_data'length, icmp_cksm);
	icmpid_frm   <= icmp_frm and frame_decode(frm_ptr, reverse(icmphdr_frame & icmprqst_frame), icmp_data'length, icmp_id);
	icmpseq_frm  <= icmp_frm and frame_decode(frm_ptr, reverse(icmphdr_frame & icmprqst_frame), icmp_data'length, icmp_seq);
	icmppl_frm   <= icmp_frm and frm_ptr(0);

	icmpcksm_irdy <= icmp_irdy and icmpcksm_frm;
	icmpid_irdy   <= icmp_irdy and icmpid_frm;
	icmpseq_irdy  <= icmp_irdy and icmpseq_frm;
	icmppl_irdy   <= icmp_irdy and icmppl_frm;

end;

