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

entity gray_cntr is
	generic (
		n   : natural);
	port (
		rst : in  std_logic := '0';
		ini : in std_logic_vector(0 to n-1) := (others => '0');
		clk : in  std_logic;
		ena : in  std_logic := '1';
		pl  : in  std_logic := '0';
		di  : in  std_logic_vector(0 to n-1) := (others => '0');
		qo  : out std_logic_vector(0 to n-1));
end;

architecture mix of gray_cntr is

	function graycode_succ (
		arg : std_logic_vector)
		return std_logic_vector is
		alias a : std_logic_vector(arg'length-1 downto 0) is arg;
		variable t : std_logic_vector(a'range) := (others => '0');
	begin
		for i in a'reverse_range loop
			for j in i to a'left loop
				t(i) := t(i) xor a(j);
			end loop;
			t(i) := not t(i);
			if i > 0 then
				for j in 0 to i-1 loop
					t(i) := t(i) and (not t(j));
				end loop;
			end if;
		end loop;
		if t(a'left-1 downto 0)=(1 to a'left => '0') then
			t(a'left) := '1';
		end if;
		return a xor t;
	end function;

	signal cnt : std_logic_vector(0 to n-1);
begin
	register_p: process (clk,rst)
	begin
		if rst='1' then
			cnt <= ini;
		elsif rising_edge(clk) then
			if pl='1' then
				cnt <= di;
			elsif ena='1' then
				cnt <= graycode_succ(cnt);
			end if;
		end if;
	end process;
	qo <= cnt;
end;
