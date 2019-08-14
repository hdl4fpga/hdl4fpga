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

entity scopeio_write is
	port (
		clk        : in  std_logic;
		bcd_frm    : in  std_logic;
		bcd_irdy   : in  std_logic;
		bcd_trdy   : buffer std_logic := '1';
		bcd_di     : in  std_logic_vector;
		ascii_frm  : in  std_logic;
		ascii_irdy : in  std_logic;
		ascii_trdy : buffer std_logic := '1';
		ascii_di   : in  std_logic_vector;
		cga_we     : out std_logic;
		cga_addr   : buffer std_logic_vector;
		cga_do     : out std_logic_vector);
end;
		
architecture mix of scopeio_write is
begin
	cga_we <= bcd_irdy or ascii_irdy;
	process (clk)
	begin
		if rising_edge(clk) then
			if bcd_irdy='1' then
				if bcd_trdy='1' then
					cga_addr <= std_logic_vector(unsigned(cga_addr) + 1);
				end if;
			end if;
		end if;
	end process;
	cga_do <= 
		 word2byte(to_ascii("0123456789 .+-"), bcd_di, ascii'length) when bcd_frm='1' else
		 ascii_di when ascii_frm='1' else
		 (cga_do'range => '-');
end;
