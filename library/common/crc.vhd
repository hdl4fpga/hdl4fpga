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

entity crc is
	generic (
		g    : std_logic_vector);
    port (
        clk  : in  std_logic;
		frm  : in  std_logic;
		dv   : in  std_logic;
		data : in  std_logic_vector;
		crc  : buffer std_logic_vector);
end;

architecture def of crc is

begin

	assert g'length mod data'length=0
	report "Length of g should be a multiplo of data'length"
	severity FAILURE;

	process (clk)
	begin
		if rising_edge(clk) then
			if frm='1' then
				if dv='1' then
					crc  <= not galois_crc(data, not crc, g);
				end if;
			else
				crc <= (crc'range => '0');
			end if;
		end if;
	end process;

end;

