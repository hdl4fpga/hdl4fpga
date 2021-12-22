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
use hdl4fpga.ddr_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx3s is

	--------------------------------------
	-- Set of profiles                  --
	type apps is (
	--	Interface_SdramSpeed_PixelFormat--
		uart_250MHz_480p24bpp,          --

		uart_133MHz_600p16bpp,          --
		uart_166MHz_600p16bpp,          --
		uart_200MHz_600p16bpp,          --
		uart_250MHz_600p16bpp,          --

		mii_166MHz_480p24bpp,           --
		mii_200MHz_480p24bpp,           --
		mii_250MHz_480p24bpp);          --
	--------------------------------------

	---------------------------------------------
	-- Set your profile here                   --
	constant app : apps := uart_250MHz_480p24bpp;
	---------------------------------------------

	constant sys_freq    : real    := 25.0e6;

	constant fpga        : natural := spartan3;
	constant mark        : natural := M7E;

	constant sclk_phases : natural := 1;
	constant sclk_edges  : natural := 1;
	constant data_phases : natural := 1;
	constant data_edges  : natural := 1;
	constant cmmd_gear   : natural := 1;
	constant data_gear   : natural := 1;
	constant bank_size   : natural := sdram_ba'length;
	constant addr_size   : natural := sdram_a'length;
	constant coln_size   : natural := 9;
	constant word_size   : natural := sdram_d'length;
	constant byte_size   : natural := 8;

	signal sys_rst       : std_logic;
	signal sys_clk       : std_logic;

	signal ddrsys_rst    : std_logic;
	signal ddrsys_clks   : std_logic_vector(0 to 0);

	signal sdram_lck     : std_logic;
	signal sdram_dqs     : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic;
	signal ctlrphy_cs    : std_logic;
	signal ctlrphy_ras   : std_logic;
	signal ctlrphy_cas   : std_logic;
	signal ctlrphy_we    : std_logic;
	signal ctlrphy_odt   : std_logic;
	signal ctlrphy_b     : std_logic_vector(sdram_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(sdram_a'length-1 downto 0);
	signal ctlrphy_dsi   : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_dst   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dso   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal sdrphy_sti    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal sdram_st_dqs_open : std_logic;

	signal sdram_dst     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dso     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqt     : std_logic_vector(sdram_d'range);
	signal sdram_do      : std_logic_vector(sdram_d'range);

	type pll_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos2_div : natural;
		clkos3_div : natural;
	end record;

	type video_modes is (
		mode480p24,
		mode600p16,
		modedebug);

	type pixel_types is (
		rgb565,
		rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug  => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 10), pixel => rgb888, mode => pclk_debug),
		mode480p24 => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 10), pixel => rgb888, mode => pclk25_00m640x480at60),
		mode600p16 => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 10), pixel => rgb565, mode => pclk40_00m800x600at60));

	signal video_clk      : std_logic;
	signal videoio_clk    : std_logic;
	signal video_lck      : std_logic;
	signal video_shft_clk : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_blank    : std_logic;
    signal video_on       : std_logic;
    signal video_dot      : std_logic;
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	type sdram_speed is (
		sdram133MHz,
		sdram166MHz,
		sdram200MHz,
		sdram225MHz,	-- Not tested yet
		sdram233MHz,
		sdram250MHz,
		sdram275MHz);

	type sdram_params is record
		pll : pll_params;
		cas : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (sdram_speed) of sdram_params;
	constant sdram_tab : sdramparams_vector := (
		sdram133MHz => (pll => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos2_div => 3, clkos3_div => 0), cas => "010"),
		sdram166MHz => (pll => (clkos_div => 2, clkop_div => 20, clkfb_div => 1, clki_div => 1, clkos2_div => 3, clkos3_div => 0), cas => "011"),
		sdram200MHz => (pll => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos2_div => 2, clkos3_div => 0), cas => "011"),
		sdram225MHz => (pll => (clkos_div => 2, clkop_div => 27, clkfb_div => 1, clki_div => 1, clkos2_div => 3, clkos3_div => 0), cas => "011"),
		sdram233MHz => (pll => (clkos_div => 2, clkop_div => 28, clkfb_div => 1, clki_div => 1, clkos2_div => 3, clkos3_div => 0), cas => "011"),
		sdram250MHz => (pll => (clkos_div => 2, clkop_div => 20, clkfb_div => 1, clki_div => 1, clkos2_div => 2, clkos3_div => 0), cas => "011"),
		sdram275MHz => (pll => (clkos_div => 2, clkop_div => 22, clkfb_div => 1, clki_div => 1, clkos2_div => 2, clkos3_div => 0), cas => "011"));

	alias ctlr_clk     : std_logic is ddrsys_clks(0);

	constant mem_size : natural := 8*(1024*8);
	signal so_frm     : std_logic;
	signal so_irdy    : std_logic;
	signal so_trdy    : std_logic;
	signal so_data    : std_logic_vector(0 to 8-1);
	signal si_frm     : std_logic;
	signal si_irdy    : std_logic;
	signal si_trdy    : std_logic;
	signal si_end     : std_logic;
	signal si_data    : std_logic_vector(0 to 8-1);

	signal sio_clk    : std_logic;

	alias dmacfg_clk  : std_logic is sio_clk;
	alias uart_clk    : std_logic is sio_clk;

	type io_iface is (
		io_hdlc,
		io_ipoe);

	type app_record is record
		iface : io_iface;
		mode  : video_modes;
		speed : sdram_speed;
	end record;

	type app_vector is array (apps) of app_record;
	constant app_tab : app_vector := (
		uart_250MHz_480p24bpp => (iface => io_hdlc, mode => mode480p24, speed => sdram250MHz),
		uart_133MHz_600p16bpp => (iface => io_hdlc, mode => mode600p16, speed => sdram133MHz),
		uart_166MHz_600p16bpp => (iface => io_hdlc, mode => mode600p16, speed => sdram166MHz),
		uart_200MHz_600p16bpp => (iface => io_hdlc, mode => mode600p16, speed => sdram200MHz),
		uart_250MHz_600p16bpp => (iface => io_hdlc, mode => mode600p16, speed => sdram250MHz),
		mii_166MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => sdram166MHz),
		mii_200MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => sdram200MHz),
		mii_250MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => sdram250MHz));

	constant nodebug_videomode : video_modes := app_tab(app).mode;
	constant video_mode   : video_modes := video_modes'VAL(setif(debug,
		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode)));

    signal video_pixel    : std_logic_vector(0 to setif(
		video_tab(app_tab(app).mode).pixel=rgb565, 16, setif(
		video_tab(app_tab(app).mode).pixel=rgb888, 32, 0))-1);

	constant sdram_mode : sdram_speed := sdram_speed'VAL(setif(not debug,
		sdram_speed'POS(app_tab(app).speed),
		sdram_speed'POS(sdram133Mhz)));

	constant ddr_tcp  : natural := natural(
		(1.0e12*real(sdram_tab(sdram_mode).pll.clki_div*sdram_tab(sdram_mode).pll.clkos2_div))/
		(real(sdram_tab(sdram_mode).pll.clkfb_div*sdram_tab(sdram_mode).pll.clkop_div)*sys_freq));

	constant io_link : io_iface := app_tab(app).iface;

