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

entity mii_pack is
    port (
		data     : in  std_logic_vector;
        mii_txc  : in  std_logic;
        mii_rxdv : in  std_logic;
        mii_rxd  : in  std_logic_vector;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture beh of mii_pack is
	signal mux_txen : std_logic;
	signal mux_txd  : std_logic_vector(mii_rxd'range);
	signal lat_txen : std_logic;
	signal lat_txd  : std_logic_vector(mii_txd'range);
begin

	mux_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => data,
        mii_txc  => mii_txc,
        mii_txdv => mii_rxdv,
        mii_txen => mux_txen,
        mii_txd  => mux_txd);

	latency_e : entity hdl4fpga.mii_latency
	generic map (
		latency => data'length)
    port map (
        mii_txc  => mii_txc,
        lat_txen => mii_rxdv,
        lat_txd  => mii_rxd,
        mii_txen => lat_txen,
        mii_txd  => lat_txd);

	mii_txd  <= wirebus(mux_txd & lat_txd, not lat_txen & lat_txen);
	mii_txen <= mux_txen or lat_txen;
end;
