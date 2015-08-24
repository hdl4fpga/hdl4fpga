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
use ieee.std_logic_textio.all;

library hdl4fpga;

architecture i2c_master of testbench is
	signal rst : std_logic := '0';
	signal i2c_scl  : std_logic := '0';
	signal i2c_sda  : std_logic;
begin
	i2c_scl <= not i2c_scl after 5 ns;
	i2c_sda <= 
		'1' , 
		'0' after 27 ns,
		'1' after 32 ns;

	rst <= '1', '0' after 10 ns;
	du : entity hdl4fpga.i2c_master
	port map (
		sys_rst => rst,
		i2c_scl => i2c_scl,
		i2c_sda => i2c_sda);
end;
