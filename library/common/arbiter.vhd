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

entity arbiter is
	port (
		clk     : in  std_logic;
		bus_req : in  std_logic_vector;
		bus_gnt : buffer std_logic_vector);
end;

architecture mix of arbiter is
	function primask (
		constant arg : std_logic_vector )
		return std_logic_vector is
		variable retval : std_logic_vector(arg'range);
	begin
		retval := (others => '0');
		for i in arg'range loop
			retval(i) := arg(i);
			exit when arg(i)='1';
		end loop;
		return retval;
	end;

	signal gnt  : std_logic_vector(bus_gnt'range);
	signal gnt1 : std_logic_vector(bus_gnt'range);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if gnt=(gnt'range => '0') then
				gnt <= primask(bus_req);
			elsif bus_req=(bus_req'range => '0') then
				gnt <= (others => '0');
			end if;
			gnt1 <= bus_gnt;
		end if;
	end process;

	bus_gnt <= gnt and bus_req;
end;
