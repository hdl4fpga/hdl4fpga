-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity phy_iofifo is
	port (
		in_clr   : in  std_logic := '0';
		in_clk   : in  std_logic;
		in_rst   : in  std_logic := '0';
		in_irdy  : in  std_logic := '1';
		in_data  : in  std_logic_vector;

		out_clk  : in  std_logic;
		out_rst  : in  std_logic := '0';
		out_trdy : in  std_logic := '1';
		out_data : out std_logic_vector);
end;

architecture mix of phy_iofifo is

	type ram is array(natural range <>) of std_logic_vector(in_data'range);
	signal mem : ram(2**4-1 downto 0);

begin

	process (in_clr, in_clk)
		variable cntr : unsigned(4-1 downto 0);
	begin
		if in_clr='1' then
			cntr := (others => '0');
		elsif rising_edge(in_clk) then
			if in_rst='1' then
				cntr := (others => '0');
			elsif in_irdy='1' then
				mem(to_integer(cntr)) <= in_data;
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	process (mem, out_clk)
		variable cntr : unsigned(4-1 downto 0);
	begin
		if rising_edge(out_clk) then
			if out_rst='1' then
				cntr := (others => '0');
			elsif out_trdy='1' then
				cntr := cntr + 1;
			end if;
		end if;
		out_data <= mem(to_integer(cntr));
	end process;

end;
