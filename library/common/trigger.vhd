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

entity schmitt_trigger is
	port (
		clk : in std_logic;
		tl  : in std_logic_vector;
		th  : in std_logic_vector;
		xin : in std_logic_vector;
		stt : out std_logic);
end;

architecture def of schmitt_trigger is
	signal edge : boolean;
begin
	assert tl'length=th'length and th'length=xin'length
		report "Size missmatch"
		severity ERROR;
		
	process(clk)
	begin
		if rising_edge(clk) then
			if not edge then
				if to_integer(unsigned(xin)) >= to_integer(unsigned(th)) then
					edge <= true;
				end if;
			else
				if to_integer(unsigned(xin)) <= to_integer(unsigned(tl)) then
					edge <= false;
				end if;
			end if;
		end if;
	end process;
	stt <= '1' when edge else '0';
end;
