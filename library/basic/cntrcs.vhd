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




