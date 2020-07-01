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

entity eth_tx is
	generic (
		mac      : in  std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_txc  : in  std_logic;
		mii_txd  : out std_logic_vector;
		mii_txdv : out std_logic;

end;

architecture def of eth_tx is
begin

	hwda_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(mac, 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => hwda_treq,
		mii_tena => hwda_ena,
		mii_txd  => hwda_txd);

	hwsa_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(mac, 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => mymac_treq,
		mii_tena => smac_ena,
		mii_txd  => mymac_txd);

	dll_e : entity hdl4fpga.eth_dll
	port map (
		mii_txc  => mii_txc,
		mii_rxdv => dll_txdv,
		mii_rxd  => dll_txd,
		mii_txdv => txdv1,
		mii_txd  => mii_txd);
	mii_txdv <= txdv1;

	dll_rxd_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		d => (0 to mii_txd'length-1 => to_miisize(etherdmac.size+ethersmac.size+ethertype.size)))
	port map (
		clk => mii_txc,
		di => rxd,
		do => txd);

	dll_rxdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to mii_txd'length-1 => to_miisize(etherdmac.size+ethersmac.size+ethertype.size)))
	port map (
		clk   => mii_txc,
		di(0) => rxdv,
		do(0) => txdv);

	dll_txd <= wirebus (
		dmac_txd & smac_txd & type_txd & txd,
		dmac_ena & smac_ena & type_ena & txdv);
	dll_txdv <=
		dmac_ena or smac_ena or type_ena or txdv;

end;

