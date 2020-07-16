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

entity arp_rx is
	port (
		mii_rxc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		eth_ptr  : in  std_logic_vector;
		eth_bcst : in  std_logic;
		arp_req  : out std_logic);

end;

architecture def of arp_rx is

	signal arp_field : std_logic_vector(0 to eth_frame'length+arp_frame'length-1);
	signal llc_equ : std_logic;
	signal tpa_req : std_logic;
	signal tpa_equ : std_logic;

begin


	llccmp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(llc_arp,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => mii_rxdv,
		mii_equ  => llc_equ);

	tpa_req <= llc_equ and eth_bcst;
	arp_field <= eth_decode(unsigned(eth_ptr), eth_frame & arp_frame, mii_rxd'length);
	tpacmp_e : entity hdl4fpga.mii_ramcmp
	generic map (
		mem_size => arp_frame(arp_tpa),
		mem_data => reverse(x"c0_a8_00_0e",8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => '0',
		mii_rxd  => mii_rxd,
		mii_treq => tpa_req,
		mii_tena => arp_field(eth_frame'length + arp_tpa),
		mii_equ  => tpa_equ);

	arp_req <= tpa_equ;

end;

