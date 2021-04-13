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
		mii_irdy   : in  std_logic;
		mii_data   : in  std_logic_vector;
		mii_ptr    : in  std_logic_vector;

		icmprqst_frm : in  std_logic;
		icmpcksm_irdy : out std_logic;
		icmpid_irdy  : out std_logic;
		icmpseq_irdy : out std_logic;
		icmppl_irdy  : out std_logic);
end;

architecture def of icmprqst_rx is

	signal icmpcksm_frm : std_logic;
	signal icmpid_frm   : std_logic;
	signal icmpseq_frm  : std_logic;
	signal icmppl_frm   : std_logic;

begin

	icmpcksm_frm <= icmprqst_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & icmphdr_frame & icmprqst_frame, mii_data'length, icmp_cksm);
	icmpid_frm   <= icmprqst_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & icmphdr_frame & icmprqst_frame, mii_data'length, icmp_id);
	icmpseq_frm  <= icmprqst_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & icmphdr_frame & icmprqst_frame, mii_data'length, icmp_seq);
	icmppl_frm   <= icmprqst_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & icmphdr_frame & icmprqst_frame, mii_data'length, icmp_seq, gt);

	icmpcksm_irdy <= mii_irdy and icmpcksm_frm;
	icmpid_irdy   <= mii_irdy and icmpid_frm;
	icmpseq_irdy  <= mii_irdy and icmpseq_frm;
	icmppl_irdy   <= mii_irdy and icmppl_frm;

end;

