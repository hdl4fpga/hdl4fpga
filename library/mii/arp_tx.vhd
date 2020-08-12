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

entity arp_tx is
	port (
		mii_txc   : in  std_logic;
		mii_txen  : in  std_logic;

		arp_frm   : in  std_logic_vector;

		sha_txen  : buffer std_logic;
		sha_txd   : in  std_logic_vector;

		spa_txen  : buffer std_logic;
		spa_txd   : in  std_logic_vector;

		tha_txen  : buffer std_logic;
		tha_txd   : in  std_logic_vector;

		tpa_txen  : buffer std_logic;
		tpa_txd   : in  std_logic_vector;

		arp_txen  : out std_logic;
		arp_txd   : out std_logic_vector);

end;

architecture def of arp_tx is

	signal pfx_txen : std_logic;
	signal pfx_txd  : std_logic_vector(arp_txd'range);

begin
	
	pfx_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(llc_arp & arp4rply_pfx, 8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => mii_txen,
		mii_txen => pfx_txen,
		mii_txd  => pfx_txd);

	sha_txen <= frame_decode(unsigned(arp_frm), arp4_frame, arp_txd'length, arp_sha);
	spa_txen <= frame_decode(unsigned(arp_frm), arp4_frame, arp_txd'length, arp_spa);
	tha_txen <= frame_decode(unsigned(arp_frm), arp4_frame, arp_txd'length, arp_tha);
	tpa_txen <= frame_decode(unsigned(arp_frm), arp4_frame, arp_txd'length, arp_tpa);

	arp_txd  <= wirebus (pfx_txd & sha_txd & spa_txd & tha_txd & tpa_txd, pfx_txen & sha_txen & spa_txen & tha_txen & tpa_txen);
	arp_txen <= pfx_txen or sha_txen or spa_txen or tha_txen or tpa_txen;

end;
