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

architecture scopeio_writeticks of testbench is

	signal rst   : std_logic := '0';
	signal clk   : std_logic := '0';
	signal frm   : std_logic;
	signal float : std_logic_vector(0 to 4*4-1);

	signal wu_frm  : std_logic;
	signal wu_trdy : std_logic;

begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				frm  <= '0';
			else
				frm <= '1';
			end if;
		end if;
	end process;

	du : entity hdl4fpga.scopeio_writeticks
	port map (
		clk      => clk,
		frm      => frm,
		irdy     => '1',
		trdy     => open,
		first    => x"0000",
		last     => x"0200",
		step     => x"0010",
		wu_frm   => wu_frm,
		wu_float => float,
		wu_irdy  => open,
		wu_trdy  => wu_frm);

--	process (clk)
--	begin
--		if rising_edge(clk) then
--			wu_trdy <= 
--		end if;
--	end process;

end;
