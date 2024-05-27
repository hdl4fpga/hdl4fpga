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

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

architecture graphics of ecp3versa is

	--------------------------------------
	-- Set of profiles                  --
	type app_profiles is (
	--	Interface_SdramSpeed_PixelFormat--

		mii_325MHz_1080p24bpp30,
		mii_350MHz_1080p24bpp30,
		mii_375MHz_1080p24bpp30,
		mii_400MHz_1080p24bpp30,
		mii_425MHz_1080p24bpp30,
		mii_450MHz_1080p24bpp30,
		mii_475MHz_1080p24bpp30,
		mii_500MHz_1080p24bpp30);
	--------------------------------------

	---------------------------------------------
	-- Set your profile here                   --
	constant app_profile  : app_profiles := mii_500MHz_1080p24bpp30;
	---------------------------------------------

	type profile_params is record
		comms : io_comms;
		mode  : video_modes;
		speed : sdram_speeds;
	end record;

	type profileparams_vector is array (app_profiles) of profile_params;
	constant profile_tab : profileparams_vector := (
		mii_325MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram325MHz),
		mii_350MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram350MHz),
		mii_375MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram375MHz),
		mii_400MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram400MHz),
		mii_425MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram425MHz),
		mii_450MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram450MHz),
		mii_475MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram475MHz),
		mii_500MHz_1080p24bpp30 => (comms => io_ipoe, mode => mode1080p24bpp30, speed => sdram500MHz));

	constant gear        : natural := 4;
	constant word_size   : natural := ddr3_dq'length;
	constant byte_size   : natural := ddr3_dq'length/ddr3_dqs'length;
	constant cgear       : natural := (gear+1)/2;

	constant bank_size   : natural := ddr3_b'length;
	constant addr_size   : natural := ddr3_a'length;
	constant coln_size   : natural := 10;

	signal sys_rst       : std_logic;

	signal ddrsys_rst    : std_logic;
	signal ddrphy_rst    : std_logic;
	signal physys_clk    : std_logic;

	signal ctlr_lck      : std_logic;

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
	signal ctlrphy_ba    : std_logic_vector(cgear*ddr3_b'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(cgear*ddr3_a'length-1 downto 0);
	signal ctlrphy_dqsi  : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqst  : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso  : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqc   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqv   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ddr_ba        : std_logic_vector(ddr3_b'length-1 downto 0);
	signal ddr_a         : std_logic_vector(ddr3_a'length-1 downto 0);

	type pll_params is record
		clkok_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
	end record;

	type video_params is record
		id     : video_modes;
		pll    : pll_params;
		timing : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant v_r : natural := 5; -- video ratio
	constant video_tab : videoparams_vector := (
		(id => modedebug,        pll => (clki_div => 1, clkok_div => v_r,  clkfb_div => 1, clkop_div => 25), timing => pclk_debug),
		(id => mode480p24bpp,    pll => (clki_div => 1, clkok_div => v_r,  clkfb_div => 1, clkop_div => 25), timing => pclk25_00m640x480at60),
		(id => mode600p24bpp,    pll => (clki_div => 1, clkok_div => v_r,  clkfb_div => 1, clkop_div => 16), timing => pclk40_00m800x600at60),
		(id => mode900p24bpp,    pll => (clki_div => 1, clkok_div => v_r,  clkfb_div => 1, clkop_div => 22), timing => pclk108_00m1600x900at60), -- 30 Hz
		(id => mode1080p24bpp30, pll => (clki_div => 4, clkok_div => v_r,  clkfb_div => 3*v_r, clkop_div =>  2), timing => pclk150_00m1920x1080at60)); -- 30 Hz

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

	constant nodebug_videomode : video_modes := profile_tab(app_profile).mode;
	constant video_mode   : video_modes := video_modes'VAL(setif(debug and false,
		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode)));
	constant video_record : video_params := videoparam(video_mode);

	signal video_clk      : std_logic := '0';
	signal video_shift_clk : std_logic := '0';
	signal videoio_clk    : std_logic := '0';
	signal video_lck      : std_logic := '0';
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
		wrl : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram325MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div => 13, clki_div => 4), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram350MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  7, clki_div => 2), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram375MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div => 15, clki_div => 4), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram400MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  4, clki_div => 1), cl => "010", cwl => "000", wrl => "010"),
		(id => sdram425MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div => 17, clki_div => 4), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram450MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  9, clki_div => 2), cl => "011", cwl => "001", wrl => "011"),
		(id => sdram475MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div => 19, clki_div => 4), cl => "011", cwl => "001", wrl => "100"),
		(id => sdram500MHz, pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  5, clki_div => 1), cl => "011", cwl => "001", wrl => "100"));

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

	constant sdram_mode   : sdram_speeds := profile_tab(app_profile).speed;
	constant sdram_params : sdramparams_record := sdramparams(sdram_mode);
	constant sdram_tcp    : real := 
		real(sdram_params.pll.clki_div)/
		(real(sdram_params.pll.clkop_div*sdram_params.pll.clkfb_div)*sys_freq);

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

	signal uart_clk    : std_logic;

    signal video_pixel    : std_logic_vector(0 to 32-1);

	constant io_link  : io_comms := profile_tab(app_profile).comms;

	constant hdplx    : std_logic := setif(debug, '0', '1');

	signal tp             : std_logic_vector(1 to 32);
	signal ctlrpll_clkok  : std_logic;
	signal ctlrpll_clkop  : std_logic;
	signal ctlrpll_clkos  : std_logic;
	signal ctlrpll_lock   : std_logic;
	signal ctlrpll_phase  : std_logic_vector(4-1 downto 0);
	signal ctlrpll_eclk   : std_logic;
	signal ctlrpll_sclk   : std_logic;
	signal ctlrpll_sclk2x : std_logic;
	alias ctlr_clk        : std_logic is ctlrpll_sclk;

	alias  sin_clk        : std_logic is phy1_125clk;

	attribute oddrapps : string;
	attribute oddrapps of phy1_gtxclk_i : label is "SCLK_ALIGNED";
	attribute oddrapps of phy1_txc_i    : label is "SCLK_ALIGNED";

