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
use hdl4fpga.std.all;

architecture scopeio_btod of testbench is
	signal rst     : std_logic := '1';
	signal clk     : std_logic := '0';

	signal bin_ena : std_logic;
    signal bin_dv  : std_logic;
    signal bin_di  : std_logic_vector(0 to 4-1);

    signal bcd_rdy : std_logic;
    signal bin_fix : std_logic;
    signal bcd_do  : std_logic_vector(0 to 4-1);

	signal bcd_lft : std_logic_vector(1 to 4);
	signal bcd_rgt : std_logic_vector(1 to 4);

	signal cntr    : unsigned(0 to 2);
begin

	clk <= not clk  after  5 ns;
	rst <= '1', '0' after 12 ns;

	process (rst, clk, bcd_rdy)
	begin
		if rst='1' then
			cntr    <= (others => '0');
			bin_fix <= '0';
			bin_ena <= '0';
		elsif rising_edge(clk) then
			bin_ena <= '1';
			if bcd_rdy='1' then
				if cntr(0)='0' then
					cntr <= cntr + 1;
				end if;
			end if;
		end if;
	end process;
	bin_di <= word2byte(x"0f0f", std_logic_vector(cntr(1 to 2)));

	du: entity hdl4fpga.scopeio_ftod
	port map (
		clk     => clk,
		bin_ena => bin_ena,
		bin_dv  => bin_dv,
		bin_di  => bin_di,
		bin_pnt => x"0",
                           
		bcd_lft => bcd_lft,
		bcd_rgt => bcd_rgt,
		bcd_rdy => bcd_rdy,
		bcd_do  => bcd_do);

end;
