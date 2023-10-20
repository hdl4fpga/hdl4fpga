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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;

library ecp5u;
use ecp5u.components.all;

architecture scopeio of ulx3s is

	--------------------------------------
	--     Set your profile here        --
	constant io_link      : io_comms     := io_usb;
	constant sdram_speed  : sdram_speeds := sdram225MHz; 
	constant video_gear   : natural      := 2;
	constant video_mode   : video_modes  := mode600p24bpp;
	-- constant video_mode   : video_modes  := mode720p24bpp;
	-- constant video_mode   : video_modes  := mode900p24bpp;
	-- constant video_mode   : video_modes  := mode1080p24bpp30;
	-- constant video_mode   : video_modes  := mode1080p24bpp;
	-- constant video_mode   : video_modes  := mode1440p24bpp30;
	--------------------------------------

	constant usb_oversampling : natural := 3;

	constant video_params : video_record := videoparam(video_mode, clk25mhz_freq);
	signal video_clk     : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk    : std_logic;
	signal video_pixel   : std_logic_vector(0 to setif(
		video_params.pixel=rgb565, 16, setif(
		video_params.pixel=rgb888, 24, 0))-1);
	signal dvid_crgb     : std_logic_vector(4*video_gear-1 downto 0);
	signal videoio_clk   : std_logic;
	signal video_hzsync : std_logic;
	signal video_vtsync : std_logic;
	signal video_blank  : std_logic;

	constant sample_size : natural := 14;

	constant inputs  : natural := 9;

	signal sample    : std_logic_vector(inputs*sample_size-1 downto 0);

	signal si_clk    : std_logic;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	constant max_delay   : natural := 2**14;
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	signal hz_slider : std_logic_vector(hzoffset_bits-1 downto 0);
	signal hz_scale  : std_logic_vector(4-1 downto 0);
	signal hz_dv     : std_logic;

	constant vt_step : real := 1.0e3*milli/2.0**16; -- Volts
	signal so_clk    : std_logic;
	signal so_frm    : std_logic;
	signal so_trdy   : std_logic;
	signal so_irdy   : std_logic;
	signal so_data   : std_logic_vector(8-1 downto 0);

	signal input_clk : std_logic;
	signal input_ena : std_logic;
	signal samples  : std_logic_vector(0 to inputs*sample_size-1);