begin

	sys_rst <= '0';
	videopll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOS2 : string;
		attribute FREQUENCY_PIN_CLKOS3 : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		constant video_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos2_div*1e6));

		constant video_shift_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos_div*1e6));

		constant videoio_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos3_div*1e6));

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is ftoa(video_shift_freq, 10);
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is ftoa(video_freq,       10);
		attribute FREQUENCY_PIN_CLKOS3 of pll_i : label is ftoa(videoio_freq,     10);
		attribute FREQUENCY_PIN_CLKI   of pll_i : label is ftoa(sys_freq/1.0e6,   10);
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is ftoa(sys_freq/1.0e6,   10);

		signal clkfb : std_logic;

	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED",
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED",
			PLL_LOCK_MODE    =>  0,
			FEEDBK_PATH      => "CLKOP",
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0,
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => video_tab(video_mode).pll.clkop_div-1,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS_DIV        => video_tab(video_mode).pll.clkos_div,
			CLKOS2_DIV       => video_tab(video_mode).pll.clkos2_div,
			CLKOS3_DIV       => video_tab(video_mode).pll.clkos3_div,
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

	ctlrpll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOS2 : string;
		attribute FREQUENCY_PIN_CLKOS3 : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;


		constant sdram_freq  : real :=
			(real(sdram_tab(sdram_mode).pll.clkfb_div*sdram_tab(sdram_mode).pll.clkop_div)*sys_freq)/
			(real(sdram_tab(sdram_mode).pll.clki_div*sdram_tab(sdram_mode).pll.clkos2_div*1e6));

		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is ftoa(sdram_freq, 10);
		attribute FREQUENCY_PIN_CLKI   of pll_i : label is ftoa(sys_freq/1.0e6, 10);
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is ftoa(sys_freq/1.0e6, 10);

		signal clkfb : std_logic;

	begin

		assert false
		report real'image(sdram_freq)
		severity NOTE;

		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED",
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED",
			PLL_LOCK_MODE    =>  0,
			FEEDBK_PATH      => "CLKOP",
			CLKOS_ENABLE     => "DISABLED", CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0,
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => sdram_tab(sdram_mode).pll.clkop_div-1,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

