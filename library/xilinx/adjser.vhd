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
use ieee.numeric_std.all;

entity adjser is
	generic (
		tap_value : natural := 0);
	port (
		clk   : in  std_logic;
		rst   : in  std_logic;
		delay : in std_logic_vector;
		ce    : buffer std_logic;
		inc   : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture beh of adjser is
begin
	process (clk)
		variable taps : unsigned(delay'length-1 downto 0);
		variable cntr : unsigned(taps'range);
		variable dgtn : unsigned(taps'range);
		variable acc  : unsigned(taps'range);
	begin
		if rising_edge(clk) then
			acc := (unsigned(delay) xor taps) and dgtn;
			if rst='1' then
				taps := to_unsigned(tap_value, delay'length);
				dgtn := (0 => '1', others => '0');
				cntr := (others => '1');
				ce   <= '0';
			elsif (rotate_right(dgtn,1) and cntr)=(delay'range => '0') then
				cntr := cntr + 1;
				ce   <= '1';
			elsif acc/=(delay'range => '0') then
				if (taps and dgtn)=(delay'range => '0') then
					inc <= '1';
				else
					inc <= '0';
				end if;
				taps := taps xor dgtn;
				cntr := to_unsigned(1, cntr'length);
				dgtn := rotate_left(dgtn, 1);
				ce   <= '1';
			else
				cntr := (others => '1');
				dgtn := rotate_left(dgtn, 1);
				ce   <= '0';
			end if;
		end if;
	end process;
