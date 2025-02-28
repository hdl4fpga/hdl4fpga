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

entity rom is
	generic (
		latency : natural := 0;
		bitrom : std_logic_vector);
	port (
		clk  : in  std_logic := '-';
		addr : in  std_logic_vector;
		data : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of rom is

	subtype word is std_logic_vector(data'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	impure function init_rom (
		constant bitdata : std_logic_vector;
		constant memsize : natural)
		return word_vector is

		variable retval : word_vector(0 to memsize-1) := (others => (others => '-'));
		variable aux    : std_logic_vector(0 to memsize*word'length-1) := (others => '-');

	begin
		aux(0 to bitdata'length-1) := bitdata;
		for i in retval'range loop
			retval(i) := aux(word'length*i to word'length*(i+1)-1);
		end loop;

		return retval;
	end;

	constant rom : word_vector(0 to 2**addr'length-1) := init_rom(bitrom, 2**addr'length);

begin


	synchronous1_g : if latency>0 generate
		process (clk)
			variable saddr : std_logic_vector(addr'range);
		begin
			if rising_edge(clk) then
				if latency=1 then
					data <= rom(to_integer(unsigned(addr)));
				else
					data <= rom(to_integer(unsigned(saddr)));
				end if;
				saddr := addr;
			end if;
		end process;
	end generate;

	synchronous0_g : if latency=0 generate
		data <= rom(to_integer(unsigned(addr)));
	end generate;

end;
