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
use hdl4fpga.ipoepkg.all;

entity arp_tx is
	generic (
		mac       : std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_txc   : in  std_logic;
		mii_req   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txen  : out std_logic;

		ipsa_treq : out std_logic;
		ipsa_trdy : in  std_logic;
		ipsa_txen : in  std_logic;
		ipsa_txd  : in  std_logic;
		udpddata_vld  : out std_logic);
end;

architecture struct of arp_tx is

begin
	
	pfx_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(arp_prefix & mac, 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => pfx_req,
		mii_trdy => pfx_rdy,
		mii_txen => pfx_txen,
		mii_txd  => pfx_rxd);

	tha_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse( x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => tha_req,
		mii_trdy => tha_rdy,
		mii_txen => tha_txen,
		mii_txd  => tha_rxd);

	mii_arpcat_e : entity hdl4fpga.mii_cat
	port map (
		mii_req  => rply_req,
		mii_rdy  => rply_rdy,
		mii_trdy => miicat_trdy,
		mii_rxdv => miicat_rxdv,
		mii_rxd  => miicat_rxd,
		mii_treq => miicat_treq,
		mii_txdv => txdv,
		mii_txd  => txd);

end;

