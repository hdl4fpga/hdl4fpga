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

entity dpram is
	port (
		rd_addr : in std_logic_vector;
		rd_data : out std_logic_vector;

		wr_clk  : in std_logic := '-';
		wr_ena  : in std_logic := '1';
		wr_addr : in std_logic_vector;
		wr_data : in std_logic_vector);
end;

architecture def of dpram is
	type word_vector is array (natural range <>) of std_logic_vector(wr_data'range);

	signal RAM : word_vector(0 to 2**wr_addr'length-1);
begin
	process (rd_addr, RAM)
		variable addr : std_logic_vector(0 to rd_addr'length-1);
	begin
		addr := rd_addr;
		if rd_data'length=wr_data'length then
			rd_data <= ram(to_integer(unsigned(rd_addr)));
		else
			rd_data <= word2byte(ram(to_integer(unsigned(addr(0 to wr_addr'length-1)))), addr(wr_addr'length to addr'right));
		end if;
	end process;
		
--	rd_data <= ram(to_integer(unsigned(rd_addr)));
	process (wr_clk)
	begin
		if rising_edge(wr_clk) then
			if wr_ena='1' then
				ram(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
		end if;
	end process;
end;
