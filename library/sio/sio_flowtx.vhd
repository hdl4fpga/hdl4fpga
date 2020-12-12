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

entity sio_flowtx is
	port (
		so_clk   : in  std_logic;
		so_frm   : in  std_logic;
		so_irdy  : in  std_logic;
		so_trdy  : out std_logic;
		so_data  : out std_logic_vector;
		so_end   : out std_logic;
		ack_data : in  std_logic_vector(8-1 downto 0);

		pkt_vld : in  std_logic;
		pkt_dup : in  std_logic);
end;

architecture def of sio_flowtx is
	signal sioack_data : std_logic_vector(0 to 40-1);
begin

	sioack_data <= x"00" & x"02" & x"00" & x"00" & ack_data;
	ack_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => sioack_data,
        sio_clk  => so_clk,
        sio_frm  => so_frm,
		so_irdy  => so_irdy,
		so_trdy  => so_trdy,
		so_end   => so_end,
        so_data  => so_data);

end;
