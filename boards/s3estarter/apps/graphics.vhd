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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.xc3s_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of s3estarter is

	--------------------------------------
	-- Set of profiles                  --
	constant settings : string := "{"                                                                     &
		"io_link: io_ipoe,"                                                                                &
		"video:{"                                                                                         &
			"dcm:"          & string'(hdl4fpga.ecp5_profiles.video_dcm(".'25mhz'.'40mhz'", 36.0e6)) & ',' &
			"videoio_freq:" & "36.0e6,"                                                                   &
			"gear:"         & "2,"                                                                        &
			"timings:"      & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'")     & ',' &
			"pixel:{"                                                                                     &
				"R:8,"                                                                                    &
				"G:8,"                                                                                    &
				"B:8}},"                                                                                  &
		"sdram:{"                                                                                         &
			"dcm:"       & string'(hdl4fpga.ecp5_profiles.sdram_dcm(".'25mhz'.'133mhz'"))                 & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT46V16M16M-6T")                                      & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc3sg2")                                                & ',' &
			"cl:"        & "'010'}}";

	constant sdram_freq  : real := sdram_freq(settings**".sdram.dcm");
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
	signal ctlrphy_b      : std_logic_vector((sdram_gear+1)/2*sd_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector((sdram_gear+1)/2*sd_a'length-1 downto 0);
	signal ctlrphy_dqsi   : std_logic_vector(sdram_gear*sd_dqs'length-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(sdram_gear*sd_dm'length-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(sdram_gear*sd_dm'length-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(sdram_gear*sd_dq'length-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(sdram_gear*sd_dq'length-1 downto 0);
	signal ctlrphy_dqv    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(sdram_gear*sd_dqs'length-1 downto 0);

	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;

	signal sd_clk         : std_logic_vector(0 downto 0);
	signal sdram_dqst     : std_logic_vector(sd_dqs'length-1 downto 0);
	signal sdram_dqso     : std_logic_vector(sd_dqs'length-1 downto 0);
	signal sdram_dqt      : std_logic_vector(sd_dq'range);
	signal sdram_dqo      : std_logic_vector(sd_dq'range);

	signal sdram_cke      : std_logic_vector(0 to 0);
	signal sdram_cs       : std_logic_vector(0 to 0);
	signal sdram_odt      : std_logic_vector(0 to 0);

	signal video_clk      : std_logic;
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
	signal video_blank    : std_logic;
	signal video_pixel    : std_logic_vector(0 to 32-1);

	constant mem_size    : natural := 8*(1024*8);
	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(0 to 8-1);
	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);

	signal mii_clk        : std_logic;
	alias sio_clk         : std_logic is e_tx_clk;

	signal sys_rst        : std_logic;
	alias sys_clk         : std_logic is clk_50mhz;

	signal tp : std_logic_vector(1 to 32);
begin

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rst <= btn_north;
		end if;
	end process;

	videodcm_i : entity hdl4fpga.xc3s_videodcm
	generic map(
		settings => hdo(settings)**".video.dcm")
	port map(
		rst       => sys_rst,
		clk       => sys_clk,
		video_clk => video_clk);

	sdramdcm_i : entity hdl4fpga.xc3s_sdramdcm
	generic map (
		settings  => settings**"sdram.dcm")
	port map (
		clk        => sys_clk,
		ctlr_clk   => ctlr_clk,
		ctlr_clk90 => ctlr_clk90,
		locked     => ctlrdcm_locked);
	ctlr_rst <= not ctlrdcm_locked;

	ipoe_b : block
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(e_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to e_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to e_rxd'length);
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
				check_dov  => true)
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
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to e_rxd'length);
				end if;
			end process;
		end block;

		dhcp_p : process(e_tx_clk)
			type states is (s_request, s_wait);
			variable state : states;
		begin
			if rising_edge(e_tx_clk) then
				case state is
				when s_request =>
					if sw0='1' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if sw0='0' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => tp,

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

			so_clk    => sio_clk,
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

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug,
		profile      => 1,
		burst_length => 2,

		sdram_freq   => sdram_freq,
		settings     => settings,
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
		video_hzsync => video_hs,
		video_vtsync => video_vs,
		video_blank  => video_blank,
		video_pixel  => video_pixel,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => ctlr_rst  ,
		ctlr_bl      => "001",
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
		bank_size   => sd_ba'length,
		addr_size   => sd_a'length,
		word_size   => sd_dq'length,
		byte_size   => sd_dq'length/sd_dm'length,
		gear        => sdram_gear,
		loopback    => false,
		bypass      => true,
		rd_fifo     => true,
		rd_align    => true)
	port map (
		rst         => ctlr_rst  ,
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
		sys_odt     => ctlrphy_odt,
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
		sys_dqv     => ctlrphy_dqv,
		sys_sti     => ctlrphy_sto,
		sys_sto     => ctlrphy_sti,

		sdram_clk     => sd_clk,
		sdram_cke     => sdram_cke,
		sdram_cs      => sdram_cs,
		sdram_odt     => sdram_odt,
		sdram_ras     => sd_ras,
		sdram_cas     => sd_cas,
		sdram_we      => sd_we,
		sdram_b       => sd_ba,
		sdram_a       => sd_a,

		sdram_dm      => sd_dm,
		sdram_dq      => sd_dq,
		sdram_dqst    => sdram_dqst,
		sdram_dqs     => sd_dqs,
		sdram_dqso    => sdram_dqso);

	sdram_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => sd_clk(0),
		o  => sd_ck_p,
		ob => sd_ck_n);

	sd_cke <= sdram_cke(0);
	sd_cs  <= sdram_cs(0);

	videoio_p : process (video_clk)
	begin
		if rising_edge(video_clk) then
			vga_red    <= multiplex(video_pixel, std_logic_vector(to_unsigned(0,2)), 8)(0);
			vga_green  <= multiplex(video_pixel, std_logic_vector(to_unsigned(1,2)), 8)(0);
			vga_blue   <= multiplex(video_pixel, std_logic_vector(to_unsigned(2,2)), 8)(0);
			vga_hsync  <= video_hs;
			vga_vsync  <= video_vs;
		end if;
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
