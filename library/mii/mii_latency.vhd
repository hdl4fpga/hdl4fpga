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

entity mii_latency is
	generic (
		latency : natural);
    port (
        mii_txc  : in  std_logic;
        lat_txdv : in  std_logic;
        lat_txd  : in  std_logic_vector;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_latency is
	constant xxx : natural := mii_txd'length;
begin
	assert mii_txd'length = lat_txd'length
	report "Length of mii_txd must be equal to the length of lat_txd"
	severity FAILURE;

	assert latency mod mii_txd'length = 0
	report "LATENCY must be a multiple of the length of mii_txd'length"
	severity FAILURE;

	txd_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		d => (0 to mii_txd'length-1 => latency/mii_txd'length))
	port map (
		clk => mii_txc,
		di => lat_txd,
		do => mii_txd);
		
	txdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => latency/mii_txd'length))
	port map (
		clk   => mii_txc,
		di(0) => lat_txdv,
		do(0) => mii_txen);
		
end;
