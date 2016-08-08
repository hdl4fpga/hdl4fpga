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

library hdl4fpga;
use hdl4fpga.std.all;

entity align is
	generic (
		n : natural := 1;
		d : natural_vector);
	port (
		clk : in  std_logic;
		ena : in  std_logic := '1';
		di  : in  std_logic_vector(0 to n-1);
		do  : out std_logic_vector(0 to n-1));
end;

architecture arch of align is
	constant dly : natural_vector(0 to d'length-1) := d;
begin
	delay: for i in 0 to n-1 generate
		signal q : std_logic_vector(0 to dly(i));
	begin
		q(q'right) <= di(i);
		process (clk)
		begin
			if rising_edge(clk) then
				if ena='1' then
					if dly(i) > 0 then
						q(0 to q'right-1) <= q(1 to q'right);
					end if;
				end if;
			end if;
		end process;
		do(i) <= q(0);
	end generate;
end;
