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
use hdl4fpga.ipoepkg.all;

entity mii_adjlen is
	generic (
		diff : std_logic_vector);
	port (
		clk     : in  std_logic;
		frm     : in  std_logic;
		irdy    : in  std_logic;
		trdy    : buffer std_logic := '1';
		si_data : in  std_logic_vector;
		so_data : out std_logic_vector);
end;

architecture def of mii_adjlen is
begin
	process (clk)
		variable value  : unsigned(0 to diff'length-1);
		alias  miib is value(0 to si_data'length-1);
		variable cy     : std_logic;
		variable sum    : unsigned(0 to si_data'length+1);
		variable op1    : unsigned(sum'range);
		variable op2    : unsigned(sum'range);
		variable active : std_logic;
	begin
		if rising_edge(clk) then
			if (frm or active)='0' then
				value := unsigned(reverse(diff,8));
				cy    := '0';
			elsif irdy='1' then
				if trdy='1' then
					op1 := unsigned('0' & reverse(si_data) & '1');
					op2 := unsigned('0' & reverse(miib) & cy);
					sum := op1 + op2;
					miib := reverse(sum(1 to si_data'length));
					cy  := sum(0);
					so_data <= std_logic_vector(miib);
					value := rotate_left(value, si_data'length);
					if frm='0' then
						active := '0';
					else
						active := '1';
					end if;
				end if;
			elsif frm='0' then
				value := unsigned(reverse(diff,8));
				cy    := '0';
				active := '0';
			end if;
		end if;
	end process;
end;
