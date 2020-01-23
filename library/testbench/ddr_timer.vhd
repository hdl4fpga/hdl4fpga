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

library hdl4fpga;
use hdl4fpga.std.all;

architecture ddr_timer of testbench is
	signal sys_clk : std_logic := '0';
	signal sys_req : std_logic;
	signal sys_rdy : std_logic;

	constant timer_sel : std_logic_vector(0 to 0) := "1";
	constant timer_data : natural_vector(0 to 4-1) := (
		58, 03, 55, 128);
begin

	sys_clk <= not sys_clk after 5 ns;
	sys_req <= '1', '0' after 45.00001 ns, '1' after 4000.00001 ns, '0' after 4045.00001 ns;

	du : entity hdl4fpga.ddr_timer
	generic map (
		timers   => timer_data(3 to 3))
	port map (
		sys_clk => sys_clk,
		tmr_id  => timer_sel,
		sys_req => sys_req,
		sys_rdy => sys_rdy);
end;
