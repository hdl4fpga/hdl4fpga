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

entity lfsr_gen is
	generic (
		g : std_logic_vector);
	port (
		clk : in  std_logic;
		rst : in  std_logic;
		req : in  std_logic;
		so  : out std_logic_vector);
end;

architecture beh of lfsr_gen is

begin
	process(clk)
		variable s  : unsigned(g'range);
		variable q  : std_logic;
		variable s1 : std_logic;
		variable s2 : std_logic;
		variable aux : unsigned(8 downto 1);
	begin

		if rising_edge(clk) then
			if rst='1' then
				s  := (others => '1');
			elsif req='1' then
				s2 := '0';
				for i in g'range loop
					s1   := s(i);
					s(i) := s2 xor (s(s'right) and g(i));
					s2   := s1;
				end loop;
			end if;
			so <= std_logic_vector(s);
		end if;
	end process;
end;
