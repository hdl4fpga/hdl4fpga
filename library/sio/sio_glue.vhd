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

entity sio_glue is
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

architecture def of sio_glue is
	signal ci : std_logic;
	signal co : std_logic;
	signal b  : std_logic_vector(si_data'range);
	signal s  : std_logic_vector(si_data'range);
	signal len_frm  : std_logic;
	signal len_data : std_logic_vector(si_data'range);
begin

	addr_e : entity hdl4fpga.adder
	port map (
		ci => ci,
		a  => si_data,
		b  => b,
		s  => len_data,
		co => co);

	process (sio_clk)
		variable cntr : unsigned(0 to 4-1);
	begin
		if rising_edge(sio_clk) then
			if si_frm='0' then
				cntr := (others => '0');
				ci   <= '0';
				len_frm <= '0';
			elsif si_irdy='1' and so_trdy='1' then
				if cntr(0)='0'then
					cntr := cntr + si_data'length;
				elsif len_frm='0' then
					len_frm <= '1';
				end if;
				if cntr(0)='1' then
					cntr := (others => '0');
				end if;
				ci   <= co;
			end if;
		end if;
	end process;

	so_data <= 
		len_data when len_frm='1' else
		si_data;
		

end;
