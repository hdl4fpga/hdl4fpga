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

entity dhcp_offer is
	generic (
		mac          : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc       : in  std_logic;
		mii_rxd       : in  std_logic_vector;
		mii_rxdv      : in  std_logic;
end;

architecture def of dhcp_offer is

	constant dhcp_frame : natural :=  udp_frame+8;
	constant dhcp_yia   : field   := (dhcp_frame+16, 4);
	constant dhcp_sia   : field   := (dhcp_frame+20, 4);

	signal dhcp_ena     : std_logic;
	signal yia_ena      : std_logic;
	signal sia_ena      : std_logic;

	signal dis_txd   : std_logic_vector(mii_txd'range);
	signal dis_txdv  : std_logic;
	signal requ_txd  : std_logic_vector(mii_txd'range);
	signal requ_txdv : std_logic;

	signal offer_rcv : std_logic;
begin
					
	dhcp_ena <= lookup((0 => udp_sport, 1 => udp_dport), std_logic_vector(mii_ptr));
	yia_ena  <= lookup((0 => dhcp_yia), std_logic_vector(mii_ptr));
	sia_ena  <= lookup((0 => dhcp_sia), std_logic_vector(mii_ptr));

	mii_dhcp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(x"00430044",8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => udpproto_vld,
		mii_ena  => dhcp_ena,
		mii_pktv => dhcp_vld);

	myipcfg_vld  <= dhcp_vld and yia_ena;
	ipdaddr_vld  <= dhcp_vld and sia_ena;
	offer_rcv    <= dhcp_vld;

end;

