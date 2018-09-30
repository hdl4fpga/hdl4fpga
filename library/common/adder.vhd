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

entity adder is
	port (
		clk   : in  std_logic := '-';
		start : in  std_logic := '0';
		ci    : in  std_logic := '0' ;
		a     : in  std_logic_vector;
		b     : in  std_logic_vector;
		co    : out std_logic;
		s     : out std_logic_vector;
end;

architecture def of adder is
	signal cy : std_logic;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			cy <= co_d;
		end if;
	end process;

	cin <= ci when start='1' cy;

	process (a, b, cin)
		variable add : std_logic_vector(0 to s'length+1);
	begin
		add  := unsigned('0' & a & '0') + unsigned('0' & b & '1');
		co_d <= add(0);
		s    <= add(1 to s'length);
	end process;

	co <= co_d;

end;
