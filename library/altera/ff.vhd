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

entity sff is
	port (
		clk : in  std_logic;
		sr  : in  std_logic;
		d   : in  std_logic;
		q   : out std_logic);
end;

library altera;
use altera.altera_primitives_components.all;

architecture intel of sff is
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if sr='1' then
				q <= '0';
			else
				q <= d;
			end if;
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;

entity aff is
	port (
		ar  : in  std_logic;
		clk : in  std_logic;
		ena : in  std_logic := '1';
		d   : in  std_logic;
		q   : out std_logic);
end;

library altera;
use altera.altera_primitives_components.all;

architecture intel of aff is
begin
	process (ar, clk)
	begin
		if ar='1' then
			q <= '0';
		elsif rising_edge(clk) then
			if ena='1' then
				q <= d;
			end if;
		end if;
	end process;
end;
