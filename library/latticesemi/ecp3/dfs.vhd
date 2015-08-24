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
use ieee.numeric_std.ALL;

library ecp3;
use ecp3.components.ALL;

entity dfs is
	generic (
		dcm_per : real := 20.0;
		dfs_div : natural := 3;
		div_op : natural;
		div_fb : natural;
		div_i  : natural);
		
	port (
        dcm_rst : in  std_logic; 
		dcm_clk : in  std_logic; 
		dfs_clk : out std_logic; 
		dcm_lkd : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of dfs is
	signal dfs_clkbuf : std_logic;
	signal dcm_clkfb  : std_logic;
	signal dcm_clk0   : std_logic;

begin

	pll_i : ehxpllf
	generic map (
		feedbk_path  => "INTERNAL",
		clkos_trim_delay =>  0,
		clkos_trim_pol => "RISING", 
		clkop_trim_delay =>  0,
		clkop_trim_pol => "RISING", 
		delay_pwd => "DISABLED",
		delay_val => 0, 
		duty => 8,
		phase_delay_cntl => "STATIC",
		phaseadj => "0.0", 
		clkok_div => 2,
		clkop_div => div_op,
		clkfb_div => div_fb,
		clki_div  => div_i,
		fin => "100.000000")
	port map (
		clki  => dcm_clk,
		clkfb => dcm_clkfb,
		rst   => '0', 
		rstk  => '0',
		wrdel => '0',
		drpai3 => '0', 
		drpai2 => '0',
		drpai1 => '0',
		drpai0 => '0', 
		dfpai3 => '0',
		dfpai2 => '0',
		dfpai1 => '0', 
		dfpai0 => '0',
		fda3 => '0',
		fda2 => '0', 
		fda1 => '0',
		fda0 => '0',
		clkop => dfs_clk, 
		lock => dcm_lkd, 
		clkintfb => dcm_clkfb);

end;
