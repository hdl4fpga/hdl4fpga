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

entity lfsr_gen is
	port (
		clk : in  std_logic;
		rst : in  std_logic;
		req : in  std_logic;
		so  : out std_logic_vector);
end;

architecture beh of lfsr_gen is

begin
	process(clk)
		variable g  : std_logic_vector(so'length downto 1);
		variable s  : std_logic_vector(g'range);
		variable q  : std_logic;
		variable s1 : std_logic;
		variable s2 : std_logic;
	begin

		case g'length is
		when 32 =>
			g := ( 32 => '1',  30 => '1',  26 => '1',  25 => '1', others => '0');
		when 64 =>                                     
			g := ( 64 => '1',  63 => '1',  61 => '1',  60 => '1', others => '0');
		when 128 =>
			g := (128 => '1', 127 => '1', 126 => '1', 121 => '1', others => '0');
		when others =>
			g := (others => '-');
		end case;

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
			so <= s;
		end if;
	end process;
end;
