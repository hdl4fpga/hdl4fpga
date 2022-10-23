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
use hdl4fpga.profiles.all;

entity xc3s_dqsdelay is
	port (
		clk    : in  std_logic;
		rst    : in  std_logic;
		delay  : in  std_logic_vector;
		dqsi   : in  std_logic;
		dqso_p : out std_logic;
		dqso_n : out std_logic);
end;

architecture xilinx of xc3s_dqsdelay is
begin
	delayed_e : entity hdl4fpga.pgm_delay
	generic map(
		n => 2) --gate_delay)
	port map (
		xi  => dqsi,
		x_p => dqso_p,
		x_n => dqso_n);
end;