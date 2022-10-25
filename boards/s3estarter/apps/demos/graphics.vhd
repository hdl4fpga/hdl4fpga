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
use hdl4fpga.sdram_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.profiles.all;
use hdl4fpga.app_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of s3estarter is

	type app_profiles is (
		sdr133mhz_480p24bpp,
		sdr166mhz_600p24bpp,
		sdr170mhz_600p24bpp,
		sdr200mhz_1080p24bpp);

	-- constant app_profile : app_profiles := sdr133mhz_480p24bpp;
	constant app_profile : app_profiles := sdr166mhz_600p24bpp;

	type profile_param is record
		comms       : io_comms;
		sdram_speed : sdram_speeds;
		video_mode  : video_modes;
	end record;

	type profileparam_vector is array (app_profiles) of profile_param;
	constant profile_tab : profileparam_vector := (
		sdr133mhz_480p24bpp  => (io_ipoe, sdram133MHz, mode480p24bpp),
		sdr166mhz_600p24bpp  => (io_ipoe, sdram166MHz, mode600p24bpp),
		sdr170mhz_600p24bpp  => (io_ipoe, sdram170MHz, mode600p24bpp),
		sdr200mhz_1080p24bpp => (io_ipoe, sdram200MHz, mode1080p24bpp));

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
		(id => mode480p24bpp,  timing => pclk25_00m640x480at60,    pll => (dcm_mul =>  2, dcm_div => 4)),
		(id => mode600p24bpp,  timing => pclk40_00m800x600at60,    pll => (dcm_mul =>  4, dcm_div => 5)),
		(id => mode720p24bpp,  timing => pclk75_00m1280x720at60,   pll => (dcm_mul =>  3, dcm_div => 2)),
		(id => mode1080p24bpp, timing => pclk150_00m1920x1080at60, pll => (dcm_mul =>  3, dcm_div => 1)));


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

	constant video_mode   : video_modes := setdebug(debug, profile_tab(app_profile).video_mode);

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram133MHz, pll => (dcm_mul =>  8, dcm_div => 3), cl => "010"),
		(id => sdram166MHz, pll => (dcm_mul => 10, dcm_div => 3), cl => "110"),
		(id => sdram170MHz, pll => (dcm_mul => 17, dcm_div => 5), cl => "110"),
		(id => sdram200MHz, pll => (dcm_mul =>  4, dcm_div => 1), cl => "011"));

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

	constant sdram_speed   : sdram_speeds  := profile_tab(app_profile).sdram_speed;
	constant sdram_params  : sdramparams_record := sdramparams(sdram_speed);

	constant sdram_tcp       : real := real(sdram_params.pll.dcm_div)*sys_per/real(sdram_params.pll.dcm_mul);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal si_frm          : std_logic;
	signal si_irdy         : std_logic;
	signal si_trdy         : std_logic;
	signal si_end          : std_logic;
	signal si_data         : std_logic_vector(0 to 8-1);

	signal so_frm          : std_logic;
	signal so_irdy         : std_logic;
	signal so_trdy         : std_logic;
	signal so_data         : std_logic_vector(0 to 8-1);

	constant sclk_phases   : natural := 4;
	constant sclk_edges    : natural := 2;
	constant cmmd_gear     : natural := 1;
	constant data_phases   : natural := 2;
	constant data_edges    : natural := 2;
	constant bank_size     : natural := sd_ba'length;
	constant addr_size     : natural := sd_a'length;
	constant coln_size     : natural := 9;
	constant data_gear     : natural := 2;
	constant word_size     : natural := sd_dq'length;
	constant byte_size     : natural := 8;

	signal sdrsys_rst      : std_logic;
	signal sdrphy_clk      : std_logic_vector(0 to 0);

	signal clk0            : std_logic;
	signal clk90           : std_logic;

	signal ctlrphy_rst     : std_logic;
	signal ctlrphy_cke     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_cs      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_ras     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_cas     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_we      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_odt     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_b       : std_logic_vector(cmmd_gear*sd_ba'length-1 downto 0);
	signal ctlrphy_a       : std_logic_vector(cmmd_gear*sd_a'length-1 downto 0);
	signal ctlrphy_dqsi    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqst    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal dqsi_inv        : std_logic;

	signal sdram_clk       : std_logic_vector(0 downto 0);
	signal sdram_dqst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqt       : std_logic_vector(sd_dq'range);
	signal sdram_dqo       : std_logic_vector(sd_dq'range);

	signal sdram_cke       : std_logic_vector(0 to 0);
	signal sdram_cs        : std_logic_vector(0 to 0);
	signal sdram_odt       : std_logic_vector(0 to 0);

	signal mii_clk         : std_logic;
	signal video_clk       : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
    signal video_blank     : std_logic;
    signal video_pixel     : std_logic_vector(0 to 32-1);

	alias ctlr_clk   : std_logic is clk0;

	alias sio_clk : std_logic is e_tx_clk;

	constant baudrate  : natural := 1000000;

	signal dmavideotrans_cnl : std_logic;
	signal tp : std_logic_vector(1 to 32);
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rst <= btn_north;
		end if;
	end process;

	videodcm_b : if not debug generate
		signal dcm_clkfb : std_logic;
		signal dcm_clk0  : std_logic;
	begin
	
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
			rst      => sys_rst ,
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

	ddrdcm_b : block
		signal dfs_lckd  : std_logic;
		signal dfs_clkfb : std_logic;
		signal dfs_clkfx : std_logic;
		signal dfs_clkfx180 : std_logic;
		
		signal dcm_rst   : std_logic;
		signal dcm_clkin : std_logic;
		signal dcm_clkfb : std_logic;
		signal dcm_clk0  : std_logic;
		signal dcm_clk90 : std_logic;
		signal dcm_clk180 : std_logic;
		signal dcm_lckd  : std_logic;

		signal sdram_clk  : std_logic;
	begin

		dfs_i : dcm_sp
		generic map(
			clk_feedback => "1X",
			clkin_period => sys_per*1.0e9,
			clkdv_divide => 2.0,
			clkin_divide_by_2 => FALSE,
			clkfx_divide => sdram_params.pll.dcm_div,
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
			clkfx    => dfs_clkfx,
			clkfx180 => dfs_clkfx180,
			locked   => dfs_lckd);

		oddr_i : oddr2
		port map (
			c0 => dfs_clkfx,
			c1 => dfs_clkfx180,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => '0',
			d1 => '1',
			q  => sdram_clk);

		sdram_clk_i : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => sdram_clk,
			o  => sd_ck_p,
			ob => sd_ck_n);

	
		dcm_dll : dcm_sp
		generic map(
			clk_feedback => "1X",
			clkin_period => (sys_per*real(sdram_params.pll.dcm_div))/real( sdram_params.pll.dcm_mul)*1.0e9,
			clkdv_divide => 2.0,
			clkin_divide_by_2 => FALSE,
			clkfx_divide => 1,
			clkfx_multiply => 2,
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
	
			rst      => '0',
			clkin    => dfs_clkfx,
			clkfb    => dfs_clkfx,
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
	
		sdrsys_rst <= not dcm_lckd;

	end block;

	ipoe_b : block

		signal mii_txcfrm : std_ulogic;
		signal mii_txcrxd : std_logic_vector(e_rxd'range);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(0 to 8-1);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(miirx_data'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (e_rx_clk)
			begin
				if rising_edge(e_rx_clk) then
					rxc_rxbus <= e_rx_dv & e_rxd;
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
				src_clk  => e_rx_clk,
				src_data => rxc_rxbus,
				dst_clk  => e_tx_clk,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (e_tx_clk)
			begin
				if rising_edge(e_tx_clk) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					mii_txcfrm <= txc_rxbus(0);
					mii_txcrxd <= txc_rxbus(1 to mii_txcrxd'length);
				end if;
			end process;
		end block;

		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => e_tx_clk,
			serdes_frm => mii_txcfrm,
			ser_irdy   => '1',
			ser_trdy   => open,
			ser_data   => mii_txcrxd,

			des_frm    => miirx_frm,
			des_irdy   => miirx_irdy,
			des_trdy   => miirx_trdy,
			des_data   => miirx_data);

		dhcp_p : process(e_tx_clk)
		begin
			if rising_edge(e_tx_clk) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
			--		dhcpcd_req <= dhcpcd_rdy xor not sw0;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => tp,

			sio_clk    => sio_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => miirx_irdy,
			miirx_trdy => miirx_trdy,
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

		led0 <= tp(1); --si_frm;
		led1 <= tp(2); --si_irdy;
		led2 <= tp(3); --si_trdy;
		led3 <= tp(4); --si_end;
		led4 <= tp(5); --'0';
		led5 <= tp(6); --'0';
		led6 <= tp(7); --'0';
		led7 <= tp(8); --'0';

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => e_tx_clk,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => e_txd);

		e_txen  <= miitx_frm and not miitx_end;

	end block;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		debug        => debug,
		profile      => 1,
		sdram_tcp      => sdram_tcp,
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
		timing_id    => videoparam(video_mode).timing,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8,

		fifo_size    => 8*2048)

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
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel,

		ctlr_clks(0) => clk0,
		ctlr_clks(1) => clk90,
		ctlr_rst     => sdrsys_rst,
		ctlr_bl      => "001",
		ctlr_cl      => sdram_params.cl,
		ctlr_rtt     => "-",
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
		tp => open);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			vga_red    <= word2byte(video_pixel, std_logic_vector(to_unsigned(0,2)), 8)(0);
			vga_green  <= word2byte(video_pixel, std_logic_vector(to_unsigned(1,2)), 8)(0);
			vga_blue   <= word2byte(video_pixel, std_logic_vector(to_unsigned(2,2)), 8)(0);
			vga_hsync  <= video_hzsync;
			vga_vsync  <= video_vtsync;
		end if;
	end process;

	dqsi_inv <= '1' when sdram_params.cl="110" else '0';	-- 2.5 cas latency;

	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		device      => xc3s,
		bypass      => true,
		loopback    => false,
		bank_size   => sd_ba'length,
		addr_size   => sd_a'length,
		cmmd_gear   => cmmd_gear,
		data_gear   => data_gear,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		iod_clk   => clk0,
		clk0        => clk0,
		clk90       => clk90,
		rst     => sdrsys_rst,

		sys_cke     => ctlrphy_cke,
		sys_cs      => ctlrphy_cs,
		sys_ras     => ctlrphy_ras,
		sys_cas     => ctlrphy_cas,
		sys_we      => ctlrphy_we,
		sys_b       => ctlrphy_b,
		sys_a       => ctlrphy_a,
		sys_dqsi    => ctlrphy_dqso,
		sys_dqst    => ctlrphy_dqst,
		sys_dqso    => ctlrphy_dqsi,
		sys_dmi     => ctlrphy_dmo,
		sys_dmt     => ctlrphy_dmt,
		sys_dmo     => ctlrphy_dmi,
		sys_dqi     => ctlrphy_dqo,
		sys_dqt     => ctlrphy_dqt,
		sys_dqo     => ctlrphy_dqi,
		sys_odt     => ctlrphy_odt,
		sys_sti     => ctlrphy_sto,
		sys_sto     => ctlrphy_sti,

		sdram_clk     => sdrphy_clk,
		sdram_cke     => sdram_cke,
		sdram_cs      => sdram_cs,
		sdram_odt     => sdram_odt,
		sdram_ras     => sd_ras,
		sdram_cas     => sd_cas,
		sdram_we      => sd_we,
		sdram_b       => sd_ba,
		sdram_a       => sd_a,

		sdram_dm      => sd_dm,
		sdram_dqt     => sdram_dqt,
		sdram_dqi     => sd_dq,
		sdram_dqo     => sdram_dqo,
		sdram_dqst    => sdram_dqst,
		sdram_dqsi    => sd_dqs,
		sdram_dqso    => sdram_dqso);

	sd_cke <= sdram_odt(0);
	sd_cs  <= sdram_cs(0);

	sdram_dqs_g : for i in sd_dqs'range generate
		sd_dqs(i) <= sdram_dqso(i) when sdram_dqst(i)='0' else 'Z';
	end generate;

	process (sdram_dqt, sdram_dqo)
	begin
		for i in sd_dq'range loop
			sd_dq(i) <= 'Z';
			if sdram_dqt(i)='0' then
				sd_dq(i) <= sdram_dqo(i);
			end if;
		end loop;
	end process;

	-- LEDs --
	----------

	-- led0 <= sys_rst;
	-- led1 <= '0';
	-- led2 <= '0';
	-- led3 <= '0';
	-- led4 <= '0';
	-- led5 <= '0';
	-- led6 <= '0';
	-- led7 <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_dte_txd <= 'Z';
	rs232_dce_txd <= 'Z';

	-- Ethernet Transceiver --
	--------------------------

	e_mdc       <= 'Z';
	e_mdio      <= 'Z';
	e_txd_4     <= 'Z';

	e_txd  	    <= (others => 'Z');
	e_txen      <= 'Z';

	-- misc --
	----------

	ad_conv     <= 'Z';
	spi_sck     <= 'Z';
	dac_cs      <= 'Z';
	amp_cs      <= 'Z';
	spi_mosi    <= 'Z';

	amp_shdn    <= 'Z';
	dac_clr     <= 'Z';
	sf_ce0      <= 'Z';
	fpga_init_b <= 'Z';
	spi_ss_b    <= 'Z';

end;
