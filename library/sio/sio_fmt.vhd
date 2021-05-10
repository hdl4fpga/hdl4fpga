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

entity sio_cap is
	port (
		sio_clk : in  std_logic;
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : in  std_logic;
		si_data : in  std_logic_vector;
		so_frm  : out std_logic;
		so_irdy : out std_logic;
		so_trdy : in  std_logic;
		so_data : out std_logic_vector);
end;

architecture def of sio_cap is
	signal idlen_end  : std_logic;
	signal idlen_data : std_logic_vector(si_data'range);
	signal fifoi_data : std_logic_vector(si_data'range);
	signal fifoo_data : std_logic_vector(si_data'range);
begin

	idlen_e : entity hdl4fpga.sio_mux is
	port (
		mux_data : in  std_logic_vector;
		sio_clk  => mii_clk,
		sio_frm  => si_frm,
		so_end   => idlen_end,
		so_data  => idlen_data);

	fifoi_irdy <= '1' when idlen_end='0' else si_irdy;
	fifoi_data <= primux(idlen_data, not idlen_end, si_data);

	fifo_e : entity hdl4fpga.fifo
	generic map (
		max_depth => my_mac'length/miirx_data'length,
		latency   => 0)
	port map (
		src_clk   => mii_clk,
		src_frm   => si_frm;
		src_irdy  => fifoi_irdy,
		src_trdy  => open,
		src_data  => fifoi_data,

		dst_clk   => mii_clk,
		dst_irdy  => so_irdy,
		dst_trdy  => so_trdy
		dst_data  => so_data);
end;
