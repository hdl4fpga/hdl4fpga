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
use hdl4fpga.ipoe.all;

entity ip_tx is
	port (
		mii_txc   : in  std_logic;

		pl_txdv   : in  std_logic;
		pl_txd    : in  std_logic_vector;

		iplen_treq : out std_logic ;
		iplen_trdy : in  std_logic := '-';
		iplen_txen : in  std_logic;
		iplen_txd  : in  std_logic_vector;

		ipsa_treq : out std_logic ;
		ipsa_trdy : in  std_logic := '-';
		ipsa_txen : in  std_logic;
		ipsa_txd  : in  std_logic_vector;

		ipda_treq : out std_logic;
		ipda_trdy : in  std_logic := '-';
		ipda_txen : in  std_logic;
		ipda_txd  : in  std_logic_vector;

		ip_txdv : out std_logic;
		ip_txd  : out std_logic_vector);
end;

architecture def of ip_tx is
begin
	<= wirebus (iplen_txd & ipsa_txd & ipda_txd, iplen_txen & ipsa_txen & ipda_txd);
	mii1checksum_e : entity hdl4fpga.mii_1chksum
	generic map (
		chksum_init =>,
		chksum_size => 16)
	port map (
		mii_txc   => mii_txc,
		cksm_txd  =>
		cksm_txen =>
		cksm_treq =>
		cksm_trdy =>

		mii_rxc   =>
		mii_rxdv  =>
		mii_rxd   =>);

end;

