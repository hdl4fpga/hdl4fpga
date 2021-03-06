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

entity imdr is
	generic (
		SIZE : natural;
		GEAR : natural);
	port (
		rst  : in  std_logic := '0';
		clk  : in  std_logic_vector(0 to 5-1);
		d    : in  std_logic_vector(0 to SIZE-1);
		q    : out std_logic_vector(0 to SIZE*GEAR-1));
end;

library unisim;
use unisim.vcomponents.all;

architecture beh of imdr is
begin

	reg_g : for i in d'range generate
		signal po : std_logic_vector(0 to 4-1);
	begin

		gear1_g : if GEAR=1 generate
			ffd_i : fdrse
			port map (
				c  => clk(0),
				ce => '1',
				s  => '0',
				r  => '0',
				d  => d(i),
				q  => po(0));

		end generate;

		gear2_g : if GEAR=2 generate
			iddr_i : iddr
			generic map (
				DDR_CLK_EDGE => "SAME_EDGE")
			port map (
				c  => clk(0),
				ce => '1',
				d  => d(i),
				q1 => po(0),
				q2 => po(1));

		end generate;

		iserdese_g : if GEAR=4 generate
			iser_i : iserdese2
			generic map (
				INTERFACE_TYPE => "MEMORY_DDR3",
				DATA_RATE      => "DDR",
				IOBDELAY       => "BOTH")
			port map (
				rst          => rst,
				clk          => clk(2),
				oclk         => clk(1),
				clkdivp      => clk(0),
				oclkb        => clk(3),
				clkb         => clk(4),
				ddly         => d(i),
				q1           => po(3),
				q2           => po(2),
				q3           => po(1),
				q4           => po(0),

				dynclksel    => '0',
				dynclkdivsel => '0',
				bitslip      => '0',
				ce1          => '1',
				ce2          => '1',
				clkdiv       => '0',
				d            => '0',
				ofb          => '0',
				shiftin1     => '0',
				shiftin2     => '0');

		end generate;

		process (po)
		begin
			for j in 0 to GEAR-1 loop
				q(GEAR*i+j) <= po(j);
			end loop;
		end process;

	end generate;

end;
