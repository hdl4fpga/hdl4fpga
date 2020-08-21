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
		mii_txc  : in  std_logic;
		mii_txen : in  std_logic;
		arp_frm  : in  std_logic_vector;
		
		sha      : in std_logic_vector;
		tha      : in std_logic_vector;
		tpa      : in std_logic_vector;
		spa      : in std_logic_vector;


		arp_txen : out std_logic;
		arp_txd  : out std_logic_vector);

end;

architecture def of arp_tx is

	signal sha_txen : std_logic;
	signal sha_txd  : std_logic_vector(arp_txd'range);

	signal spa_txen : std_logic;
	signal spa_txd  : std_logic_vector(arp_txd'range);

	signal tha_txen : std_logic;
	signal tha_txd  : std_logic_vector(arp_txd'range);

	signal tpa_txen : std_logic;
	signal tpa_txd  : std_logic_vector(arp_txd'range);

	signal pfx_txen : std_logic;
	signal pfx_txd  : std_logic_vector(arp_txd'range);

begin
	
	pfx_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(arp4rply_pfx, 8))
	port map (
		mii_txc  => mii_txc,
		mii_txen => mii_txen,
		mii_txdv => pfx_txen,
		mii_txd  => pfx_txd);

	sha_txen <= frame_decode(arp_frm, arp4_frame, arp_txd'length, arp_sha);
	sha_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => sha,
		mii_txc  => mii_txc,
		mii_rxdv => sha_txen,
		mii_txd  => sha_txd);

	spa_txen <= frame_decode(arp_frm, arp4_frame, arp_txd'length, arp_spa);
	spa_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => spa,
		mii_txc  => mii_txc,
		mii_rxdv => spa_txen,
		mii_txd  => spa_txd);

	tha_txen <= frame_decode(arp_frm, arp4_frame, arp_txd'length, arp_tha);
	tha_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => tha,
		mii_txc  => mii_txc,
		mii_rxdv => tha_txen,
		mii_txd  => tha_txd);

	tpa_txen <= frame_decode(arp_frm, arp4_frame, arp_txd'length, arp_tpa);
	tpa_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => tpa,
		mii_txc  => mii_txc,
		mii_rxdv => tpa_txen,
		mii_txd  => tpa_txd);


	arp_txd  <= wirebus (pfx_txd & sha_txd & spa_txd & tha_txd & tpa_txd, pfx_txen & sha_txen & spa_txen & tha_txen & tpa_txen);
	arp_txen <= pfx_txen or sha_txen or spa_txen or tha_txen or tpa_txen;

end;
