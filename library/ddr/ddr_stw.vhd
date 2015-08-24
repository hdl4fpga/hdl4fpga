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

library ieee;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;

entity ddr_stw is
	port (
		ddr_st_hlf : in  std_logic;
		ddr_st_clk : in  std_logic;
		ddr_st_drr : in  std_logic;
		ddr_st_drf : in  std_logic;
		ddr_st_dqs : out std_logic);
end;

library hdl4fpga;

architecture mix of ddr_stw is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin
	rclk <= 
		not ddr_st_clk when ddr_st_hlf='1' else
		ddr_st_clk;

	oddr_i : entity hdl4fpga.ddro
	port map (
		clk => rclk,
		dr => ddr_st_drr,
		df => ddr_st_drf,
		q  => ddr_st_dqs);
end;
