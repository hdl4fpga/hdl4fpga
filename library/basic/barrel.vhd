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

entity barrel is
	generic (
		shift : boolean := FALSE;
		left  : boolean := TRUE);
	port (
		shf : in  std_logic_vector;
		di  : in  std_logic_vector;
		do  : out std_logic_vector);
end;

architecture beh of barrel is
begin
	process (di, shf)
		variable aux :  unsigned(di'length-1 downto 0);
	begin
		aux := unsigned(di);

		for i in shf'range loop
			if shf(i)= '1' then
				if left then
					if shift then
						aux := shift_left (aux, 2**i);
					else
						aux := rotate_left(aux, 2**i);
					end if;
				else
					if shift then
						aux := shift_left(aux,   2**i);
					else
						aux := rotate_right(aux, 2**i);
					end if;
				end if;
			end if;
		end loop;

		do <= std_logic_vector(aux);
	end process;
end;




