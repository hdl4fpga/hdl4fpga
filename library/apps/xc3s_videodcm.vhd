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

entity xc3s_videodcm is
	generic (
		settings  : string);
	port (
		rst       : in std_logic := '0';
		clk       : in std_logic;
		video_clk : out std_logic;
		locked    : buffer std_logic);

end;

library hdl4fpga;
use hdl4fpga.xc3s_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture def of xc3s_videodcm is
    constant freq_in        : real    := settings**".freq_in";
	constant clkfx_multiply : natural := settings**".clkfx_multiply=0";
	constant clkfx_divide   : natural := settings**".clkfx_divide=1";

	signal dcm_clkfb : std_logic;
	signal dcm_clk0  : std_logic;

begin

	bug_i : bufg
	port map (
		I => dcm_clk0,
		O => dcm_clkfb);

	dcm_i : dcm
	generic map(
		clk_feedback   => "1x",
		clkdv_divide   => 2.0,
		clkfx_multiply => clkfx_multiply,
		clkfx_divide   => clkfx_divide,
		clkin_divide_by_2 => false,
		clkin_period   => 1.0e9/freq_in,
		clkout_phase_shift => "none",
		deskew_adjust  => "system_synchronous",
		dfs_frequency_mode => "LOW",
		duty_cycle_correction => true,
		factory_jf   => x"c080",
		phase_shift  => 0,
		startup_wait => false)
	port map (
		rst      => rst ,
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',
		clkfb    => dcm_clkfb,
		clkin    => clk,
		clkfx    => video_clk,
		clkfx180 => open,
		clk0     => dcm_clk0,
		locked   => open,
		psdone   => open,
		status   => open);
end;