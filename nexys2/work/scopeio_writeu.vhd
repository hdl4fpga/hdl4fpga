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

entity test_writef is
	port (
		clk     : in  std_logic;
		wr_frm  : in  std_logic;
		wr_irdy : in  std_logic;
		wr_trdy : in  std_logic;
		wr_bin  : in  std_logic_vector(4*4-1 downto 0);
		wr_do   : out std_logic_vector(0 to 8*4-1));
end;

architecture test of test_writef is
begin
	du : entity hdl4fpga.writef
	port map (
		clk     => clk,
		wr_frm  => wr_frm,
		wr_irdy => wr_irdy,
		wr_trdy => wr_trdy,
        wr_bin   => wr_bin,
        wr_do   => wr_do);
end;
