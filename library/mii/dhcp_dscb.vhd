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
		dhcp_ip4 : in std_logic_vector(0 to 32-1) := x"c0_a8_00_0e";
		dhcp_sp  : in std_logic_vector(16-1 downto 0) := x"0044";
		dhcp_dp  : in std_logic_vector(16-1 downto 0) := x"0043";
		dhcp_mac : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_txc   : in  std_logic;
		dscb_cksm : buffer std_logic_vector(0 to 16-1);
		dscb_len  : out std_logic_vector(16-1 downto 0);
		dscb_treq : in  std_logic;
		dscb_trdy : out std_logic;
		dscb_txen : out std_logic;
		dscb_txd  : out std_logic_vector);
end;

architecture def of dhcp_dscb is

	constant payload_size : natural := 244+6;

	constant vendor_data : std_logic_vector := 
		x"63825363"     &    -- MAGIC COOKIE
		x"350101"       &    -- DHCPDISCOVER
		x"320400000000" &    -- IP REQUEST
		x"FF";               -- END

	constant shdr1 : std_logic_vector :=
		udp_checksummed (
			dhcp_ip4,
			x"ffffffff",
			dhcp_sp     &    -- UDP Source port
			dhcp_dp     &    -- UDP Destination port
			std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
			oneschecksum(vendor_data,16) &	-- UDP CHECKSUM
			x"01010600" &    -- OP, HTYPE, HLEN,  HOPS
			x"3903f326" &    -- XID
			x"00000000" &    -- SECS, FLAGS
			x"00000000" &    -- CIADDR
			x"00000000" &    -- YIADDR
			x"00000000" &    -- SIADDR
			x"00000000" &    -- GIADDR
			dhcp_mac    &    -- CHADDR  
			x"0000"     &    -- CHADDR
			x"00000000" &    -- CHADDR
			x"00000000");    -- CHADDR

	signal shdr1_trdy  : std_logic;
	signal shdr1_txen  : std_logic;
	signal shdr1_txd   : std_logic_vector(dscb_txd'range);

	signal names_trdy  : std_logic;
	signal names_txen  : std_logic;
	signal names_txd   : std_logic_vector(dscb_txd'range);

	signal vendor_txen : std_logic;
	signal vendor_txd  : std_logic_vector(dscb_txd'range);

	constant dhcp_shdr1 : std_logic_vector := shdr1(summation(udp4hdr_frame) to shdr1'right);
	constant dhcp_shdr2 : std_logic_vector := (0 to summation(dhcp4hdr_frame(dhcp4_shname to dhcp4_fbname))-1 => '0');

begin

	dscb_len  <= std_logic_vector(to_unsigned(payload_size, dscb_len'length));
	dscb_cksm <= reverse(shdr1(summation(udp4hdr_frame(0 to udp4_cksm-1)) to summation(udp4hdr_frame(0 to udp4_cksm))-1),8);

--	assert false
--	report to_string(dscb_cksm)
--	severity failure;

	shdr1_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(dhcp_shdr1,8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => dscb_treq,
		mii_trdy => shdr1_trdy,
		mii_txen => shdr1_txen,
		mii_txd  => shdr1_txd);

	sbname_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => dhcp_shdr2)
	port map (
		mii_txc  => mii_txc,
		mii_treq => shdr1_trdy,
		mii_trdy => names_trdy,
		mii_txen => names_txen,
		mii_txd  => names_txd);

	vendor_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(vendor_data,8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => names_trdy,
		mii_trdy => dscb_trdy,
		mii_txen => vendor_txen,
		mii_txd  => vendor_txd);

	dscb_txd  <= wirebus(shdr1_txd & names_txd & vendor_txd, shdr1_txen & names_txen & vendor_txen);
	dscb_txen <= shdr1_txen or names_txen or vendor_txen;
end;

