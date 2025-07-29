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

entity xc5v_videodcm is
	generic (
		settings  : string);
	port (
		rst       : in std_logic := '0';
		clk       : in std_logic;
		video_clk : out std_logic;
		locked    : buffer std_logic);

    constant freq_in        : real    := settings**".freq_in";
	constant clkfx_multiply : natural := settings**".clkfx_multiply=1";
	constant clkfx_divide   : natural := settings**".clkfx_divide=1";

end;

library hdl4fpga;
use hdl4fpga.xc5v_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture def of xc5v_videodcm is
	signal clkfx : std_logic;
begin

	dcm_i : dcm_base
	generic map (
		clk_feedback   => "NONE",
		clkin_period   => 1.0e9/freq_in,
		clkfx_multiply => clkfx_multiply,
		clkfx_divide   => clkfx_divide,
		dfs_frequency_mode => "LOW")
	port map (
		rst    => rst,
		clkfb  => '0',
		clkin  => clk,
		clkfx  => clkfx,
		locked => locked);

	bufg_i : bufg
	port map (
		i => clkfx,
		o => video_clk);
end;