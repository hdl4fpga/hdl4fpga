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

entity sio_cmp is
    port (
		mux_data : in  std_logic_vector;
        sio_clk  : in  std_logic;
        sio_frm  : in  std_logic;
		sio_irdy : in  std_logic;
		sio_trdy : out std_logic;
		so_last  : out std_logic;
		so_end   : out std_logic;
		so_equ   : out std_logic;
        si_data  : in  std_logic_vector;
        so_data  : buffer std_logic_vector);
end;

architecture def of sio_cmp is
begin

	data_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_data,
        sio_clk  => sio_clk,
		sio_frm  => sio_frm,
		sio_irdy => sio_irdy,
        sio_trdy => sio_trdy,
		so_last  => so_last,
        so_end   => so_end,
        so_data  => so_data);

	process (si_data, so_data, sio_clk)
		variable cy : std_logic;
	begin
		if rising_edge(sio_clk) then
			if sio_frm='0' then
				cy := '1';
			elsif sio_irdy='1' then
				cy := setif(so_data=si_data) and cy;
			end if;
		end if;
		so_equ <= setif(so_data=si_data) and cy;
	end process;

end;
