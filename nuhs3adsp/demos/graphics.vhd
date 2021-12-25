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
use hdl4fpga.cgafonts.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of nuhs3adsp is

	type apps is (
		mode900p_ddr166mhz,
		mode1080p_ddr166mhz,
		mode1080p_ddr200mhz);
	constant app         : apps := mode1080p_ddr200mhz; --mode900p_ddr166mhz;

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

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --  20     --  25     --  10     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------

	constant sys_per       : real    := 50.0;

	constant fpga          : natural := spartan3;
	constant mark          : natural := m6t;

	constant sclk_phases   : natural := 4;
	constant sclk_edges    : natural := 2;
	constant cmmd_gear     : natural := 1;
	constant data_phases   : natural := 2;
	constant data_edges    : natural := 2;
	constant bank_size     : natural := ddr_ba'length;
	constant addr_size     : natural := ddr_a'length;
	constant coln_size     : natural := 8;
	constant data_gear     : natural := 2;
	constant word_size     : natural := ddr_dq'length;
	constant byte_size     : natural := 8;

	signal ddrsys_lckd     : std_logic;
	signal ddrsys_rst      : std_logic;

	constant clk0          : natural := 0;
	constant clk90         : natural := 1;
	signal ddrsys_clks     : std_logic_vector(0 to 2-1);

	signal ctlrphy_rst     : std_logic;
	signal ctlrphy_cke     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_cs      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_ras     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_cas     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_we      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_odt     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ctlrphy_b       : std_logic_vector(cmmd_gear*ddr_ba'length-1 downto 0);
	signal ctlrphy_a       : std_logic_vector(cmmd_gear*ddr_a'length-1 downto 0);
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
	signal ddr_st_dqs_open : std_logic;

	signal ddr_clk         : std_logic_vector(0 downto 0);
	signal ddr_dqst        : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso        : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt         : std_logic_vector(ddr_dq'range);
	signal ddr_dqo         : std_logic_vector(ddr_dq'range);

	signal mii_clk         : std_logic;
	signal video_clk       : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
    signal video_blank     : std_logic;
    signal video_pixel     : std_logic_vector(0 to 32-1);

	type pll_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type display_param is record
		pll  : pll_params;
		mode : videotiming_ids;
	end record;

	type video_modes is (
		modedebug,
		mode480p,
		mode600p,
		mode720p,
		mode900p,
		mode1080p);

	type displayparam_vector is array (video_modes) of display_param;
	constant video_tab : displayparam_vector := (
		modedebug   => (mode => pclk_debug,               pll => (dcm_mul =>  4, dcm_div => 2)),
		mode480p    => (mode => pclk25_00m640x480at60,    pll => (dcm_mul =>  5, dcm_div => 4)),
		mode600p    => (mode => pclk40_00m800x600at60,    pll => (dcm_mul =>  2, dcm_div => 1)),
		mode720p    => (mode => pclk75_00m1280x720at60,   pll => (dcm_mul => 15, dcm_div => 4)),
		mode900p    => (mode => pclk108_00m1600x900at60,  pll => (dcm_mul => 27, dcm_div => 5)),
		mode1080p   => (mode => pclk150_00m1920x1080at60, pll => (dcm_mul => 15, dcm_div => 2)));

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

	type ddr_params is record
		pll : pll_params;
		cas : std_logic_vector(0 to 3-1);
	end record;

	type ddr_speeds is (
		ddr_133MHz,
		ddr_166MHz,
		ddr_200MHz);

	type ddram_vector is array (ddr_speeds) of ddr_params;
	constant ddr_tab : ddram_vector := (
		ddr_133MHz => (pll => (dcm_mul => 20, dcm_div => 3), cas => "010"),
		ddr_166MHz => (pll => (dcm_mul => 25, dcm_div => 3), cas => "110"),
		ddr_200MHz => (pll => (dcm_mul => 10, dcm_div => 1), cas => "011"));

	type app_param is record
		ddr_speed  : ddr_speeds;
		video_mode : video_modes;
	end record;

	type apparam_vector is array (apps) of app_param;
	constant app_tab : apparam_vector := (
		mode900p_ddr166mhz  => (ddr_166MHz, mode900p),
		mode1080p_ddr166mhz => (ddr_166MHz, mode1080p),
		mode1080p_ddr200mhz => (ddr_200MHz, mode1080p));

	constant ddr_speed  : ddr_speeds  := app_tab(app).ddr_speed;
	constant video_mode : video_modes := setif(debug, modedebug, app_tab(app).video_mode);

	constant ddr_param : ddr_params := ddr_tab(ddr_speed);

	constant ddr_tcp   : natural := (natural(sys_per)*ddr_param.pll.dcm_div*1000)/(ddr_param.pll.dcm_mul); -- 1 ns /1ps

	alias dmacfg_clk : std_logic is sys_clk;
--	alias dmacfg_clk : std_logic is mii_txc;
	alias ctlr_clks  : std_logic_vector(ddrsys_clks'range) is ddrsys_clks;
	alias ctlr_clk   : std_logic is ddrsys_clks(clk0);

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

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 50.0,
		dfs_mul => video_tab(video_mode).pll.dcm_mul,
		dfs_div => video_tab(video_mode).pll.dcm_div)
	port map(
		dcm_rst => sys_rst,
		dcm_clk => sys_clk,
		dfs_clk => video_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_clk);

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_param.pll.dcm_mul,
		dfs_div => ddr_param.pll.dcm_div)
	port map (
		dfsdcm_rst   => sys_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => ctlr_clk,
		dfsdcm_clk90 => ddrsys_clks(clk90),
		dfsdcm_lckd  => ddrsys_lckd);
	ddrsys_rst <= not ddrsys_lckd;

	ipoe_b : block

		signal mii_txcfrm : std_ulogic;
		signal mii_txcrxd : std_logic_vector(mii_rxd'range);

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
					mii_txcfrm <= txc_rxbus(0);
					mii_txcrxd <= txc_rxbus(1 to mii_txcrxd'length);
				end if;
			end process;
		end block;

		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => mii_txc,
			serdes_frm => mii_txcfrm,
			ser_irdy   => '1',
			ser_trdy   => open,
			ser_data   => mii_txcrxd,

			des_frm    => miirx_frm,
			des_irdy   => miirx_irdy,
			des_trdy   => miirx_trdy,
			des_data   => miirx_data);

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
--			default_ipv4a => x"c0_a8_00_0e")
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
		profile      => 1,
		ddr_tcp      => ddr_tcp,
		fpga         => fpga,
		mark         => mark,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_tab(video_mode).mode,
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

		dmacfg_clk   => dmacfg_clk,
		ctlr_clks    => ctlr_clks,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "001",
		ctlr_cl      => ddr_param.cas,
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
			red    <= word2byte(video_pixel, std_logic_vector(to_unsigned(0,2)), 8);
			green  <= word2byte(video_pixel, std_logic_vector(to_unsigned(1,2)), 8);
			blue   <= word2byte(video_pixel, std_logic_vector(to_unsigned(2,2)), 8);
			blankn <= not video_blank;
			hsync  <= video_hzsync;
			vsync  <= video_vtsync;
			sync   <= not video_hzsync and not video_vtsync;
		end if;
	end process;

	ddrphy_e : entity hdl4fpga.xcs3_ddrphy
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
		sys_clks    => ddrsys_clks,
		sys_rst     => ddrsys_rst,

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

		ddr_sto(0)  => ddr_st_dqs,
		ddr_sto(1)  => ddr_st_dqs_open,
		ddr_sti(0)  => ddr_st_lp_dqs,
		ddr_sti(1)  => ddr_st_lp_dqs,
		ddr_clk     => ddr_clk,
		ddr_cke     => ddr_cke,
		ddr_cs      => ddr_cs,
		ddr_ras     => ddr_ras,
		ddr_cas     => ddr_cas,
		ddr_we      => ddr_we,
		ddr_b       => ddr_ba,
		ddr_a       => ddr_a,

		ddr_dm      => ddr_dm,
		ddr_dqt     => ddr_dqt,
		ddr_dqi     => ddr_dq,
		ddr_dqo     => ddr_dqo,
		ddr_dqst    => ddr_dqst,
		ddr_dqsi    => ddr_dqs,
		ddr_dqso    => ddr_dqso);

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

	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => video_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

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

	led18 <= not tp(1); --tp(8);
	led16 <= tp(1); -- '0'; --tp(7);
	led15 <= '0'; --tp(6);
	led13 <= '0'; --tp(3); --tp(5);
	led11 <= '0'; --tp(4);
	led9  <= tp(2); --tp(3);
	led8  <= tp(3); --tp(2);
	led7  <= tp(4);

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= ddrsys_lckd;
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
