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
use hdl4fpga.profiles.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx4m_ld is

	--------------------------------------
	-- Set of profiles                  --
	type app_profiles is (
	--	Interface_SdramSpeed_PixelFormat--

		uart_325MHz_480p24bpp,
		uart_350MHz_480p24bpp,
		uart_375MHz_480p24bpp,
		uart_400MHz_480p24bpp,
		uart_425MHz_480p24bpp,
		uart_450MHz_480p24bpp,
		uart_475MHz_480p24bpp,
		uart_500MHz_480p24bpp,

		uart_350MHz_600p24bpp,
		uart_400MHz_600p24bpp,

		uart_350MHz_1080p24bpp30,
		uart_375MHz_1080p24bpp30,
		uart_400MHz_1080p24bpp30,
		uart_425MHz_1080p24bpp30,
		uart_450MHz_1080p24bpp30,
		uart_475MHz_1080p24bpp30,
		uart_500MHz_1080p24bpp30,

		mii_400MHz_480p24bpp,
		mii_425MHz_480p24bpp,
		mii_450MHz_480p24bpp,
		mii_475MHz_480p24bpp,
		mii_500MHz_480p24bpp);
	--------------------------------------

	---------------------------------------------
	-- Set your profile here                   --
	constant app_profile  : app_profiles := uart_425MHz_1080p24bpp30;

	---------------------------------------------

	type profile_params is record
		comms       : io_comms;
		sdram_speed : sdram_speeds;
		video_mode  : video_modes;
		hack        : real;
	end record;

	type profileparams_vector is array (app_profiles) of profile_params;
	constant profile_tab : profileparams_vector := (
		uart_325MHz_480p24bpp    => (io_hdlc, sdram325MHz, mode480p24bpp,    hack => 1.0),
		uart_350MHz_480p24bpp    => (io_hdlc, sdram350MHz, mode480p24bpp,    hack => 1.0),
		uart_375MHz_480p24bpp    => (io_hdlc, sdram375MHz, mode480p24bpp,    hack => 1.0),
		uart_400MHz_480p24bpp    => (io_hdlc, sdram400MHz, mode480p24bpp,    hack => 1.0),
		uart_425MHz_480p24bpp    => (io_hdlc, sdram425MHz, mode480p24bpp,    hack => 1.0625),
		uart_450MHz_480p24bpp    => (io_hdlc, sdram450MHz, mode480p24bpp,    hack => 1.125),
		uart_475MHz_480p24bpp    => (io_hdlc, sdram475MHz, mode480p24bpp,    hack => 1.250),
		uart_500MHz_480p24bpp    => (io_hdlc, sdram500MHz, mode480p24bpp,    hack => 1.375),
                                                   
		uart_350MHz_600p24bpp    => (io_hdlc, sdram350MHz, mode600p24bpp,    hack => 1.0),
		uart_400MHz_600p24bpp    => (io_hdlc, sdram400MHz, mode600p24bpp,    hack => 1.0),

		uart_350MHz_1080p24bpp30 => (io_hdlc, sdram350MHz, mode1080p24bpp30, hack => 1.0),
		uart_375MHz_1080p24bpp30 => (io_hdlc, sdram375MHz, mode1080p24bpp30, hack => 1.0),
		uart_400MHz_1080p24bpp30 => (io_hdlc, sdram400MHz, mode1080p24bpp30, hack => 1.0),
		uart_425MHz_1080p24bpp30 => (io_hdlc, sdram425MHz, mode1080p24bpp30, hack => 1.0625),
		uart_450MHz_1080p24bpp30 => (io_hdlc, sdram450MHz, mode1080p24bpp30, hack => 1.125),
		uart_475MHz_1080p24bpp30 => (io_hdlc, sdram475MHz, mode1080p24bpp30, hack => 1.1875),
		uart_500MHz_1080p24bpp30 => (io_hdlc, sdram500MHz, mode1080p24bpp30, hack => 1.250),
                                                                    
		mii_400MHz_480p24bpp     => (io_ipoe, sdram400MHz, mode480p24bpp,    hack => 1.0),
		mii_425MHz_480p24bpp     => (io_ipoe, sdram425MHz, mode480p24bpp,    hack => 1.0625),
		mii_450MHz_480p24bpp     => (io_ipoe, sdram450MHz, mode480p24bpp,    hack => 1.125),
		mii_475MHz_480p24bpp     => (io_ipoe, sdram475MHz, mode480p24bpp,    hack => 1.250),
		mii_500MHz_480p24bpp     => (io_ipoe, sdram500MHz, mode480p24bpp,    hack => 1.375));

	type pll_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos2_div : natural;
		clkos3_div : natural;
	end record;

	type video_params is record
		id     : video_modes;
		pll    : pll_params;
		timing : videotiming_ids;
		pixel  : pixel_types;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant v_r : natural := 5; -- video ratio
	constant video_tab : videoparams_vector := (
		(id => modedebug,        pll => (clkos_div => 5, clkop_div => 25,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*5, clkos3_div => 16), pixel => rgb888, timing => pclk_debug),
		(id => mode480p24bpp,    pll => (clkos_div => 5, clkop_div => 25,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*5, clkos3_div => 16), pixel => rgb888, timing => pclk25_00m640x480at60),
		(id => mode600p24bpp,    pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*2, clkos3_div => 10), pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode900p24bpp,    pll => (clkos_div => 2, clkop_div => 22,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*2, clkos3_div => 14), pixel => rgb888, timing => pclk108_00m1600x900at60), -- 30 Hz
		(id => mode1080p24bpp30, pll => (clkos_div => 2, clkop_div => 30,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*2, clkos3_div => 19), pixel => rgb888, timing => pclk150_00m1920x1080at60)); -- 30 Hz

	function videoparam (
		constant id  : video_modes)
		return video_params is
		constant tab : videoparams_vector := video_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>videoparam<<< : video id not available"
		severity failure;

		return tab(tab'left);
	end;

	constant nodebug_videomode : video_modes := profile_tab(app_profile).video_mode;
	constant video_mode   : video_modes := video_modes'VAL(setif(debug,
		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode)));
	-- constant video_mode   : video_modes := nodebug_videomode;
	constant video_record : video_params := videoparam(video_mode);

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
		wrl : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram325MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 13, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram350MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 14, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram375MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 15, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram400MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 16, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram425MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 17, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram450MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 18, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram475MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 19, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "100"),
		(id => sdram500MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 20, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001", wrl => "100"));

	function sdramparams (
		constant id  : sdram_speeds)
		return sdramparams_record is
		constant tab : sdramparams_vector := sdram_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>sdramparams<<< : sdram speed not enabled"
		severity failure;

		return tab(tab'left);
	end;

	constant sdram_mode : sdram_speeds := profile_tab(app_profile).sdram_speed;
	-- constant sdram_mode : sdram_speeds := sdram_speeds'VAL(setif(not debug,
		-- sdram_speeds'POS(profile_tab(app_profile).sdram_speed),
		-- sdram_speeds'POS(sdram400Mhz)));
	constant sdram_params : sdramparams_record := sdramparams(sdram_mode);

	constant sdram_tcp : real := 
		real(sdram_params.pll.clki_div)/
		(real(sdram_params.pll.clkos_div*sdram_params.pll.clkfb_div)*sys_freq);

	constant sclk_phases : natural := 1;
	constant sclk_edges  : natural := 1;
	constant cmmd_gear   : natural := 2;
	constant data_edges  : natural := 1;
	constant data_gear   : natural := 4;

	constant bank_size   : natural := ddram_ba'length;
	constant addr_size   : natural := ddram_a'length;
	constant coln_size   : natural := 10;
	constant word_size   : natural := ddram_dq'length;
	constant byte_size   : natural := ddram_dq'length/ddram_dqs'length;

	signal sys_rst       : std_logic;

	signal ddrsys_rst    : std_logic;
	signal ddrphy_rst    : std_logic;
	signal ddrphy_rdy    : std_logic;
	signal physys_clk    : std_logic;

	signal dramclk_lck   : std_logic;

	signal ctlrphy_frm   : std_logic;
	signal ctlrphy_trdy  : std_logic;
	signal ctlrphy_ini   : std_logic;
	signal ctlrphy_rw    : std_logic;
	signal ctlrphy_wlreq : std_logic;
	signal ctlrphy_wlrdy : std_logic;
	signal ctlrphy_rlreq : std_logic;
	signal ctlrphy_rlrdy : std_logic;

	signal ctlrphy_rst   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cke   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cs    : std_logic_vector(0 to 2-1);
	signal ctlrphy_ras   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cas   : std_logic_vector(0 to 2-1);
	signal ctlrphy_we    : std_logic_vector(0 to 2-1);
	signal ctlrphy_odt   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cmd   : std_logic_vector(0 to 3-1);
	signal ctlrphy_ba    : std_logic_vector(cmmd_gear*ddram_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(cmmd_gear*ddram_a'length-1 downto 0);
	signal ctlrphy_dsi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dst   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dso   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal sdr_ba        : std_logic_vector(ddram_ba'length-1 downto 0);
	signal sdr_a         : std_logic_vector(ddram_a'length-1 downto 0);

	signal video_clk     : std_logic;
	signal videoio_clk   : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal dvid_crgb     : std_logic_vector(8-1 downto 0);


	signal ctlr_clk      : std_logic;

	constant mem_size    : natural := 8*(1024*8);
	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	signal sio_clk       : std_logic;

    signal video_pixel   : std_logic_vector(0 to 32-1);

	constant io_link     : io_comms := profile_tab(app_profile).comms;

	constant hdplx       : std_logic := setif(debug, '0', '1');

	signal tp            : std_logic_vector(1 to 32);
	signal tp_phy        : std_logic_vector(1 to 32);
	signal sdrphy_locked : std_logic;

begin

	sys_rst <= '0';
	videopll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOS2 : string;
		attribute FREQUENCY_PIN_CLKOS3 : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		constant video_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkos2_div*1e6));

		constant video_shift_freq  : real := 
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkos_div*1e6));

		constant videoio_freq  : real := 
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkos3_div*1e6));

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
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => video_record.pll.clkop_div-1,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS_DIV        => video_record.pll.clkos_div,
			CLKOS2_DIV       => video_record.pll.clkos2_div,
			CLKOS3_DIV       => video_record.pll.clkos3_div,
			CLKOP_DIV        => video_record.pll.clkop_div,
			CLKFB_DIV        => video_record.pll.clkfb_div,
			CLKI_DIV         => video_record.pll.clki_div)
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

		constant ddram_mhz : real := 1.0e-6/sdram_tcp;
		constant hack      : real := profile_tab(app_profile).hack;

		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(ddram_mhz/hack, 10);
		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(sys_freq/hack/1.0e6, 10);

		signal clkfb : std_logic;

	begin

		assert false
		report real'image(ddram_mhz)
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
			CLKOS2_ENABLE    => "DISABLED", CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => sdram_params.pll.clkop_div-1,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

