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

entity bcd_adder is
	port (
		ci  : in  std_logic := '0' ;
		a   : in  std_logic_vector;
		b   : in  std_logic_vector;
		co  : out std_logic;
		s   : out std_logic_vector);

	constant bcd_length : natural := 4;
end;

architecture def of bcd_adder is
	subtype digit_vector is unsigned(bcd_length*((s'length+bcd_length-1)/bcd_length)-1 downto 0);
begin

	process (a, b)
		variable opa  : unsigned(0 to a'length-1);
		variable opb  : unsigned(0 to b'length-1);
		variable ops  : unsigned(0 to s'length-1);

		variable sum  : unsigned(0 to bcd_length+1);
		variable sum6 : unsigned(0 to bcd_length);
		variable op1  : unsigned(sum'range);
		variable op2  : unsigned(sum'range);
		variable cy   : std_logic;
	begin
		opa  := unsigned(a);
		opb  := unsigned(b);

		for i in 0 to s'length/bcd_length-1 loop
    		opa  := rotate_right(opa, bcd_length);
    		opb  := rotate_right(opb, bcd_length);
    		op1  := resize(unsigned(opa(0 to bcd_length-1) & '1'), op1'length);
    		op2  := resize(unsigned(opa(0 to bcd_length-1) &  cy), op2'length);
    		sum  := op1 + op2;
    		sum6 := sum(sum6'range) + 6;
    		if sum6 >= 16 then
    			sum6 := rotate_left(sum6, 1);
				cy   := '1';
    		else
    			sum  := rotate_left(sum,  1);
				cy   := '0';
    		end if;

    		ops := shift_right(ops, bcd_length);
    		ops := sum(0 to bcd_length-1);
    		opa(0 to bcd_length-1) := (others => '0');
    		opb(0 to bcd_length-1) := (others => '0');
		end loop;
	end process;

end;
