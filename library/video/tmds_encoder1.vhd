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

entity tmds_encoder1 is
	port (
		clk     : in  std_logic;
		c       : in  std_logic_vector( 2-1 downto 0);
		blank   : in  std_logic;
		data    : in  std_logic_vector( 8-1 downto 0);
		encoded : out std_logic_vector(10-1 downto 0));
end;

architecture def of tmds_encoder1 is
begin

	process (data, blank)
		variable cnt : unsigned(5-1 downto 0);
		variable acc : unsigned(4-1 downto 0);
		variable q_m : unsigned(encoded'range);
	begin
		acc := (others => '0');
		for i in data'range loop
			if data(i)='1' then 
				acc := acc + 1;
			end if;
		end loop;

		q_m := (others => '0');
		for i in data'range loop
			q_m(i+1) := q_m(i) xor data(i);
		end loop;

		if acc > 4 or (acc=4 and data(0)='0') then
			q_m := q_m xor (q_m'range => '1');
		end if;
		q_m := shift_right(q_m, 1);

		acc := (others => '0');
		for i in data'range loop
			if q_m(i)='1' then 
				acc := acc + 1;
			end if;
		end loop;
		acc := acc - 4;

		if blank='1' then
		else
			if cnt=0 then
				encoded <= std_logic_vector(not q_m(8) & q_m(8) & (q_m(data'range) xor (data'range => q_m(8))));
				if q_m(8) ='1' then
					cnt := 0 + resize(acc, cnt'length);
				else
					cnt := 0 - resize(acc, cnt'length);
				end if;
			elsif acc=0 then
				encoded <= std_logic_vector(not q_m(8) & q_m(8) & (q_m(data'range) xor (data'range => q_m(8))));
			else
			end if;
		end if;
		
	end process;
end;