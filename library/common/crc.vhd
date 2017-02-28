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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity test is
end;

architecture mix of test is
	subtype  word is unsigned(0 to 4-1);
	signal   data : word;
	signal   crc  : unsigned(0 to 8-1);
	constant p    : unsigned(0 to 8)   := b"100000111";
	signal clk : std_logic := '0';
	signal rst : std_logic :='1';
begin
	process (clk)
		variable msg : line;
		variable aux : unsigned(p'range) := (others => '0');
	begin
		if rising_edge(clk) then
			if rst='1' then
				aux := (others => '0');
			else
				aux(data'range) := aux(data'range) xor data;
				for i in data'range loop
					if aux(0)='1' then
						for j in p'range loop
							aux(j) := aux(j) xor p(j);
						end loop;
					end if;
					aux  := aux  sll 1;
				end loop;
			end if;
			crc <= aux(crc'range);
		end if;
	end process;

	process (clk)
		variable msg : line;
		variable kkk : unsigned(0 to 8-1) := b"01010111";
		variable cnt : natural := 0;
	begin
		if cnt < 4 then
			clk <= not clk after 1 ns;
		end if;
		if rising_edge(clk) then
			case cnt is
			when 0 =>
				rst <= '0';
				data <= kkk(data'range);
				kkk  := kkk sll data'length;
			when 1|2 =>
				rst <= '0';
				data <= kkk(data'range);
				kkk  := kkk sll data'length;
			when others =>
				write (msg, std_logic_vector(crc(crc'range)));
				writeline (output, msg);
			end case;
			cnt := cnt + 1;
		end if;
	end process;
end;
