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

entity arbiter is
	generic (
		idle_cycle : boolean := true);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		csc  : in  std_logic := '1';
		req  : in  std_logic_vector;
		swp  : out std_logic;
		gswp : out std_logic;
		idle : out std_logic;
		gnt  : buffer std_logic_vector);
end;

architecture mix of arbiter is

	function primask (
		constant arg : std_logic_vector )
		return std_logic_vector is
		variable retval : std_logic_vector(arg'range);
	begin
		retval := (others => '0');
		for i in arg'range loop
			if arg(i)='1' then
				retval(i) := '1';
				return retval;
			end if;
		end loop;
		return (arg'range => '0');
	end;

	signal gntq : std_logic_vector(gnt'range) := (others => '0');

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if ena='1' then
				if gntq=(gntq'range => '0') then
					gntq <= req and (gnt'range => csc);
				else
					gntq <= gnt;
				end if;
			end if;
		end if;
	end process;

	assert req'length=gnt'length
	severity failure;

	gnt <=
		primask(multiplex((req and gntq) & (req and (gnt'range => csc)), setif((gntq'range => '0')=gntq))) when idle_cycle else
		primask(multiplex((req and gntq) & (req and (gnt'range => csc)), setif((gntq'range => '0')=(gntq and req))));

	swp  <= setif(gntq/=gnt);
	gswp <= setif(gntq/=gnt and gntq/=(gntq'range => '0') and gnt/=(gnt'range => '0'));
	idle <= setif(gnt=(gnt'range => '0'));

end;
