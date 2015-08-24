--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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
use ieee.std_logic_textio.all;

architecture gray_cntr of testbench is
	constant n : natural := 8;
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal pl  : std_logic := '0';
	signal qo  : std_logic_vector(0 to n-1);
begin
	rst <= '1', '0' after 13 ns;
	pl  <= '0', '1' after 52 ns, '0' after 60 ns;
	clk <= not clk after 5 ns;

	du : entity hdl4fpga.gray_cntr
	generic map (
		n => n)
	port map (
		rst => rst,
		clk => clk,
		pl  => pl,
		di  => (others => '1'),
		qo  => qo);

	process (qo)
		variable msg : line;
		variable cnt : std_logic_vector(qo'range);
	begin
		write(msg, qo);
		cnt := qo;
		writeline(output, msg);
	end process;
end;
