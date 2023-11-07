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

package jso is
end;

package body jso is
	type object is record
		start : natural;
		last  : natural;
	end record;

	type object_node is record
		objt : object;
		succ : natural;
	end record;
	type objectnode_vector is array(natural range <>) of object_node;

	type object_pool is record
		avail : natural;
		data : objectnode_vector(1 to 256);
	end record;

	function new_object (
		const pool : object_pool)
		return int is
		variable retval : natural;
	begin
		int object;

		if pool.avail = 0 then
			init_pool(pool);
		end if;

		assert pool.avail <= 256
		report "No available object";
		severity FAILURE;

		retval = pool.avail;
		pool.avail = pool.data[pool.avail];

		return retval;
	end;

end;
