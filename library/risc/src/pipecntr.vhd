--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

-- Date   : November 2007
-- Author : Miguel Angel Sagreras

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PipeCntr is
	port (
		rst : in  std_ulogic;
		clk : in  std_ulogic;
		ena : in  std_ulogic;
		ldData : in  std_ulogic;
		data   : in  std_ulogic_vector;
		q   : out std_ulogic_vector;
		cy  : out std_ulogic);
end;

architecture Behavioral of PipeCntr is
	signal cnt   : std_ulogic_vector(q'length-1 downto 0);
	signal cntP2 : std_ulogic_vector(q'length downto 1);
begin
	process (rst, clk)

		function "+" (arg1 : std_ulogic_vector; arg2 : integer)
			return std_ulogic_vector is
		begin
			return std_ulogic_vector(UNSIGNED(arg1) + arg2);
		end;

	begin
		if rst='1' then
			cnt   <= (others => '0');
			cntP2 <= (others => '0');
		elsif rising_edge(clk) then
			if ena='1' then
				cntP2 <= '0' & cnt(cnt'left downto cnt'right+1) + 1;
				if ldData = '0' then
					cnt <= cntP2(cntP2'left-1 downto cntP2'right) & not cnt(cnt'right);
				else
					cnt <= data;
				end if;
			end if;
		end if;
	end process;

	q  <= cnt;
	cy <= cntP2(cntP2'left);
end;
