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

entity scopeio_iterator is
	generic (
		signed_number : boolean := false);
	port (
		clk   : in  std_logic;
		init  : in  std_logic;
		ena   : in  std_logic;
		start : in  std_logic_vector;
		stop  : in  std_logic_vector;
		step  : in  std_logic_vector;
		ended : buffer std_logic;
		value : buffer std_logic_vector);
end;

architecture def of scopeio_iterator is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if init='1' then
				value <= start;
			elsif ena='1' then
				if ended='0' then
					value <= std_logic_vector(unsigned(value) + unsigned(step));
				end if;
			end if;
		end if;
	end process;
	ended <= 
		'0' when signed_number=true  and   signed(value) <   signed(stop) and signed(step) > 0 else
		'0' when signed_number=true  and   signed(value) >   signed(stop) and signed(step) < 0 else
		'0' when signed_number=false and unsigned(value) < unsigned(stop) else
		'1';
end;
