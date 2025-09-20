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

entity mii_chksum1 is
	generic (
		n      : natural := 16;
		init   : std_logic_vector := (0 to 0 => '0'));
	port (
		clk    : in  std_logic;
		frm    : in  std_logic := '1';
		irdy   : in  std_logic;
		trdy   : out std_logic := '1';
		data   : in  std_logic_vector;
		chksum : buffer std_logic_vector);
end;

architecture beh of mii_chksum1 is
begin

	process (frm, irdy, clk)
		variable sum : unsigned(0 to data'length+1);
		variable op1 : unsigned(sum'range);
		variable op2 : unsigned(sum'range);
		variable acc : unsigned(0 to n-1);
		variable cy  : std_logic;

		variable active : std_logic;
	begin
		if rising_edge(clk) then
			if ((active or frm) and irdy)='1' then
				acc := rotate_right(acc, data'length);
				op1 := unsigned'('0' & acc(0 to data'length-1) & '1');
				op2 := unsigned'('0' & unsigned(data) & cy);
				sum := op1 + op2;
				acc(0 to data'length-1) := sum(1 to data'length);
				cy  := sum(0);
			end if;
			if frm='0' then
				if irdy='0' then
					active := '0';
				elsif active='1' then
					active := '0';
				end if;
			elsif irdy='1' then
				active := '1';
			end if;
			if active='0' then
				acc := unsigned(chksum1(init,n));
				cy  := '0';
			end if;
			chksum <= reverse(std_logic_vector(acc(0 to chksum'length-1)));
		end if;
		trdy <= (frm or active) and irdy;
	end process;

end;
