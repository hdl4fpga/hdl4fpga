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
use hdl4fpga.ipoe.all;

entity ip_tx is
	port (
		mii_txc   : in  std_logic;

		pl_txdv   : in  std_logic;
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

		ip4_txdv : out std_logic;
		ip4_txd  : out std_logic_vector);
end;

architecture def of ip_tx is

	signal ip4_ptr : unsigned;

begin

	process (mii_txc)
	begin
		if rising_edge((mii_txc) then
			if pl_txen='0' then
				ip4_ptr <= (others => '0');
			elsif ip4_ptr(0)='0' then
				ip4_ptr <= ip4_ptr + 1;
			end if;
		end if;
	end process;


	cksm_rxd  <= wirebus(iplen_txd & ipsa_txd & ipda_txd, iplen_txen & ipsa_txen & ipda_txen);
	cksm_rxdv <= iplen_txen & ipsa_txen & ipda_txen;
	
	ip4len_ena <= frame_decode(ip4_ptr, ip4_len, ip4hdr_frame, mii_rxd'length);

	iplenlat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => iphdr_frame(ip_verihl)+iphdr_frame(ip_tos))
	port map (
		mii_txc => mii_txc,
		lat_txd => cksm_rxd,
		mii_txd => lenlat_txd);
	
	ipalat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => iphdr_frame(ip_verihl)+iphdr_frame(ip_tos))
	port map (
		mii_txc => mii_txc,
		lat_txd => lenlat_txd,
		mii_txd => ipalat_txd);
	
	ip4shr_tena <= frame_decode(
		ip4_ptr,
	   	natural_vector'(ip4_verihl, ip4_tos, ip4_ident, ip4_flgsfrg, ip4_ttl, ip4_proto),
	   	ip4hdr_frame, 
		mii_rxd'length);

	miiip4shdr_e : entity hdl4fpga.mii_rom
	generic map (
	port map (
		mii_txc  => mii_txc,
		mii_treq => pl_txdv,
		mii_tena => ip4shr_tena,
		mii_trdy => ip4shdr_trdy,
		mii_txdv => ip4shdr_txdv,
		mii_txd  => ip4shdr_txd);

	mii1checksum_e : entity hdl4fpga.mii_1chksum
	generic map (
		chksum_init =>,
		chksum_size => 16)
	port map (
		mii_rxc   => mii_txc,
		cksm_rxdv => cksm_rxd,
		cksm_rxd  => cksm_rxdv,

		mii_txc   => mii_txc,
		cksm_treq => 
		cksm_trdy => cksm_trdy,
		cksm_txen => cksm_txdv,
		cksm_txd  => cksm_txd);

	ip4_txd <= wirebus (ip4shdr_txd & lenlat_txd & chksm_txd, ip4shdr_txdv & lenlat_txdv & cksm_txdv)
end;

