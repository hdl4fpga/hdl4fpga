--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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