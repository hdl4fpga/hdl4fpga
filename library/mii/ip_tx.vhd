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

		ip_length : in  std_logic_vector;

		ipsa_treq : out std_logic ;
		ipsa_trdy : in  std_logic := '-';
		ipsa_txen : in  std_logic;
		ipsa_txd  : in  std_logic_vector;

		ipda_treq : out std_logic;
		ipda_trdy : in  std_logic := '-';
		ipda_txen : in  std_logic;
		ipda_txd  : in  std_logic_vector;

		ip_txdv : out std_logic;
		ip_txd  : out std_logic_vector);
end;

architecture def of ip_tx is

	signal ip4_ptr : unsigned;
	signal ip4_ena : std_logic_vector(ip4hdr_frame'range);

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

	lengthmux_e : entity hdl4fpga.mii_mux
    port map (
		mux_data => ip_length,
        mii_txc  => mii_txc,
		mii_treq => iplen_treq,
		mii_trdy => iplen_trdy,
        mii_txen => iplen_txen,
        mii_txd  => iplen_txd);

	ipsa_treq <= iplen_trdy;
	ipda_treq <= ipsa_trdy;

	cksm_rxd  <= wirebus(iplen_txd & ipsa_txd & ipda_txd, iplen_txen & ipsa_txen & ipda_txen);
	cksm_rxdv <= iplen_txen & ipsa_txen & ipda_txen;

	ip4_ena <= frame_decode(ip4_ptr, ip4hdr_frame, mii_rxd'length);

	frame_dec

	lenlat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => iphdr_frame(ip_verihl)ip_tos     
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
		cksm_trdy =>
		cksm_txen =>
		cksm_txd  =>);

end;

