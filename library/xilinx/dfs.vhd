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
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library unisim;
use unisim.vcomponents.ALL;

entity dfs is
	generic (
		dfs_frequency_mode : string := "high";
		dcm_per : real := 20.0;
		dfs_div : natural := 3;
		dfs_mul : natural := 10);
	port (
        dcm_rst : in  std_logic; 
		dcm_clk : in  std_logic; 
		dfs_clk : out std_logic; 
		dcm_lck : out std_logic);
end;

architecture xilinx of dfs is

   signal dcm_clkfb  : std_logic;
   signal dcm_clk0   : std_logic;
begin


	dcmclk_g : bufg
	port map (
		I => dcm_clk0,
		O => dcm_clkfb);
   
	dfs_i : dcm
	generic map(
		clk_feedback => "1x",
		clkdv_divide => 2.0,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkin_divide_by_2 => false,
		clkin_period => dcm_per,
		clkout_phase_shift => "none",
		deskew_adjust => "system_synchronous",
		dfs_frequency_mode => dfs_frequency_mode,
		dll_frequency_mode => "high",
		duty_cycle_correction => true,
		factory_jf   => x"c080",
		phase_shift  => 0,
		startup_wait => false)
	port map (
		rst   => dcm_rst,
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clkfb => dcm_clkfb,
		clkin => dcm_clk,
		clkfx => dfs_clk,
		clkfx180 => open,
		clk0  => dcm_clk0,
		locked => dcm_lck,
		psdone => open,
		status => open);
end;