begin

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		io_link      => io_link,
		clkio_freq   => 12.0e6*real(usb_oversampling),
		clkref_freq  => clk25mhz_freq,
		default_gear => video_gear,
		video_params => video_params)
	port map (
		clk_rst     => right,
		clk_ref     => clk_25mhz,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_eclk  => video_eclk,
		video_lck   => video_lck);

	scopeio_export_b : block

		signal rgtr_id   : std_logic_vector(8-1 downto 0);
		signal rgtr_dv   : std_logic;
		signal rgtr_data : std_logic_vector(32-1 downto 0);

	begin

		scopeio_sin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => si_clk,
			sin_frm   => si_frm,
			sin_irdy  => si_irdy,
			sin_data  => si_data,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,

			hz_dv     => hz_dv,
			hz_scale  => hz_scale,
			hz_slider => hz_slider);

	end block;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		videotiming_id   => video_params.timing,
		hz_unit          => 31.25*micro,
		vt_steps         => (0 to 3 => vt_step, 4 to inputs-1 => 3.32 * vt_step),
		vt_unit          => 500.0*micro,
		inputs           => inputs,
		input_names      => (
			text(id => "vt(0).text", content => "V_P(+) V_N(-)"),
			text(id => "vt(1).text", content => "A6(+)  A7(-)"),
			text(id => "vt(2).text", content => "A8(+)  A9(-)"),
			text(id => "vt(3).text", content => "A10(+) A11(-)"),
			text(id => "vt(4).text", content => "A0(+)"),
			text(id => "vt(5).text", content => "A1(+)"),
			text(id => "vt(6).text", content => "A2(+)"),
			text(id => "vt(7).text", content => "A3(+)"),
			text(id => "vt(8).text", content => "A4(+)")),
		layout           => displaylayout_tab(sd600),
		hz_factors       => (
			 0 => 2**(0+0)*5**(0+0),  1 => 2**(0+0)*5**(0+0),  2 => 2**(0+0)*5**(0+0),  3 => 2**(0+0)*5**(0+0),
			 4 => 2**(0+0)*5**(0+0),  5 => 2**(1+0)*5**(0+0),  6 => 2**(2+0)*5**(0+0),  7 => 2**(0+0)*5**(1+0),
			 8 => 2**(0+1)*5**(0+1),  9 => 2**(1+1)*5**(0+1), 10 => 2**(2+1)*5**(0+1), 11 => 2**(0+1)*5**(1+1),
			12 => 2**(0+2)*5**(0+2), 13 => 2**(1+2)*5**(0+2), 14 => 2**(2+2)*5**(0+2), 15 => 2**(0+2)*5**(1+2)),

		default_tracesfg => b"1_111" & b"0_110" & b"0_101" & b"0_100" & b"0_011" & b"0_010" & b"0_001" & b"0_111" & b"0_110",
		default_gridfg   => b"1_100",
		default_gridbg   => b"1_000",
		default_hzfg     => b"1_111",
		default_hzbg     => b"1_001",
		default_vtfg     => b"0_111",
		default_vtbg     => b"1_001",
		default_textfg   => b"1_111",
		default_textbg   => b"1_000",
		default_sgmntbg  => b"1_011",
		default_bg       => b"1_111")
	port map (
		sio_clk     => si_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_data     => so_data,
		input_clk   => input_clk,
		input_ena   => input_ena,
		input_data  => samples,
		video_clk   => video_clk,
		video_pixel => video_pixel,
		video_hsync => video_hzsync,
		video_vsync => video_vtsync,
		video_blank => video_blank);

	-- HDMI/DVI VGA --
	------------------

	dvi_b : block
		signal dvid_blank : std_logic;
		signal rgb : std_logic_vector(0 to 3*8-1) := (others => '0');
		constant red_length : natural := 8;
		constant green_length : natural := 8;
		constant blue_length : natural := 8;

	begin

		dvid_blank <= video_blank;
			process (video_pixel)
				variable urgb  : unsigned(0 to 3*8-1);
				variable pixel : unsigned(0 to video_pixel'length-1);
			begin
				pixel := unsigned(video_pixel);

				urgb(0 to red_length-1)  := pixel(0 to red_length-1);
				urgb  := urgb rol 8;
				pixel := pixel sll red_length;

				urgb(0 to green_length-1) := pixel(0 to green_length-1);
				urgb  := urgb rol 8;
				pixel := pixel sll green_length;

				urgb(0 to blue_length-1) := pixel(0 to blue_length-1);
				urgb  := urgb rol 8;
				pixel := pixel sll blue_length;

				rgb <= std_logic_vector(urgb);
		   end process;

		dvi_e : entity hdl4fpga.dvi
		generic map (
			fifo_mode => false, --dvid_fifo,
			gear  => video_gear)
		port map (
			clk   => video_clk,
			rgb   => rgb,
			hsync => video_hzsync,
			vsync => video_vtsync,
			blank => dvid_blank,
			cclk  => video_shift_clk,
			chnc  => dvid_crgb(video_gear*4-1 downto video_gear*3),
			chn2  => dvid_crgb(video_gear*3-1 downto video_gear*2),  
			chn1  => dvid_crgb(video_gear*2-1 downto video_gear*1),  
			chn0  => dvid_crgb(video_gear*1-1 downto video_gear*0));

	end block;

	hdmibrd_g : if video_gear=2 generate 
		signal crgb : std_logic_vector(dvid_crgb'range);
	begin
		reg_e : entity hdl4fpga.latency
		generic map (
			n => dvid_crgb'length,
			d => (dvid_crgb'range => 1))
		port map (
			clk => video_shift_clk,
			di  => dvid_crgb,
			do  => crgb);

		gbx_g : entity hdl4fpga.ecp5_ogbx
		generic map (
			mem_mode  => false,
			lfbt_frst => false,
			interlace => true,
			size      => gpdi_d'length,
			gear      => video_gear)
		port map (
			sclk      => video_shift_clk,
			eclk      => video_eclk,
			d         => crgb,
			q         => gpdi_d);

	end generate;

end;
