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

entity dhcp_dscb is
	generic (
		dhcp_sp   : std_logic_vector(0 to 16-1);
		dhcp_dp   : std_logic_vector(0 to 16-1);
		dhcp_mac  : std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_txc   : in  std_logic;
		mii_txen  : in  std_logic;
		udpdhcp_len  : out std_logic_vector(16-1 downto 0);
		udpdhcp_ptr  : in  std_logic_vector;
		udpdhcp_txen : buffer std_logic;
		udpdhcp_txd  : out std_logic_vector);
end;

architecture def of dhcp_dscb is

	constant payload_size : natural := 244+6;

	constant vendor_data : std_logic_vector := 
		x"350101"       &    -- DHCPDISCOVER
		x"320400000000" &    -- IP REQUEST
		x"FF";               -- END

	constant dhcp_pkt : std_logic_vector :=
		udp_checksummed (
			x"00000000",
			x"ffffffff",
			dhcp_sp      &    -- UDP Source port
			dhcp_dp      &    -- UDP Destination port
			std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
			oneschecksum(vendor_data,16) &	-- UDP CHECKSUM
			x"01010600"  &    -- OP, HTYPE, HLEN,  HOPS
			x"3903f326"  &    -- XID
			dhcp_mac     &    -- CHADDR  
			x"63825363") &    -- MAGIC COOKIE
			vendor_data;

	signal dhcppkt_ena : std_logic;
	signal dhcppkt_txd : std_logic_vector(udpdhcp_txd'range);

	constant dhcp_vendor : natural := dhcp4hdr_frame'right+1;
	constant vendor_frame : natural_vector := (
		dhcp_vendor => vendor_data'length);

begin

	udpdhcp_len <= std_logic_vector(to_unsigned(payload_size, udpdhcp_len'length));

	dhcppkt_ena <= frame_decode(udpdhcp_ptr, udp4hdr_frame & dhcp4hdr_frame & dhcp_vendor, udpdhcp_txd'length, (
		udp4_sp, udp4_dp, udp4_len, udp4_cksm, 
		dhcp4_op, dhcp4_htype, dhcp4_hlen, dhcp4_hops, 
		dhcp4_xid, 
		dhcp4_chaddr,
		dhcp4_cookie,
		dhcp_vendor));

	dhcppkt_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(vendor_data,8))
	port map (
		mii_txc  => mii_txc,
		mii_txen => mii_txen,
		mii_ena  => dhcppkt_ena,
		mii_txdv => udpdhcp_txen,
		mii_txd  => dhcppkt_txd);

	udpdhcp_txd  <= wirebus(dhcppkt_txd, (0 to 0 =>udpdhcp_txen));
end;

