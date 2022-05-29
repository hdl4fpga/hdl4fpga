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
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;

library ieee;
use ieee.std_logic_1164.all;

library ecp5u;
use ecp5u.components.all;

architecture ser_debug of ulx3s is

	constant sys_freq   : real    := 25.0e6;

	type video_modes is (
		mode600p,
		mode600p18,
		mode600p24,
		mode1080p);

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
	constant video_tab : videoparams_vector := (
		mode600p   => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk40_00m800x600at60),
		mode600p18 => (pll => (clkos_div => 3, clkop_div => 29,  clkfb_div => 1, clki_div => 1, clkos2_div => 18, clkos3_div => 2), pixel => rgb666, mode => pclk40_00m800x600at60),
		mode600p24 => (pll => (clkos_div => 2, clkop_div => 25,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 2), pixel => rgb888, mode => pclk40_00m800x600at60),
		mode1080p  => (pll => (clkos_div => 1, clkop_div => 24,  clkfb_div => 1, clki_div => 1, clkos2_div =>  5, clkos3_div => 2), pixel => rgb565, mode => pclk120_00m1920x1080at50));

	constant video_mode : video_modes := mode600p;
	constant videodot_freq : natural := 
		(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div*natural(sys_freq))/
		(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos2_div);

    signal video_pixel     : std_logic_vector(0 to setif(video_tab(video_mode).pixel=rgb565, 16, 32)-1);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
    signal video_on        : std_logic;
	signal video_dot       : std_logic;
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

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is  "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is  "25.000000";

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is "200.000000";
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is  "40.000000";

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

		constant uart_xtal : natural := natural(videodot_freq);

		constant baudrate  : natural := 3000000;

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
			uart_rxd  => uart_rxd(0),
			uart_rxdv => uart_rxdv);

		ser_frm  <= '1';
		ser_irdy <= uart_rxdv;
		ser_data <= uart_rxd;

	end block;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id       => video_tab(video_mode).mode,
		red_length      => 5,
		green_length    => 6,
		blue_length     => 5)
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

	ddr_g : for i in gpdi_dp'range generate
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
			z  => gpdi_dp(i),
			zn => gpdi_dn(i));
	end generate;

end;
