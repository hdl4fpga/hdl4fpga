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
		mii_rxc    : in  std_logic;
		mii_rxd    : in  std_logic_vector;
		mii_rxdv   : in  std_logic;

		ipsa_rxdv  : in  std_logic;
		ipsa_txen  : out std_logic;
		ipsa_txd   : out std_logic_vector;
		ipsa_txdv  : in  std_logic;
		ipsa_treq  : in  std_logic;
		ipsa_trdy  : out std_logic;
		ipsa_teoc  : out std_logic);

end;

architecture def of mii_file is

begin

	ipsaddr_e : entity hdl4fpga.mii_ram
	generic map (
		size => ip4_size)
	port map(
		mii_rxc  => mii_rxc,
		mii_rxdv => ipsa_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => mii_txc,
		mii_txdv => ipsa_txen,
		mii_txd  => ipsa_txd,
		mii_txen => ipsa_txdv,
		mii_treq => ipsa_treq,
		mii_teoc => ipsa_teoc,
		mii_trdy => ipsa_trdy);

end;

