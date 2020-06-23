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

entity mii_file is
	generic (
		ip4_size : natural;
		mac_size : natural);
	port (
		mii_rxc       : in  std_logic;
		mii_rxd       : in  std_logic_vector;
		mii_rxdv      : in  std_logic;

		mii_txc       : in  std_logic;
		mii_txd       : out std_logic_vector;
		mii_txen      : out std_logic;

		ipsaddr_vld   : in  std_logic;
		ipsaddr_txen  : out std_logic;
		ipsaddr_txd   : out std_logic_vector;
		ipsaddr_txdv  : in  std_logic;
		ipsaddr_treq  : in  std_logic;
		ipsaddr_trdy  : out std_logic;
		ipsaddr_teoc  : out std_logic;

		macdaddr_vld  : in  std_logic;
		macdaddr_txen : out std_logic;
		macdaddr_txd  : out std_logic_vector;
		macdaddr_txdv : in  std_logic;
		macdaddr_treq : in  std_logic;
		macdaddr_trdy : out std_logic;
		macdaddr_teoc : out std_logic;

		ipdaddr_vld   : in  std_logic;
		ipdaddr_txen  : out std_logic;
		ipdaddr_txd   : out std_logic_vector;
		ipdaddr_txdv  : in  std_logic;
		ipdaddr_treq  : in  std_logic;
		ipdaddr_trdy  : out std_logic;
		ipdaddr_teoc  : out std_logic);

end;

architecture struct of mii_file is

begin

	ipsaddr_e : entity hdl4fpga.mii_ram
	generic map (
		size => ip4_size)
	port map(
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => ipsaddr_vld,
		mii_txc  => mii_txc,
		mii_txdv => ipsaddr_txen,
		mii_txd  => ipsaddr_txd,
		mii_txen => ipsaddr_txdv,
		mii_treq => ipsaddr_treq,
		mii_teoc => ipsaddr_teoc,
		mii_trdy => ipsaddr_trdy);

	ethdmac_e : entity hdl4fpga.mii_ram
	generic map (
		size => mac_size)
	port map(
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => macdaddr_vld,
		mii_txc  => mii_txc,
		mii_txdv => macdaddr_txen,
		mii_txd  => macdaddr_txd,
		mii_txen => macdaddr_txdv,
		mii_treq => macdaddr_treq,
		mii_teoc => macdaddr_teoc,
		mii_trdy => macdaddr_trdy);

	ipdaddr_e : entity hdl4fpga.mii_ram
	generic map (
		size => ip4_size)
	port map(
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => ipdaddr_vld,
		mii_txc  => mii_txc,
		mii_txdv => ipdaddr_txen,
		mii_txd  => ipdaddr_txd,
		mii_treq => ipdaddr_treq,
		mii_teoc => ipdaddr_teoc,
		mii_trdy => ipdaddr_trdy);

end;

