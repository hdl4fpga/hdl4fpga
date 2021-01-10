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

entity so_data is
	port (
		sio_clk  : in  std_logic;
		si_frm   : in  std_logic;
		si_irdy  : in  std_logic;
		si_trdy  : out std_logic;
		si_data  : in  std_logic_vector;

		so_frm   : out std_logic;
		so_irdy  : buffer std_logic;
		so_trdy  : in  std_logic;
		so_length : in std_logic_vector;
		so_data  : out std_logic_vector);
end;

architecture def of so_data is

	signal ser_irdy : std_logic;
	signal ser_trdy : std_logic;
	signal ser_data : std_logic_vector(so_data'range);

	signal cntr  : unsigned(0 to 8);

begin

	desser_e : entity hdl4fpga.desser
	port map (
		desser_clk => sio_clk,

		des_frm    => si_frm,
		des_irdy   => si_irdy,
		des_trdy   => si_trdy,
		des_data   => si_data,

		ser_irdy   => ser_irdy,
		ser_trdy   => ser_trdy,
		ser_data   => ser_data);

	ser_trdy <= so_trdy and not cntr(0);
	process(sio_clk)
		type states is (st_rid, st_len, st_data);
		variable state : states;
	begin
		if rising_edge(sio_clk) then
			if so_trdy='1' or to_stdulogic(to_bit(so_irdy))='0' then
				if si_frm='0' then
					cntr <= (others => '0');
				else
					case state is
					when st_rid =>
						so_data <= x"ff";
						so_irdy <= '1';
						state := st_len;
					when st_len =>
						so_data <= so_length(8-1 downto 0);
						so_irdy <= '1';
						cntr  <= resize(unsigned(so_length(8-1 downto 0)), cntr'length);
						state := st_data;
					when st_data =>
						so_irdy <= ser_irdy;
						so_data <= ser_data;
						if ser_irdy='1' then
							if cntr(0)='0' then
								cntr <= cntr - 1;
							end if;
						end if;
					end case;
				end if;
				so_frm <= to_stdulogic(to_bit(si_frm));
			end if;
		end if;
	end process;


end;
