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

entity boothmult is
	port (
		clk     : in  std_logic;
		ini     : in  std_logic;
		multand : in  std_logic_vector(16-1 downto 0);
		multier : in  std_logic_vector( 8-1 downto 0);
		valid   : out std_logic;
		product : out signed(24-1 downto 0));
end;

architecture smult of boothmult is
begin
	du : entity hdl4fpga.boothmult
	port map (
		clk     => clk,
		ini     => ini,
		multand => signed(multand),
		multier => signed(multier),
		valid   => valid,
		product => product);
end;
