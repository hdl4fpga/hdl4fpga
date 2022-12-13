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

library altera_mf;
use altera_mf.altera_mf_components.all;

architecture graphics of dk_dev_5cea7n is

	--------------------------------------
	-- Set of profiles                  --
	type app_profiles is (
	--	Interface_SdramSpeed_PixelFormat--

		uart_350MHz_480p24bpp,
		uart_375MHz_480p24bpp,
		uart_400MHz_480p24bpp,
		uart_425MHz_480p24bpp,
		uart_450MHz_480p24bpp,
		uart_475MHz_480p24bpp,
		uart_500MHz_480p24bpp,
		uart_400MHz_600p24bpp,


		mii_400MHz_480p24bpp,
		mii_425MHz_480p24bpp,
		mii_450MHz_480p24bpp,
		mii_475MHz_480p24bpp,
		mii_500MHz_480p24bpp);
	--------------------------------------

	---------------------------------------------
	-- Set your profile here                   --
	constant app_profile  : app_profiles := uart_350MHz_480p24bpp;
	---------------------------------------------

	type profile_params is record
		comms      : io_comms;
		sdram_speed  : sdram_speeds;
		video_mode : video_modes;
	end record;

	type profileparams_vector is array (app_profiles) of profile_params;
	constant profile_tab : profileparams_vector := (
		uart_350MHz_480p24bpp => (io_hdlc, sdram350MHz, mode480p24bpp),
		uart_375MHz_480p24bpp => (io_hdlc, sdram375MHz, mode480p24bpp),
		uart_400MHz_480p24bpp => (io_hdlc, sdram400MHz, mode480p24bpp),
		uart_400MHz_600p24bpp => (io_hdlc, sdram400MHz, mode600p24bpp),
		uart_425MHz_480p24bpp => (io_hdlc, sdram425MHz, mode480p24bpp),
		uart_450MHz_480p24bpp => (io_hdlc, sdram450MHz, mode480p24bpp),
		uart_475MHz_480p24bpp => (io_hdlc, sdram475MHz, mode480p24bpp),
		uart_500MHz_480p24bpp => (io_hdlc, sdram500MHz, mode480p24bpp),
                                                
		mii_400MHz_480p24bpp  => (io_ipoe, sdram400MHz, mode480p24bpp),
		mii_425MHz_480p24bpp  => (io_ipoe, sdram425MHz, mode480p24bpp),
		mii_450MHz_480p24bpp  => (io_ipoe, sdram450MHz, mode480p24bpp),
		mii_475MHz_480p24bpp  => (io_ipoe, sdram475MHz, mode480p24bpp),
		mii_500MHz_480p24bpp  => (io_ipoe, sdram500MHz, mode480p24bpp));

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
		(id => modedebug,     pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 16,    clkos3_div => 10), pixel => rgb888, timing => pclk_debug),
		(id => mode480p24bpp, pll => (clkos_div => 5, clkop_div => 25,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*5, clkos3_div => 16), pixel => rgb888, timing => pclk25_00m640x480at60),
		(id => mode600p16bpp, pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*2, clkos3_div => 10), pixel => rgb565, timing => pclk40_00m800x600at60),
		(id => mode600p24bpp, pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*2, clkos3_div => 10), pixel => rgb888, timing => pclk40_00m800x600at60),
		(id => mode900p24bpp, pll => (clkos_div => 2, clkop_div => 22,  clkfb_div => 1, clki_div => 1, clkos2_div => v_r*2, clkos3_div => 14), pixel => rgb888, timing => pclk108_00m1600x900at60)); -- 30 Hz

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
	constant video_record : video_params := videoparam(video_mode);

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram350MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 14, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000"),
		(id => sdram375MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 15, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000"),
		(id => sdram400MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 16, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "010", cwl => "000"),
		(id => sdram425MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 17, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001"),
		(id => sdram450MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 18, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001"),
		(id => sdram475MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 19, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001"),
		(id => sdram500MHz, pll => (clkos_div => 1, clkop_div => 1, clkfb_div => 20, clki_div => 1, clkos2_div => 1, clkos3_div => 1), cl => "011", cwl => "001"));

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

	constant sdram_mode : sdram_speeds := sdram_speeds'VAL(setif(not debug,
		sdram_speeds'POS(profile_tab(app_profile).sdram_speed),
		sdram_speeds'POS(sdram400Mhz)));
	constant sdram_params : sdramparams_record := sdramparams(sdram_mode);

	constant sdram_tcp : real := 
		real(sdram_params.pll.clki_div)/
		(real(sdram_params.pll.clkos_div*sdram_params.pll.clkfb_div)*sys_freq);

	constant sclk_phases : natural := 1;
	constant sclk_edges  : natural := 1;
	constant cmmd_gear   : natural := 2;
	constant data_edges  : natural := 1;
	constant data_gear   : natural := 4;

	constant bank_size   : natural := ddr3_ba'length;
	constant addr_size   : natural := ddr3_a'length;
	constant coln_size   : natural := 10;
	constant word_size   : natural := ddr3_dq'length;
	constant byte_size   : natural := ddr3_dq'length/ddr3_dqs_p'length;

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
	signal ctlrphy_ba    : std_logic_vector(cmmd_gear*ddr3_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(cmmd_gear*ddr3_a'length-1 downto 0);
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
	signal sdr_ba        : std_logic_vector(ddr3_ba'length-1 downto 0);
	signal sdr_a         : std_logic_vector(ddr3_a'length-1 downto 0);

	signal video_clk      : std_logic;
	signal videoio_clk    : std_logic;
	signal video_lck      : std_logic;
	signal video_shft_clk : std_logic;
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);


	signal ctlr_clk   : std_logic;

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


    signal video_pixel : std_logic_vector(0 to setif(
		video_record.pixel=rgb565, 16, setif(
		video_record.pixel=rgb888, 32, 0))-1);

	constant io_link : io_comms := profile_tab(app_profile).comms;

	constant hdplx   : std_logic := setif(debug, '0', '1');

	signal tp : std_logic_vector(1 to 32);
	signal tp_phy : std_logic_vector(1 to 32);
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

		constant ddr3_mhz : real := 1.0e-6/sdram_tcp;


		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(ddr3_mhz, 10);
		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(sys_freq/1.0e6, 10);

		signal clkfb : std_logic;

	begin

		assert false
		report real'image(ddr3_mhz)
		severity NOTE;

		ddrpll_i :  altpll
    	generic map (
    		bandwidth :	natural := 0;
    		bandwidth_type : string := "AUTO";

    		port_clk0                   : string := "PORT_CONNECTIVITY";
    		c0_high                     : natural := 0;
    		c0_initial                  : natural := 0;
    		c0_low                      : natural := 0;
    		c0_mode                     : string := "BYPASS";
    		c0_ph                       : natural := 0;
    		c0_test_source              : natural := 5;
    		clk0_counter                : string := "G0";
    		clk0_divide_by              : natural := 1;
    		clk0_duty_cycle	            : natural := 50;
    		clk0_multiply_by            : natural := 1;
    		clk0_output_frequency       : natural := 0;
    		clk0_phase_shift            : string := "0";
    		clk0_time_delay             : string := "0";
    		clk0_use_even_counter_mode  : string := "OFF";
    		clk0_use_even_counter_value : string := "OFF";

    		port_clk1                   : string := "PORT_CONNECTIVITY";
    		c1_high                     : natural := 0;
    		c1_initial                  : natural := 0;
    		c1_low                      : natural := 0;
    		c1_mode                     : string := "BYPASS";
    		c1_ph                       : natural := 0;
    		c1_test_source              : natural := 5;
    		clk1_counter                : string := "G0";
    		clk1_divide_by              : natural := 1;
    		clk1_duty_cycle	            : natural := 50;
    		clk1_multiply_by            : natural := 1;
    		clk1_output_frequency       : natural := 0;
    		clk1_phase_shift            : string := "0";
    		clk1_time_delay             : string := "0";
    		clk1_use_even_counter_mode  : string := "OFF";
    		clk1_use_even_counter_value : string := "OFF";

    		port_clk2                   : string := "PORT_CONNECTIVITY";
    		c2_high                     : natural := 0;
    		c2_initial                  : natural := 0;
    		c2_low                      : natural := 0;
    		c2_mode                     : string := "BYPASS";
    		c2_ph                       : natural := 0;
    		c2_test_source              : natural := 5;
    		clk2_counter                : string := "G0";
    		clk2_divide_by              : natural := 1;
    		clk2_duty_cycle	            : natural := 50;
    		clk2_multiply_by            : natural := 1;
    		clk2_output_frequency       : natural := 0;
    		clk2_phase_shift            : string := "0";
    		clk2_time_delay             : string := "0";
    		clk2_use_even_counter_mode  : string := "OFF";
    		clk2_use_even_counter_value : string := "OFF";

    		port_clk3                   : string := "PORT_CONNECTIVITY";
    		c3_high                     : natural := 0;
    		c3_initial                  : natural := 0;
    		c3_low                      : natural := 0;
    		c3_mode                     : string := "BYPASS";
    		c3_ph                       : natural := 0;
    		c3_test_source              : natural := 5;
    		clk3_counter                : string := "G0";
    		clk3_divide_by              : natural := 1;
    		clk3_duty_cycle	            : natural := 50;
    		clk3_multiply_by            : natural := 1;
    		clk3_output_frequency       : natural := 0;
    		clk3_phase_shift            : string := "0";
    		clk3_time_delay             : string := "0";
    		clk3_use_even_counter_mode  : string := "OFF";
    		clk3_use_even_counter_value : string := "OFF";

    		port_clk4                   : string := "PORT_CONNECTIVITY";
    		c4_high                     : natural := 0;
    		c4_initial                  : natural := 0;
    		c4_low                      : natural := 0;
    		c4_mode                     : string := "BYPASS";
    		c4_ph                       : natural := 0;
    		c4_test_source              : natural := 5;
    		clk4_counter                : string := "G0";
    		clk4_divide_by              : natural := 1;
    		clk4_duty_cycle	            : natural := 50;
    		clk4_multiply_by            : natural := 1;
    		clk4_output_frequency       : natural := 0;
    		clk4_phase_shift            : string := "0";
    		clk4_time_delay             : string := "0";
    		clk4_use_even_counter_mode  : string := "OFF";
    		clk4_use_even_counter_value : string := "OFF";

    		port_clk5                   : string := "PORT_CONNECTIVITY";
    		c5_high                     : natural := 0;
    		c5_initial                  : natural := 0;
    		c5_low                      : natural := 0;
    		c5_mode                     : string := "BYPASS";
    		c5_ph                       : natural := 0;
    		c5_test_source              : natural := 5;
    		clk5_counter                : string := "G0";
    		clk5_divide_by              : natural := 1;
    		clk5_duty_cycle	            : natural := 50;
    		clk5_multiply_by            : natural := 1;
    		clk5_output_frequency       : natural := 0;
    		clk5_phase_shift            : string := "0";
    		clk5_time_delay             : string := "0";
    		clk5_use_even_counter_mode  : string := "OFF";
    		clk5_use_even_counter_value : string := "OFF";

    		port_clk6                   : string := "PORT_UNUSED";
    		c6_high                     : natural := 0;
    		c6_initial                  : natural := 0;
    		c6_low                      : natural := 0;
    		c6_mode                     : string := "BYPASS";
    		c6_ph                       : natural := 0;
    		c6_test_source              : natural := 5;
    		clk6_counter                : string := "G0";
    		clk6_divide_by              : natural := 1;
    		clk6_duty_cycle	            : natural := 50;
    		clk6_multiply_by            : natural := 1;
    		clk6_output_frequency       : natural := 0;
    		clk6_phase_shift            : string := "0";
    		clk6_time_delay             : string := "0";
    		clk6_use_even_counter_mode  : string := "OFF";
    		clk6_use_even_counter_value : string := "OFF";

    		port_clk7                   : string := "PORT_UNUSED";
    		c7_high                     : natural := 0;
    		c7_initial                  : natural := 0;
    		c7_low                      : natural := 0;
    		c7_mode                     : string := "BYPASS";
    		c7_ph                       : natural := 0;
    		c7_test_source              : natural := 5;
    		clk7_counter                : string := "G0";
    		clk7_divide_by              : natural := 1;
    		clk7_duty_cycle	            : natural := 50;
    		clk7_multiply_by            : natural := 1;
    		clk7_output_frequency       : natural := 0;
    		clk7_phase_shift            : string := "0";
    		clk7_time_delay             : string := "0";
    		clk7_use_even_counter_mode  : string := "OFF";
    		clk7_use_even_counter_value : string := "OFF";

    		port_clk8                   : string := "PORT_UNUSED";
    		c8_high                     : natural := 0;
    		c8_initial                  : natural := 0;
    		c8_low                      : natural := 0;
    		c8_mode                     : string := "BYPASS";
    		c8_ph                       : natural := 0;
    		c8_test_source              : natural := 5;
    		clk8_counter                : string := "G0";
    		clk8_divide_by              : natural := 1;
    		clk8_duty_cycle	            : natural := 50;
    		clk8_multiply_by            : natural := 1;
    		clk8_output_frequency       : natural := 0;
    		clk8_phase_shift            : string := "0";
    		clk8_time_delay             : string := "0";
    		clk8_use_even_counter_mode  : string := "OFF";
    		clk8_use_even_counter_value : string := "OFF";

    		port_clk9                   : string := "PORT_UNUSED";
    		c9_high                     : natural := 0;
    		c9_initial                  : natural := 0;
    		c9_low                      : natural := 0;
    		c9_mode                     : string  := "BYPASS";
    		c9_ph                       : natural := 0;
    		c9_test_source              : natural := 5;
    		clk9_counter                : string  := "G0";
    		clk9_divide_by              : natural := 1;
    		clk9_duty_cycle	            : natural := 50;
    		clk9_multiply_by            : natural := 1;
    		clk9_output_frequency       : natural := 0;
    		clk9_phase_shift            : string := "0";
    		clk9_time_delay             : string := "0";
    		clk9_use_even_counter_mode  : string := "OFF";
    		clk9_use_even_counter_value : string := "OFF";

    		charge_pump_current	        : natural := 2;
    		charge_pump_current_bits	: natural := 9999;

    		compensate_clock            : string  := "CLK0";
    		down_spread                 : string  := "0";
    		dpa_divide_by               : natural := 1;
    		dpa_divider                 : natural := 0;
    		dpa_multiply_by             : natural := 0;

    		e0_high	                    : natural := 1;
    		e0_initial                  : natural := 1;
    		e0_low                      : natural := 1;
    		e0_mode                     : string := "BYPASS";
    		e0_ph                       : natural := 0;
    		e0_time_delay               : natural := 0;
    		extclk0_counter             : string := "E0";
    		extclk0_divide_by           : natural := 1;
    		extclk0_duty_cycle          : natural := 50;
    		extclk0_multiply_by         : natural := 1;
    		extclk0_phase_shift         : string := "0";
    		extclk0_time_delay          : string := "0";

    		e1_high	                    : natural := 1;
    		e1_initial                  : natural := 1;
    		e1_low                      : natural := 1;
    		e1_mode                     : string := "BYPASS";
    		e1_ph                       : natural := 0;
    		e1_time_delay               : natural := 0;
    		extclk1_counter             : string := "E0";
    		extclk1_divide_by           : natural := 1;
    		extclk1_duty_cycle          : natural := 50;
    		extclk1_multiply_by         : natural := 1;
    		extclk1_phase_shift         : string := "0";
    		extclk1_time_delay          : string := "0";

    		e2_high	                    : natural := 1;
    		e2_initial                  : natural := 1;
    		e2_low                      : natural := 1;
    		e2_mode                     : string := "BYPASS";
    		e2_ph                       : natural := 0;
    		e2_time_delay               : natural := 0;
    		extclk2_counter             : string := "E0";
    		extclk2_divide_by           : natural := 1;
    		extclk2_duty_cycle          : natural := 50;
    		extclk2_multiply_by         : natural := 1;
    		extclk2_phase_shift         : string := "0";
    		extclk2_time_delay          : string := "0";

    		e3_high	                    : natural := 1;
    		e3_initial                  : natural := 1;
    		e3_low                      : natural := 1;
    		e3_mode                     : string := "BYPASS";
    		e3_ph                       : natural := 0;
    		e3_time_delay               : natural := 0;
    		extclk3_counter             : string := "E0";
    		extclk3_divide_by           : natural := 1;
    		extclk3_duty_cycle          : natural := 50;
    		extclk3_multiply_by         : natural := 1;
    		extclk3_phase_shift         : string := "0";
    		extclk3_time_delay          : string := "0";

    		enable0_counter	:	string := "L0";
    		enable1_counter	:	string := "L0";
    		enable_switch_over_counter	:	string := "OFF";

    		feedback_source	:	string := "EXTCLK0";

    		g0_high	        :	natural := 1;
    		g0_initial      :	natural := 1;
    		g0_low          :	natural := 1;
    		g0_mode         :	string := "BYPASS";
    		g0_ph           :	natural := 0;
    		g0_time_delay	:	natural := 0;

    		g1_high	        :	natural := 1;
    		g1_initial      :	natural := 1;
    		g1_low          :	natural := 1;
    		g1_mode         :	string := "BYPASS";
    		g1_ph           :	natural := 0;
    		g1_time_delay	:	natural := 0;

    		g2_high	        :	natural := 1;
    		g2_initial      :	natural := 1;
    		g2_low          :	natural := 1;
    		g2_mode         :	string := "BYPASS";
    		g2_ph           :	natural := 0;
    		g2_time_delay	:	natural := 0;

    		g3_high	        :	natural := 1;
    		g3_initial      :	natural := 1;
    		g3_low          :	natural := 1;
    		g3_mode         :	string := "BYPASS";
    		g3_ph           :	natural := 0;
    		g3_time_delay	:	natural := 0;

    		gate_lock_counter	:	natural := 0;
    		gate_lock_signal	:	string := "NO";
    		inclk0_input_frequency	:	natural;
    		inclk1_input_frequency	:	natural := 0;
    		intended_device_family	:	string := "NONE";
    		invalid_lock_multiplier	:	natural := 5;
    		l0_high	:	natural := 1;
    		l0_initial	:	natural := 1;
    		l0_low	:	natural := 1;
    		l0_mode	:	string := "BYPASS";
    		l0_ph	:	natural := 0;
    		l0_time_delay	:	natural := 0;
    		l1_high	:	natural := 1;
    		l1_initial	:	natural := 1;
    		l1_low	:	natural := 1;
    		l1_mode	:	string := "BYPASS";
    		l1_ph	:	natural := 0;
    		l1_time_delay	:	natural := 0;
    		lock_high	:	natural := 1;
    		lock_low	:	natural := 1;
    		lock_window_ui	:	string := " 0.05";
    		lock_window_ui_bits	:	string := "UNUSED";
    		loop_filter_c	:	natural := 5;
    		loop_filter_c_bits	:	natural := 9999;
    		loop_filter_r	:	string := " 1.000000";
    		loop_filter_r_bits	:	natural := 9999;
    		lpm_hint	:	string := "UNUSED";
    		lpm_type	:	string := "altpll";
    		m	:	natural := 0;
    		m2	:	natural := 1;
    		m_initial	:	natural := 0;
    		m_ph	:	natural := 0;
    		m_test_source	:	natural := 5;
    		m_time_delay	:	natural := 0;
    		n	:	natural := 1;
    		n2	:	natural := 1;
    		n_time_delay	:	natural := 0;
    		operation_mode	:	string;
    		pfd_max	    : natural := 0;
    		pfd_min	    : natural := 0;
    		pll_type    : string := "AUTO";
    		port_activeclock	:	string := "PORT_CONNECTIVITY";
    		port_areset	:	string := "PORT_CONNECTIVITY";

    		port_clkbad0 :	string := "PORT_CONNECTIVITY";
    		port_clkbad1 :	string := "PORT_CONNECTIVITY";

    		port_clkena0 :	string := "PORT_CONNECTIVITY";
    		port_clkena1 :	string := "PORT_CONNECTIVITY";
    		port_clkena2 :	string := "PORT_CONNECTIVITY";
    		port_clkena3 :	string := "PORT_CONNECTIVITY";
    		port_clkena4 :	string := "PORT_CONNECTIVITY";
    		port_clkena5 :	string := "PORT_CONNECTIVITY";

    		port_clkloss :	string := "PORT_CONNECTIVITY";
    		port_clkswitch	:	string := "PORT_CONNECTIVITY";
    		port_configupdate	:	string := "PORT_CONNECTIVITY";
    		port_enable0 :	string := "PORT_CONNECTIVITY";
    		port_enable1 :	string := "PORT_CONNECTIVITY";
    		port_extclk0 :	string := "PORT_CONNECTIVITY";
    		port_extclk1 :	string := "PORT_CONNECTIVITY";
    		port_extclk2 :	string := "PORT_CONNECTIVITY";
    		port_extclk3 :	string := "PORT_CONNECTIVITY";
    		port_extclkena0	:	string := "PORT_CONNECTIVITY";
    		port_extclkena1	:	string := "PORT_CONNECTIVITY";
    		port_extclkena2	:	string := "PORT_CONNECTIVITY";
    		port_extclkena3	:	string := "PORT_CONNECTIVITY";
    		port_fbin :	string := "PORT_CONNECTIVITY";
    		port_fbout : string := "PORT_CONNECTIVITY";
    		port_inclk0	: string := "PORT_CONNECTIVITY";
    		port_inclk1	: string := "PORT_CONNECTIVITY";
    		port_locked	: string := "PORT_CONNECTIVITY";
    		port_pfdena	: string := "PORT_CONNECTIVITY";
    		port_phasecounterselect	:	string := "PORT_CONNECTIVITY";
    		port_phasedone : string := "PORT_CONNECTIVITY";
    		port_phasestep : string := "PORT_CONNECTIVITY";
    		port_phaseupdown : string := "PORT_CONNECTIVITY";
    		port_pllena	: string := "PORT_CONNECTIVITY";
    		port_scanaclr :	string := "PORT_CONNECTIVITY";
    		port_scanclk :	string := "PORT_CONNECTIVITY";
    		port_scanclkena	:	string := "PORT_CONNECTIVITY";
    		port_scandata :	string := "PORT_CONNECTIVITY";
    		port_scandataout :	string := "PORT_CONNECTIVITY";
    		port_scandone :	string := "PORT_CONNECTIVITY";
    		port_scanread :	string := "PORT_CONNECTIVITY";
    		port_scanwrite :	string := "PORT_CONNECTIVITY";
    		port_sclkout0 :	string := "PORT_CONNECTIVITY";
    		port_sclkout1 :	string := "PORT_CONNECTIVITY";
    		port_vcooverrange :	string := "PORT_CONNECTIVITY";
    		port_vcounderrange : string := "PORT_CONNECTIVITY";
    		primary_clock :	string := "INCLK0";
    		qualify_conf_done :	string := "OFF";
    		scan_chain : string := "LONG";
    		scan_chain_mif_file	: string := "UNUSED";
    		sclkout0_phase_shift : string := "0";
    		sclkout1_phase_shift : string := "0";
    		self_reset_on_gated_loss_lock :	string := "OFF";
    		self_reset_on_loss_lock	: string := "OFF";
    		sim_gate_lock_device_behavior :	string := "OFF";
    		skip_vco : string := "OFF";
    		spread_frequency	:	natural := 0;
    		ss : natural := 1;
    		switch_over_counter	: natural := 0;
    		switch_over_on_gated_lock :	string := "OFF";
    		switch_over_on_lossclk : string := "OFF";
    		switch_over_type :	string := "AUTO";
    		using_fbmimicbidir_port	:	string := "OFF";
    		valid_lock_multiplier	:	natural := 1;
    		vco_center	:	natural := 0;
    		vco_divide_by	:	natural := 0;
    		vco_frequency_control	:	string := "AUTO";
    		vco_max	:	natural := 0;
    		vco_min	:	natural := 0;
    		vco_multiply_by	:	natural := 0;
    		vco_phase_shift_step	:	natural := 0;
    		vco_post_scale	:	natural := 0;
    		vco_range_detector_high_bits	:	string := "UNUSED";
    		vco_range_detector_low_bits	:	string := "UNUSED";
    		width_clock	:	natural := 6;
    		width_phasecounterselect	:	natural := 4	);
    	port(
    		activeclock	:	out std_logic;
    		areset	:	in std_logic := '0';
    		clk	:	out std_logic_vector(WIDTH_CLOCK-1 downto 0);
    		clkbad	:	out std_logic_vector(1 downto 0);
    		clkena	:	in std_logic_vector(5 downto 0) := (others => '1');
    		clkloss	:	out std_logic;
    		clkswitch	:	in std_logic := '0';
    		configupdate	:	in std_logic := '0';
    		enable0	:	out std_logic;
    		enable1	:	out std_logic;
    		extclk	:	out std_logic_vector(3 downto 0);
    		extclkena	:	in std_logic_vector(3 downto 0) := (others => '1');
    		fbin	:	in std_logic := '1';
    		fbmimicbidir	:	inout std_logic;
    		fbout	:	out std_logic;
    		fref	:	out std_logic;
    		icdrclk	:	out std_logic;
    		inclk	:	in std_logic_vector(1 downto 0) := (others => '0');
    		locked	:	out std_logic;
    		pfdena	:	in std_logic := '1';
    		phasecounterselect	:	in std_logic_vector(WIDTH_PHASECOUNTERSELECT-1 downto 0) := (others => '1');
    		phasedone	:	out std_logic;
    		phasestep	:	in std_logic := '1';
    		phaseupdown	:	in std_logic := '1';
    		pllena	:	in std_logic := '1';
    		scanaclr	:	in std_logic := '0';
    		scanclk	:	in std_logic := '0';
    		scanclkena	:	in std_logic := '1';
    		scandata	:	in std_logic := '0';
    		scandataout	:	out std_logic;
    		scandone	:	out std_logic;
    		scanread	:	in std_logic := '0';
    		scanwrite	:	in std_logic := '0';
    		sclkout0	:	out std_logic;
    		sclkout1	:	out std_logic;
    		vcooverrange	:	out std_logic;
    		vcounderrange	:	out std_logic
    	);
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

		alias ftdi_txd    : std_logic is gpio23;
		alias ftdi_txen   : std_logic is gpio13;
		alias ftdi_rxd    : std_logic is gpio24;

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

		ftdi_txen <= '1';
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

	ipoe_e : if io_link=io_ipoe generate
		-- RMII pins as labeled on the board and connected to ULX3S with pins down and flat cable
		alias rmii_crs    : std_logic is gpio17;

		alias rmii_tx_en  : std_logic is gpio6;
		alias rmii_tx0    : std_logic is gpio7;
		alias rmii_tx1    : std_logic is gpio8;

		alias rmii_rx_dv  : std_logic is rmii_crs;
		alias rmii_rx0    : std_logic is gpio9;
		alias rmii_rx1    : std_logic is gpio11;

		alias rmii_nint   : std_logic is gpio19;
		alias rmii_mdio   : std_logic is gpio22;
		alias rmii_mdc    : std_logic is gpio25;
		signal mii_clk    : std_logic;

		signal mii_txen   : std_logic;
		signal mii_txd    : std_logic_vector(0 to 2-1);

		signal mii_rxdv   : std_logic;
		signal mii_rxd    : std_logic_vector(0 to 2-1);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

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
				mii_rxdv <= rmii_rx_dv;
				mii_rxd  <= rmii_rx0 & rmii_rx1;
			end if;
		end process;

		rmii_mdc  <= '0';
		rmii_mdio <= '0';

		-- dhcp_p : process(mii_clk)
		-- begin
		-- 	if rising_edge(mii_clk) then
		-- 		if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
		-- 			dhcpcd_req <= dhcpcd_rdy xor ((btn(1) and dhcpcd_rdy) or (btn(2) and not dhcpcd_rdy));
		-- 		end if;
		-- 	end if;
		-- end process;
				dhcpcd_req <= dhcpcd_rdy;
		-- led(0) <= dhcpcd_rdy;
		-- led(7) <= not dhcpcd_rdy;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			hdplx      => hdplx,
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

	graphics_e : entity hdl4fpga.demo_graphics
	generic map (
		-- debug        => true,
		debug        => debug,
		profile      => 2,

		sdram_tcp      => 2.0*sdram_tcp,
		fpga         => ecp5,
		mark         => MT41K4G107,
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

		timing_id    => video_record.timing,
		red_length   => setif(video_record.pixel=rgb565, 5, setif(video_record.pixel=rgb888, 8, 0)),
		green_length => setif(video_record.pixel=rgb565, 6, setif(video_record.pixel=rgb888, 8, 0)),
		blue_length  => setif(video_record.pixel=rgb565, 5, setif(video_record.pixel=rgb888, 8, 0)),
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

		video_clk    => '0', --video_clk,
		video_shift_clk => '0', --video_shft_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clks(0) => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => sdram_params.cl,
		ctlr_cwl     => sdram_params.cwl,
		ctlr_wrl     => "010",
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
			led(0) <= tp(1);
			led(7 downto 2) <= tp_phy(1 to 6);
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
				led(1) <= tp_dv;
			end if;
		end process;
		
	end block;

	sdrphy_e : entity hdl4fpga.ecp5_sdrphy
	generic map (
		debug         => debug,
		sdr_tcp       => sdram_tcp,
		cmmd_gear     => cmmd_gear,
		data_gear     => data_gear,
		bank_size     => ddr3_ba'length,
		addr_size     => ddr3_a'length,
		word_size     => word_size,
		byte_size     => byte_size)
	port map (
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

		sdr_rst       => ddr3_resetn,
		sdr_ck        => ddr3_clk,
		sdr_cke       => ddr3_cke,
		sdr_cs        => ddr3_csn,
		sdr_ras       => ddr3_rasn,
		sdr_cas       => ddr3_casn,
		sdr_we        => ddr3_wen,
		sdr_odt       => ddr3_odt,
		sdr_b         => ddr3_ba,
		sdr_a         => ddr3_a,

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

	fpdi_clk_i : oddrx1f
	port map(
		sclk => video_shft_clk,
		rst  => '0',
		d0   => dvid_crgb(2*0),
		d1   => dvid_crgb(2*0+1),
		q    => fpdi_clk);
 
	fpdi_d0_i : oddrx1f
	port map(
		sclk => video_shft_clk,
		rst  => '0',
		d0   => dvid_crgb(2*1),
		d1   => dvid_crgb(2*1+1),
		q    => fpdi_d0);
 
	fpdi_d1_i : oddrx1f
	port map(
		sclk => video_shft_clk,
		rst  => '0',
		d0   => dvid_crgb(2*2),
		d1   => dvid_crgb(2*2+1),
		q    => fpdi_d1);
 
	fpdi_d2_i : oddrx1f
	port map(
		sclk => video_shft_clk,
		rst  => '0',
		d0   => dvid_crgb(2*3),
		d1   => dvid_crgb(2*3+1),
		q    => fpdi_d2);
 
end;
