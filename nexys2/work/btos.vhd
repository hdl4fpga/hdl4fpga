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

entity test_btos is
	port (
		clk       : in  std_logic;
		bin_frm   : in  std_logic;
		bin_irdy  : in  std_logic;
		bin_trdy  : out std_logic;
		bin_flt   : in  std_logic;
		bin_di    : in  std_logic_vector(0 to 4-1);

		bcd_rst   : in  std_logic;
		bcd_addr  : in  std_logic_vector(0 to 4-1);
		bcd_left  : out std_logic_vector(0 to 4-1);
		bcd_right : out std_logic_vector(0 to 4-1);
		bcd_do    : out std_logic_vector(0 to 4-1));
end;

architecture btos of test_btos is
begin
	du_e : entity hdl4fpga.btos
	port map (
		clk       => clk,
		bin_frm   => bin_frm,
		bin_irdy  => bin_irdy,
		bin_trdy  => bin_trdy,
		bin_flt   => bin_flt,
		bin_di    => bin_di,
                  
		bcd_rst   => bcd_rst,
		bcd_addr  => bcd_addr,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_do    => bcd_do);
end;
