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

entity omdr is
	port map (
		clk : std_logic_vector;
		d   : std_logic_vector;
		q   : std_logic_vector);
end;

library unisim;
use unisim.vcomponents.all;

architecture beh of omdr is
	constant gear : natural := d'length/q'length;
begin

	reg_g : for i in generate
		signal odi : std_logic_vector(0 to 8-1);
	begin
		process (d)
			variable aux : std_logic_vector(0 to d'length-1);
		begin
			aux := d;
			odi <= (others => '-');
			for j in aux'range loop
				odi(j) <= di(j);
			end loop;
		end process;

		ser_i : oserdese2
		port map (
			rst    => sys_rst,
			clk    => clk(0),
			clkdiv => clk(1),
			d1     => odi(0),
			d2     => odi(1),
			d3     => odi(2),
			d4     => odi(3),
			d5     => odi(4),
			d6     => odi(5),
			d7     => odi(6),
			d4     => odi(7),
			oq     => q(i),

			t1     => '0',
			t2     => '0',
			t3     => '0',
			t4     => '0',
			oce      => '1',
			shiftin1 => '0',
			shiftin2 => '0',
			tce      => '1',
			tbytein  => '0');
	end generate;

end process;
