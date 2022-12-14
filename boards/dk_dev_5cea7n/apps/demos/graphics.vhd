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

	ctlrpll_b : block

		constant ddr3_mhz : real := 1.0e-6/sdram_tcp;

	begin

		assert false
		report real'image(ddr3_mhz)
		severity NOTE;

		ddrpll_i :  altpll
    	generic map (
    		operation_mode              => "NORMAL",

			inclk0_input_frequency	    => 50,
    		compensate_clock            => "CLK0",
    		width_clock                 => 5,
    		port_clk0                   => "PORT_CONNECTIVITY",
    		c0_high                     => 0,
    		c0_initial                  => 0,
    		c0_low                      => 0,
    		c0_mode                     => "BYPASS",
    		c0_ph                       => 0,
    		c0_test_source              => 5,
    		clk0_counter                => "G0",
    		clk0_divide_by              => 1,
    		clk0_duty_cycle	            => 50,
    		clk0_multiply_by            => 1,
    		clk0_output_frequency       => 0,
    		clk0_phase_shift            => "0",
    		clk0_time_delay             => "0",
    		clk0_use_even_counter_mode  => "OFF",
    		clk0_use_even_counter_value => "OFF",

    		port_clk1                   => "PORT_CONNECTIVITY",
    		c1_high                     => 0,
    		c1_initial                  => 0,
    		c1_low                      => 0,
    		c1_mode                     => "BYPASS",
    		c1_ph                       => 0,
    		c1_test_source              => 5,
    		clk1_counter                => "G0",
    		clk1_divide_by              => 1,
    		clk1_duty_cycle	            => 50,
    		clk1_multiply_by            => 1,
    		clk1_output_frequency       => 0,
    		clk1_phase_shift            => "0",
    		clk1_time_delay             => "0",
    		clk1_use_even_counter_mode  => "OFF",
    		clk1_use_even_counter_value => "OFF",

    		port_clk2                   => "PORT_CONNECTIVITY",
    		c2_high                     => 0,
    		c2_initial                  => 0,
    		c2_low                      => 0,
    		c2_mode                     => "BYPASS",
    		c2_ph                       => 0,
    		c2_test_source              => 5,
    		clk2_counter                => "G0",
    		clk2_divide_by              => 1,
    		clk2_duty_cycle	            => 50,
    		clk2_multiply_by            => 1,
    		clk2_output_frequency       => 0,
    		clk2_phase_shift            => "0",
    		clk2_time_delay             => "0",
    		clk2_use_even_counter_mode  => "OFF",
    		clk2_use_even_counter_value => "OFF",

    		port_clk3                   => "PORT_CONNECTIVITY",
    		c3_high                     => 0,
    		c3_initial                  => 0,
    		c3_low                      => 0,
    		c3_mode                     => "BYPASS",
    		c3_ph                       => 0,
    		c3_test_source              => 5,
    		clk3_counter                => "G0",
    		clk3_divide_by              => 1,
    		clk3_duty_cycle	            => 50,
    		clk3_multiply_by            => 1,
    		clk3_phase_shift            => "0",
    		clk3_time_delay             => "0",
    		clk3_use_even_counter_mode  => "OFF",
    		clk3_use_even_counter_value => "OFF",

    		port_clk4                   => "PORT_UNUSED",
    		c4_high                     => 0,
    		c4_initial                  => 0,
    		c4_low                      => 0,
    		c4_mode                     => "BYPASS",
    		c4_ph                       => 0,
    		c4_test_source              => 5,
    		clk4_counter                => "G0",
    		clk4_divide_by              => 1,
    		clk4_duty_cycle	            => 50,
    		clk4_multiply_by            => 1,
    		clk4_phase_shift            => "0",
    		clk4_time_delay             => "0",
    		clk4_use_even_counter_mode  => "OFF",
    		clk4_use_even_counter_value => "OFF",

    		port_clk5                   => "PORT_UNUSED",
    		port_clk6                   => "PORT_UNUSED",
    		port_clk7                   => "PORT_UNUSED",
    		port_clk8                   => "PORT_UNUSED",
    		port_clk9                   => "PORT_UNUSED",

    		port_extclkena0             => "PORT_UNUSED",
    		port_extclk0                => "PORT_UNUSED",
    		port_extclkena1             => "PORT_UNUSED",
    		port_extclk1                => "PORT_UNUSED",
    		port_extclkena2             => "PORT_UNUSED",
    		port_extclk2                => "PORT_UNUSED",
    		port_extclkena3             => "PORT_UNUSED",
    		port_extclk3                => "PORT_UNUSED",
    		port_activeclock            => "PORT_UNUSED",
    		port_areset                 => "PORT_UNUSED",

    		port_clkbad0                => "PORT_UNUSED",
    		port_clkbad1                => "PORT_UNUSED",

    		port_clkena0                => "PORT_UNUSED",
    		port_clkena1                => "PORT_UNUSED",
    		port_clkena2                => "PORT_UNUSED",
    		port_clkena3                => "PORT_UNUSED",
    		port_clkena4                => "PORT_UNUSED",
    		port_clkena5                => "PORT_UNUSED",

    		port_clkloss                => "PORT_UNUSED",
    		port_clkswitch              => "PORT_UNUSED",
    		port_configupdate           => "PORT_UNUSED",
    		port_enable0                => "PORT_UNUSED",
    		port_enable1                => "PORT_UNUSED",
    		port_fbin                   => "PORT_UNUSED",
    		port_fbout                  => "PORT_UNUSED",
    		port_inclk0	                => "PORT_UNUSED",
    		port_inclk1	                => "PORT_UNUSED",
    		port_locked	                => "PORT_UNUSED",
    		port_pfdena	                => "PORT_UNUSED",
    		port_phasecounterselect     => "PORT_UNUSED",
    		port_phasedone              => "PORT_UNUSED",
    		port_phasestep              => "PORT_UNUSED",
    		port_phaseupdown            => "PORT_UNUSED",
    		port_pllena                 => "PORT_UNUSED",
    		port_vcooverrange           => "PORT_UNUSED",
    		port_vcounderrange          => "PORT_UNUSED",

    		port_scanaclr               => "PORT_UNUSED",
    		port_scanclk                => "PORT_UNUSED",
    		port_scanclkena             => "PORT_UNUSED",
    		port_scandata               => "PORT_UNUSED",
    		port_scandataout            => "PORT_UNUSED",
    		port_scandone               => "PORT_UNUSED",
    		port_scanread               => "PORT_UNUSED",
    		port_scanwrite              => "PORT_UNUSED",
    		port_sclkout0               => "PORT_UNUSED",
    		port_sclkout1               => "PORT_UNUSED");
    	-- port map (
    	-- 	areset        : in  std_logic := '0';
    	-- 	clk           : out std_logic_vector(WIDTH_CLOCK-1 downto 0);
    	-- 	clkbad        : out std_logic_vector(1 downto 0);
    	-- 	clkloss       : out std_logic;
    	-- 	enable0       : out std_logic;
    	-- 	enable1       : out std_logic;
    	-- 	extclk        : out std_logic_vector(3 downto 0);
    	-- 	fbmimicbidir  : inout std_logic;
    	-- 	fbout         : out std_logic;
    	-- 	fref          : out std_logic;
    	-- 	icdrclk       : out std_logic;
    	-- 	inclk         : in  std_logic_vector(1 downto 0) := (others => '0');
    	-- 	locked        : out std_logic;
    	-- 	pfdena        : in  std_logic := '1';
    	-- 	phasedone     : out std_logic;

    	-- 	scandataout   : out std_logic;
    	-- 	scandone      : out std_logic;
    	-- 	sclkout0      : out std_logic;
    	-- 	sclkout1      : out std_logic;
    	-- 	vcooverrange  : out std_logic;
    	-- 	vcounderrange : out std_logic);
	end block;

 
end;
