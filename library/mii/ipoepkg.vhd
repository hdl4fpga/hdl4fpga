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

package ipoepkg is

	constant llc_ip  : std_logic_vector := x"0800";
	constant llc_arp : std_logic_vector := x"0806";

	constant arp_htype : natural := 0;
	constant arp_ptype : natural := 1;
	constant arp_hlen  : natural := 2;
	constant arp_plen  : natural := 3;
	constant arp_oper  : natural := 4;
	constant arp_sha   : natural := 5;
	constant arp_spa   : natural := 6;
	constant arp_tha   : natural := 7;
	constant arp_tpa   : natural := 8;

	constant arp_frame : natural_vector := (
		arp_htype => 2*8,
		arp_ptype => 2*8,
		arp_hlen  => 1*8,
		arp_plen  => 1*8,
		arp_oper  => 2*8,
		arp_sha   => 6*8,
		arp_spa   => 4*8,
		arp_tha   => 6*8,
		arp_tpa   => 4*8);

	constant arprply_pfx : std_logic_vector :=
		x"0001" & -- htype 
		x"0800" & -- ptype 
		x"06"   & -- hlen  
		x"04"   & -- plen  
		x"0002";  -- oper  
	   
	constant ip_verihl  : natural :=  0;
	constant ip_tos     : natural :=  1;
	constant ip_len     : natural :=  2;
	constant ip_ident   : natural :=  3;
	constant ip_flgsfrg : natural :=  4;
	constant ip_ttl     : natural :=  5;
	constant ip_proto   : natural :=  6;
	constant ip_chksum  : natural :=  7;
	constant ip_saddr   : natural :=  8;
	constant ip_daddr   : natural :=  9;

	constant iphdr_frame : natural_vector := (
		ip_verihl  => 1,
		ip_tos     => 1,
		ip_len     => 2,
		ip_ident   => 2,
		ip_flgsfrg => 2,
		ip_ttl     => 1,
		ip_proto   => 1,
		ip_chksum  => 2,
		ip_saddr   => 4,
		ip_daddr   => 4);
		
	constant ip4_shdr : std_logic_vector := (
		x"4500" &    -- Version, TOS
		x"0000" &    -- Total Length
		x"0000" &    -- Identification
		x"0000" &    -- Fragmentation
		x"0511" &    -- TTL, protocol
		x"0000" &    -- Header Checksum
		); 

end;
