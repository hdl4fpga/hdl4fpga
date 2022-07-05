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

entity adjser is
	generic (
		tap_value : natural := 0);
	port (
		clk   : in  std_logic;
		rst   : in  std_logic;
		delay : in std_logic_vector;
		ce    : out std_logic;
		inc   : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of adjser is
begin
	process (clk)
		variable taps : unsigned(delay'length-1 downto 0);
		variable cntr : unsigned(taps'range);
		variable dgtn : unsigned(taps'range);
		variable acc  : unsigned(taps'range);
	begin
		if rising_edge(clk) then
			acc := (unsigned(delay) xor taps) and dgtn;
			inc <= setif((acc and taps)=(delay'range => '0'));
			if rst='1' then
				taps := to_unsigned(tap_value, delay'length);
				dgtn := (0 => '1', others => '0');
				cntr := (0 => '1', others => '0');
				ce   <= '0';
			elsif acc/=(delay'range => '0') then
				if (acc and cntr)=(delay'range => '0') then
					cntr := cntr + 1;
					ce   <= '1';
				else
					taps := taps xor acc;
					cntr := (0 => '1', others => '0');
					dgtn := rotate_left(dgtn, 1);
					ce   <= '1';
				end if;
			else
				taps := taps xor acc;
				cntr := (0 => '1', others => '0');
				dgtn := rotate_left(dgtn, 1);
				ce   <= '0';
			end if;
		end if;
	end process;
end;