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
		sio_clk   : in  std_logic;
		si_frm    : in  std_logic;
		si_irdy   : in  std_logic;
		si_trdy   : out std_logic;
		si_length : in  std_logic_vector;
		si_end    : buffer std_logic;
		si_data   : in  std_logic_vector;

		so_frm    : buffer std_logic;
		so_irdy   : buffer std_logic;
		so_trdy   : in  std_logic;
		so_end    : out std_logic;
		so_data   : out std_logic_vector);
end;

architecture def of so_data is

	signal ser_irdy  : std_logic;
	signal ser_trdy  : std_logic;
	signal ser_data  : std_logic_vector(so_data'range);
	signal low_cntr  : unsigned(0 to 8);
	signal high_cntr : unsigned(0 to setif(si_length'length > 8, si_length'length - 8, 0));

	type states is (st_idle, st_rid, st_len, st_data);
	signal state : states;

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

	process(sio_clk)
	begin
		if rising_edge(sio_clk) then
			case state is
			when st_idle =>
				low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
				high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
				if si_frm='1' then
					state <= st_rid;
				else
					state <= st_idle;
				end if;
			when st_rid  =>
				if si_frm='1' then
					state <= st_len;
				else
					low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
					high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
					state <= st_idle;
				end if;
			when st_len =>
				high_cntr <= high_cntr - 1;
				low_cntr  <= low_cntr  - 1;
				if si_frm='1' then
					state <= st_data;
				else
					low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
					high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
					state <= st_idle;
				end if;
			when st_data =>
				if si_frm='1' then
					if ser_irdy='1' then
						if low_cntr(0)='0' then
							low_cntr <= low_cntr - 1;
							state  <= st_data;
						elsif high_cntr(0)='0' then
							low_cntr <= '0' & (1 to 8 => '1');
							state  <= st_rid;
						end if;
					end if;
				else
					low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
					high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
					state <= st_idle;
				end if;
			end case;
		end if;
	end process;

	si_end   <= 
		'0' when state=st_idle else 
		si_frm and high_cntr(0) and low_cntr(0);

	ser_trdy <= so_trdy when state=st_data else '0';

	so_frm   <= to_stdulogic(to_bit(si_frm));
	so_irdy  <= 
		'0' when state=st_idle else
		ser_irdy when state=st_data else
		'1';
	with state select
	so_data <= 
		x"ff"     when st_idle | st_rid,
		std_logic_vector(resize(low_cntr, so_data'length)) when st_len,
		std_logic_vector(resize(low_cntr, so_data'length)) when st_data;
--		ser_data  when st_data;
	so_end <= si_end;

end;
