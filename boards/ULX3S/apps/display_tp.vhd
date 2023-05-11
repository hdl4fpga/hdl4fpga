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
