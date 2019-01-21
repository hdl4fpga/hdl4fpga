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

architecture def of testbench is

	signal rst      : std_logic;

	signal clk      : std_logic := '0';
	signal wr_frm   : std_logic;
	signal wr_irdy  : std_logic;

	signal buf_trdy  : std_logic;
	signal buf_do    : std_logic_vector(0 to 4-1);

begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk after 10 ns;

	writef_e : entity hdl4fpga.writef
	port map (
		clk      => clk,
		wr_frm   => bin_frm,
		wr_irdy  => '1',
		wr_trdy  => wr_trdy,
		wr_bin   => x"104b",
		buf_trdy => buf_trdy,
		buf_do   => buf_do);

end;
