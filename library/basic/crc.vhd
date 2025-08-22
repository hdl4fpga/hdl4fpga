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

entity crc is
	generic (
		debug : boolean := false);
    port (
		g    : in  std_logic_vector;
        clk  : in  std_logic;
		frm  : in  std_logic := '0';
		irdy : in  std_logic := '0';
		trdy : buffer std_logic := '0';
		data : in  std_logic_vector;
		crc  : buffer std_logic_vector);
end;

architecture def of crc is

begin

	assert g'length mod data'length=0
		report "crc () : length of g => " & natural'image(g'length) & " should be multiple of data'length => " & natural'image(data'length)
		severity FAILURE;

	process (frm, clk)
		variable last : std_logic;
	begin
		if rising_edge(clk) then
			if ((last or frm) and irdy and trdy)='1' then
				crc <= not galois_crc(data, not crc, g);
			end if;
			if (frm or irdy)='0' then
				crc <= (crc'range => '0');
			end if;
			if frm='0' then
				if irdy='0' then
					last := '0';
				elsif trdy='1' then
					last := '0';
				end if;
			else
				last := '1';
			end if;
		end if;
		trdy <= frm or last;
	end process;

end;
