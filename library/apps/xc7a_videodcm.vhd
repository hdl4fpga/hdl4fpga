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

entity xc7a_videodcm is
	generic (
		settings    : string);
	port (
		rst         : in std_logic := '0';
		clk         : in std_logic;
		video_clk   : out std_logic;
		video_clkx2 : out std_logic;
		video_shift_clk : out std_logic;
		locked      : buffer std_logic);

	constant gear           : natural := settings**".gear=1";
	constant freq_in        : real    := settings**".dcm.freq_in=1";
	constant clkfbout_mult_f : real    := settings**".dcm.clkfbout_mul_f=1.0";
	constant clkout0_divide_f : real := settings**".dcm.clkout0_divide_f=1";
	constant clkout1_divide : natural := settings**".dcm.clkout1_divide=1";

end;

library unisim;
use unisim.vcomponents.all;

architecture def of xc7a_videodcm is
	signal clkfb   : std_logic;
	signal clkout0 : std_logic;
	signal clkout1 : std_logic;
	signal clkout2 : std_logic;
begin
	assert false
		report settings
		severity note;

	pll_i :  mmcme2_base
	generic map (
		clkin1_period  => 1.0e9/freq_in,
		clkfbout_mult_f => clkfbout_mult_f,
		clkout0_divide_f => clkout0_divide_f,
		clkout1_divide => clkout1_divide,
		clkout2_divide => clkout1_divide*gear)
	port map (
		pwrdwn   => '0',
		rst      => rst,
		clkin1   => clk,
		clkfbin  => clkfb,
		clkfbout => clkfb,
		clkout0  => clkout0,
		clkout1  => clkout1,
		clkout2  => clkout2,
		locked   => locked);

 	gbx1_g : if gear=1 generate
		video_clk       <= clkout0;
	end generate;

 	gbx2_g : if gear=2 generate
		video_clk       <= clkout0;
		video_clkx2     <= clkout1;
		video_shift_clk <= clkout1;
	end generate;

	gbx4_g : if gear=4 generate
		video_clk       <= clkout0;
		video_clkx2     <= clkout1;
		video_shift_clk <= clkout2;
	end generate;
end;