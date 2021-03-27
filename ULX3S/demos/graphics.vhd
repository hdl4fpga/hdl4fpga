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
use hdl4fpga.videopkg.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx3s is

	constant sys_freq     : real    := 25.0e6;

	constant fpga         : natural := spartan3;
	constant mark         : natural := M7E;

	constant sclk_phases  : natural := 1;
	constant sclk_edges   : natural := 1;
	constant data_phases  : natural := 1;
	constant data_edges   : natural := 1;
	constant cmmd_gear    : natural := 1;
	constant data_gear    : natural := 1;
	constant bank_size    : natural := sdram_ba'length;
	constant addr_size    : natural := sdram_a'length;
	constant coln_size    : natural := 9;
	constant word_size    : natural := sdram_d'length;
	constant byte_size    : natural := 8;

	signal sys_rst        : std_logic;
	signal sys_clk        : std_logic;

	signal ddrsys_rst     : std_logic;
	signal ddrsys_clks    : std_logic_vector(0 to 0);

	signal sdram_lck      : std_logic;
	signal sdram_dqs      : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ctlrphy_rst    : std_logic;
	signal ctlrphy_cke    : std_logic;
	signal ctlrphy_cs     : std_logic;
	signal ctlrphy_ras    : std_logic;
	signal ctlrphy_cas    : std_logic;
	signal ctlrphy_we     : std_logic;
	signal ctlrphy_odt    : std_logic;
	signal ctlrphy_b      : std_logic_vector(sdram_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector(sdram_a'length-1 downto 0);
	signal ctlrphy_dsi    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_dst    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dso    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal sdrphy_sti     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal sdram_st_dqs_open : std_logic;

	signal sdram_dst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqt      : std_logic_vector(sdram_d'range);
	signal sdram_do       : std_logic_vector(sdram_d'range);

	constant modedebug    : natural := 0;
	constant mode600p     : natural := 1;
	constant mode600p18   : natural := 2;
	constant mode600p24   : natural := 3;
	constant mode900p     : natural := 4;
	constant mode1080p    : natural := 5;

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

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug  => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk_debug),
		mode600p   => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk40_00m800x600at60),
		mode600p18 => (pll => (clkos_div => 3, clkop_div => 29,  clkfb_div => 1, clki_div => 1, clkos2_div => 18, clkos3_div => 2), pixel => rgb666, mode => pclk40_00m800x600at60),
		mode600p24 => (pll => (clkos_div => 2, clkop_div => 25,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 2), pixel => rgb888, mode => pclk40_00m800x600at60),
		mode900p   => (pll => (clkos_div => 1, clkop_div => 20,  clkfb_div => 1, clki_div => 1, clkos2_div =>  5, clkos3_div => 2), pixel => rgb565, mode => pclk100_00m1600x900at60),
		mode1080p  => (pll => (clkos_div => 1, clkop_div => 24,  clkfb_div => 1, clki_div => 1, clkos2_div =>  5, clkos3_div => 2), pixel => rgb565, mode => pclk120_00m1920x1080at50));

	constant nodebug_videomode : natural := mode600p;
--	constant nodebug_videomode : natural := mode600p18;
--	constant nodebug_videomode : natural := mode600p24;
--	constant nodebug_videomode : natural := mode900p;
--	constant nodebug_videomode : natural := mode1080p;

	constant videodot_freq : natural := 
		(video_tab(nodebug_videomode).pll.clkfb_div*video_tab(nodebug_videomode).pll.clkop_div*natural(sys_freq))/
		(video_tab(nodebug_videomode).pll.clki_div*video_tab(nodebug_videomode).pll.clkos2_div);

	constant video_mode   : natural := setif(debug, modedebug, nodebug_videomode);
--	constant video_mode   : natural := nodebug_videomode;

	signal video_clk      : std_logic;
	signal video_lck      : std_logic;
	signal video_shift_clk : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_blank    : std_logic;
    signal video_on       : std_logic;
    signal video_dot      : std_logic;
    signal video_pixel    : std_logic_vector(0 to setif(video_tab(video_mode).pixel=rgb565, 16, 32)-1);
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	type sdram_params is record
		pll : pll_params;
		cas : std_logic_vector(0 to 3-1);
	end record;

	type sdram_vector is array (natural range <>) of sdram_params;
	constant sdram133MHz  : natural := 0;
	constant sdram166MHz  : natural := 1;
	constant sdram200MHz  : natural := 2;
	constant sdram233MHz  : natural := 3;
	constant sdram250MHz  : natural := 4;
	constant sdram275MHz  : natural := 5;

--	constant sdram_mode   : natural := setif(debug, sdram133MHz, sdram133MHz);
--	constant sdram_mode   : natural := setif(debug, sdram133Mhz, sdram166MHz);
--	constant sdram_mode   : natural := setif(debug, sdram133Mhz, sdram200MHz);
--	constant sdram_mode   : natural := setif(debug, sdram133Mhz, sdram233MHz);
	constant sdram_mode   : natural := setif(debug, sdram133Mhz, sdram250MHz);
--	constant sdram_mode   : natural := setif(debug, sdram133Mhz, sdram275MHz);

	type sdramparams_vector is array (natural range <>) of sdram_params;
	constant sdram_tab : sdramparams_vector := (
		sdram133MHz => (pll => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos2_div => 0, clkos3_div => 3), cas => "010"),
		sdram166MHz => (pll => (clkos_div => 2, clkop_div => 20, clkfb_div => 1, clki_div => 1, clkos2_div => 0, clkos3_div => 3), cas => "011"),
		sdram200MHz => (pll => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos2_div => 0, clkos3_div => 2), cas => "011"),
		sdram233MHz => (pll => (clkos_div => 2, clkop_div => 28, clkfb_div => 1, clki_div => 1, clkos2_div => 0, clkos3_div => 3), cas => "011"),
		sdram250MHz => (pll => (clkos_div => 2, clkop_div => 20, clkfb_div => 1, clki_div => 1, clkos2_div => 0, clkos3_div => 2), cas => "011"),
		sdram275MHz => (pll => (clkos_div => 2, clkop_div => 22, clkfb_div => 1, clki_div => 1, clkos2_div => 0, clkos3_div => 2), cas => "011"));

	constant ddr_tcp   : natural := natural(
		(1.0e12*real(sdram_tab(sdram_mode).pll.clki_div*sdram_tab(sdram_mode).pll.clkos3_div))/
		(real(sdram_tab(sdram_mode).pll.clkfb_div*sdram_tab(sdram_mode).pll.clkop_div)*sys_freq));
	alias ctlr_clk     : std_logic is ddrsys_clks(0);

	constant mem_size  : natural := 8*(1024*8);
	signal sin_frm     : std_logic;
	signal sin_irdy    : std_logic;
	signal sin_data    : std_logic_vector(0 to 8-1);
	signal sout_frm    : std_logic;
	signal sout_irdy   : std_logic;
	signal sout_trdy   : std_logic;
	signal sout_data   : std_logic_vector(0 to 8-1);

	signal sio_clk     : std_logic;
	signal dmacfg_clk  : std_logic;

	-----------------
	-- Select link --
	-----------------

	constant io_hdlc : natural := 0;
	constant io_ipoe : natural := 1;

	constant io_link : natural := io_ipoe;

