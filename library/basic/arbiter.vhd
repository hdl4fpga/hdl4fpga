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

library hdl4fpga;
use hdl4fpga.base.all;

entity arbiter is
	generic (
		idle_cycle : boolean := true);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		csc  : in  std_logic := '1';
		req  : in  std_logic_vector;
		swp  : out std_logic;
		gswp : out std_logic;
		idle : out std_logic;
		gnt  : buffer std_logic_vector);
end;

architecture mix of arbiter is

	function primask (
		constant arg : std_logic_vector )
		return std_logic_vector is
		variable retval : std_logic_vector(arg'range);
	begin
		retval := (others => '0');
		for i in arg'range loop
			if arg(i)='1' then
				retval(i) := '1';
				return retval;
			end if;
		end loop;
		return (arg'range => '0');
	end;

	signal gntq : std_logic_vector(gnt'range) := (others => '0');

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if ena='1' then
				if gntq=(gntq'range => '0') then
					gntq <= req and (gnt'range => csc);
				else
					gntq <= gnt;
				end if;
			end if;
		end if;
	end process;

	assert req'length=gnt'length
	severity failure;

	gnt <=
		primask(multiplex((req and gntq) & (req and (gnt'range => csc)), setif((gntq'range => '0')=gntq))) when idle_cycle else
		primask(multiplex((req and gntq) & (req and (gnt'range => csc)), setif((gntq'range => '0')=(gntq and req))));

	swp  <= setif(gntq/=gnt);
	gswp <= setif(gntq/=gnt and gntq/=(gntq'range => '0') and gnt/=(gnt'range => '0'));
	idle <= setif(gnt=(gnt'range => '0'));

end;

