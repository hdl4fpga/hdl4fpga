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

entity sio_latency is
	generic (
		latency : natural);
    port (
        sio_clk  : in  std_logic;
        sio_frm  : in  std_logic := '-';
        si_irdy  : in  std_logic;
        si_trdy  : out std_logic;
		si_data  : in  std_logic_vector;
        so_irdy  : out std_logic;
        so_trdy  : in  std_logic;
		so_data  : out std_logic_vector);
end;

architecture def of sio_latency is
	signal ena : std_logic;
begin

	assert si_data'length = so_data'length
	report "Length of si_data must be equal to the length of so_data"
	severity FAILURE;

	assert latency mod si_data'length = 0
	report "LATENCY must be a multiple of the length of si_data'length"
	severity FAILURE;

	lat_e : entity hdl4fpga.align
	generic map (
		n => si_data'length,
		d => (0 to si_data'length-1 => latency/si_data'length),
		i => (0 to si_data'length-1 => '0'))
	port map (
		clk => sio_clk,
		ena => so_trdy,
		di  => si_data,
		do  => so_data);
		
	irdy_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => latency/si_data'length),
		i => (0 to 0 => '0'))
	port map (
		clk   => sio_clk,
		ena   => so_trdy,
		di(0) => si_irdy,
		do(0) => so_irdy);

	si_trdy <= so_trdy;
		
end;
