--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture crc of testbench is
	constant n : natural := 8;
	signal clk : std_logic := '0';
	signal xi  : unsigned(0 to 8-1) := "01010111";
	signal xq  : std_logic_vector(0 to 8-1);
	signal pl  : std_logic;
begin
	clk <= not clk after 5 ns;
	pl  <= '1', '0' after 12 ns;

	du : entity hdl4fpga.crc
	generic map (
		n => n)
	port map (
		clk => clk,
		g  => b"0000_0111",
		pl => pl,
		x0 => (others => '0'),
		xi => xi(0),
		xp => xq);

	process
		variable msg : line;
	begin
		if pl='0' then
			xi <= xi sll 1;
		end if;
		write (msg, string'("xq : "));
		write (msg, xq);
		writeline (output, msg);
		wait on clk until clk='1';
	end process;
end;
