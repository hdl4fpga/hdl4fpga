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

	signal gntd : std_logic_vector(gnt'range) := (others => '0');

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if ena='1' then
				gntd <= gnt;
			end if;
		end if;
	end process;

	assert req'length=gnt'length
	severity failure;

	gnt <= 
		primask(word2byte((req and gntd) & req, setif((gntd'range => '0')=gntd))) and (gnt'range => csc) when idle_cycle else
		primask(word2byte((req and gntd) & req, setif((gntd'range => '0')=(gntd and req)))) and (gnt'range => csc);

	swp  <= setif(gntd/=gnt);
	gswp <= setif(gntd/=gnt and gntd/=(gntd'range => '0') and gnt/=(gnt'range => '0'));
	idle <= setif(gnt=(gnt'range => '0'));

end;