begin

	sys_rst <= '0';
	videopll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOK  : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		constant video_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkok_div*1e6));

		constant video_shift_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkok_div*1e6));

		constant videoio_freq  : real :=
			(real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*sys_freq)/
			(real(video_record.pll.clki_div*video_record.pll.clkok_div*1e6));

		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(sys_freq/1.0e6,   10);
		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(video_shift_freq, 10);
		attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa(video_freq,       10);
		attribute FREQUENCY_PIN_CLKOK of pll_i : label is ftoa(videoio_freq,     10);

		signal clkfb : std_logic;

	begin
		pll_i : ehxpllf
        generic map (
			CLKOS_TRIM_DELAY => 0,
			CLKOS_TRIM_POL   => "RISING", 
			CLKOS_BYPASS     => "DISABLED", 
			CLKOP_TRIM_DELAY => 0,
			CLKOP_TRIM_POL   => "RISING", 
			CLKOP_BYPASS     => "DISABLED", 
			CLKOK_INPUT      => "CLKOP",
			CLKOK_BYPASS     => "DISABLED", 
			DELAY_PWD        => "DISABLED",
			DELAY_VAL        => 0, 
			DUTY             => 8,
			PHASE_DELAY_CNTL => "DYNAMIC",
			PHASEADJ         => "0.0", 

			CLKOK_DIV        => video_record.pll.clkok_div,
			CLKOP_DIV        => video_record.pll.clkop_div,
			CLKFB_DIV        => video_record.pll.clkfb_div,
			CLKI_DIV         => video_record.pll.clki_div)
        port map (
			rst      => '0',
			rstk     => '0',
			drpai3   => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3   => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3     => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			wrdel    => '0',
			clki     => clk,
			CLKFB    => clkfb,
			CLKOP    => video_shift_clk,
			CLKOK    => video_clk,
			LOCK     => video_lck,
			clkintfb         => clkfb);

	end block;

	ctlrpll_b : block

		attribute FREQUENCY_PIN_CLKI  : string;
		attribute FREQUENCY_PIN_FIN   : string;
		attribute FREQUENCY_PIN_CLKOS : string;
		attribute FREQUENCY_PIN_CLKOP : string;
		attribute FREQUENCY_PIN_CLKOK : string; 

		constant sdram_mhz : real := 1.0e-6/sdram_tcp;

		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(sys_freq/1.0e6, 10);
		attribute FREQUENCY_PIN_FIN   of pll_i : label is ftoa(sdram_mhz, 10);
		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(sdram_mhz, 10);
		attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa(sdram_mhz, 10);
		attribute FREQUENCY_PIN_CLKOK of pll_i : label is ftoa(sdram_mhz/2.0, 10);

		signal clkfb      : std_logic;
		signal lock       : std_logic;

		signal dtct_req   : std_logic;
		signal dtct_rdy   : std_logic;
		signal step_req   : std_logic;
		signal step_rdy   : std_logic;

		signal eclk_rpha  : std_logic_vector(4-1 downto 0) := (others => '0');
		signal dfpa3      : std_logic;
		signal rst        : std_logic;

	begin

		assert false
		report "SDRAM clock : " & real'image(sdram_mhz)
		severity NOTE;

		dfpa3 <= not ctlrpll_phase(3);
		pll_i : ehxpllf
		generic map (
			CLKOK_BYPASS     => "DISABLED", 
			CLKOS_BYPASS     => "DISABLED", 
			CLKOP_BYPASS     => "DISABLED", 
			CLKOK_INPUT      => "CLKOP",
			DELAY_PWD        => "DISABLED",
			DELAY_VAL        => 0, 
			CLKOS_TRIM_DELAY => 0,
			CLKOS_TRIM_POL   => "RISING", 
			CLKOP_TRIM_DELAY => 0,
			CLKOP_TRIM_POL   => "RISING", 
			PHASE_DELAY_CNTL => "DYNAMIC",
			DUTY             => 8,
			PHASEADJ         => "0.0", 
			CLKOK_DIV        => sdram_params.pll.clkok_div,
			CLKOP_DIV        => sdram_params.pll.clkop_div,
			CLKFB_DIV        => sdram_params.pll.clkfb_div,
			CLKI_DIV         => sdram_params.pll.clki_div,
			FEEDBK_PATH      => "INTERNAL")
		port map (
			rstk             => '0',
			clki             => clk,
			clkfb            => clkfb,
			rst              => '0', 
			drpai3           => ctlrpll_phase(3),
			drpai2           => ctlrpll_phase(2), 
			drpai1           => ctlrpll_phase(1), 
			drpai0           => ctlrpll_phase(0), 
			dfpai3           => dfpa3,
			dfpai2           => ctlrpll_phase(2), 
			dfpai1           => ctlrpll_phase(1), 
			dfpai0           => ctlrpll_phase(0), 
			fda3             => '0',
			fda2             => '0',
			fda1             => '0',
			fda0             => '0', 
			wrdel            => '0',
			clkintfb         => clkfb,
			clkop            => ctlrpll_clkop, 
			clkos            => ctlrpll_clkos,
			clkok            => ctlrpll_clkok,
			clkok2           => open,
			lock             => ctlrpll_lock);
	
		rst <= not lock;

	end block;

	ipoe_b : block
		port (
			mii_rxc  : in std_logic;
			mii_rxdv : in std_logic;
			mii_rxd  : in std_logic_vector;
			mii_txc  : in  std_logic;
			mii_txd  : out std_logic_vector(phy1_tx_d'range);
			mii_txen : out std_logic;
			so_clk   : in  std_logic);
		port map (
		    mii_rxc  => phy1_rxc,
		    mii_rxdv => phy1_rx_dv,
		    mii_rxd  => phy1_rx_d,
			mii_txc  => phy1_125clk,
			mii_txen => phy1_tx_en,
			mii_txd  => phy1_tx_d,
			so_clk   => sin_clk);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);
		signal mii_txcrxd : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);
		signal ser_data   : std_logic_vector(mii_txd'range);
		signal txen       : std_logic;
		signal txd        : std_logic_vector(mii_txd'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					rxc_rxbus <= mii_rxdv & mii_rxd;
				end if;
			end process;

			rxc2txc_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 4,
				latency    => 0,
				dst_offset => 0,
				src_offset => 2,
				check_sov  => false,
				check_dov  => true,
				gray_code  => false)
			port map (
				src_clk    => mii_rxc,
				src_data   => rxc_rxbus,
				dst_clk    => mii_txc,
				dst_irdy   => dst_irdy,
				dst_trdy   => dst_trdy,
				dst_data   => txc_rxbus);

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_txcrxd'length);
				end if;
			end process;
		end block;

		dhcp_p : process(mii_txc)
			type states is (s_request, s_wait);
			variable state : states;
		begin
			if rising_edge(mii_txc) then
				case state is
				when s_request =>
					if fpga_gsrn='0' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if fpga_gsrn='1' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;
		-- led(0) <= dhcpcd_rdy;
		-- led(1) <= dhcpcd_rdy;
		-- led(2) <= fpga_gsrn;
		-- led(3) <= dhcpcd_req xor dhcpcd_rdy;

		-- dhcpcd_req <= dhcpcd_rdy;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => false,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => '1', --miirx_irdy,
			miirx_trdy => open,
			miirx_data => miirx_data,

			mii_clk    => mii_txc,
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

			so_clk     => so_clk,
			so_frm     => so_frm,
			so_irdy    => so_irdy,
			so_trdy    => so_trdy,
			so_data    => so_data);

		desser_e : entity hdl4fpga.desser
		port map (
			desser_clk => mii_txc,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => ser_data);

		txen <= miitx_frm and not miitx_end;
		txd  <= ser_data;
		buffer_e : entity hdl4fpga.latency
		generic map (
			n => mii_txd'length+1,
			d => (0 to mii_txd'length+1-1 => 4))
		port map (
			clk => mii_txc,
			di(mii_txd'length) => txen,
			di(mii_txd'range)  => txd,
			do(mii_txd'length) => mii_txen,
			do(mii_txd'range)  => mii_txd);

	end block;

	grahics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug,
		profile      => 2,

		sdram_tcp    => 2.0*sdram_tcp,
		-- mark         => MT41J1G15E,
		mark         => MT41K8G125,
		burst_length => 8,
		gear         => gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_record.timing,
		fifo_size    => mem_size)
	port map (
		sin_clk      => sin_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_clk     => phy1_125clk,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => '0', --video_clk,
		video_shift_clk => '0', --video_shift_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => sdram_params.cl,
		ctlr_cwl     => sdram_params.cwl,
		ctlr_wrl     => sdram_params.wrl,
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
		ctlrphy_b    => ddr_ba,
		ctlrphy_a    => ddr_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_dqv  => ctlrphy_dqv,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	tp(2) <= (ctlrphy_wlreq xor ctlrphy_wlrdy);
	tp(3) <= (ctlrphy_rlreq xor ctlrphy_rlrdy);
	tp(4) <= ctlrphy_ini;

	process (ddr_ba)
	begin
		for i in ddr_ba'range loop
			for j in 0 to cgear-1 loop
				ctlrphy_ba(i*cgear+j) <= ddr_ba(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to cgear-1 loop
				ctlrphy_a(i*cgear+j) <= ddr_a(i);
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

	ddrphy_rst <= not ctlr_lck;
	process (ctlr_lck, ctlr_clk)
	begin
		if ctlr_lck='0' then
			ddrsys_rst <= '1';
		elsif rising_edge(ctlr_clk) then
			ddrsys_rst <= '0';
		end if;
	end process;
	
	sdrphy_b : block
		port (
			rst    : in  std_logic;
			sclk   : in  std_logic;
			sclk2x : in  std_logic;
			eclk   : in  std_logic);
		port map (
    		rst    => ddrphy_rst,
    		sclk   => ctlrpll_clkok,
    		sclk2x => ctlrpll_clkop,
    		eclk   => ctlrpll_clkos);
    	signal eclksynca_clk  : std_logic;

		signal dqsbuf_rst : std_logic;
		signal dqsdel     : std_logic;
		signal all_lock   : std_logic;
		signal uddcntln   : std_logic;

		signal reset : std_logic;
		signal reset_datapath : std_logic := '0';

        component ecp3_csa
        	generic (
        		period_eclk        : real);
            port  (
                reset              : in  std_logic;
                reset_datapath     : in  std_logic;
                refclk             : in  std_logic;
                clkop              : in  std_logic;
                clkos              : in  std_logic;
                clkok              : in  std_logic;
                uddcntln           : in  std_logic;
                pll_phase          : out std_logic_vector(4-1 downto 0);
                pll_lock           : in std_logic;
                eclk               : out std_logic;
                sclk               : out std_logic;
                sclk2x             : out std_logic;
                reset_datapath_out : out std_logic;
                dqsdel             : out std_logic;
                all_lock           : out std_logic;
                align_status       : out std_logic_vector(2-1 downto 0);
                good               : out std_logic;
                err                : out std_logic);
        end component;

		signal locked : std_logic_vector(ddr3_dqs'range);
	begin

    	dqsdll_uddcntln_b : block
        	signal update : std_logic;
    	begin
        	process (sclk)
        		variable q : std_logic_vector(0 to 4-1);
        	begin
        		if rising_edge(sclk) then
        			if rst='1' then
        				q := (others => '0');
        			elsif q(0)='0' then
        				if all_lock='1' then
        					q := inc(gray(q));
        				end if;
        			end if;
        			update <= not q(0);
        		end if;
        	end process;

        	process (sclk2x)
        	begin
        		if rising_edge(sclk2x) then
        			uddcntln <= update;
        		end if;
        	end process;
    	end block;

		reset <= not ctlrpll_lock;
		ecp3_csa_e : ecp3_csa
		generic map (
			period_eclk => sdram_tcp)
		port map (
			reset              => reset,
			reset_datapath     => reset_datapath,
			refclk             => clk, 
			clkop              => ctlrpll_clkop,
			clkos              => ctlrpll_clkos, 
			clkok              => ctlrpll_clkok, 
			uddcntln           => uddcntln,
			pll_phase          => ctlrpll_phase, 
			pll_lock           => ctlrpll_lock, 
			eclk               => ctlrpll_eclk,
			sclk               => ctlrpll_sclk,
			sclk2x             => ctlrpll_sclk2x, 
			reset_datapath_out => dqsbuf_rst,
			dqsdel             => dqsdel,
			all_lock           => all_lock,
			align_status       => open, 
			good               => ctlr_lck, 
			err                => open);

		-- seg_a <= not setif(locked=(locked'range => '1'));
		-- seg_b <= not locked(0);
		-- seg_c <= not locked(1);
    	sdrphy_e : entity hdl4fpga.ecp3_sdrphy
    	generic map (
    		taps      => natural(floor(sdram_tcp/26.0e-12)),
    		gear      => gear,
    		bank_size => ddr3_b'length,
    		addr_size => ddr3_a'length,
    		word_size => word_size,
    		byte_size => byte_size)
    	port map (
			rst       => dqsbuf_rst,
    		sclk      => ctlrpll_clkok,
    		sclk2x    => ctlrpll_clkop,
    		eclk      => ctlrpll_eclk,
			dqsdel    => dqsdel,
			locked    => locked,
    		phy_frm   => ctlrphy_frm,
    		phy_trdy  => ctlrphy_trdy,
    		phy_cmd   => ctlrphy_cmd,
    		phy_rw    => ctlrphy_rw,
    		phy_ini   => ctlrphy_ini,

    		phy_wlreq => ctlrphy_wlreq,
    		phy_wlrdy => ctlrphy_wlrdy,

    		phy_rlreq => ctlrphy_rlreq,
    		phy_rlrdy => ctlrphy_rlrdy,

    		phy_rst   => ctlrphy_rst,
    		phy_cs    => ctlrphy_cs,
    		phy_cke   => ctlrphy_cke,
    		phy_ras   => ctlrphy_ras,
    		phy_cas   => ctlrphy_cas,
    		phy_we    => ctlrphy_we,
    		phy_odt   => ctlrphy_odt,
    		phy_b     => ctlrphy_ba,
    		phy_a     => ctlrphy_a,
    		phy_dqsi  => ctlrphy_dqso,
    		phy_dqst  => ctlrphy_dqst,
    		phy_dqso  => ctlrphy_dqsi,
    		phy_dmi   => ctlrphy_dmo,
    		phy_dmo   => ctlrphy_dmi,
    		phy_dqi   => ctlrphy_dqo,
    		phy_dqt   => ctlrphy_dqt,
    		phy_dqo   => ctlrphy_dqi,
    		phy_sti   => ctlrphy_sto,
    		phy_sto   => ctlrphy_sti,

    		sdr_rst   => ddr3_rst,
    		sdr_ck    => ddr3_clk,
    		sdr_cke   => ddr3_cke,
    		sdr_cs    => ddr3_cs,
    		sdr_ras   => ddr3_ras,
    		sdr_cas   => ddr3_cas,
    		sdr_we    => ddr3_we,
    		sdr_odt   => ddr3_odt,
    		sdr_b     => ddr3_b,
    		sdr_a     => ddr3_a,

    		sdr_dm    => ddr3_dm,
    		sdr_dq    => ddr3_dq,
    		sdr_dqs   => ddr3_dqs);

	end block;

	-- VGA --
	---------

	phy1_txc_i : oddrxd1
	port map (
		sclk => phy1_rxc,
		da   => '0',
		db   => '1',
		q    => phy1_txc);

	phy1_gtxclk_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

	phy1_rst <= '1';

end;
