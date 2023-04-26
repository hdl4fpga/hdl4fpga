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

library ieee;
use ieee.std_logic_1164.all;

library ecp5u;
use ecp5u.components.all;

architecture ser_debug of ulx3s is

	type video_modes is (
		mode600p24);

	type pll_params is record
		clkos_div   : natural;
		clkop_div   : natural;
		clkfb_div   : natural;
		clki_div    : natural;
		clkos2_div  : natural;
		clkos3_div  : natural;
	end record;

	type pixel_types is (rgb565, rgb666, rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant v_r : natural := 5; -- video ratio
	constant video_tab : videoparams_vector := (
		mode600p24 => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 5*2, clkos3_div => 2*v_r), pixel => rgb888, mode => pclk40_00m800x600at60));

	constant video_mode : video_modes := mode600p24;
	constant videodot_freq : real := 
		real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*clk25mhz_freq/
		real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos2_div);
	alias video_record is video_tab(video_mode);

    signal video_pixel     : std_logic_vector(0 to setif(video_tab(video_mode).pixel=rgb565, 16, 32)-1);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
	signal dvid_crgb       : std_logic_vector(7 downto 0);

	signal ser_clk         : std_logic;
	signal ser_frm         : std_logic;
	signal ser_irdy        : std_logic;
	signal ser_data        : std_logic_vector(0 to 0);

begin

	sys_rst <= '0';

	videopll_b : block
		signal clkfb : std_logic;

		attribute FREQUENCY_PIN_CLKI   : string; 
		attribute FREQUENCY_PIN_CLKOP  : string; 
		attribute FREQUENCY_PIN_CLKOS  : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		constant video_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*clk25mhz_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkos2_div*1e6));

		constant video_shift_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*clk25mhz_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkos_div*1e6));

		constant videoio_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*clk25mhz_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkos3_div*1e6));

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is ftoa(video_shift_freq,    10);
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is ftoa(video_freq,          10);
		attribute FREQUENCY_PIN_CLKOS3 of pll_i : label is ftoa(videoio_freq,        10);
		attribute FREQUENCY_PIN_CLKI   of pll_i : label is ftoa(clk25mhz_freq/1.0e6, 10);
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is ftoa(clk25mhz_freq/1.0e6, 10);

	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED", 
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED", 
			PLL_LOCK_MODE    =>  0, 
			FEEDBK_PATH      => "CLKOP",
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => video_tab(video_mode).pll.clkop_div-1,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0, 
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS3_DIV       => video_tab(video_mode).pll.clkos3_div, 
			CLKOS2_DIV       => video_tab(video_mode).pll.clkos2_div, 
			CLKOS_DIV        => video_tab(video_mode).pll.clkos_div,
			CLKOP_DIV        => video_tab(video_mode).pll.clkop_div,
			CLKFB_DIV        => video_tab(video_mode).pll.clkfb_div,
			CLKI_DIV         => video_tab(video_mode).pll.clki_div)
        port map (
			rst       => '0', 
			clki      => clk_25mhz,
			CLKFB     => clkfb, 
            PHASESEL0 => '0', PHASESEL1 => '0', 
			PHASEDIR  => '0', 
            PHASESTEP => '0', PHASELOADREG => '0', 
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0', 
			ENCLKOS   => '0',
			ENCLKOS2  => '0', 
            ENCLKOS3  => '0', 
			CLKOP     => clkfb,
			CLKOS     => video_shift_clk,
            CLKOS2    => video_clk,
            CLKOS3    => open,
			LOCK      => video_lck, 
            INTLOCK   => open, 
			REFCLK    => open,
			CLKINTFB  => open);

	end block;

	dut_b : block

		constant uart_xtal : real := videodot_freq;

		constant baudrate  : natural := 3000000;

		signal uart_frm    : std_logic;
		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(0 to 0);

	begin

		ser_clk <= video_clk;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => ser_clk,
			uart_sin  => ftdi_txd,
			uart_frm  => uart_frm,
			uart_rxd  => uart_rxd(0),
			uart_rxdv => uart_rxdv);

--		ser_frm  <= '1';
		ser_frm  <= uart_frm;
		ser_irdy <= uart_rxdv;
		ser_data <= uart_rxd;

	end block;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id       => video_tab(video_mode).mode)
	port map (
		ser_clk         => ser_clk, 
		ser_frm         => ser_frm, 
		ser_irdy        => ser_irdy, 
		ser_data        => ser_data, 
		
		video_clk       => video_clk,
		video_shift_clk => video_shift_clk,
		video_hzsync    => video_hzsync,
		video_vtsync    => video_vtsync,
		video_pixel     => video_pixel,
		dvid_crgb       => dvid_crgb);

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
