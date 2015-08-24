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
use ieee.numeric_std.all;

entity dpram is
	port (
		rd_clk  : in std_logic;
		rd_ena  : in std_logic := '1';
		rd_addr : in std_logic_vector;
		rd_data : out std_logic_vector;

		wr_clk  : in std_logic := '-';
		wr_ena  : in std_logic := '0';
		wr_addr : in std_logic_vector;
		wr_data : in std_logic_vector);
end;

architecture def of dpram is
	type word_vector is array (natural range <>) of std_logic_vector(wr_data'range);

	signal RAM : word_vector(0 to 2**rd_addr'length-1);
begin
	process (rd_clk)
	begin
		if rising_edge(rd_clk) then
			if rd_ena='1' then
				rd_data <= ram(to_integer(unsigned(rd_addr)));
			end if;
		end if;
	end process;
	
	process (wr_clk)
	begin
		if rising_edge(wr_clk) then
			if wr_ena='1' then
				ram(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
		end if;
	end process;
end;
