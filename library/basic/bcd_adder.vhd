-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_adder is
	port (
		ci  : in  std_logic := '0' ;
		a   : in  std_logic_vector;-- := std_logic_vector'(0 to 0 => '0'); Latticesemi Diamond bug
		b   : in  std_logic_vector;-- := std_logic_vector'(0 to 0 => '0'); Latticesemi Diamond bug
		s   : out std_logic_vector;
		co  : out std_logic);

	constant bcd_length : natural := 4;
end;

architecture def of bcd_adder is
begin

	assert s'length >= a'length
		report "a'length greater than s'length"
		severity failure;

	assert s'length >= b'length
		report "b'length greater than s'length"
		severity failure;

	process (a, b, ci)
		variable opa  : unsigned(0 to s'length-1);
		variable opb  : unsigned(0 to s'length-1);
		variable ops  : unsigned(0 to s'length-1);

		variable sum  : unsigned(0 to bcd_length+1);
		variable op1  : unsigned(sum'range);
		variable op2  : unsigned(sum'range);
		variable sum6 : unsigned(0 to bcd_length);
		variable cy   : std_logic;
	begin
		opa  := resize(unsigned(a), s'length);
		opb  := resize(unsigned(b), s'length);
		cy   := ci;

		for i in 0 to s'length/bcd_length-1 loop
    		opa  := rotate_right(opa, bcd_length);
    		opb  := rotate_right(opb, bcd_length);
    		ops  := shift_right(ops, bcd_length);
    		op1  := resize(unsigned(opa(0 to bcd_length-1) & '1'), op1'length);
    		op2  := resize(unsigned(opb(0 to bcd_length-1) &  cy), op2'length);
    		sum  := op1 + op2;
    		sum6 := sum(sum6'range) + 6;

    		sum  := rotate_left(sum, 1);
			cy   := '0';
			ops(0 to bcd_length-1) := sum(0 to bcd_length-1);
    		if sum6 >= 16 then
    			sum6 := rotate_left(sum6, 1);
				ops(0 to bcd_length-1) := sum6(0 to bcd_length-1);
				cy   := '1';
    		end if;

    		opa(0 to bcd_length-1) := (others => '0');
    		opb(0 to bcd_length-1) := (others => '0');
		end loop;
		s  <= std_logic_vector(ops);
		co <= cy;
	end process;

end;
