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

entity crc is
	generic (
		p    : std_logic_vector);
	port (
		clk  : in  std_logic;
		load : in  std_logic;
		data : in  std_logic_vector;
		crc  : out std_logic_vector);
end;

architecture mix of crc is
begin

	process (clk)
		variable aux : unsigned(p'range) := (others => '0');
	begin
		if rising_edge(clk) then
			if load='1' then
				aux := (others => '0');
				aux(data'range) := aux(data'range);
			else
				aux(data'range) := aux(data'range) xor unsigned(data);
			end if;

			for i in data'range loop
				if aux(0)='1' then
					for j in p'range loop
						aux(j) := aux(j) xor p(j);
					end loop;
				end if;
				aux := aux sll 1;
			end loop;
			crc <= std_logic_vector(aux(crc'range));
		end if;
	end process;

end;
