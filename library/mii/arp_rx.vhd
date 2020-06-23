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

entity arp_rx is
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;
		ptype_vld : in  std_logic);

end;

architecture struct of arp_rx is

	constant arp_pfx : natural_vector := (
		htype => 2*8,
		ptype => 2*8,
		hlen  => 1*8,
		plen  => 1*8,
		oper  => 2*8,
		sha   => 6*8,
		spa   => 4*8,
		tha   => 6*8,
		tpa   => 4*8);

begin

	tpacmp : entity hdl4fpga.mii_cmp
	port map (
		mii_req  => arpproto_vld,
		mii_rxc  => mii_rxc,
		mii_ena  => tpa_ena,
		mii_rdy  => ipsaddr_rrdy,
		mii_rxd1 => mii_rxd,
		mii_rxd2 => ipsaddr_rtxd,
		mii_equ  => cmp_equ);

end;