begin

	sys_rst <= '0';
	videopll_b : block

		signal clkfb : std_logic;

		attribute FREQUENCY_PIN_CLKI   : string; 
		attribute FREQUENCY_PIN_CLKOP  : string; 
		attribute FREQUENCY_PIN_CLKOS  : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is "25.000000";

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is setif(video_mode=mode600p,
			"200.000000", setif(video_mode=mode600p18,
			"240.000000", setif(video_mode=mode600p24,
			"320.000000",
			"400.000000")));
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is setif(video_mode=mode600p,
			"40.000000", setif(video_mode=mode600p18,
			"40.000000", setif(video_mode=mode600p24,
			"40.000000",
			"120.000000")));

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

		led(6) <= video_lck;
	end block;

	ctlrpll_b : block

		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKOS : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is  "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is  "25.000000";

		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is setif(sdram_mode=sdram133MHz, 
			"133.333333", setif(sdram_mode=sdram166Mhz,
			"166.666666", setif(sdram_mode=sdram200Mhz,
			"200.000000", setif(sdram_mode=sdram233Mhz,
			"233.000000", setif(sdram_mode=sdram250Mhz,
			"250.000000",
			"275.000000")))));

		signal clkfb : std_logic;
		signal dqs   : std_logic;
		signal clkos : std_logic;

	begin

		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED", 
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED", 
			PLL_LOCK_MODE    =>  0, 
			FEEDBK_PATH      => "CLKOP",
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => sdram_tab(sdram_mode).pll.clkop_div-1,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0, 
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKI_DIV         => sdram_tab(sdram_mode).pll.clki_div,
			CLKFB_DIV        => sdram_tab(sdram_mode).pll.clkfb_div,
			CLKOP_DIV        => sdram_tab(sdram_mode).pll.clkop_div,
			CLKOS_DIV        => sdram_tab(sdram_mode).pll.clkos_div,
			CLKOS2_DIV       => sdram_tab(sdram_mode).pll.clkos3_div, 
			CLKOS3_DIV       => sdram_tab(sdram_mode).pll.clkos3_div) 
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
			CLKOS     => clkos,
			CLKOS2    => ctlr_clk,
			CLKOS3    => dqs, 
			LOCK      => sdram_lck, 
            INTLOCK   => open, 
			REFCLK    => open,
			CLKINTFB  => open);

		ddrsys_rst <= not sdram_lck;
		led(7) <= sdram_lck;

		ctlrphy_dso <= (others => not ctlr_clk) when sdram_mode/=sdram133MHz or debug=true else (others => ctlr_clk);

	end block;

	hdlc_g : if io_link=io_hdlc generate

	--	constant uart_xtal : natural := natural(sys_freq);
	--	alias uart_clk     : std_logic is clk_25mhz;

		constant uart_xtal : natural := natural(videodot_freq);
		signal uart_clk    : std_logic;

		constant baudrate  : natural := 3000000;
	--	constant baudrate  : natural := 115200;

		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(0 to 8-1);
		signal uart_idle   : std_logic;
		signal uart_txen   : std_logic;
		signal uart_txd    : std_logic_vector(uart_rxd'range);

		signal tp          : std_logic_vector(1 to 32);

	begin

		uart_clk   <= video_clk;
		sio_clk    <= video_clk;
		dmacfg_clk <= video_clk;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_txd,
			uart_rxdv => uart_rxdv,
			uart_rxd  => uart_rxd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => uart_clk,
			uart_sout => ftdi_rxd,
			uart_idle => uart_idle,
			uart_txen => uart_txen,
			uart_txd  => uart_txd);

		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size  => mem_size)
		port map (
			uart_clk  => uart_clk,
			uart_rxdv => uart_rxdv,
			uart_rxd  => uart_rxd,
			uart_idle => uart_idle,
			uart_txd  => uart_txd,
			uart_txen => uart_txen,
			sio_clk   => sio_clk,
			so_frm    => sin_frm,
			so_irdy   => sin_irdy,
			so_data   => sin_data,

			si_frm    => sout_frm,
			si_irdy   => sout_irdy,
			si_trdy   => sout_trdy,
			si_data   => sout_data,
			tp        => tp);

		process (sio_clk)
			variable t : std_logic;
			variable e : std_logic;
			variable i : std_logic;
		begin
			if rising_edge(sio_clk) then
				if i='1' and e='0' then
					t := not t;
				end if;
				e := i;
				i := tp(1);

				led(0) <= t;
				led(1) <= not t;
			end if;
		end process;
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

		signal mii_txc   : std_logic;
		signal mii_txen  : std_logic;
		signal mii_txd   : std_logic_vector(0 to 2-1);

		signal mii_rxc   : std_logic;
		signal mii_rxdv  : std_logic;
		signal mii_rxd   : std_logic_vector(0 to 2-1);

		signal ipv4acfg_req  : std_logic := '0';

	begin
	
		dmacfg_clk <= video_clk;

		sio_clk <= rmii_nint;
		mii_txc <= rmii_nint;
		rmii_tx_en <= mii_txen;
		(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;

		mii_rxc  <= rmii_nint;
		mii_rxdv <= rmii_crs;
		mii_rxd  <= rmii_rx0 & rmii_rx1;

		rmii_mdc  <= '0';
		rmii_mdio <= 'Z';

		ipv4acfg_req <= not btn_pwr_n;
--		udpdaisy_e : entity hdl4fpga.sio_dayudp
--		generic map (
--			default_ipv4a => x"c0_a8_00_0e")
--		port map (
--			ipv4acfg_req => ipv4acfg_req,
--
--			phy_rxc   => mii_rxc,
--			phy_rx_dv => mii_rxdv,
--			phy_rx_d  => mii_rxd,
--
--			phy_txc   => mii_txc,
--			phy_tx_en => mii_txen,
--			phy_tx_d  => mii_txd,
--		
--			sio_clk   => sio_clk,
--			si_frm    => sout_frm,
--			si_irdy   => sout_irdy,
--			si_trdy   => sout_trdy,
--			si_data   => sout_data,
--
--			so_frm    => sin_frm,
--			so_irdy   => sin_irdy,
--			so_trdy   => '1',
--			so_data   => sin_data);

		process (sio_clk)
			variable t : std_logic;
			variable e : std_logic;
			variable i : std_logic;
		begin
			if rising_edge(sio_clk) then
				if i='1' and e='0' then
					t := not t;
				end if;
				e := i;
				i := mii_txen;

				led(0) <= t;
				led(1) <= not t;
			end if;
		end process;

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
		red_length   => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb666, 6, 8)),
		green_length => setif(video_tab(video_mode).pixel=rgb565, 6, setif(video_tab(video_mode).pixel=rgb666, 6, 8)),
		blue_length  => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb666, 6, 8)),
		fifo_size    => mem_size)

	port map (
		sio_clk      => sio_clk,
		sin_frm      => sin_frm,
		sin_irdy     => sin_irdy,
		sin_data     => sin_data,
		sout_frm     => sout_frm,
		sout_irdy    => sout_irdy,
		sout_trdy    => sout_trdy,
		sout_data    => sout_data,

		video_clk    => video_clk,
		video_shift_clk => video_shift_clk,
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
		bank_size   => sdram_ba'length,
		addr_size   => sdram_a'length,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		sys_clk     => ctlr_clk,
		sys_rst     => ddrsys_rst,

		phy_cs      => ctlrphy_cs,
		phy_cke     => ctlrphy_cke,
		phy_ras     => ctlrphy_ras,
		phy_cas     => ctlrphy_cas,
		phy_we      => ctlrphy_we,
		phy_b       => ctlrphy_b,
		phy_a       => ctlrphy_a,
		phy_dsi     => ctlrphy_dso,
		phy_dst     => ctlrphy_dst,
		phy_dso     => ctlrphy_dsi,
		phy_dmi     => ctlrphy_dmo,
		phy_dmt     => ctlrphy_dmt,
		phy_dmo     => ctlrphy_dmi,
		phy_dqi     => ctlrphy_dqo,
		phy_dqt     => ctlrphy_dqt,
		phy_dqo     => ctlrphy_dqi,
		phy_sti     => sdrphy_sti,
		phy_sto     => ctlrphy_sti,

		sdr_clk     => sdram_clk,
		sdr_cke     => sdram_cke,
		sdr_cs      => sdram_csn,
		sdr_ras     => sdram_rasn,
		sdr_cas     => sdram_casn,
		sdr_we      => sdram_wen,
		sdr_b       => sdram_ba,
		sdr_a       => sdram_a,

		sdr_dm      => sdram_dqm,
		sdr_dq      => sdram_d);

	-- VGA --
	---------

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
