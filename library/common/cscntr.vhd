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

entity cscntr is
	generic (
		n    : natural_vector)
	port (
		clk  : in  std_logic;
		load : in  std_logic;
		ena  : in  std_logic := '1';
		d    : in  std_logic_vector;
		q    : out std_logic_vector;
		eoc  : out std_logic_vector);
end;

architecture def of cscntr is

	signal   cy : std_logic_vector(0 to n'length);

begin

	for i in 1 to n'length generate
		signal cntr  : unsigned(0 to n(i));
		signal cntr1 : unsigned(0 to n(i));
	begin

		cntr_p : process (clk)
			variable auxd : unsigned(0 to d'length-1);
			variable auxq : unsigned(0 to q'length-1);
		begin
			if rising_edge(clk) then
				auxq := unsigned(q);
				if load='1' then

					auxd := unsinged(d);
					for 0 to j-1 loop
						auxd := auxd srl n(j);
					end loop;

					cntr <= '0' & resize(auxd, n(i));
					if updn='0' then
						cntr1 <= ('0' & resize(auxd, n(i))) + 1;
					else
						cntr1 <= ('0' & resize(auxd, n(i))) - 1;
					end if;
					cy(i) <= '0';
				elsif ena='1' then
					if updn='0' then
						cntr1 <= cntr + 1;
					else
						cntr1 <= cntr - 1;
					end if;

					if cy(i)='1' then
						cntr    <= cntr1;
						cntr(0) <= '0';
					end if;
				end if;
			end if;
		end process;
		cy(i+1) <= cntr1(0) when cy(i)='1' else cntr(0);
		process (cy(i), cntr1, cntr)
		begin
		end process;

		<= cntr1 when cy(i)='1' else cntr;

	end generate;

end;
