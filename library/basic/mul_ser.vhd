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

library hdl4fpga;

entity mul_ser is
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		load : in  std_logic;
		feed : out  std_logic;
		a    : in  unsigned;
		b    : in  unsigned;
		s    : out unsigned);
end;

architecture def of mul_ser is
	function mul (
		constant op1 : unsigned;
		constant op2 : unsigned)
		return unsigned is
		variable retval : unsigned(op1'length+op2'length-1 downto 0);
	begin
		retval := (others => '0');
		for i in op2'reverse_range loop
			if op2(i)='1' then
				retval := retval + op1;
			elsif op2(i)/='0' then
				retval := (others => 'X');
			end if;
		end loop;
		return retval;
	end;

	signal p : unsigned(a'length+b'length-1 downto 0);
begin
	p <= mul(a,b);
	process (clk)
	begin
		if rising_edge(clk) then
		end if;
	end process;

	process (clk)
		variable shr : unsigned(s'length-1 downto 0);
	begin
		if rising_edge(clk) then
			if ena='1' then
				if load='1' then
					shr := (others => '0');
				end if;
				shr(p'range) := shr(p'range) + p;
				shr := rotate_right(shr, b'length);
				s <= shr;
			end if;
		end if;
	end process;

end;