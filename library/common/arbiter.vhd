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
		clk : in  std_logic;
		req : in  std_logic_vector;
		rdy : out std_logic_vector;
		did : out std_logic_vector);
end;

architecture beh of arbiter is
begin

	process(clk, rdy, req)
		variable id : unsigned(did'range);
	begin
		if rising_edge(clk) then
			if id=(id'range => '0') then
				for i in req'range loop
					if rdy(i)/='0' then
						id := std_logic_vector(to_unsigned(i, id'length));
						exit;
					end if;
				end loop;
			else
				if req(to_integer(id))='0' then
					id := (others => '0');
				end if;
			end if;
		end if;
		if rdy=(rdy'range => '1') then
			did := (others => '0');
		else
			did <= std_logic_vector(id);
		end if;
	end process;

end;
