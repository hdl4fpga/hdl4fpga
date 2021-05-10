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

entity sio_tag is
	port (
		sio_clk : in  std_logic;
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;
		so_frm  : out std_logic;
		so_irdy : out std_logic;
		so_trdy : in  std_logic;
		so_data : out std_logic_vector);
end;

architecture def of sio_tag is

	signal tag_trdy   : std_logic;
	signal tag_end    : std_logic;
	signal tag_data   : std_logic_vector(si_data'range);

	signal fifoo_irdy : std_logic;
	signal fifoo_trdy : std_logic;
	signal fifoo_data : std_logic_vector(si_data'range);

begin

	tag_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ,
		sio_clk  => mii_clk,
		sio_frm  => si_frm,
		sio_irdy => so_trdy,
		sio_trdy => tag_trdy,
		so_end   => tag_end,
		so_data  => tag_data);

	fifo_e : entity hdl4fpga.fifo
	generic map (
		max_depth => my_mac'length/miirx_data'length,
		latency   => 0)
	port map (
		src_clk   => mii_clk,
		src_frm   => si_frm;
		src_irdy  => si_irdy,
		src_trdy  => open,
		src_data  => si_data,

		dst_clk   => mii_clk,
		dst_irdy  => fifoo_irdy,
		dst_trdy  => fifoo_trdy
		dst_data  => fifoo_data);

	so_frm     <= si_frm;
	so_irdy    <= tag_trdy when tag_end='0' else fifoo_trdy;
	fifoo_trdy <= '0'      when tag_end='0' else so_trdy;
	so_data    <= primux(tag_data, not tag_end, fifoo_data);

end;
