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

entity mii_muxcmp is
    port (
		mux_data : in  std_logic_vector;
        mii_rxc  : in  std_logic;
        mii_rxdv : in  std_logic;
        mii_rxd  : in  std_logic_vector;
		mii_ena  : in  std_logic;
		mii_equ  : out std_logic);
end;

architecture def of mii_muxcmp is
	signal mii_txd : std_logic_vector(mii_rxd'range);
begin

	miimux_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => mux_data,
        mii_txc  => mii_rxc,
        mii_txdv => mii_ena,
        mii_txd  => mii_txd);

	miicmp_e : entity hdl4fpga.mii_cmp
    port map (
        mii_rxc  => mii_rxc,
        mii_rxdv => mii_rxdv,
        mii_rxd  => mii_rxd,
        mii_txd  => mii_txd,
		mii_ena  => mii_ena,
		mii_equ  => mii_equ);

end;
