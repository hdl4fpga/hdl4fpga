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
use hdl4fpga.base.all;

entity sio_muxcmp is
	generic (
		n : natural := 1);
    port (
		mux_data : in  std_logic_vector;
        sio_clk  : in  std_logic;
        sio_frm  : in  std_logic;
		sio_irdy : in  std_logic;
		sio_trdy : out std_logic;
        si_data  : in  std_logic_vector;
		so_last  : out std_logic;
		so_end   : out std_logic;
		so_equ   : out std_logic_vector(0 to n-1));
end;

architecture def of sio_muxcmp is
	signal sio_last : std_logic_vector(0 to n-1);
	signal sio_end  : std_logic_vector(0 to n-1);
begin

	g : for i in 0 to n-1 generate

		signal sio_data : std_logic_vector(0 to mux_data'length/n-1);
		signal so_data  : std_logic_vector(si_data'range);

	begin

		sio_data <= multiplex(mux_data, i, sio_data'length);
		data_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => sio_data,
			sio_clk  => sio_clk,
			sio_frm  => sio_frm,
			sio_irdy => sio_irdy,
			sio_trdy => sio_trdy,
			so_last  => sio_last(i),
			so_end   => sio_end(i),
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
			so_equ(i) <= setif(so_data=si_data) and cy;
		end process;


	end generate;

	so_last <= sio_last(0);
	so_end  <= sio_end(0);
end;
