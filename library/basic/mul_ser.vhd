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

entity mul_ser is
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		load : in  std_logic;
		a    : in  unsigned;
		b    : in  unsigned;
		s    : out unsigned);
end;

architecture def of mul_ser is
begin

	process (clk)
		variable shr : unsigned(s'length-1 downto 0);
		alias acc : unsigned(0 to s'lenght) is s_shr;
	begin
		if rising_edge(clk) then
			if ena='1' then
				if load='1' then
					shr := a & b;
				end if;
				s_shr := shift_right(s_shr);
				if shr(0)='1' then
					acc  := acc + a;
				end if;
				s <= s_shr;
			end if;
		end if;
	end process;

end;