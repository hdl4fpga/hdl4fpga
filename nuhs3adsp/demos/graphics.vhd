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
use hdl4fpga.cgafonts.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of nuhs3adsp is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(8-1 downto 0);

	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(8-1 downto 0);

	signal sout1_frm      : std_logic;
	signal sout1_irdy     : std_logic;
	signal sout1_trdy     : std_logic;
	signal sout1_data     : std_logic_vector(8-1 downto 0);

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --  20     --  25     --  10     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------

	constant sys_per      : real    := 50.0;

	constant fpga         : natural := spartan3;
	constant mark         : natural := m6t;


	constant sclk_phases  : natural := 4;
	constant sclk_edges   : natural := 2;
	constant cmmd_gear    : natural := 1;
	constant data_phases  : natural := 2;
	constant data_edges   : natural := 2;
	constant bank_size    : natural := ddr_ba'length;
	constant addr_size    : natural := ddr_a'length;
	constant coln_size    : natural := 8;
	constant data_gear    : natural := 2;
	constant word_size    : natural := ddr_dq'length;
	constant byte_size    : natural := 8;

	signal ddrsys_lckd    : std_logic;
	signal ddrsys_rst     : std_logic;

	constant clk0         : natural := 0;
	constant clk90        : natural := 1;
	signal ddrsys_clks    : std_logic_vector(0 to 2-1);

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

	signal ddr_clk        : std_logic_vector(0 downto 0);
	signal ddr_dqst       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt        : std_logic_vector(ddr_dq'range);
	signal ddr_dqo        : std_logic_vector(ddr_dq'range);

	signal mii_clk        : std_logic;
	signal video_clk      : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_blank    : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);

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
		mode900p,
		mode1080p);

	type displayparam_vector is array (video_modes) of display_param;
	constant video_tab : displayparam_vector := (
		modedebug   => (mode => pclk_debug,               pll => (dcm_mul =>  4, dcm_div => 2)),
		mode480p    => (mode => pclk25_00m640x480at60,    pll => (dcm_mul =>  5, dcm_div => 4)),
		mode600p    => (mode => pclk40_00m800x600at60,    pll => (dcm_mul =>  2, dcm_div => 1)),
		mode900p    => (mode => pclk100_00m1600x900at60,  pll => (dcm_mul =>  5, dcm_div => 1)),
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

	type apps is (
		grade4,
		grade5);

	type app_param is record
		ddr_speed  : ddr_speeds;
		video_mode : video_modes;
	end record;

	type apparam_vector is array (apps) of app_param;
	constant app_tab : apparam_vector := (
		grade4 => (ddr_166MHz, mode900p),	
		grade5 => (ddr_200MHz, mode1080p));
		
	constant app : apps := grade5;
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
	signal txc_rxdv : std_logic;
	signal tp : std_logic_vector(1 to 32);
	signal ipv4acfg_req  : std_logic;
begin

	sys_rst <= not hd_t_clock;
	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

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

	ipv4acfg_req <= not sw1;
	udpdaisy_e : entity hdl4fpga.sio_dayudp
	generic map (
		default_ipv4a => x"c0_a8_00_0e")
	port map (
		ipv4acfg_req => ipv4acfg_req,

		phy_rxc   => mii_rxc,
		phy_rx_dv => mii_rxdv,
		phy_rx_d  => mii_rxd,

		phy_txc   => mii_txc,
		phy_col   => mii_col,
		phy_crs   => mii_crs,
		phy_tx_en => mii_txen,
		phy_tx_d  => mii_txd,
		txc_rxdv  => txc_rxdv,
	
		sio_clk   => sio_clk,
		si_frm    => sout_frm,
		si_irdy   => sout_irdy,
		si_trdy   => sout_trdy,
		si_data   => sout_data,

		so_frm    => sin_frm,
		so_irdy   => sin_irdy,
		so_trdy   => '1',
		so_data   => sin_data,
		tp        => open);
	
	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
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
		
		fifo_size    => 2048)

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
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel,

		dmacfg_clk   => dmacfg_clk,
		ctlr_clks    => ctlr_clks,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "001",
--		cas          => "010",	-- 2   133 Mhz
--		cas          => "110",	-- 2.5 166 Mhz
--		cas          => "011",	-- 3   200 Mhz
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

	process (mii_txc)
		variable q : std_logic;
		variable e : std_logic;
		variable d : std_logic;
	begin
		if rising_edge(mii_txc) then
			d := sin_frm;
			if e='0' and d='1' then
				q := not q;
			end if;
			led18 <= q;
			led16 <= not q;
			e := d;
		end if;
	end process;

--	led18 <= '0';
--	led16 <= '0';
	led15 <= '0';
	led13 <= tp(5);
	led11 <= tp(4); -- '0';
	led9  <= tp(3); -- txc_rxdv ;
	led8  <= tp(2); -- tp(2);
	led7  <= tp(1); -- tp(1); --'0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= '1';
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
