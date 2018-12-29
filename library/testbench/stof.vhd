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

architecture stof of testbench is

	signal rst       : std_logic := '0';
	signal clk       : std_logic := '0';

	signal bcd_frm   : std_logic;
	signal bin_flt   : std_logic;
	signal bin_di    : std_logic_vector(0 to 4-1);
	signal bcd_do    : std_logic_vector(0 to 4-1);
	signal bcd_left  : std_logic_vector(0 to 4-1);
	signal bcd_right : std_logic_vector(0 to 4-1);
	signal bcd_addr  : std_logic_vector(0 to 5-1) := (others => '0');
	signal fix_do    : std_logic_vector(0 to 6*4-1);

	signal btod_frm  : std_logic;
	signal fix_irdy : std_logic;
	signal fix_trdy : std_logic;
	signal stof_frm  : std_logic;
	signal stof_eddn : std_logic;

begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk  after 10 ns;

	bcd_frm <= not rst;
	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		bcd_eddn  => stof_eddn,
		bcd_frm   => bcd_frm,
		bcd_left  => b"00000",
		bcd_right => b"11110",
		bcd_addr  => bcd_addr,
		bcd_di    => x"1",
		fix_trdy => '1',
		fix_irdy => fix_trdy,
		fix_do    => fix_do);

end;
