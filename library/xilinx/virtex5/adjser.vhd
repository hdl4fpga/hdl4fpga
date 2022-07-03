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

entity adjser is
	port (
		clk   : in  std_logic;
		rst   : in  std_logic;
		delay : in std_logic_vector;
		ce    : out std_logic;
		inc   : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of adjser is
begin
	process (clk)
		variable dgtn : unsigned(unsigned_num_bits(delay'length)-1 downto 0);
		variable taps : unsigned(2**dgtn'length-1 downto 0);
		variable acc  : unsigned(taps'range);
		variable cntr : unsigned(delay'length-1 downto 0);
	begin
		if rising_edge(clk) then
			acc := (others => '1');
			acc(cntr'range) := cntr;
			if rst='1' then
				taps := (others => '0');
				dgtn := (others => '0');
				cntr := (others => '1');
			elsif acc(to_integer(dgtn))='0' then
				cntr := cntr + 1;
			else
				acc  := taps xor resize(unsigned(delay), acc'length);
				if acc(to_integer(dgtn))='1' then
					taps(to_integer(dgtn)) := delay(to_integer(dgtn));
					cntr := (others => '0');
					dgtn := dgtn + 1;
				end if;
			end if;
			ce  <= not cntr(to_integer(dgtn));
			acc := resize(unsigned(delay), acc'length);
			inc <= acc(to_integer(dgtn));
		end if;
	end process;
end;