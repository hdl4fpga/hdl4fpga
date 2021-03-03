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
        mii_clk  : in  std_logic;
		mii_frm  : in  std_logic;
		mii_irdy : in  std_logic := '1';
		mii_trdy : out std_logic;
        mii_data : in  std_logic_vector;
        lat_frm  : out std_logic;
		lat_irdy : out std_logic;
		lat_trdy : in  std_logic := '1';
        lat_data : out std_logic_vector);
end;

architecture def of mii_latency is
	signal ena : std_logic;
begin

	assert mii_data'length=lat_data'length
	report "Length of mii_data must be equal to the length of lat_data"
	severity FAILURE;

	assert latency mod mii_data'length = 0
	report "LATENCY must be a multiple of the length of mii_data'length"
	severity FAILURE;

	ena <= mii_irdy and lat_trdy;
	frm_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => latency/mii_data'length),
		i => (0 to 0 => '0'))
	port map (
		clk   => mii_clk,
		ena   => ena,
		di(0) => mii_frm,
		do(0) => lat_frm);
		
	data_e : entity hdl4fpga.align
	generic map (
		n => mii_data'length,
		d => (0 to mii_data'length-1 => latency/mii_data'length),
		i => (0 to mii_data'length-1 => '0'))
	port map (
		clk => mii_clk,
		ena => ena,
		di  => mii_data,
		do  => lat_data);

	lat_irdy <= mii_irdy;
	mii_trdy <= lat_trdy;
		
end;
