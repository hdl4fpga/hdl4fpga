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

entity tmds_encoder is
	generic (
		n       : natural := 8);
	port (
		clk     : in  std_logic;
		c       : in  std_logic_vector(2+n-1 downto 0);
		de      : in  std_logic;
		data    : in  std_logic_vector(  n-1 downto 0);
		encoded : out std_logic_vector(2+n-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of tmds_encoder is
begin

	process (clk)
		variable cnt : unsigned(unsigned_num_bits(data'length)-1 downto 0);
		variable n10 : unsigned(cnt'range);
		variable q_m : std_logic_vector(encoded'range);
	begin
		if rising_edge(clk) then
    		n10 := (others => '0');
    		for i in data'range loop
    			if data(i)='1' then 
    				n10 := n10 + 1;
    			end if;
    		end loop;

    		q_m := (others => '0');
    		q_m(0) := data(0);
    		for i in 1 to data'length-1 loop
				if n10 > 4 or (n10=4 and data(0)='0') then
					q_m(i) := q_m(i-1) xnor data(i);
					q_m(data'length) := '0';
				else
					q_m(i) := q_m(i-1) xor data(i);
					q_m(data'length) := '1';
				end if;
    		end loop;

    		n10 := (others => '0');
    		for i in data'range loop
    			if q_m(i)='1' then 
    				n10 := n10 + 1;
    			end if;
    		end loop;
    		n10 := n10 - 4;

    		if de='1' then
				cnt := (others => '0');
    			q_m := c;
    		else
    			if cnt=0 or n10=0 then
    				if q_m(8) ='1' then
    					cnt := cnt + resize(n10, cnt'length);
						q_m := "01" &     q_m(data'range);
					else
    					cnt := cnt - resize(n10, cnt'length);
						q_m := "10" & not q_m(data'range);
    				end if;
    			elsif ((cnt(3), n10(3))=unsigned'("00")) or ((cnt(3), n10(3))=unsigned'("11")) then
    				cnt := cnt - resize(n10, cnt'length);
    				if q_m(8)='1' then
    					cnt := cnt + 1;
    				end if;
					q_m := "1" & q_m(8) & not q_m(data'range);
    			else
    				cnt := cnt + resize(n10, cnt'length);
    				if q_m(8)='0' then
    					cnt := cnt - 1;
    				end if;
					q_m := "0" & q_m(8) &     q_m(data'range);
    			end if;
			end if;
			encoded <= q_m;
		end if;
	end process;
end;
