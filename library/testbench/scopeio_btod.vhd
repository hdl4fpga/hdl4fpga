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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture scopeio_btod of testbench is
	signal rst     : std_logic;
	signal clk     : std_logic := '0';
	signal bin_ena : std_logic;
    signal bin_dv  : std_logic;
    signal bin_di  : std_logic_vector(0 to 16-1);

    signal bcd_sz1 : std_logic_vector(0 to 4-1);
    signal bcd_ena : std_logic;
    signal bcd_lst : std_logic;
    signal bcd_do  : std_logic_vector(0 to 4-1);

	signal bin_fix : std_logic;
begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 12 ns;

	process (rst, clk, bcd_lst)
		variable xx : natural;
	begin
		if bcd_lst='1' and xx>=1 then
			bin_fix <= '1';
		end if;
		if rst='1' then
			bin_ena <= '0';
			bcd_ena <= '0';
			xx := 0;
			bin_fix <= '0';
		elsif rising_edge(clk) then
			bin_ena <= '1';
			bcd_ena <= '1';
			if bcd_lst='1' then
				if xx <= 0 then
					xx := xx + 1;
				end if;
			end if;
		end if;
	end process;

	du: entity hdl4fpga.scopeio_btod
	port map (
		clk     => clk,
		bin_ena => bin_ena,
		bin_dv  => open,
		bin_di  => x"0001", --bin_di,
		bin_fix => bin_fix,
                           
		bcd_sz1 => x"f", --bcd_sz1,
		
		bcd_lst => bcd_lst,
		bcd_do  => bcd_do);

end;
