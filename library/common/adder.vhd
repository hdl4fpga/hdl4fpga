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
		clk : in  std_logic := '-';
		ini : in  std_logic := '1';
		ci  : in  std_logic := '0' ;
		a   : in  std_logic_vector;
		b   : in  std_logic_vector;
		co  : out std_logic;
		s   : out std_logic_vector);
end;

architecture def of adder is
	signal cy_q : std_logic;
	signal cy_d : std_logic;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			cy_q <= cy_d;
		end if;
	end process;

	process (a, b, ci)
		variable add : unsigned(0 to s'length+1);
	begin
		add(0) := '0';
		add := add rol 1;

		add(0 to a'length-1) := unsigned(a);
		add := add rol a'length;

		add(0) := (cy_q and ini) or (cy_q and not ini);

		add  := add + unsigned('0' & b & '1');
		cy_d <= add(0);
		add  := add rol 1;
		s    <= std_logic_vector(add(0 to s'length-1));
	end process;

	co <= cy_d;

end;
