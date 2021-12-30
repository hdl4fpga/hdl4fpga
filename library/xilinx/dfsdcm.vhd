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

entity dfsdcm is
	generic (
		dfs_mode : string := "HIGH";
		dcm_per : real;
		dfs_div : natural;
		dfs_mul : natural);
	port (
		dfsdcm_rst   : in std_logic;
		dfsdcm_clkin : in std_logic;
		dfsdcm_clk0  : out std_logic;
		dfsdcm_clk90 : out std_logic;
		dfsdcm_lckd  : out std_logic);
end;

library unisim;
use unisim.vcomponents.ALL;

library hdl4fpga;
use hdl4fpga.std.all;

architecture spartan3 of dfsdcm is
	signal dfs_lckd : std_logic;
    signal dfs_clkfb  : std_logic;

	signal dcm_rst : std_logic;
	signal dcm_clkin : std_logic;
	signal dcm_clkfb : std_logic;
	signal dcm_clk0  : std_logic;
	signal dcm_clk90 : std_logic;

begin

	dcm_dfs : dcm_sp
	generic map(
		clk_feedback => "1X",
		clkin_period => dcm_per,
		clkdv_divide => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => dfs_mode,
		duty_cycle_correction => TRUE,
		factory_jf   => X"C080",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',

		rst => dfsdcm_rst,
		clkin => dfsdcm_clkin,
		clkfb => dfs_clkfb,
		clk0  => dfs_clkfb,
		clkfx => dcm_clkin,
		locked => dfs_lckd);

	process (dfsdcm_rst, dfsdcm_clkin)
	begin
		if dfsdcm_rst='1' then
			dcm_rst <= '1';
		elsif rising_edge(dfsdcm_clkin) then
			dcm_rst <= not dfs_lckd;
		end if;
	end process;

	dcm_dll : dcm_sp
	generic map(
		clk_feedback => "1X",
		clkdv_divide => 2.0,
		clkfx_divide => 1,
		clkfx_multiply => 2,
		clkin_divide_by_2 => FALSE,
		clkin_period => (dcm_per*real(dfs_div))/real(dfs_mul),
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => dfs_mode,
		duty_cycle_correction => TRUE,
		factory_jf => x"C080",
		phase_shift => 0,
		startup_wait => FALSE)
	port map (
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',

		rst   => dcm_rst,
		clkin => dcm_clkin,
		clkfb => dcm_clkfb,
		clk0  => dcm_clk0,
		clk90 => dcm_clk90,
		locked => dfsdcm_lckd);


	dcm_clkfb_bufg : bufg
	port map (
		i => dcm_clk0,
		o => dcm_clkfb);

	dcm_clk90_bufg : bufg
	port map (
		i => dcm_clk90,
		o => dfsdcm_clk90);

	dfsdcm_clk0 <= dcm_clkfb;

end;


