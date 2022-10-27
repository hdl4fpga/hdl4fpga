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
use hdl4fpga.base.all;

entity cntrcs is
	generic (
		slices  : natural_vector);
	port (
		clk  : in  std_logic;
		load : in  std_logic := '0';
		ena  : in  std_logic := '1';
		updn : in  std_logic := '0';
		d    : in  std_logic_vector;
		q    : out std_logic_vector;
		eoc  : out std_logic_vector);
end;

architecture def of cntrcs is

--	alias aliasd : std_logic_vector(d'length-1 downto 0) is d;
--	alias aliasq : std_logic_vector(q'length-1 downto 0) is q;

	signal aliasd : std_logic_vector(d'length-1 downto 0); -- Workaround Lattice Diamond 3.11 cannot deal with VHDL alias
	signal aliasq : std_logic_vector(q'length-1 downto 0); -- Workaround Lattice Diamond 3.11 cannot deal with VHDL alias

	signal cntr1 : unsigned(q'length+slices'length-1 downto 0);

begin

	aliasd <= d; -- Workaround Lattice Diamond 3.11 cannot deal with VHDL alias
	cntr_p : process (clk)

		variable cntr  : unsigned(q'length+slices'length-1 downto 0);
		variable cy    : std_logic;

		variable left   : natural;
		variable right  : natural;
		variable left1  : natural;
		variable right1 : natural;

	begin
		if rising_edge(clk) then
			cy    := '1';
			right  := 0;
			right1 := 0;
			for i in slices'range loop
				left  := right  + slices(i)-1;
				left1 := right1 + slices(i);

				if load='1' then
					cntr(left1 downto right1) := '0' & unsigned(aliasd(left downto right));

					if i/=slices'left then
						if updn='0' then
							cntr1(left1 downto right1) <= cntr(left1 downto right1) + 1;
						else
							cntr1(left1 downto right1) <= cntr(left1 downto right1) - 1;
						end if;
					end if;

					eoc(i) <= '0';

				elsif ena='1' then
					if i=slices'left then
						if updn='0' then
							cntr(left1 downto right1)  := cntr(left1 downto right1) + 1;
						else
							cntr(left1 downto right1)  := cntr(left1 downto right1) - 1;
						end if;
					else
						if updn='0' then
							cntr1(left1 downto right1) <= cntr(left1 downto right1) + 1;
						else
							cntr1(left1 downto right1) <= cntr(left1 downto right1) - 1;
						end if;
					end if;

					if i=slices'left then
						cy := cntr(left1);
					else
						if cy='1' then
							cntr(left1 downto right1) := cntr1(left1 downto right1);
							cy := cntr(left1);
						end if;
					end if;
					eoc(i) <= cy;

					cntr(left1) := '0';
				end if;

				aliasq(left downto right) <= std_logic_vector(cntr(left1-1 downto right1));
				right  := left+1;
				right1 := left1+1;
			end loop;
		end if;
	end process;
	q <= aliasq; -- Workaround Lattice Diamond 3.11 cannot deal with VHDL alias

end;
