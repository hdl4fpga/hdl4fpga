-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.hdo.all;

entity xc3s_sdramdcm is
	generic (
		settings  : string);
	port (
		rst        : in  std_logic := '0';
		clk        : in  std_logic;
		ctlr_clk   : buffer std_logic;
		ctlr_clk90 : out std_logic;
		locked     : buffer std_logic);

    constant freq_in        : real    := settings**".freq_in";
	constant clkfx_multiply : natural := settings**".clkfx_multiply=0";
	constant clkfx_divide   : natural := settings**".clkfx_divide=1";

end;

library unisim;
use unisim.vcomponents.all;

architecture def of xc3s_sdramdcm is

	constant sdram_freq : real := hdl4fpga.xc3s_profiles.sdram_freq(settings); -- GHDL annoyance

	signal dfs_lckd  : std_logic;
	signal dfs_clkfb : std_logic;
	
	signal dcm_clkin : std_logic;
	signal dcm_clkfb : std_logic;
	signal dcm_clk   : std_logic;
	signal dcm_clk90 : std_logic;

begin

	dcmdfs_i : dcm_sp
	generic map(
		clk_feedback   => "NONE",
		clkin_period   => 1.0e9/freq_in,
		clkdv_divide   => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_multiply => clkfx_multiply,
		clkfx_divide   => clkfx_divide,
		clkout_phase_shift => "NONE",
		deskew_adjust  => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf     => X"C080",
		phase_shift    => 0,
		startup_wait   => FALSE)
	port map (
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',

		rst      => rst,
		clkin    => clk,
		clkfb    => '0',
		clk0     => dfs_clkfb,
		clkfx    => dcm_clkin,
		locked   => dfs_lckd);

	dcmdll_i : dcm_sp
	generic map(
		clk_feedback   => "1X",
		clkin_period   => 1.0e9/sdram_freq,
		clkdv_divide   => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_divide   => 1,
		clkfx_multiply => 2,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf    => x"C080",
		phase_shift   => 0,
		startup_wait  => FALSE)
	port map (
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',

		rst      => '0',
		clkin    => dcm_clkin,
		clkfb    => ctlr_clk,
		clk0     => dcm_clk,
		clk90    => dcm_clk90,
		locked   => locked);

	clk0_bufg_i : bufg
	port map (
		i => dcm_clk,
		o => ctlr_clk);

	clk90_bufg_i : bufg
	port map (
		i => dcm_clk90,
		o => ctlr_clk90);

end;
