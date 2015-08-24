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

entity testbench is
end;

architecture bin2def of testbench is
	constant n : natural := 12;
	constant m : natural := 16;

	signal clk : std_logic := '0';
	signal ld  : std_logic := '1';
	signal bcd : std_logic_vector(15 downto 0);
begin
	clk <= not clk after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			ld <= '0';
		end if;
	end process;

	du : entity hdl4fpga.bin2bcd
 	generic map (
		n => n,
		m => m)
	port map (
		clk => clk,
		ld  => ld,
		bin => X"579",
		bcd => bcd);
end;
