--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity ffdasync is
	generic (
		n : natural := 1);
	port (
		arst : in std_logic := '0';
		srst : in std_logic := '0';
		clk  : in  std_logic;
		d    : in  std_logic_vector(0 to n-1);
		q    : out std_logic_vector(0 to n-1));
end;

architecture arch of ffdasync is
begin
	g : for i in d'range generate
		process (arst, clk)
			variable shr : std_logic_vector(0 to 1);
		begin
			if arst='1' then
				shr(1) := '0';
			elsif rising_edge(clk) then
				if srst='1' then
					q(i) <= '0';
					shr := (others => '0');
			else
				q(i) <= shr(0);
				shr := shr(1 to 1) & d(i);
				end if;
			end if;
		end process;
	end generate;
end;
