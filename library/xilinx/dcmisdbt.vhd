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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity dcmisdbt is
	port ( 
		dcm_rst : in  std_logic; 
		dcm_clk : in  std_logic; 
		dfs_clk : out std_logic; 
		dcm_lck : out std_logic);
end;

architecture behavioral of dcmisdbt is
   signal u1_clk0_buf        : std_logic;
   signal u1_clkfb_in        : std_logic;
   signal u1_clkfx_buf       : std_logic;
   signal u1_locked_inv_in   : std_logic;
   signal u2_clkin_in        : std_logic;
   signal u2_clkfb_in        : std_logic;
   signal u2_clk0_buf        : std_logic;
   signal u2_clk90_buf       : std_logic;
   signal u2_fds_q_out       : std_logic;
   signal u2_fd1_q_out       : std_logic;
   signal u2_fd2_q_out       : std_logic;
   signal u2_fd3_q_out       : std_logic;
   signal u2_locked_inv_rst  : std_logic;
   signal u2_or3_o_out       : std_logic;
   signal u2_rst_in          : std_logic;
 
   signal u2_clkfb_ibufgds: std_logic;
   constant n1 : natural := 16;
   constant n2 : natural := 16;
begin
   
	u1_clk0_bufg_inst : bufg
    port map (
		i => u1_clk0_buf,
        o => u1_clkfb_in);
   
	dcm1_u : dcm_sp
	generic map(
		clk_feedback => "1X",
		clkdv_divide => 2.0,
		clkfx_divide => 15,
		clkfx_multiply => n1,
		clkin_divide_by_2 => FALSE,
		clkin_period => 50.0,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => TRUE,
		factory_jf => x"c080",
		phase_shift => 0,
		startup_wait => FALSE)
	port map (
		clkfb  => u1_clkfb_in,
		clkin  => dcm_clk,
		dssen  => '0',
		psclk  => '0',
		psen   => '0',
		psincdec =>'0',
		rst   => dcm_rst,
		clkdv => open,
		clkfx => u1_clkfx_buf,
		clkfx180 => open,
		clk0   => u1_clk0_buf,
		clk2x  => open,
		clk2x180=>open,
		clk90  => open,
		clk180 => open,
		clk270 => open,
		locked => u1_locked_inv_in,
		psdone => open,
		status => open);

	u2_clkfx_bufg_inst : bufg
	port map (
		i => u1_clkfx_buf,
		o => u2_clkin_in);

	u2_clk0_bufg_inst : bufg
    port map (
		i => u2_clk0_buf,
        o => u2_clkfb_in);
		
	dcm_sp_inst2 : dcm_sp
	generic map(
		clk_feedback   => "1X",
		clkdv_divide   => 2.0,
--		clkfx_divide   => 21,
		clkfx_divide   => 3,
		clkfx_multiply => n2,
		clkin_divide_by_2 => FALSE,
		clkin_period   => (50.0*15.0)/real(n1),
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => true,
		factory_jf     => x"c080",
		phase_shift    => 0,
		startup_wait   => FALSE)
	port map (
		clkfb    => u2_clkfb_in,
		clkin    => u2_clkin_in,
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',
		rst      => u2_rst_in,
		clk0     => open,
		clk90    => open,
		clk180   => open,
		clk270   => open,
		clk2x    => open,
		clk2x180 => open,
		clkdv    => open,
		clkfx    => dfs_clk,
		clkfx180 => open,
		locked   => dcm_lck,
		psdone   => open,
		status   => open);

	u1_inv_inst : inv
	port map (
		i => u1_locked_inv_in,
		o => u2_locked_inv_rst);

	u2_fds_inst : fds
	port map (
		c => u2_clkin_in,
		d => '0',
		s => '0',
		q => u2_fds_q_out);
   
	u2_fd1_inst : fd
	port map (
		c => u2_clkin_in,
		d => u2_fds_q_out,
		q => u2_fd1_q_out);
   
	u2_fd2_inst : fd
	port map (
		c => u2_clkin_in,
		d => u2_fd1_q_out,
		q => u2_fd2_q_out);

	u2_fd3_inst : fd
	port map (
		c => u2_clkin_in,
		d => u2_fd2_q_out,
		q => u2_fd3_q_out);

	u2_or2_inst : or2
	port map (
		i0 => u2_locked_inv_rst,
		i1 => u2_or3_o_out,
		o  => u2_rst_in);

	u2_or3_inst : or3
	port map (
		i0 => u2_fd3_q_out,
		i1 => u2_fd2_q_out,
		i2 => u2_fd1_q_out,
		o  => u2_or3_o_out);
end;


