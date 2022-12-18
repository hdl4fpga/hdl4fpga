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

package ipoepkg is

	constant arp_htype : natural := eth_frame'right+1;
	constant arp_ptype : natural := eth_frame'right+2;
	constant arp_hlen  : natural := eth_frame'right+3;
	constant arp_plen  : natural := eth_frame'right+4;
	constant arp_oper  : natural := eth_frame'right+5;
	constant arp_sha   : natural := eth_frame'right+6;
	constant arp_spa   : natural := eth_frame'right+7;
	constant arp_tha   : natural := eth_frame'right+8;
	constant arp_tpa   : natural := eth_frame'right+9;

	constant arp4_frame : natural_vector(arp_htype to arp_tpa) := (
		arp_htype => 2*octect_size,
		arp_ptype => 2*octect_size,
		arp_hlen  => 1*octect_size,
		arp_plen  => 1*octect_size,
		arp_oper  => 2*octect_size,
		arp_sha   => 6*octect_size,
		arp_spa   => 4*octect_size,
		arp_tha   => 6*octect_size,
		arp_tpa   => 4*octect_size);

	constant ipv4_verihl  : natural :=  eth_frame'right+1;
	constant ipv4_tos     : natural :=  eth_frame'right+2;
	constant ipv4_len     : natural :=  eth_frame'right+3;
	constant ipv4_ident   : natural :=  eth_frame'right+4;
	constant ipv4_flgsfrg : natural :=  eth_frame'right+5;
	constant ipv4_ttl     : natural :=  eth_frame'right+6;
	constant ipv4_proto   : natural :=  eth_frame'right+7;
	constant ipv4_chksum  : natural :=  eth_frame'right+8;
	constant ipv4_sa      : natural :=  eth_frame'right+9;
	constant ipv4_da      : natural :=  eth_frame'right+10;

	constant ipv4hdr_frame : natural_vector(ipv4_verihl to ipv4_da) := ( -- Quartus Prime 22.1 bug cannot deal with unconstrains array
		ipv4_verihl  => 1*octect_size,
		ipv4_tos     => 1*octect_size,
		ipv4_len     => 2*octect_size,
		ipv4_ident   => 2*octect_size,
		ipv4_flgsfrg => 2*octect_size,
		ipv4_ttl     => 1*octect_size,
		ipv4_proto   => 1*octect_size,
		ipv4_chksum  => 2*octect_size,
		ipv4_sa      => 4*octect_size,
		ipv4_da      => 4*octect_size);
		
	constant ipv4proto_icmp : std_logic_vector(0 to ipv4hdr_frame(ipv4_proto)-1) := x"01";
	constant ipv4proto_udp  : std_logic_vector(0 to ipv4hdr_frame(ipv4_proto)-1) := x"11";

	constant icmp_type : natural :=  ipv4hdr_frame'right+1;
	constant icmp_code : natural :=  ipv4hdr_frame'right+2;
	constant icmp_cksm : natural :=  ipv4hdr_frame'right+3;
	constant icmp_id   : natural :=  ipv4hdr_frame'right+4;
	constant icmp_seq  : natural :=  ipv4hdr_frame'right+5;

	constant icmphdr_frame : natural_vector(icmp_type to icmp_cksm) :=  ( -- Quartus Prime 22.1 bug cannot deal with unconstrains array
		icmp_type => 1*octect_size,
		icmp_code => 1*octect_size,
		icmp_cksm => 2*octect_size);

	constant icmpcode_rply : std_logic_vector(0 to icmphdr_frame(icmp_code)-1) := x"00";
	constant icmptype_rply : std_logic_vector(0 to icmphdr_frame(icmp_type)-1) := x"00";
	constant icmpcode_rqst : std_logic_vector(0 to icmphdr_frame(icmp_type)-1) := x"00";
	constant icmptype_rqst : std_logic_vector(0 to icmphdr_frame(icmp_type)-1) := x"08";

	constant icmprqst_frame : natural_vector := (
		icmp_id  => 2*octect_size,
		icmp_seq => 2*octect_size);
		
	constant icmprply_frame : natural_vector := (
		icmp_id  => 2*octect_size,
		icmp_seq => 2*octect_size);
		
	constant udp4_sp   : natural :=  ipv4hdr_frame'right+1;
	constant udp4_dp   : natural :=  ipv4hdr_frame'right+2;
	constant udp4_len  : natural :=  ipv4hdr_frame'right+3;
	constant udp4_cksm : natural :=  ipv4hdr_frame'right+4;

	constant udp4hdr_frame : natural_vector := (
		udp4_sp   => 2*octect_size,
		udp4_dp   => 2*octect_size,
		udp4_len  => 2*octect_size,
		udp4_cksm => 2*octect_size);
		
	constant dhcp4_op       : natural := udp4hdr_frame'right+ 1;
	constant dhcp4_htype    : natural := udp4hdr_frame'right+ 2;
	constant dhcp4_hlen     : natural := udp4hdr_frame'right+ 3;
	constant dhcp4_hops     : natural := udp4hdr_frame'right+ 4;
	constant dhcp4_xid      : natural := udp4hdr_frame'right+ 5;
	constant dhcp4_secs     : natural := udp4hdr_frame'right+ 6;
	constant dhcp4_flags    : natural := udp4hdr_frame'right+ 7;
	constant dhcp4_ciaddr   : natural := udp4hdr_frame'right+ 8;
	constant dhcp4_yiaddr   : natural := udp4hdr_frame'right+ 9;
	constant dhcp4_siaddr   : natural := udp4hdr_frame'right+10;
	constant dhcp4_giaddr   : natural := udp4hdr_frame'right+11;
	constant dhcp4_chaddr6  : natural := udp4hdr_frame'right+12;
	constant dhcp4_chaddr10 : natural := udp4hdr_frame'right+13;
	constant dhcp4_shname   : natural := udp4hdr_frame'right+14;
	constant dhcp4_fbname   : natural := udp4hdr_frame'right+15;
	constant dhcp4_cookie   : natural := udp4hdr_frame'right+16;
                                       
	constant dhcp4hdr_frame : natural_vector(dhcp4_op to dhcp4_cookie) := ( -- Quartus Prime 22.1 bug cannot deal with unconstrains array
		dhcp4_op     =>   1*octect_size,
		dhcp4_htype  =>   1*octect_size,
		dhcp4_hlen   =>   1*octect_size,
		dhcp4_hops   =>   1*octect_size,
		dhcp4_xid    =>   4*octect_size,
		dhcp4_secs   =>   2*octect_size,
		dhcp4_flags  =>   2*octect_size,
		dhcp4_ciaddr =>   4*octect_size,
		dhcp4_yiaddr =>   4*octect_size,
		dhcp4_siaddr =>   4*octect_size,
		dhcp4_giaddr =>   4*octect_size,
		dhcp4_chaddr6  =>  6*octect_size,
		dhcp4_chaddr10 =>  10*octect_size,
		dhcp4_shname =>  64*octect_size,
		dhcp4_fbname => 128*octect_size,
		dhcp4_cookie =>   4*octect_size);

	constant dhcp4_offer : std_logic_vector(0 to dhcp4hdr_frame(dhcp4_op)-1) := x"02";

	function aton (
		constant ipa : string)
		return std_logic_vector;
end;

package body ipoepkg is

	function aton (
		constant ipa : string)
		return std_logic_vector is
		constant n      : natural := 8;
		variable aux    : natural range 0 to 2**n-1;
		variable retval : unsigned(0 to 32-1);
	begin
		retval := (others => '0');
		aux    := 0;
		for i in ipa'range loop
			if ipa(i)='.' then
				retval(0 to n-1) := to_unsigned(aux,n);
				retval := retval rol 8;
				aux := 0;
			else
				aux := aux * 10;
				aux := aux + (character'pos(ipa(i))-character'pos('0'));
			end if;
		end loop;
		retval(0 to n-1) := to_unsigned(aux,n);
		retval := retval rol 8;
		return std_logic_vector(retval);
	end;

end;