--			CLKOS_DIV        => sdram_params.pll.clkos_div,
--			CLKOS2_DIV       => sdram_params.pll.clkos2_div,
--			CLKOS3_DIV       => sdram_params.pll.clkos3_div,
			CLKOP_DIV        => sdram_params.pll.clkop_div,
			CLKFB_DIV        => sdram_params.pll.clkfb_div,
			CLKI_DIV         => sdram_params.pll.clki_div)
        port map (
			rst       => '0',
			clki      => clk_25mhz,
			CLKFB     => physys_clk,
            PHASESEL0 => '0', PHASESEL1 => '0',
			PHASEDIR  => '0',
            PHASESTEP => '0', PHASELOADREG => '0',
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0',
			ENCLKOS   => '0',
			ENCLKOS2  => '0',
            ENCLKOS3  => '0',
			CLKOP     => physys_clk,
			CLKOS     => open,
			CLKOS2    => open,
			CLKOS3    => open,
			LOCK      => dramclk_lck,
            INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);

	end block;

	hdlc_g : if io_link=io_hdlc generate

		constant uart_xtal : real := 
			real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq/
			real(video_record.pll.clki_div*video_record.pll.clkos3_div);

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

		signal tp         : std_logic_vector(1 to 32);

		signal dummy_txd  : std_logic_vector(uart_rxd'range);
		alias uart_clk    : std_logic is sio_clk;

	begin

		process (uart_clk)
			variable q0 : std_logic := '0';
			variable q1 : std_logic := '0';
		begin
			if rising_edge(uart_clk) then
				-- led(1) <= q1;
				-- led(7) <= q0;
				if tp(1)='1' then
					if tp(2)='1' then
						q1 := not q1;
					end if;
				end if;
				if uart_rxdv='1' then
					q0 := not q0;
				end if;
			end if;
		end process;

		process (dummy_txd ,uart_clk)
			variable q : std_logic := '0';
			variable e : std_logic := '1';
		begin
			if rising_edge(uart_clk) then
				-- led(5) <= q;
				if (so_frm and not e)='1' then
					q := not q;
				end if;
				-- led(4) <= so_frm;
				e := so_frm;
			end if;
		end process;

		ftdi_txden <= '1';
		nodebug_g : if not debug generate
			uart_clk <= videoio_clk;
		end generate;

		debug_g : if debug generate
			uart_clk <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
		end generate;

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

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => uart_clk,
			uart_frm  => video_lck,
			uart_irdy => uart_txen,
			uart_trdy => uart_idle,
			uart_data => uart_txd,
			uart_sout => ftdi_rxd);

		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size    => mem_size)
		port map (
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
			si_data     => si_data,
			tp          => tp);

	end generate;

	
	assert io_link/=io_ipoe 
	report "NO mii ready"
	severity FAILURE;

	graphics_e : entity hdl4fpga.demo_graphics
	generic map (
		ena_burstref  => false,
		-- debug        => true,
		debug        => debug,
		profile      => 2,

		sdram_tcp      => 2.0*sdram_tcp,
		fpga         => ecp5,
		-- mark         => MT41K8G107,
		mark         => MT41K8G125,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		burst_length => 8,
		data_phases  => data_gear,
		data_edges   => data_edges,
		data_gear    => data_gear,
		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		red_length   => 8,
		green_length => 8,
		blue_length  => 8,
		timing_id    => video_record.timing,
		fifo_size    => mem_size)
	port map (
		sin_clk      => sio_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_clk     => sio_clk,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => video_clk,
		video_shift_clk => video_shift_clk,
		-- video_clk    => '0',
		-- video_shift_clk => '0',
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clks(0) => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => sdram_params.cl,
		ctlr_cwl     => sdram_params.cwl,
		ctlr_wrl     => sdram_params.wrl, --"010",
		ctlr_rtt     => "001",
		ctlr_cmd     => ctlrphy_cmd,
		ctlr_inirdy  => tp(1),

		ctlrphy_wlreq => ctlrphy_wlreq,
		ctlrphy_wlrdy => ctlrphy_wlrdy,
		ctlrphy_rlreq => ctlrphy_rlreq,
		ctlrphy_rlrdy => ctlrphy_rlrdy,

		ctlrphy_irdy => ctlrphy_frm,
		ctlrphy_trdy => ctlrphy_trdy,
		ctlrphy_ini  => ctlrphy_ini,
		ctlrphy_rw   => ctlrphy_rw,

		ctlrphy_rst  => ctlrphy_rst(0),
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_odt  => ctlrphy_odt(0),
		ctlrphy_b    => sdr_ba,
		ctlrphy_a    => sdr_a,
		ctlrphy_dsi  => ctlrphy_dsi,
		ctlrphy_dst  => ctlrphy_dst,
		ctlrphy_dso  => ctlrphy_dso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	tp(2) <= not (ctlrphy_wlreq xor ctlrphy_wlrdy);
	tp(3) <= not (ctlrphy_rlreq xor ctlrphy_rlrdy);
	tp(4) <= ctlrphy_ini;

	process (clk_25mhz)
	begin
		if rising_edge(clk_25mhz) then
			led(0) <= sdrphy_locked;
			led(7 downto 1) <= tp_phy(1 to 7);
		end if;
	end process;

	process (sdr_ba)
	begin
		for i in sdr_ba'range loop
			for j in 0 to cmmd_gear-1 loop
				ctlrphy_ba(i*cmmd_gear+j) <= sdr_ba(i);
			end loop;
		end loop;
	end process;

	process (sdr_a)
	begin
		for i in sdr_a'range loop
			for j in 0 to cmmd_gear-1 loop
				ctlrphy_a(i*cmmd_gear+j) <= sdr_a(i);
			end loop;
		end loop;
	end process;

	ctlrphy_rst(1) <= ctlrphy_rst(0);
	ctlrphy_cke(1) <= ctlrphy_cke(0);
	ctlrphy_cs(1)  <= ctlrphy_cs(0);
	ctlrphy_ras(1) <= '1';
	ctlrphy_cas(1) <= '1';
	ctlrphy_we(1)  <= '1';
	ctlrphy_odt(1) <= ctlrphy_odt(0);

	ddrphy_rst <= not dramclk_lck;
	process (ddrphy_rst, ddrphy_rdy, ctlr_clk)
	begin
		if ddrphy_rst='1' then
			ddrsys_rst <= '1';
		elsif ddrphy_rdy='0' then
			ddrsys_rst <= '1';
		elsif rising_edge(ctlr_clk) then
			ddrsys_rst <= not dramclk_lck;
		end if;
	end process;
	
	tp_b : block
		signal tp_dv : std_logic;
	begin
		process (ctlr_clk)
			variable q : std_logic;
			variable q1 : std_logic := '0';
		begin
			if rising_edge(ctlr_clk) then
				if ctlrphy_sti(0)='1' then
					if q='0' then
						q1 := not q1;
					end if;
				end if;
				q := ctlrphy_sti(0);
			tp_dv <= q1;
			end if;
		end process;
		
		process (clk_25mhz)
		begin
			if rising_edge(clk_25mhz) then
				-- led(1) <= tp_dv;
			end if;
		end process;
		
	end block;

	process (ctlr_clk)
		variable q0 : std_logic;
		variable q1 : std_logic;
	begin
		if rising_edge(ctlr_clk) then
			cam_scl  <= q0;
			gpio_scl <= q1;
			q0 := not q0;
			q1 := not q1;
		end if;
	end process;

	sdrphy_e : entity hdl4fpga.ecp5_sdrphy
	generic map (
		debug         => debug,
		sdr_tcp       => sdram_tcp,
		cmmd_gear     => cmmd_gear,
		data_gear     => data_gear,
		bank_size     => ddram_ba'length,
		addr_size     => ddram_a'length,
		word_size     => word_size,
		byte_size     => byte_size)
	port map (
		tpin          => btn(1),
		rst           => ddrphy_rst,
		sync_clk      => clk_25mhz,
		clkop         => physys_clk,
		sclk          => ctlr_clk,
		rdy           => ddrphy_rdy,
		phy_frm       => ctlrphy_frm,
		phy_trdy      => ctlrphy_trdy,
		phy_cmd       => ctlrphy_cmd,
		phy_rw        => ctlrphy_rw,
		phy_ini       => ctlrphy_ini,
		phy_locked    => sdrphy_locked,

		phy_wlreq     => ctlrphy_wlreq,
		phy_wlrdy     => ctlrphy_wlrdy,

		phy_rlreq     => ctlrphy_rlreq,
		phy_rlrdy     => ctlrphy_rlrdy,

		phy_rst       => ctlrphy_rst,
		phy_cs        => ctlrphy_cs,
		phy_cke       => ctlrphy_cke,
		phy_ras       => ctlrphy_ras,
		phy_cas       => ctlrphy_cas,
		phy_we        => ctlrphy_we,
		phy_odt       => ctlrphy_odt,
		phy_b         => ctlrphy_ba,
		phy_a         => ctlrphy_a,
		phy_dqsi      => ctlrphy_dso,
		phy_dqst      => ctlrphy_dst,
		phy_dqso      => ctlrphy_dsi,
		phy_dmi       => ctlrphy_dmo,
		phy_dmt       => ctlrphy_dmt,
		phy_dmo       => ctlrphy_dmi,
		phy_dqi       => ctlrphy_dqo,
		phy_dqt       => ctlrphy_dqt,
		phy_dqo       => ctlrphy_dqi,
		phy_sti       => ctlrphy_sto,
		phy_sto       => ctlrphy_sti,

		sdr_rst       => ddram_reset_n,
		sdr_ck        => ddram_clk,
		sdr_cke       => ddram_cke,
		sdr_cs        => ddram_cs_n,
		sdr_ras       => ddram_ras_n,
		sdr_cas       => ddram_cas_n,
		sdr_we        => ddram_we_n,
		sdr_odt       => ddram_odt,
		sdr_b         => ddram_ba,
		sdr_a         => ddram_a,

		sdr_dm        => open,
		sdr_dq        => ddram_dq,
		sdr_dqs       => ddram_dqs,
		tp => tp_phy);
	ddram_dm <= (others => '0');

	-- VGA --
	---------

	debug_q : if debug generate
		signal q : bit;
	begin
		q <= not q after 1 ns;
		rgmii_tx_clk <= to_stdulogic(q);
	end generate;

	nodebug_g : if not debug generate
		rgmii_ref_clk_i : oddrx1f
		port map(
			sclk => rgmii_rx_clk,
			rst  => '0',
			d0   => '1',
			d1   => '0',
			q    => rgmii_tx_clk);
	end generate;
	
	hdmi0_blue_i : oddrx1f
	port map(
		sclk => video_shift_clk,
		d0   => dvid_crgb(2*0),
		d1   => dvid_crgb(2*0+1),
		q    => hdmi0_blue);
 
	hdmi0_green_i : oddrx1f
	port map(
		sclk => video_shift_clk,
		d0   => dvid_crgb(2*1),
		d1   => dvid_crgb(2*1+1),
		q    => hdmi0_green);
 
	hdmi0_red_i : oddrx1f
	port map(
		sclk => video_shift_clk,
		d0   => dvid_crgb(2*2),
		d1   => dvid_crgb(2*2+1),
		q    => hdmi0_red);
 
	hdmi0_clock_i : oddrx1f
	port map(
		sclk => video_shift_clk,
		d0   => dvid_crgb(2*3),
		d1   => dvid_crgb(2*3+1),
		q    => hdmi0_clock);
 
	-- hdmi1_blue_i : oddrx1f
	-- port map(
		-- sclk => video_shift_clk,
		-- d0   => dvid_crgb(2*0),
		-- d1   => dvid_crgb(2*0+1),
		-- q    => hdmi1_blue);
--  
	-- hdmi1_green_i : oddrx1f
	-- port map(
		-- sclk => video_shift_clk,
		-- d0   => dvid_crgb(2*1),
		-- d1   => dvid_crgb(2*1+1),
		-- q    => hdmi1_green);
--  
	-- hdmi1_red_i : oddrx1f
	-- port map(
		-- sclk => video_shift_clk,
		-- d0   => dvid_crgb(2*2),
		-- d1   => dvid_crgb(2*2+1),
		-- q    => hdmi1_red);
--  
	-- hdmi1_clock_i : oddrx1f
	-- port map(
		-- sclk => video_shift_clk,
		-- d0   => dvid_crgb(2*3),
		-- d1   => dvid_crgb(2*3+1),
		-- q    => hdmi1_clock);
 
end;
