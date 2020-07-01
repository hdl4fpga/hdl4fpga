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

entity ipoe is
	generic (
		mac      : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc  : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rxdv : in  std_logic;

		mii_txc  : in  std_logic;
		mii_txd  : out std_logic_vector;
		mii_txdv : out std_logic;

end;

architecture def of ipoe is	

	signal eth_pre  : std_logic;
	signal eth_bcst : std_logic;
	signal eth_macd : std_logic;
	signal arp_req  : std_logic;
	signal mii_txdv : std_logic;
	signal mii_txd  : std_logic;
	signal mii_tena : std_logic;
	signal mii_treq : std_logic;
	signal mii_trdy : std_logic;

begin

	ipsa_e : entity hdl4fpga.mii_ram
	generic map (
		size => ip4a_size)
	port map(
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => ipda_rxdv,

		mii_txc  => mii_txc,
		mii_txdv => ipsa_txdv,
		mii_txd  => ipsa_txd,
		mii_tena => ipsa_tena,
		mii_treq => ipsa_treq,
		mii_trdy => ipsa_trdy);

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		arp_req  => arp_req);

end;

