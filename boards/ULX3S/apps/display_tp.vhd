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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture display_tp of ulx3s is

	constant video_mode  : video_modes := mode600p24bpp;
	constant video_param : video_record := videoparam(video_mode);

	signal video_pixel   : std_logic_vector(0 to setif(
		video_param.pixel=rgb565, 16, setif(
		video_param.pixel=rgb888, 32, 0))-1);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal videoio_clk     : std_logic;
	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
	signal dvid_crgb       : std_logic_vector(7 downto 0);

	signal tp              : std_logic_vector(0 to 6-1);
begin

	sys_rst <= '0';

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		clkref_freq  => clk25mhz_freq,
		default_gear => 2,
		video_param  => video_param)
	port map (
		clk_ref     => clk_25mhz,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_lck   => video_lck);

	tp <= (fire1, fire2, up, down, left, right);
	displaytp_e : entity hdl4fpga.display_tp
	generic map (
		timing_id    => video_param.timing,
		video_gear   => 2,
		num_of_cols  => 1,
		field_widths => (15,10,3),
		labels     => 
			"fire1" & NUL &
			"fire2" & NUL &
			"up"    & NUL &
			"down"  & NUL &
			"left"  & NUL &
			"right" & NUL)
	port map (
		sweep_clk   => video_clk,
		tp          => tp,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_hs    => video_hzsync,
		video_vs    => video_vtsync,
		video_pixel => video_pixel,
		dvid_crgb   => dvid_crgb);

	ddr_g : for i in gpdi_d'range generate
		signal q : std_logic;
	begin
		oddr_i : oddrx1f
		port map(
			sclk => video_shift_clk,
			rst  => '0',
			d0   => dvid_crgb(2*i),
			d1   => dvid_crgb(2*i+1),
			q    => q);
		olvds_i : olvds 
		port map(
			a  => q,
			z  => gpdi_d(i),
			zn => gpdi_dn(i));
	end generate;

end;





