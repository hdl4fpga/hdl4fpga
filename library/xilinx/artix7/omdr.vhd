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
	port (
		rst : in  std_logic;
		clk : in  std_logic_vector;
		t   : in  std_logic_vector;
		tq  : out std_logic_vector;
		d   : in  std_logic_vector;
		q   : out std_logic_vector);
end;

library unisim;
use unisim.vcomponents.all;

architecture beh of omdr is
	constant gear : natural := d'length/q'length;

	signal sqo  : std_logic_vector(0 to q'length-1);
	signal sto : std_logic_vector(0 to t'length-1);
begin

	reg_g : for i in q'range generate
		signal si : std_logic_vector(0 to 8-1);
	begin
		process (d)
			variable aux : std_logic_vector(0 to d'length-1);
		begin
			aux := d;
			si <= (others => '-');
			for j in aux'range loop
				si(j) <= aux(gear*i+j);
			end loop;
		end process;

		ser_i : oserdese2
		port map (
			rst      => rst,
			clk      => clk(0),
			clkdiv   => clk(1),
			d1       => si(0),
			d2       => si(1),
			d3       => si(2),
			d4       => si(3),
			d5       => si(4),
			d6       => si(5),
			d7       => si(6),
			d8       => si(7),
			oq       => sqo(i),

			t1       => '0',
			t2       => '0',
			t3       => '0',
			t4       => '0',
			tq       => sto(i)
			oce      => '1',
			shiftin1 => '0',
			shiftin2 => '0',
			tce      => '1',
			tbytein  => '0');
	end generate;
	q <= sqo;

end;
