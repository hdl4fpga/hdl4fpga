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
		hwsa      : std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_txc   : in  std_logic;

		ipsa_treq : out std_logic;
		ipsa_trdy : in  std_logic := '-';
		ipsa_txen : in  std_logic;
		ipsa_txd  : in  std_logic_vector;

		arp_treq  : in  std_logic;
		arp_trdy  : out std_logic;
		arp_txen  : out std_logic;
		arp_txd   : out std_logic_vector);

end;

architecture def of arp_tx is

	signal pfx_trdy : std_logic;
	signal pfx_txen : std_logic;
	signal pfx_txd  : std_logic_vector(arp_txd'range);

	signal tha_treq : std_logic;
	signal tha_trdy : std_logic;
	signal tha_txen : std_logic;
	signal tha_txd  : std_logic_vector(arp_txd'range);

	signal tpa_txen : std_logic;
	signal tpa_txd  : std_logic_vector(arp_txd'range);

begin
	
	pfx_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(llc_arp & arprply_pfx & hwsa, 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => arp_treq,
		mii_trdy => pfx_trdy,
		mii_txen => pfx_txen,
		mii_txd  => pfx_txd);


	process(mii_txc, pfx_trdy, ipsa_trdy, tha_trdy)
		variable tpa : std_logic;
	begin
		if rising_edge(mii_txc) then
			if pfx_trdy='0' then
				tpa := '0';
			elsif ipsa_trdy='1' then
				tpa := '1';
			end if;
		end if;
		tha_treq  <= setif(tpa='0', ipsa_trdy, pfx_trdy);
		ipsa_treq <= setif(tpa='0', pfx_trdy,  tha_trdy);
	end process;

	tha_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse( x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => tha_treq,
		mii_trdy => tha_trdy,
		mii_txen => tha_txen,
		mii_txd  => tha_txd);

	arp_txd  <= primux (pfx_txd & ipsa_txd & tha_txd & ipsa_txd, pfx_txen & ipsa_txen & tha_txen & ipsa_txen);
	arp_txen <= pfx_txen or ipsa_txen or tha_txen or ipsa_txen;

end;

