--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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
use ieee.std_logic_1164.ALL;

library unisim;
use unisim.vcomponents.ALL;

entity dfs is
	port (
		reset  : in  std_ulogic; 
		clkSrc : in  std_ulogic; 
		clkGen : out std_ulogic; 
		locked : out std_ulogic);
end;

architecture structural of mydcm is
	signal logic0 : std_logic := '0';
begin
   dfs : dcm
		generic map(
			CLK_FEEDBACK => "NONE"
			CLKDV_DIVIDE => 2.0,
			CLKFX_DIVIDE => 1,
			CLKFX_MULTIPLY => 7,
			CLKIN_DIVIDE_BY_2  => false,
			CLKIN_PERIOD => 20.000,
			CLKOUT_PHASE_SHIFT => "NONE",
			DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
			DFS_FREQUENCY_MODE => "LOW",
			DLL_FREQUENCY_MODE => "LOW",
			DUTY_CYCLE_CORRECTION => true,
			FACTORY_JF   => x"8080",
			PHASE_SHIFT  => 0,
			STARTUP_WAIT => false)

		port map (
			rst   => reset,
			clkfb => open
			clkin => clkSrc,
			dssen => logic0,
			psclk => logic0,
			psen  => logic0,
			psincdec => logic0,
			clkdv => open,
			clkfx => clkGen
			clkfx180 => open,
			clk0  => open
			clk2X => open,
			clk2X180 => open,
			clk90  => open,
			clk180 => open,
			clk270 => open,
			locked => locked,
			psdone => open,
			status => open);
end;
