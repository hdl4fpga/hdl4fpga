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
use hdl4fpga.base.all;

entity videogbx is
	port (
		video_clk   : in  std_logic;
		video_red   : in  std_logic_vector;
		video_green : in  std_logic_vector;
		video_blue  : in  std_logic_vector;

		gbx_clk     : out std_logic_vector;
		gbx_red     : out std_logic_vector;
		gbx_green   : out std_logic_vector;
		gbx_blue    : out std_logic);
end;

architecture def of videogbx is

begin
	process (video_clk)
	begin 
		if rising_edge(video_clk) then
			gbx_red <= 
		end if;
	end process;
end;