--			CLKOS_DIV        => sdram_tab(sdram_mode).pll.clkos_div,
			CLKOS2_DIV       => sdram_tab(sdram_mode).pll.clkos2_div,
--			CLKOS3_DIV       => sdram_tab(sdram_mode).pll.clkos3_div,
			CLKOP_DIV        => sdram_tab(sdram_mode).pll.clkop_div,
			CLKFB_DIV        => sdram_tab(sdram_mode).pll.clkfb_div,
			CLKI_DIV         => sdram_tab(sdram_mode).pll.clki_div)
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
			CLKOS     => open,
			CLKOS2    => ctlr_clk,
			CLKOS3    => open,
			LOCK      => sdram_lck,
            INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);

		ddrsys_rst <= not sdram_lck;

		ctlrphy_dso <= (others => not ctlr_clk) when sdram_mode/=sdram133MHz or debug=true else (others => ctlr_clk);

	end block;

	hdlc_g : if io_link=io_hdlc generate

		constant uart_xtal : natural := natural(
			(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div*natural(sys_freq))/
			(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos3_div));

		constant uart_xtal16 : natural := uart_xtal/16;

		constant baudrate : natural := setif(
			uart_xtal >= 32000000, 3000000, setif(
			uart_xtal >= 25000000, 2000000,
                                   115200));

		signal uart_rxdv  : std_logic;
		signal uart_rxd   : std_logic_vector(0 to 8-1);
		signal uarttx_frm : std_logic;
		signal uart_idle  : std_logic;
		signal uart_txen  : std_logic;
		signal uart_txd   : std_logic_vector(uart_rxd'range);

		signal tp         : std_logic_vector(1 to 32);

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
--					led <= uart_rxd;
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
			uart_frm  => video_lck,
			uart_irdy => uart_txen,
			uart_trdy => uart_idle,
			uart_data => uart_txd);

			led(0) <= si_frm;
			led(2) <= si_irdy;
		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size  => mem_size)
		port map (
			uart_clk  => uart_clk,
			uartrx_irdy => uart_rxdv,
			uartrx_data => uart_rxd,
			uarttx_frm  => uarttx_frm,
			uarttx_trdy => uart_idle,
			uarttx_data => uart_txd,
			uarttx_irdy => uart_txen,
			sio_clk   => sio_clk,
			so_frm    => so_frm,
			so_irdy   => so_irdy,
			so_trdy   => so_trdy,
			so_data   => so_data,

			si_frm    => si_frm,
			si_irdy   => si_irdy,
			si_trdy   => si_trdy,
			si_end    => si_end,
			si_data   => si_data,
			tp        => tp);

	end generate;

	ipoe_e : if io_link=io_ipoe generate
		-- RMII pins as labeled on the board and connected to ULX3S with pins down and flat cable
		alias rmii_tx_en : std_logic is gn(10);
		alias rmii_tx0   : std_logic is gp(10);
		alias rmii_tx1   : std_logic is gn(9);

		alias rmii_rx0   : std_logic is gn(11);
		alias rmii_rx1   : std_logic is gp(11);

		alias rmii_crs   : std_logic is gp(12);

		alias rmii_nint  : std_logic is gn(12);
		alias rmii_mdio  : std_logic is gn(13);
		alias rmii_mdc   : std_logic is gp(13);
		signal mii_clk   : std_logic;

		signal mii_txen  : std_logic;
		signal mii_txd   : std_logic_vector(0 to 2-1);

		signal mii_rxdv  : std_logic;
		signal mii_rxd   : std_logic_vector(0 to 2-1);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		wifi_en <= '0';

		sio_clk <= rmii_nint;
		mii_clk <= rmii_nint;

		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				rmii_tx_en <= mii_txen;
				(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;
			end if;
		end process;

		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				mii_rxdv <= rmii_crs;
				mii_rxd  <= rmii_rx0 & rmii_rx1;
			end if;
		end process;

		rmii_mdc  <= '0';
		rmii_mdio <= '0';

		dhcp_p : process(mii_clk)
		begin
			if rising_edge(mii_clk) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					dhcpcd_req <= dhcpcd_rdy xor ((fire2 and dhcpcd_rdy) or (fire1 and not dhcpcd_rdy));
				end if;
			end if;
		end process;
		led(0) <= dhcpcd_rdy;
		led(7) <= not dhcpcd_rdy;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			default_ipv4a => aton("192.168.1.1"))
		port map (
			hdplx      => '1',
			sio_clk    => mii_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => mii_rxdv,
			miirx_data => mii_rxd,

			miitx_frm  => miitx_frm,
			miitx_irdy => miitx_irdy,
			miitx_trdy => miitx_trdy,
			miitx_end  => miitx_end,
			miitx_data => miitx_data,

			si_frm     => si_frm,
			si_irdy    => si_irdy,
			si_trdy    => si_trdy,
			si_end     => si_end,
			si_data    => si_data,

			so_frm     => so_frm,
			so_irdy    => so_irdy,
			so_trdy    => so_trdy,
			so_data    => so_data);

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => mii_clk,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => mii_txd);

		mii_txen <= miitx_frm and not miitx_end;

	end generate;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		profile      => 0,

		ddr_tcp      => ddr_tcp,
		fpga         => fpga,
		mark         => mark,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_tab(video_mode).mode,
		red_length   => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		green_length => setif(video_tab(video_mode).pixel=rgb565, 6, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		blue_length  => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		fifo_size    => mem_size)

	port map (
		sio_clk      => sio_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => video_clk,
		video_shift_clk => video_shft_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		dmacfg_clk   => dmacfg_clk,
		ctlr_clks(0) => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => sdram_tab(sdram_mode).cas,

		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke,
		ctlrphy_cs   => ctlrphy_cs,
		ctlrphy_ras  => ctlrphy_ras,
		ctlrphy_cas  => ctlrphy_cas,
		ctlrphy_we   => ctlrphy_we,
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dsi  => ctlrphy_dsi,
		ctlrphy_dst  => ctlrphy_dst,
		ctlrphy_dso  => open,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	sdram_sti : entity hdl4fpga.align
	generic map (
		n => sdrphy_sti'length,
		d => (0 to sdrphy_sti'length-1 => setif(sdram_mode/=sdram133MHz, 1, 0)))
	port map (
		clk => ctlr_clk,
		di  => ctlrphy_sto,
		do  => sdrphy_sti);

	sdrphy_e : entity hdl4fpga.sdrphy
	generic map (
		cmmd_latency  => false,
		read_latency  => true,
		write_latency => true,
		bank_size     => sdram_ba'length,
		addr_size     => sdram_a'length,
		word_size     => word_size,
		byte_size     => byte_size)
	port map (
		sys_clk       => ctlr_clk,
		sys_rst       => ddrsys_rst,

		phy_cs        => ctlrphy_cs,
		phy_cke       => ctlrphy_cke,
		phy_ras       => ctlrphy_ras,
		phy_cas       => ctlrphy_cas,
		phy_we        => ctlrphy_we,
		phy_b         => ctlrphy_b,
		phy_a         => ctlrphy_a,
		phy_dsi       => ctlrphy_dso,
		phy_dst       => ctlrphy_dst,
		phy_dso       => ctlrphy_dsi,
		phy_dmi       => ctlrphy_dmo,
		phy_dmt       => ctlrphy_dmt,
		phy_dmo       => ctlrphy_dmi,
		phy_dqi       => ctlrphy_dqo,
		phy_dqt       => ctlrphy_dqt,
		phy_dqo       => ctlrphy_dqi,
		phy_sti       => sdrphy_sti,
		phy_sto       => ctlrphy_sti,

		sdr_clk       => sdram_clk,
		sdr_cke       => sdram_cke,
		sdr_cs        => sdram_csn,
		sdr_ras       => sdram_rasn,
		sdr_cas       => sdram_casn,
		sdr_we        => sdram_wen,
		sdr_b         => sdram_ba,
		sdr_a         => sdram_a,

		sdr_dm        => sdram_dqm,
		sdr_dq        => sdram_d);

	-- VGA --
	---------

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
