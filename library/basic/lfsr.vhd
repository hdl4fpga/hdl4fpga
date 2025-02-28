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

entity lfsr is
	generic (
		g    : std_logic_vector);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		init : in  std_logic_vector(g'range) := (g'range => '1');
		load : in  std_logic;
		data : out std_logic_vector(g'range));
end;

architecture beh of lfsr is
begin
	process(clk)
		variable s  : unsigned(g'range);
		variable q  : std_logic;
		variable s1 : std_logic;
		variable s2 : std_logic;
	begin

		if rising_edge(clk) then
			if load='1' then
				s  := unsigned(init);
			elsif ena='1' then
				s2 := '0';
				for i in g'range loop
					s1   := s(i);
					s(i) := s2 xor (s(s'right) and g(i));
					s2   := s1;
				end loop;
			end if;
			data <= std_logic_vector(s);
		end if;
	end process;
end;



