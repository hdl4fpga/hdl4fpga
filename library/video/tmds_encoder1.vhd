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

entity tmds_encoder1 is
	port (
		clk     : in  std_logic;
		c       : in  std_logic_vector( 2-1 downto 0);
		de      : in  std_logic;
		data    : in  std_logic_vector( 8-1 downto 0);
		encoded : out std_logic_vector(10-1 downto 0));
end;

architecture def of tmds_encoder1 is
begin

	process (clk)
		variable cnt : unsigned(4-1 downto 0);
		variable n10 : unsigned(4-1 downto 0);
		variable q_m : unsigned(encoded'range);
	begin
		if rising_edge(clk) then
    		n10 := (others => '0');
    		for i in data'range loop
    			if data(i)='1' then 
    				n10 := n10 + 1;
    			end if;
    		end loop;

    		q_m := (others => '0');
    		for i in data'reverse_range loop
    			q_m(i+1) := q_m(i) xor data(i);
    		end loop;
			q_m(9) := '1';

    		if n10 > 4 or (n10=4 and data(0)='0') then
    			q_m := q_m xor (q_m'range => '1');
    		end if;
    		q_m := shift_right(q_m, 1);

    		n10 := (others => '0');
    		for i in data'range loop
    			if q_m(i)='1' then 
    				n10 := n10 + 1;
    			end if;
    		end loop;
    		n10 := n10 - 4;

    		if de='1' then
                case c is            
    			when "00"   => 
    				encoded <= "1101010100";
    			when "01"   => 
    				encoded <= "0010101011";
    			when "10"   => 
    				encoded <= "0101010100";
    			when others => 
    				encoded <= "1010101011";
    			end case;
				cnt := (others => '0');
    		else
    			if cnt=0 or n10=0 then
    				q_m := not q_m(8) & q_m(8) & (q_m(data'range) xnor (data'range => q_m(8)));
    				if cnt=0 then
    					if q_m(8) ='1' then
    						cnt := cnt + resize(n10, cnt'length);
    					else
    						cnt := cnt - resize(n10, cnt'length);
    					end if;
    				else
    					q_m := not q_m;
    				end if;
    				encoded <= std_logic_vector(q_m);
    			elsif ((cnt(3), n10(3))=unsigned'("00")) or ((cnt(3), n10(3))=unsigned'("11")) then
    				encoded <= std_logic_vector(q_m(8) & q_m(8) & not q_m(data'range));
    				cnt := cnt - resize(n10, cnt'length);
    				if q_m(8)='1' then
    					cnt := cnt + 1;
    				end if;
    			else
    				encoded <= std_logic_vector(not q_m(8) & q_m(8) & q_m(data'range));
    				cnt := cnt + resize(n10, cnt'length);
    				if q_m(8)='0' then
    					cnt := cnt - 1;
    				end if;
    			end if;
			end if;
		end if;
	end process;
end;