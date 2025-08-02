-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.xc3s_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of nuhs3adsp is

	constant settings : string := "{"                                                                     &
		"io_link: io_ipoe,"                                                                               &
		"video:{"                                                                                         &
			"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'20mhz'.'150mhz'"))                   & ',' &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'1920x1080'.'@60'.'150mhz'")             & ',' &
			"pixel:"   & "{R:8,G:8,B:8}}"                                                                 & ',' &
		"sdram:{"                                                                                         &
			"dcm:"       & string'(hdl4fpga.ecp5_profiles.sdram_dcm(".'25mhz'.'133mhz'"))                 & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT46V16M16M-6T")                                      & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc3sg2")                                                & ',' &
			"cl:"        & "'010'}}";

	signal sys_rst       : std_logic;
	alias sys_clk is clk;

	signal video_clk     : std_logic;
	signal video_hzsync  : std_logic;
	signal video_vtsync  : std_logic;
    signal video_blank   : std_logic;
	signal video_pixel    : std_logic_vector(hdo(settings)**".video.pixel.R=8"+hdo(settings)**".video.pixel.G=8"+hdo(settings)**".video.pixel.B=8"-1 downto 0);

	constant sdram_freq   : real := sdram_freq(hdo(settings)**".sdram.dcm");
	constant sdram_gear   : natural := hdo(settings)**".sdram.phy_data.orgz.gear";

	signal ctlr_rst       : std_logic;
	signal ctlr_clk       : std_logic;
	signal ctlr_clk90     : std_logic;
	signal ctlrdcm_locked : std_logic;

	signal ctlrphy_rst    : std_logic;
	signal ctlrphy_cke    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_cs     : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_ras    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_cas    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_we     : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_odt    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_b      : std_logic_vector((sdram_gear+1)/2*ddr_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector((sdram_gear+1)/2*ddr_a'length-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqsi   : std_logic_vector(sdram_gear*ddr_dqs'length-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(sdram_gear*ddr_dm'length-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(sdram_gear*ddr_dm'length-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(sdram_gear*ddr_dq'length-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(sdram_gear*ddr_dq'length-1 downto 0);
	signal ctlrphy_dqv    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(sdram_gear*ddr_dqs'length-1 downto 0);

	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;

	signal ddr_clk       : std_logic_vector(0 downto 0);
	signal ddr_odt       : std_logic_vector(0 to 0);
	signal sdram_cke     : std_logic_vector(0 to 0);
	signal sdram_cs      : std_logic_vector(0 to 0);
	signal ddr_lp_ck     : std_logic;
	signal st_dqs_open   : std_logic;

	constant mem_size    : natural := 8*(1024*8);
	alias sio_clk        : std_logic is mii_txc;
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);
	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);

	signal mii_tp         : std_logic_vector(1 to 32);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			sys_rst <= not sw1;
		end if;
	end process;

	videodcm_i : entity hdl4fpga.xc3s_videodcm
	generic map(
		settings => hdo(settings)**".dcm")
	port map(
		rst       => sys_rst,
		clk       => sys_clk,
		video_clk => video_clk);

	ddr_lp_ck_i : ibufgds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_lp_ckp,
		ib => ddr_lp_ckn,
		o  => ddr_lp_ck);

	sdramdcm_i : entity hdl4fpga.xc3s_sdramdcm
	generic map (
		settings  => settings**".dcm")
	port map (
		clk        => sys_clk,
		ctlr_clk   => ctlr_clk,
		ctlr_clk90 => ctlr_clk90,
		locked     => ctlrdcm_locked);
	ctlr_rst <= not ctlrdcm_locked;

	miidcm_g : if not debug generate
	   signal clk0    : std_logic;
	   signal clkfb   : std_logic;
	   signal clkfx   : std_logic;
	begin
	
		bug_i : bufg
		port map (
			I => clk0,
			O => clkfb);
	
		dcm_i : dcm
		generic map(
			clk_feedback   => "1x",
			clkdv_divide   => 2.0,
			clkfx_divide   => 4,
			clkfx_multiply => 5,
			clkin_divide_by_2 => false,
			clkin_period   => clk_per*1.0e9,
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
			clkfb    => clkfb,
			clkin    => clk,
			clkfx    => mii_refclk,
			clkfx180 => open,
			clk0     => clk0,
			locked   => open,
			psdone   => open,
			status   => open);
	end generate;

	debug_g : if debug generate
		signal q : bit;
	begin
		q <= not q after 20 ns;
		mii_refclk <= to_stdulogic(q);
	end generate;

	ipoe_b : block


		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
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
				check_dov  => true)
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
			tp         => mii_tp,

			mii_clk    => sio_clk,
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

			so_clk     => sio_clk,
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

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug,
		profile      => 1,
		burst_length => 2,
		-- burst_length => 4,
		-- burst_length => 8,

		sdram_freq   => sdram_freq,
		settings     => settings,
		fifo_size    => mem_size)
	port map (
		tp_sel       => "0000",
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
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => ctlr_rst,
		ctlr_bl      => "001",				-- Busrt length 2
		-- ctlr_bl      => "010",				-- Busrt length 4
		-- ctlr_bl      => "011",				-- Busrt length 8
		ctlr_cl      => settings**".sdram.cl",
		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_dqv  => ctlrphy_dqv,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		tp           => open);

	ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
	ctlrphy_rlreq <= to_stdulogic(to_bit(ctlrphy_rlrdy));

	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		-- dqs_delay   => (0 to 0 => 0 ns),
		-- dqi_delay   => (0 to 0 => 0 ns),
		device      => hdo(settings)**".sdram.phy_data.device",
		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		word_size   => ddr_dq'length,
		byte_size   => ddr_dq'length/ddr_dm'length,
		gear        => sdram_gear,
		bypass      => true,
		loopback    => true,
		rd_fifo     => true,
		rd_align    => true)
	port map (
		rst         => ctlr_rst,
		iod_clk     => ctlr_clk,
		clk         => ctlr_clk,
		clk_shift   => ctlr_clk90,

		phy_wlreq   => ctlrphy_wlreq,
		phy_wlrdy   => ctlrphy_wlrdy,
		phy_rlreq   => ctlrphy_rlreq,
		phy_rlrdy   => ctlrphy_rlrdy,
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
		sys_dmo     => ctlrphy_dmi,
		sys_dqi     => ctlrphy_dqo,
		sys_dqt     => ctlrphy_dqt,
		sys_dqo     => ctlrphy_dqi,
		sys_odt     => ctlrphy_odt,
		sys_dqv     => ctlrphy_dqv,
		sys_sti     => ctlrphy_sto,
		sys_sto     => ctlrphy_sti,

		sdram_sto(0)  => ddr_st_dqs,
		sdram_sto(1)  => st_dqs_open,
		sdram_sti(0)  => ddr_st_lp_dqs,
		sdram_sti(1)  => ddr_st_lp_dqs,
		sdram_clk     => ddr_clk,
		sdram_cke     => sdram_cke,
		sdram_cs      => sdram_cs,
		sdram_odt     => ddr_odt,
		sdram_ras     => ddr_ras,
		sdram_cas     => ddr_cas,
		sdram_we      => ddr_we,
		sdram_b       => ddr_ba,
		sdram_a       => ddr_a,

		sdram_dm      => open,
		sdram_dq      => ddr_dq,
		sdram_dqs     => ddr_dqs);

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_clk(0),
		o  => ddr_ckp,
		ob => ddr_ckn);

	ddr_cke <= sdram_cke(0);
	ddr_cs  <= sdram_cs(0);
	ddr_dm <= (others => '0');

	videoio_b : block
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
-- 
		-- clk_videodac <= video_clk;
    	process (video_clk)
    	begin
    		if rising_edge(video_clk) then
    			red    <= multiplex(video_pixel, std_logic_vector(to_unsigned(0,2)), 8);
    			green  <= multiplex(video_pixel, std_logic_vector(to_unsigned(1,2)), 8);
    			blue   <= multiplex(video_pixel, std_logic_vector(to_unsigned(2,2)), 8);
    			blankn <= not video_blank;
    			hsync  <= video_hzsync;
    			vsync  <= video_vtsync;
    			sync   <= not video_hzsync and not video_vtsync;
    		end if;
    	end process;
	end block;

	psave <= '1';
	adc_clkab <= 'Z';

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

	mii_rstn <= not ctlr_rst;
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
