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
		debug : boolean := false);
    port (
		g    : in  std_logic_vector;
        clk  : in  std_logic;
		init : in  std_logic;
		sero : in  std_logic := '0';
		ena  : in  std_logic;
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
			if init='1' then
				crc <= (crc'range => '0');
			elsif ena='1' then
				if sero='1' then
					crc <= std_logic_vector(unsigned(crc) rol data'length);
				else
					crc  <= not galois_crc(data, not crc, g);
					if debug then
						crc <= x"7e7d";
					end if;
				end if;
			end if;
		end if;
	end process;

end;

