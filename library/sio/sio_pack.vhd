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

entity sio_pack is
	port (
		sio_clk   : in  std_logic;
		sio_frm   : in  std_logic;
		rid       : in  std_logic_vector(8-1 downto 0);
		data      : in  std_logic_vector;
		si_irdy   : in  std_logic;
		si_trdy   : out std_logic;
		si_data   : in  std_logic_vector;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector);
end;

architecture beh of sio_pack is
	signal mux_trdy : std_logic;
	signal mux_end  : std_logic;
	signal mux_data : std_logic_vector(so_data'range);
begin

	assert si_data'length=so_data'length
	report "si_data not equal so_data"
	severity FAILURE;

	mux_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => data,
		sio_clk  => sio_clk,
		sio_frm  => sio_frm,
		so_irdy  => si_irdy,
		so_trdy  => mux_trdy,
		so_end   => mux_end,
		so_data  => mux_data);

	so_data <= wirebus(mux_data & si_data, mux_end & not mux_end);
	si_trdy <= '0' when mux_end='0' else so_trdy;
	so_irdy <= mux_trdy when mux_end='0' else si_irdy;
end;
