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

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dcms is
	generic (
		ddr_mul : natural := 25;
		ddr_div : natural := 9;
		sys_per : real := 50.0);
	port (
		sys_rst   : in  std_logic;
		sys_clk   : in  std_logic;
		input_clk : buffer std_logic;
		ddr_clk0  : buffer std_logic;
		ddr_clk90 : out std_logic;
		video_clk : buffer std_logic;
		mii_clk   : buffer std_logic;
		input_rst : out std_logic;
		ddr_rst  : out std_logic;
		mii_rst   : out std_logic;
		video_rst   : out std_logic);
end;

architecture def of dcms is

	-------------------------------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 180 Mhz -- 193 Mhz -- 200 Mhz  --
	-- Multiply by --  20     --  25     --   9     --  29     --  10      --
	-- Divide by   --   3     --   3     --   1     --   3     --   1      --
	-------------------------------------------------------------------------

	signal dcm_rst : std_logic;

	signal input_lckd : std_logic := '1';
	signal ddr_lckd   : std_logic;
	signal mii_lckd   : std_logic;
	signal video_lckd : std_logic;

begin

	dcm_rst <= sys_rst;
	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => dcm_rst,
		dcm_clk => sys_clk,
		dfs_clk => video_clk,
		dcm_lck => video_lckd);
	video_rst <= not video_lckd;

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst => dcm_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => ddr_clk0,
		dfsdcm_clk90 => ddr_clk90,
		dfsdcm_lckd => ddr_lckd);
	ddr_rst <= not ddr_lckd;

-- --	inputdcm_e : entity hdl4fpga.dfs
	-- inputdcm_e : entity hdl4fpga.dcmisdbt
-- --	generic map (
-- --		dcm_per => sys_per,
-- --		dfs_mul => 2,
-- --		dfs_div => 2)
	-- port map (
		-- sys_rst => dcm_rst,
		-- sys_clk => sys_clk,
		-- dfs_clk => input_clk,
		-- dcm_lck => input_lckd);
	-- input_rst <= not input_lckd;

	input_clk <= sys_clk;
	input_rst <= '0';
	
	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => sys_clk,
		dfs_clk => mii_clk,
		dcm_lck => mii_lckd);
	mii_rst <= not mii_lckd;


end;
