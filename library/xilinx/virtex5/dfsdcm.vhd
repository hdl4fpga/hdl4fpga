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

entity dfsdcm is
	generic (
		dcm_per : real;
		dfs_div : natural;
		dfs_mul : natural);
	port ( 
		dfsdcm_rst : in std_logic; 
		dfsdcm_clkin : in std_logic; 
		dfsdcm_clk0  : out std_logic; 
		dfsdcm_clk90 : out std_logic; 
		dfsdcm_lckd : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of dfsdcm is
	signal dfs_clkfb  : std_logic;
	signal dfs_lckd  : std_logic;

	signal dcm_rst : std_logic;
	signal dcm_clkin : std_logic;
	signal dcm_clkfb : std_logic;
	signal dcm_clk0  : std_logic;
	signal dcm_clk90 : std_logic;
	signal dcm_lckd  : std_logic;
begin

	dfs_i : dcm_adv
	generic map (
		clk_feedback => "1X",
		clkdv_divide => 2.0,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkin_period => dcm_per,
		clkin_divide_by_2 => FALSE,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => TRUE,
		factory_jf   => X"F0F0",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		rst   => dfsdcm_rst,
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clkfb => dfs_clkfb,
		clkin => dfsdcm_clkin,
		clk0  => dfs_clkfb,
		clkfx => dcm_clkin,
		locked => dfs_lckd);
   
	process (dfs_lckd, dfsdcm_clkin)
		variable srl16 : std_logic_vector(0 to 16-1) := (others => '1');
	begin
		if dfs_lckd='0' then
			dcm_rst <= '1';
		elsif rising_edge(dfsdcm_clkin) then
			dcm_rst <= srl16(0) or not dfs_lckd;
			srl16 := srl16(1 to srl16'right) & not dfs_lckd;
		end if;
	end process;

	dcm_i : dcm_adv
	generic map (
		clk_feedback => "1x",
		clkin_divide_by_2 => FALSE,
		clkin_period => (real(dfs_div)*dcm_per)/real(dfs_mul),
		clkdv_divide => 2.0,
		clkfx_divide => 1,
		clkfx_multiply => 4,
		clkout_phase_shift   => "NONE",
		dcm_autocalibration  => TRUE,
		dcm_performance_mode => "MAX_SPEED",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		dll_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf   => X"F0F0",
		phase_shift  => 0,
		startup_wait => FALSE,
		sim_device   => "VIRTEX5")
	port map (
		rst   => dcm_rst,
		clkin => dcm_clkin,
		clkfb => dcm_clkfb,
		daddr => (others => '0'),
		dclk  => '0',
		den   => '0',
		di    => (others => '0'),
		dwe   => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clk0  => dcm_clk0,
		clk90 => dcm_clk90,
		locked => dcm_lckd);
   

	process (dcm_lckd, dfsdcm_clkin)
		variable srl16 : std_logic_vector(0 to 16-1) := (others => '1');
	begin
		if dcm_lckd='0' then
			dfsdcm_lckd <= '0';
		elsif rising_edge(dfsdcm_clkin) then
			dfsdcm_lckd <= not srl16(0) and dfs_lckd;
			srl16 := srl16(1 to srl16'right) &  not dfs_lckd;
		end if;
	end process;

	clk0_bufg_i : bufg
	port map (
		i => dcm_clk0,
		o => dcm_clkfb);
   
	dfsdcmclk90_bufg_i : bufg
	port map (
		i => dcm_clk90,
		o => dfsdcm_clk90);

	dfsdcm_clk0 <= dcm_clkfb;
end;
