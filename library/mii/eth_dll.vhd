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

entity eth_dll is
	generic (
		preamble_disable : boolean := false);
	port (
		mii_txc  : in  std_logic;
		dll_txen : in  std_logic;
		dll_txd  : in  std_logic_vector;
		mii_txen : out std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture mix of eth_dll is

	constant mii_pre  : std_logic_vector := reverse(x"5555_5555_5555_55d5", 8);

	signal pre_txd    : std_logic_vector(dll_txd'range);
	signal pre_txen   : std_logic;

	constant lat_length : natural := mii_pre'length/mii_txd'length;
	signal lat_txd    : std_logic_vector(dll_txd'range);
	signal lat_txen   : std_logic;

	constant crc32_size   : natural := 32;
	signal crc32_txd  : std_logic_vector(mii_txd'range);
	signal crc32_txen : std_logic;

begin

	miitx_pre_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mii_pre)
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => pre_txen,
		mii_txd  => pre_txd);

	lattxd_e : entity hdl4fpga.align
	generic map (
		n  => mii_txd'length,
		d  => (0 to mii_txd'length-1 => lat_length))
	port map (
		clk => mii_txc,
		di  => dll_txd,
		do  => lat_txd);

	lattxdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to mii_txd'length-1 => lat_length),
		i => (0 to mii_txd'length-1 => '0'))
	port map (
		clk   => mii_txc,
		di(0) => dll_txen,
		do(0) => lat_txen);

	crc32_e : entity hdl4fpga.eth_crc32
	port map (
		mii_txc  => mii_txc,
		mii_rxd  => lat_txd,
		mii_rxdv => lat_txen,
		mii_txdv => crc32_txen,
		mii_txd  => crc32_txd);

	mii_txd  <= wirebus (pre_txd & lat_txd & crc32_txd, pre_txen & lat_txen & crc32_txen);
	mii_txen <= pre_txen or lat_txen or crc32_txen;

end;
