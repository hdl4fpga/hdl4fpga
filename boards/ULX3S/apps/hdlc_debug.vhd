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

library ecp5u;
use ecp5u.components.all;

architecture hdlc_debug of ulx3s is

	type video_modes is (
		mode600p,
		modedebug);

	type pll_params is record
		clkos_div   : natural;
		clkop_div   : natural;
		clkfb_div   : natural;
		clki_div    : natural;
		clkos2_div  : natural;
		clkos3_div  : natural;
	end record;

	type pixel_types is (rgb565, rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		mode600p   => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk40_00m800x600at60),
		modedebug  => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 10), pixel => rgb565, mode => pclk_debug));

	constant nodebug_videomode : video_modes := mode600p;
	constant videodot_freq : natural :=
		(video_tab(nodebug_videomode).pll.clkfb_div*video_tab(nodebug_videomode).pll.clkop_div*natural(sys_freq))/
		(video_tab(nodebug_videomode).pll.clki_div*video_tab(nodebug_videomode).pll.clkos2_div);

	constant video_mode   : video_modes := video_modes'VAL(setif(debug,
--		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode),
		video_modes'POS(nodebug_videomode)));

    signal video_pixel    : std_logic_vector(0 to setif(video_tab(video_mode).pixel=rgb565, 16, 32)-1);

	signal sys_rst        : std_logic;
	signal sys_clk        : std_logic;

	signal video_clk      : std_logic;
	signal videoio_clk    : std_logic;
	signal video_shft_clk : std_logic;
	signal video_lck      : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_on       : std_logic;
	signal video_dot      : std_logic;
	signal dvid_crgb      : std_logic_vector(7 downto 0);

	signal sio_clk        : std_logic;
	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(0 to 8-1);
	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);

	signal ser_frm        : std_logic;
	signal ser_irdy       : std_logic;
	signal ser_data       : std_logic_vector(0 to 2-1);

	alias uart_clk    : std_logic is videoio_clk;
	signal tp             : std_logic_vector(1 to 32);
	alias rx_data : std_logic_vector(0 to 8-1) is tp(9 to 16);


	constant uart_xtal : real := 
		real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq/
		real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos3_div);

	constant uart_xtal16 : real := uart_xtal/16.0;

	constant baudrate : natural := setif(
		uart_xtal >= 32.0e6, 3000000, setif(
		uart_xtal >= 25.0e6, 2000000,
                             115200));

	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(0 to 8-1);
	signal uarttx_frm : std_logic;
	signal uart_idle  : std_logic;
	signal uart_txen  : std_logic;
	signal uart_txd   : std_logic_vector(uart_rxd'range);

	constant mem_size  : natural := 8*(1024*8);

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
			CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
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
			CLKOS     => video_shft_clk,
            CLKOS2    => video_clk,
            CLKOS3    => videoio_clk,
			LOCK      => video_lck,
            INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);

	end block;

	hdlc_b : block

	begin

		sio_clk <= videoio_clk;

		assert FALSE
			report "BAUDRATE : " & " " & integer'image(baudrate)
			severity NOTE;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_txd,
			uart_irdy => uart_rxdv,
			uart_data => uart_rxd);

		process (uart_clk)
		begin
			if rising_edge(uart_clk) then
				if uart_rxdv='1' then
					led <= uart_rxd;
				end if;
			end if;
		end process;

		process (uart_clk)
		begin
			if rising_edge(uart_clk) then
				if uart_txen='1' then
--					led <= uart_txd;
				end if;
			end if;
		end process;

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => uart_clk,
			uart_sout => ftdi_rxd,
			uart_irdy => uart_txen,
			uart_trdy => uart_idle,
			uart_data => uart_txd);

		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size  => mem_size)
		port map (
			tp          => tp,
			uart_clk    => uart_clk,
			uartrx_irdy => uart_rxdv,
			uartrx_data => uart_rxd,
			uarttx_frm  => uarttx_frm,
			uarttx_trdy => uart_idle,
			uarttx_data => uart_txd,
			uarttx_irdy => uart_txen,
			sio_clk     => sio_clk,
			so_frm      => so_frm,
			so_irdy     => so_irdy,
			so_trdy     => so_trdy,
			so_data     => so_data,

			si_frm      => si_frm,
			si_irdy     => si_irdy,
			si_trdy     => si_trdy,
			si_end      => si_end,
			si_data     => si_data);

	end block;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id       => video_tab(video_mode).mode,
		red_length      => 5,
		green_length    => 6,
		blue_length     => 5)
	port map (
		ser_clk         => sio_clk,
		ser_frm         => uart_rxdv,
		ser_irdy        => '1',
		ser_data        => uart_rxd,

		video_clk       => video_clk,
		video_shift_clk => video_shft_clk,
		video_hzsync    => video_hzsync,
		video_vtsync    => video_vtsync,
		video_pixel     => video_pixel,
		dvid_crgb       => dvid_crgb);

	ddr_g : for i in gpdi_dp'range generate
		signal q : std_logic;
	begin
		oddr_i : oddrx1f
		port map(
			sclk => video_shft_clk,
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
