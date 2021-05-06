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

entity sio_fmt is
    port (
		data     : in  std_logic_vector;
        sio_clk  : in  std_logic;
		si_frm   : in  std_logic;
        si_irdy  : in  std_logic;
        si_trdy  : out std_logic;
        si_data  : in  std_logic_vector;
		so_frm   : out std_logic;
        so_irdy  : out std_logic;
        so_trdy  : in  std_logic;
        so_data  : out std_logic_vector);
end;

architecture beh of sio_fmt is
	signal mux_txen : std_logic;
	signal mux_txd  : std_logic_vector(mii_rxd'range);
	signal lat_txen : std_logic;
	signal lat_txd  : std_logic_vector(mii_txd'range);
begin

	mux_e : entity hdl4pga.sio_mux
    port (
		mux_data => data,
        sio_clk  => sio_clk,
        sio_frm  => si_frm,
		sio_irdy => so_trdy,
		sio_trdy => mux_trdy,
		so_end   => mux_end,
        so_data  => mux_data);

	lat_e : entity hdl4fpga.align
	generic map (
		d => data'length)
    port map (
        clk  => sio_clk,
		di   => si_data,
        do   => lat_data);

	so_frm  <= si_frm;
	so_irdy <= primux(mux_trdy & si_irdy,  not mux_end & '1');
	so_data <= primux(mux_data & lat_data, not mux_end & '1');
end;
