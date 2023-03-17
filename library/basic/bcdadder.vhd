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

entity bcdadder is
	port (
		clk : in  std_logic := '-';
		ini : in  std_logic := '1';
		ci  : in  std_logic := '0' ;
		a   : in  std_logic_vector;
		b   : in  std_logic_vector;
		co  : out std_logic;
		s   : out std_logic_vector);
end;

architecture def of bcdadder is
	signal cy_q : std_logic;
	signal cy_d : std_logic;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			cy_q <= cy_d;
		end if;
	end process;

	process (ini, ci, a, b, cy_q)
		variable op1 : unsigned(a'length-1 downto 0);
		variable op2 : unsigned(b'length-1 downto 0);
		variable add : unsigned(s'length-1 downto 0);
		variable bcd : unsigned(0 to 4+1);
	begin

		bcd := (1 to 5 => '0') & ((cy_q and not ini) or (ci and ini));
		op1 := unsigned(a);
		op2 := unsigned(b);
		add := (others => '0');

		for i in 0 to s'length/4-1 loop
			bcd := ('0' & op1(4-1 downto 0) & bcd(0));
			bcd := ('0' & op2(4-1 downto 0) & '1') + bcd;
			if bcd(1 to 4) > 9 then
				bcd := bcd + (2*6+1);
			end if;
			add(4-1 downto 0) := bcd(1 to 4);
			op1 := op1 ror 4;
			op2 := op2 ror 4;
			add := add ror 4;
		end loop;

		cy_d <= bcd(0);
		s    <= std_logic_vector(add);
	end process;

	co <= cy_d;

end;
