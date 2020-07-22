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
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity ip_tx is
	port (
		mii_txc   : in  std_logic;

		pl_txen   : in  std_logic;
		pl_txd    : in  std_logic_vector;

		ip4len_treq : out std_logic ;
		ip4len_trdy : in  std_logic := '-';
		ip4len_txen : in  std_logic;
		ip4len_txd  : in  std_logic_vector;

		ip4sa_treq : out std_logic ;
		ip4sa_trdy : in  std_logic := '-';
		ip4sa_txen : in  std_logic;
		ip4sa_txd  : in  std_logic_vector;

		ip4da_treq : out std_logic;
		ip4da_trdy : in  std_logic := '-';
		ip4da_txen : in  std_logic;
		ip4da_txd  : in  std_logic_vector;

		ip4_txen : out std_logic;
		ip4_txd  : out std_logic_vector);
end;

architecture def of ip_tx is

	signal ip4_ptr      : unsigned(0 to unsigned_num_bits(summation(ip4hdr_frame)-1));
	signal ip4shdr_trdy : std_logic;
	signal ip4shdr_treq : std_logic;
	signal ip4shdr_tena : std_logic;
	signal ip4shdr_txen : std_logic;
	signal ip4shdr_txd  : std_logic_vector(ip4_txd'range);
	signal cksm_txd     : std_logic_vector(ip4_txd'range);
	signal cksm_txen    : std_logic;
	signal cksmd_trdy   : std_logic;
	signal cksmd_treq   : std_logic;
	signal cksmd_txd    : std_logic_vector(ip4_txd'range);
	signal cksmd_txen   : std_logic;
	signal lenlat_txd   : std_logic_vector(ip4_txd'range);
	signal lenlat_txen  : std_logic;
	signal ip4alat_txd  : std_logic_vector(ip4_txd'range);
	signal ip4alat_txen : std_logic;

begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if pl_txen='0' then
				ip4_ptr <= (others => '0');
			elsif ip4_ptr(0)='0' then
				ip4_ptr <= ip4_ptr + 1;
			end if;
		end if;
	end process;

	lenlat_txen <= frame_decode(ip4_ptr, ip4_len, ip4hdr_frame, ip4_txd'length);

	ip4shdr_tena <= frame_decode(
		ip4_ptr,
	   	(ip4_verihl, ip4_tos, ip4_ident, ip4_flgsfrg, ip4_ttl, ip4_proto),
	   	ip4hdr_frame, 
		ip4_txd'length);

	miiip4shdr_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => ip4_shdr)
	port map (
		mii_txc  => mii_txc,
		mii_treq => pl_txen,
		mii_tena => ip4shdr_tena,
		mii_trdy => ip4shdr_trdy,
		mii_txen => ip4shdr_txen,
		mii_txd  => ip4shdr_txd);

	iplenlat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => 
			ip4hdr_frame(ip4_verihl)+
			ip4hdr_frame(ip4_tos))
	port map (
		mii_txc => mii_txc,
		lat_txd => cksm_txd,
		mii_txd => lenlat_txd);
	
	ip4alat_txen <= frame_decode( ip4_ptr, (ip4_sa, ip4_da), ip4hdr_frame, ip4_txd'length);

	ipalat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => 
			ip4hdr_frame(ip4_ident)+
			ip4hdr_frame(ip4_flgsfrg)+
			ip4hdr_frame(ip4_ttl)+
			ip4hdr_frame(ip4_proto)+
			ip4hdr_frame(ip4_chksum))
	port map (
		mii_txc => mii_txc,
		lat_txd => lenlat_txd,
		mii_txd => ip4alat_txd);
	
	ip4len_treq <= pl_txen;
	ip4sa_treq  <= ip4len_trdy;
	ip4da_treq  <= ip4sa_trdy;

	cksm_txd  <= wirebus(ip4len_txd & ip4sa_txd & ip4da_txd, ip4len_txen & ip4sa_txen & ip4da_txen);
	cksm_txen <= ip4len_txen or ip4sa_txen or ip4da_txen;
	mii1checksum_e : entity hdl4fpga.mii_1chksum
	generic map (
		chksum_init => oneschecksum(ip4_shdr, 16),
		chksum_size => 16)
	port map (
		mii_txc   => mii_txc,
		mii_txen  => cksm_txen,
		mii_txd   => cksm_txd,

		cksm_treq => cksmd_treq,
		cksm_trdy => cksmd_trdy,
		cksm_txen => cksmd_txen,
		cksm_txd  => cksmd_txd);

	ip4_txd  <= wirebus(ip4shdr_txd & lenlat_txd & ip4alat_txd & cksmd_txd, ip4shdr_txen & lenlat_txen & ip4alat_txen & cksmd_txen);
	ip4_txen <= ip4shdr_txen or lenlat_txen or ip4alat_txen or cksmd_txen;
end;

