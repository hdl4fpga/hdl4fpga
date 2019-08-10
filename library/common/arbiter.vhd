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
		clk      : in  std_logic;
		bus_req  : in  std_logic_vector;
		bus_gnt  : out std_logic_vector;
		bus_busy : out std_logic;
		dev_id   : out std_logic_vector);
end;

architecture mix of arbiter is
	alias  req : std_logic_vector(1 to bus_req'length) is bus_req;
	signal gnt : std_logic_vector(1 to bus_gnt'length);
begin

	process(clk)
		variable id : unsigned(dev_id'range);
	begin
		if rising_edge(clk) then
			if id=(id'range => '0')then
				for i in req'range loop
					if req(i)/='0' then
						id     := to_unsigned(i, id'length);
						gnt(i) <= req(i);
						exit;
					end if;
				end loop;
			elsif req(to_integer(id))='0' then
				id  := (others => '0');
				gnt <= (gnt'range => '0');
				for i in req'range loop
					if req(i)/='0' then
						id     := to_unsigned(i, id'length);
						gnt(i) <= req(i);
						exit;
					end if;
				end loop;
			end if;
			dev_id <= std_logic_vector(id);
		end if;
	end process;

	bus_gnt  <= gnt and req;
	bus_busy <= setif(bus_req/=(bus_req'range => '0'));

end;
