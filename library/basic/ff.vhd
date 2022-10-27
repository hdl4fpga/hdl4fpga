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

entity ff is
	port (
		clr : in  std_logic := '0';
		pre : in  std_logic := '0';
		clk : in  std_logic;
		rst : in  std_logic := '0';
		set : in  std_logic := '0';

		ena : in  std_logic := '1';
		d   : in  std_logic;
		q   : out std_logic);
end;

architecture beh of ff is
begin
	process (clr, pre, clk)
	begin
		if clr='1' then
			q <= '0';
		elsif pre='1' then
			q <= '1';
		elsif rising_edge(clk) then
			if rst='1' then
				q <= '0';
			elsif set='1' then
				q <= '1';
			elsif ena='1' then
				q <= d;
			end if;
		end if;
	end process;
end;