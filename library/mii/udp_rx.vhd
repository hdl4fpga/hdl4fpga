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

entity udp_rx is
	port (
		mii_irdy     : in  std_logic;
		mii_data     : in  std_logic_vector;
		mii_ptr      : in  std_logic_vector;

		udp_frm      : in  std_logic;
		udpsp_irdy   : out std_logic;
		udpdp_irdy   : out std_logic;
		udplen_irdy  : out std_logic;
		udpcksm_irdy : out std_logic;
		udppl_frm    : buffer std_logic;
		udppl_irdy   : out std_logic);
end;

architecture def of udp_rx is

	signal udpsp_frm   : std_logic;
	signal udpdp_frm   : std_logic;
	signal udplen_frm  : std_logic;
	signal udpcksm_frm : std_logic;

begin
					
	udpsp_frm   <= udp_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & udp4hdr_frame, mii_data'length, udp4_sp);
	udpdp_frm   <= udp_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & udp4hdr_frame, mii_data'length, udp4_dp);
	udplen_frm  <= udp_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & udp4hdr_frame, mii_data'length, udp4_len);
	udpcksm_frm <= udp_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & udp4hdr_frame, mii_data'length, udp4_cksm);
	udppl_frm   <= udp_frm and frame_decode(mii_ptr, eth_frame & ipv4hdr_frame & udp4hdr_frame, mii_data'length, udp4_cksm, gt);

	udpsp_irdy   <= mii_irdy and udpsp_frm;
	udpdp_irdy   <= mii_irdy and udpdp_frm;
	udplen_irdy  <= mii_irdy and udplen_frm;
	udpcksm_irdy <= mii_irdy and udpcksm_frm;
	udppl_irdy   <= mii_irdy and udppl_frm;
end;

