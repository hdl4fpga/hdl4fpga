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
use hdl4fpga.sdr_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.profiles.all;
use hdl4fpga.app_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of nuhs3adsp is

	type app_profiles is (
		sdr133mhz_480p24bpp,
		sdr133mhz_600p24bpp,
		sdr166mhz_480p24bpp,
		sdr145mhz_600p24bpp,
		sdr150mhz_600p24bpp,
		sdr166mhz_600p24bpp,
		sdr133mhz_720p24bpp,
		sdr166mhz_900p24bpp,
		sdr166mhz_1080p24bpp,
		sdr200mhz_1080p24bpp);

	constant app_profile : app_profiles := sdr166mhz_1080p24bpp;

	type profile_param is record
		comms      : io_comms;
		sdr_speed  : sdram_speeds;
		video_mode : video_modes;
		profile    : natural;
	end record;

	type profileparam_vector is array (app_profiles) of profile_param;
	constant profile_tab : profileparam_vector := (
		sdr133mhz_480p24bpp  => (io_ipoe, sdram133MHz, mode480p24bpp,  1),
		sdr133mhz_600p24bpp  => (io_ipoe, sdram133MHz, mode600p24bpp,  1),
		sdr166mhz_480p24bpp  => (io_ipoe, sdram166MHz, mode480p24bpp,  1),
		sdr145mhz_600p24bpp  => (io_ipoe, sdram166MHz, mode600p24bpp,  1),
		sdr150mhz_600p24bpp  => (io_ipoe, sdram145MHz, mode600p24bpp,  1),
		sdr166mhz_600p24bpp  => (io_ipoe, sdram150MHz, mode600p24bpp,  1),
		sdr133mhz_720p24bpp  => (io_ipoe, sdram166MHz, mode900p24bpp,  1),
		sdr166mhz_900p24bpp  => (io_ipoe, sdram133MHz, mode720p24bpp,  1),
		sdr166mhz_1080p24bpp => (io_ipoe, sdram166MHz, mode1080p24bpp, 1),
		sdr200mhz_1080p24bpp => (io_ipoe, sdram200MHz, mode1080p24bpp, 1));

	type pll_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type video_params is record
		id   : video_modes;
		pll    : pll_params;
		timing : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		(id => modedebug,      timing => pclk_debug,               pll => (dcm_mul =>  4, dcm_div => 2)),
		(id => mode480p24bpp,  timing => pclk25_00m640x480at60,    pll => (dcm_mul =>  5, dcm_div => 4)),
		(id => mode600p24bpp,  timing => pclk40_00m800x600at60,    pll => (dcm_mul =>  2, dcm_div => 1)),
		(id => mode720p24bpp,  timing => pclk75_00m1280x720at60,   pll => (dcm_mul => 15, dcm_div => 4)),
		(id => mode900p24bpp,  timing => pclk108_00m1600x900at60,  pll => (dcm_mul => 27, dcm_div => 5)),
		(id => mode1080p24bpp, timing => pclk150_00m1920x1080at60, pll => (dcm_mul => 15, dcm_div => 2)));

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

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cas : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram133MHz, pll => (dcm_mul => 20, dcm_div => 3), cas => "010"),
		(id => sdram145MHz, pll => (dcm_mul => 29, dcm_div => 4), cas => "110"),
		(id => sdram150MHz, pll => (dcm_mul => 15, dcm_div => 2), cas => "110"),
		(id => sdram166MHz, pll => (dcm_mul => 25, dcm_div => 3), cas => "110"),
		(id => sdram200MHz, pll => (dcm_mul => 10, dcm_div => 1), cas => "011"));

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

	signal sys_rst       : std_logic;
	signal sys_clk       : std_logic;

	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);

	constant sys_per     : real    := 50.0e-9;

	constant sclk_phases : natural := 4;
	constant sclk_edges  : natural := 2;
	constant cmmd_gear   : natural := 1;
	constant data_phases : natural := 2;
	constant data_edges  : natural := 2;
	constant data_gear   : natural := 2;
	constant bank_size   : natural := ddr_ba'length;
	constant addr_size   : natural := ddr_a'length;
	constant coln_size   : natural := 9;
	constant word_size   : natural := ddr_dq'length;
	constant byte_size   : natural := 8;

	signal ddrsys_lckd   : std_logic;
	signal ddrsys_rst    : std_logic;

	signal clk0          : std_logic;
	signal clk90         : std_logic;

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_cs    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_ras   : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_cas   : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_we    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_odt   : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_b     : std_logic_vector(cmmd_gear*ddr_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(cmmd_gear*ddr_a'length-1 downto 0);
	signal ctlrphy_dqsi  : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqst  : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso  : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddr_st_dqs_open : std_logic;

	signal ddr_clk       : std_logic_vector(0 downto 0);
	signal ddr_dqst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt       : std_logic_vector(ddr_dq'range);
	signal ddr_dqo       : std_logic_vector(ddr_dq'range);

	signal mii_clk       : std_logic;
	signal video_clk     : std_logic;
	signal video_hzsync  : std_logic;
    signal video_vtsync  : std_logic;
    signal video_blank   : std_logic;
    signal video_pixel   : std_logic_vector(0 to 32-1);

	constant sdr_speed   : sdram_speeds  := profile_tab(app_profile).sdr_speed;

	function setif (
		constant expr  : boolean;
		constant true  : video_modes;
		constant false : video_modes)
		return video_modes is
	begin
		if expr then
			return true;
		end if;
		return false;
	end;
	constant video_mode : video_modes := setif(debug, modedebug, profile_tab(app_profile).video_mode);

	constant sdram_params : sdramparams_record := sdramparams(sdr_speed);

	constant sdr_tcp   : real := real(sdram_params.pll.dcm_div)*sys_per/real(sdram_params.pll.dcm_mul);

	constant uart_xtal : natural := natural(5.0*10.0**9/real(sys_per*4.0));
	alias sio_clk : std_logic is mii_txc;

	constant baudrate  : natural := 1000000;
--	constant baudrate  : natural := 115200;

	signal dmavideotrans_cnl : std_logic;
	signal tp : std_logic_vector(1 to 32);
begin

--	sys_rst <= not hd_t_clock;
	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rst <= not sw1;
		end if;
	end process;

	videodcm_b : if not debug generate
	   signal dcm_rst   : std_logic;
	   signal dcm_clkfb : std_logic;
	   signal dcm_clk0  : std_logic;
	begin
	
		dcm_rst <= setif(debug, '1', sys_rst);
		bug_i : bufg
		port map (
			I => dcm_clk0,
			O => dcm_clkfb);
	
		dcm_i : dcm
		generic map(
			clk_feedback   => "1x",
			clkdv_divide   => 2.0,
			clkfx_divide   => videoparam(video_mode).pll.dcm_div,
			clkfx_multiply => videoparam(video_mode).pll.dcm_mul,
			clkin_divide_by_2 => false,
			clkin_period   => sys_per*1.0e9,
			clkout_phase_shift => "none",
			deskew_adjust  => "system_synchronous",
			dfs_frequency_mode => "LOW",
			duty_cycle_correction => true,
			factory_jf   => x"c080",
			phase_shift  => 0,
			startup_wait => false)
		port map (
			rst      => dcm_rst,
			dssen    => '0',
			psclk    => '0',
			psen     => '0',
			psincdec => '0',
			clkfb    => dcm_clkfb,
			clkin    => sys_clk,
			clkfx    => video_clk,
			clkfx180 => open,
			clk0     => dcm_clk0,
			locked   => open,
			psdone   => open,
			status   => open);

	end generate;

	miidcm_g : if not debug generate
	   signal dcm_clkfb  : std_logic;
	   signal dcm_clk0   : std_logic;
	begin
	
		bug_i : bufg
		port map (
			I => dcm_clk0,
			O => dcm_clkfb);
	
		dcm_i : dcm
		generic map(
			clk_feedback   => "1x",
			clkdv_divide   => 2.0,
			clkfx_divide   => 4,
			clkfx_multiply => 5,
			clkin_divide_by_2 => false,
			clkin_period   => sys_per*1.0e9,
			clkout_phase_shift => "none",
			deskew_adjust  => "system_synchronous",
			dfs_frequency_mode => "LOW",
			duty_cycle_correction => true,
			factory_jf   => x"c080",
			phase_shift  => 0,
			startup_wait => false)
		port map (
			rst      => '0',
			dssen    => '0',
			psclk    => '0',
			psen     => '0',
			psincdec => '0',
			clkfb    => dcm_clkfb,
			clkin    => sys_clk,
			clkfx    => mii_clk,
			clkfx180 => open,
			clk0     => dcm_clk0,
			locked   => open,
			psdone   => open,
			status   => open);

	end generate;

	debug_g : if debug generate
		signal q : bit;
	begin
		q <= not q after 20 ns;
		mii_clk <= to_stdulogic(q);
	end generate;

	ddrdcm_b : block
		signal dfs_lckd  : std_logic;
		signal dfs_clkfb : std_logic;
		
		signal dcm_rst   : std_logic;
		signal dcm_clkin : std_logic;
		signal dcm_clk0  : std_logic;
		signal dcm_clk90 : std_logic;
		signal dcm_lckd  : std_logic;

	begin

		dfs_i : dcm_sp
		generic map(
			clk_feedback  => "1X",
			clkin_period  => sys_per*1.0e9,
			clkdv_divide  => 2.0,
			clkin_divide_by_2 => FALSE,
			clkfx_divide  => sdram_params.pll.dcm_div,
			clkfx_multiply => sdram_params.pll.dcm_mul,
			clkout_phase_shift => "NONE",
			deskew_adjust => "SYSTEM_SYNCHRONOUS",
			dfs_frequency_mode => "HIGH",
			duty_cycle_correction => TRUE,
			factory_jf   => X"C080",
			phase_shift  => 0,
			startup_wait => FALSE)
		port map (
			dssen    => '0',
			psclk    => '0',
			psen     => '0',
			psincdec => '0',
	
			rst      => sys_rst,
			clkin    => sys_clk,
			clkfb    => dfs_clkfb,
			clk0     => dfs_clkfb,
			clkfx    => dcm_clkin,
			locked   => dfs_lckd);

		process (sys_rst, sys_clk)
		begin
			if sys_rst='1' then
				dcm_rst <= '1';
			elsif rising_edge(sys_clk) then
				dcm_rst <= not dfs_lckd;
			end if;
		end process;

		dcm_dll : dcm_sp
		generic map(
			clk_feedback => "1X",
			clkdv_divide => 2.0,
			clkfx_divide => 1,
			clkfx_multiply => 2,
			clkin_divide_by_2 => FALSE,
			clkin_period => (real(sdram_params.pll.dcm_div)*sys_per*1.0e9)/real( sdram_params.pll.dcm_mul),
			clkout_phase_shift => "NONE",
			deskew_adjust => "SYSTEM_SYNCHRONOUS",
			dfs_frequency_mode => "HIGH",
			duty_cycle_correction => TRUE,
			factory_jf => x"C080",
			phase_shift => 0,
			startup_wait => FALSE)
		port map (
			dssen    => '0',
			psclk    => '0',
			psen     => '0',
			psincdec => '0',
	
			rst      => dcm_rst,
			clkin    => dcm_clkin,
			clkfb    => clk0,
			clk0     => dcm_clk0,
			clk90    => dcm_clk90,
			locked   => dcm_lckd);

		clk0_bufg_i : bufg
		port map (
			i => dcm_clk0,
			o => clk0);
	
		clk90_bufg_i : bufg
		port map (
			i => dcm_clk90,
			o => clk90);
	
		ddrsys_rst <= not dcm_lckd;

	end block;

	ipoe_b : block


		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
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
				src_clk  => mii_rxc,
				src_data => rxc_rxbus,
				dst_clk  => mii_txc,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_rxd'length);
				end if;
			end process;
		end block;

		dhcp_p : process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
			--		dhcpcd_req <= dhcpcd_rdy xor not sw1;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => debug,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
--			tp         => tp,

			sio_clk    => sio_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => miirx_irdy,
			miirx_trdy => open,
			miirx_data => miirx_data,

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
			desser_clk => mii_txc,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => mii_txd);

		mii_txen  <= miitx_frm and not miitx_end;

	end block;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		debug        => debug,
		profile      => profile_tab(app_profile).profile,
		sdr_tcp      => sdr_tcp,
		fpga         => xc3s,
		mark         => MT46V256M6T,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		cmmd_gear    => cmmd_gear,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		burst_length => 2,
		-- burst_length => 4,
		-- burst_length => 8,
		timing_id    => videoparam(video_mode).timing,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8,

		fifo_size    => 8*2048)

	port map (
		tpin => "0000",
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
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel,

		ctlr_clks(0) => clk0,
		ctlr_clks(1) => clk90,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "001",				-- Busrt length 2
		-- ctlr_bl      => "010",				-- Busrt length 4
		-- ctlr_bl      => "011",				-- Busrt length 8
		ctlr_cl      => sdram_params.cas,
		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dsi  => ctlrphy_dqsi,
		ctlrphy_dst  => ctlrphy_dqst,
		ctlrphy_dso  => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		tp => tp);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			red    <= word2byte(video_pixel, std_logic_vector(to_unsigned(0,2)), 8);
			green  <= word2byte(video_pixel, std_logic_vector(to_unsigned(1,2)), 8);
			blue   <= word2byte(video_pixel, std_logic_vector(to_unsigned(2,2)), 8);
			blankn <= not video_blank;
			hsync  <= video_hzsync;
			vsync  <= video_vtsync;
			sync   <= not video_hzsync and not video_vtsync;
		end if;
	end process;

	sdrphy_e : entity hdl4fpga.xc3s_sdrphy
	generic map (
		gate_delay  => 2,
		loopback    => true,
		rgtr_dout   => false,
		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		cmmd_gear   => cmmd_gear,
		data_gear   => data_gear,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		sys_rst     => ddrsys_rst,
		clk0 => clk0,
		clk90 => clk90,

		phy_cke     => ctlrphy_cke,
		phy_cs      => ctlrphy_cs,
		phy_ras     => ctlrphy_ras,
		phy_cas     => ctlrphy_cas,
		phy_we      => ctlrphy_we,
		phy_b       => ctlrphy_b,
		phy_a       => ctlrphy_a,
		phy_dqsi    => ctlrphy_dqso,
		phy_dqst    => ctlrphy_dqst,
		phy_dqso    => ctlrphy_dqsi,
		phy_dmi     => ctlrphy_dmo,
		phy_dmt     => ctlrphy_dmt,
		phy_dmo     => ctlrphy_dmi,
		phy_dqi     => ctlrphy_dqo,
		phy_dqt     => ctlrphy_dqt,
		phy_dqo     => ctlrphy_dqi,
		phy_odt     => ctlrphy_odt,
		phy_sti     => ctlrphy_sto,
		phy_sto     => ctlrphy_sti,

		sdr_sto(0)  => ddr_st_dqs,
		sdr_sto(1)  => ddr_st_dqs_open,
		sdr_sti(0)  => ddr_st_lp_dqs,
		sdr_sti(1)  => ddr_st_lp_dqs,
		sdr_clk     => ddr_clk,
		sdr_cke     => ddr_cke,
		sdr_cs      => ddr_cs,
		sdr_ras     => ddr_ras,
		sdr_cas     => ddr_cas,
		sdr_we      => ddr_we,
		sdr_b       => ddr_ba,
		sdr_a       => ddr_a,

		sdr_dm      => ddr_dm,
		sdr_dqt     => ddr_dqt,
		sdr_dqi     => ddr_dq,
		sdr_dqo     => ddr_dqo,
		sdr_dqst    => ddr_dqst,
		sdr_dqsi    => ddr_dqs,
		sdr_dqso    => ddr_dqso);

	ddr_dqs_g : for i in ddr_dqs'range generate
		ddr_dqs(i) <= ddr_dqso(i) when ddr_dqst(i)='0' else 'Z';
	end generate;

	process (ddr_dqt, ddr_dqo)
	begin
		for i in ddr_dq'range loop
			ddr_dq(i) <= 'Z';
			if ddr_dqt(i)='0' then
				ddr_dq(i) <= ddr_dqo(i);
			end if;
		end loop;
	end process;

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_clk(0),
		o  => ddr_ckp,
		ob => ddr_ckn);

	psave <= '1';
--	adcclkab_e : entity hdl4fpga.ddro
--	port map (
--		clk => '0', --adc_clk,
--		dr  => '1',
--		df  => '0',
--		q   => adc_clkab);
	adc_clkab <= 'Z';

	clk_videodac_b : block
		signal videoclk_n : std_logic;
	begin
		videoclk_n <= not video_clk;
		clk_videodac_i : oddr2
		port map (
			c0 => video_clk,
			c1 => videoclk_n,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => '0',
			d1 => '1',
			q => clk_videodac);
		end block;

--	clk_mii_e : entity hdl4fpga.ddro
--	port map (
--		clk => mii_clk,
--		dr => '0',
--		df => '1',
--		q => mii_refclk);
	mii_refclk <= mii_clk;

	hd_t_data <= 'Z';

	-- LEDs --
	----------

	led18 <= '0'; --tp(1); --'0';
	led16 <= '0'; --tp(2);
	led15 <= '0'; --tp(3);
	led13 <= '0'; --tp(4);
	led11 <= '0'; --si_end;
	led9  <= '0'; --si_trdy;
	led8  <= '0'; --si_irdy;
	led7  <= '0'; --si_frm;

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= not ddrsys_rst;
	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

end;
