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

package object_alloc is
	generic (
		type o);

	type pooltab is record
		following : natural;
		available : integer_vector(1 to 256);
	end record;

	procedure new_object (
		variable pool      : inout pooltab;
		variable following : out   natural);
end;

package body object_alloc is

	procedure init_pool (
		variable pool : inout pooltab) is
	begin
		pool.following := 1;
		for i in pool.available'range loop
			pool.available(i) := i+1;
		end loop;
	end;

	procedure new_object (
		variable pool      : inout pooltab;
		variable following : out   natural) is
	begin
		assert pool.following <= 256
		report "No available object"
		severity FAILURE;

		if pool.following=0 then
			init_pool(pool);
		end if;
		following      := pool.following;
		pool.following := pool.available(pool.following);
	end;

end;
