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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.xc5v_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of ml50x is

	constant settings : string := "{"                                                      &
		"io_link: io_ipoe,"                                                                &
		"video:{"                                                                          &
			"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'100mhz'.'40mhz'"))    & ',' &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'") & ',' &
			"pixel:"   & "{R:8,G:8,B:8}}"                                                  & ',' &
		"sdram:{"                                                                          &
			"dcm:"       & string'(hdl4fpga.xc5v_profiles.sdram_dcm(".'100mhz'.'400mhz'")) & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT46V16M16M-6T")                       & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc3sg2")                                 & ',' &
			"cl:"        & "'010'}}";

	signal sys_rst        : std_logic;
	signal sys_clk        : std_logic;

	signal gtx_rst        : std_logic;
	signal gtx_clk        : std_logic;

	constant mem_size     : natural := 8*(1024*8);
	alias  sio_clk        : std_logic is gtx_clk;
	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);
	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(0 to 8-1);

	signal video_clk      : std_logic;
	signal video_lckd     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_hzsync   : std_logic;
	signal video_vtsync   : std_logic;
	signal video_blank    : std_logic;
	signal video_pixel    : std_logic_vector(0 to 32-1);
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);
	signal videoio_clk    : std_logic;

	constant sdram_gear   : natural := hdo(settings)**".sdram.phy_data.orgz.gear";

	signal ctlr_rst       : std_logic;
	signal ctlr_rst90     : std_logic;
	signal ctlr_clk       : std_logic;
	signal ctlr_clk90     : std_logic;
	signal ctlr_clkx2     : std_logic;
	signal ctlr_clk90x2   : std_logic;

	signal ctlrphy_frm    : std_logic;
	signal ctlrphy_trdy   : std_logic;
	signal ctlrphy_locked : std_logic;
	signal ctlrphy_ini    : std_logic;
	signal ctlrphy_rw     : std_logic;

	signal ddr_b          : std_logic_vector(ddr2_ba'range);
	signal ddr_a          : std_logic_vector(ddr2_a'range);

	signal ctlrphy_rst    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cke    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cs     : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_ras    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cas    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_we     : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_odt    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cmd    : std_logic_vector(0 to 3-1);
	signal ctlrphy_b      : std_logic_vector(sdram_gear/2*ddr_b'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector(sdram_gear/2*ddr_a'length-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(sdram_gear*ddr2_dm'length-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(sdram_gear*ddr2_dm'length-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(sdram_gear*ddr2_d'length-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(sdram_gear*ddr2_d'length-1 downto 0);
	signal ctlrphy_dqv    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(sdram_gear*ddr2_dqs_p'length-1 downto 0);

	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;

	signal ddr2_clk       : std_logic_vector(ddr2_clk_p'range);
	signal ddr2_dqst      : std_logic_vector(ddr2_dqs_p'length-1 downto 0);
	signal ddr2_dqso      : std_logic_vector(ddr2_dqs_p'length-1 downto 0);
	signal ddr2_dqsi      : std_logic_vector(ddr2_dqs_p'length-1 downto 0);
	signal ddr2_dqo       : std_logic_vector(ddr2_d'length-1 downto 0);
	signal ddr2_dqt       : std_logic_vector(ddr2_d'length-1 downto 0);

	alias  iodctrl_rst    : std_logic is sys_rst;
	signal iodctrl_clk    : std_logic;
	signal iodctrl_rdy    : std_logic;

	alias  dmacfg_clk     : std_logic is gtx_clk;

	signal tp_sel         : std_logic_vector(1 downto 0);
	signal tp_sdrphy      : std_logic_vector(1 to 32);

begin

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	process (sys_clk)
		variable tmr : unsigned(0 to 8-1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			if tmr(0)='0' then
				tmr := tmr + 1;
			end if;
		end if;
		sys_rst <= not tmr(0);
	end process;
	
	videodcm_i : entity hdl4fpga.xc5v_videodcm
	generic map(
		settings => hdo(settings)**".dcm")
	port map(
		rst       => sys_rst,
		clk       => sys_clk,
		video_clk => video_clk);

	sdramdcm_i : entity hdl4fpga.xc5v_sdramdcm
	generic map (
		settings  => settings**".dcm")
	port map (
		rst          => sys_rst,
		clk          => sys_clk,
		ctlr_clk     => ctlr_clk,
		ctlr_clkx2   => ctlr_clkx2,
		ctlr_clk90   => ctlr_clk90,
		ctlr_clk90x2 => ctlr_clk90x2,
		ctlr_rst     => ctlr_rst,
		ctlr_rst90   => ctlr_rst90);

	iodctrl_b : block
		signal clk_fpga : std_logic;
	begin

		idelay_ibufg_i : IBUFGDS_LVPECL_25
		port map (
			I  => clk_fpga_p,
			IB => clk_fpga_n,
			O  => clk_fpga);
	
		bufg_i : bufg
		port map (
			i => clk_fpga,
			o => iodctrl_clk);
	end block;

	gtx_b : block
		signal clkfx  : std_logic;
		signal locked : std_logic;
	begin
		gtx_i : dcm_base
		generic map  (
			CLK_FEEDBACK   => "NONE",
			clkin_period   => userclk_per*1.0e9,
			clkfx_multiply => 5,
			clkfx_divide   => 4)
		port map (
			rst    => sys_rst,
			clkin  => sys_clk,
			clkfb  => '0',
			clkfx  => clkfx, 
			locked => locked);

		gtx_rst <= not locked;
		bufg_i : bufg
		port map (
			i => clkfx,
			o => gtx_clk);

	end block;

	gmii_e : entity hdl4fpga.link_mii
	generic map (
		rmii          => false,
		default_mac   => x"00_40_00_01_02_03",
		default_ipv4a => aton("192.168.0.14"),
		n             => phy_rxd'length)
	port map (
		si_frm     => si_frm,
		si_irdy    => si_irdy,
		si_trdy    => si_trdy,
		si_end     => si_end,
		si_data    => si_data,
	
		so_frm     => so_frm,
		so_irdy    => so_irdy,
		so_trdy    => so_trdy,
		so_data    => so_data,
		dhcp_btn   => gpio_sw_s,
		mii_txc    => phy_txclk,
		mii_txen   => phy_txctl_txen,
		mii_txd    => phy_txd,

		mii_rxc    => phy_rxclk,
		mii_rxdv   => phy_rxctl_rxdv, 
		mii_rxd    => phy_rxd);   

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug => debug,
		profile      => 1,
		sdram_freq   => sdram_freq(settings**".sdram.dcm")/2.0,
		burst_length => 8,
		settings     => settings,
		fifo_size    => mem_size)
	port map (
		sin_clk       => sio_clk,
		sin_frm       => so_frm,
		sin_irdy      => so_irdy,
		sin_trdy      => so_trdy,
		sin_data      => so_data,
		sout_clk      => sio_clk,
		sout_frm      => si_frm,
		sout_irdy     => si_irdy,
		sout_trdy     => si_trdy,
		sout_end      => si_end,
		sout_data     => si_data,

		video_clk     => video_clk,
		video_shift_clk => video_shift_clk,
		video_hzsync  => video_hzsync,
		video_vtsync  => video_vtsync,
		video_blank   => video_blank,
		video_pixel   => video_pixel,
		dvid_crgb     => dvid_crgb,

		ctlr_clk      => ctlr_clk,
		ctlr_rst      => ctlr_rst,
		ctlr_rtt      => "11",
		ctlr_al       => "000",
		ctlr_bl       => "011", -- Busrt length 8
		ctlr_cl      => settings**".sdram.cl",
		ctlr_cmd      => ctlrphy_cmd,
		ctlrphy_ini   => ctlrphy_ini,
		ctlrphy_rlreq => ctlrphy_rlreq,
		ctlrphy_rlrdy => ctlrphy_rlrdy,
		ctlrphy_irdy  => ctlrphy_frm,
		ctlrphy_rw    => ctlrphy_rw,
		ctlrphy_trdy  => ctlrphy_trdy,
		ctlrphy_rst   => ctlrphy_rst(0),
		ctlrphy_cke   => ctlrphy_cke(0),
		ctlrphy_cs    => ctlrphy_cs(0),
		ctlrphy_ras   => ctlrphy_ras(0),
		ctlrphy_cas   => ctlrphy_cas(0),
		ctlrphy_we    => ctlrphy_we(0),
		ctlrphy_odt   => ctlrphy_odt(0),
		ctlrphy_b     => ddr_b,
		ctlrphy_a     => ddr_a,
		ctlrphy_dqst  => ctlrphy_dqst,
		ctlrphy_dqso  => ctlrphy_dqso,
		ctlrphy_dmi   => ctlrphy_dmi,
		ctlrphy_dmo   => ctlrphy_dmo,
		ctlrphy_dqi   => ctlrphy_dqi,
		ctlrphy_dqt   => ctlrphy_dqt,
		ctlrphy_dqo   => ctlrphy_dqo,
		ctlrphy_sto   => ctlrphy_sto,
		ctlrphy_sti   => ctlrphy_sti,
		ctlrphy_dqv   => ctlrphy_dqv,
		tp            => open);

	cgear_g : for i in 1 to sdram_gear/2-1 generate
		ctlrphy_rst(i) <= ctlrphy_rst(0);
		ctlrphy_cke(i) <= ctlrphy_cke(0);
		ctlrphy_cs(i)  <= ctlrphy_cs(0);
		ctlrphy_ras(i) <= '1';
		ctlrphy_cas(i) <= '1';
		ctlrphy_we(i)  <= '1';
		ctlrphy_odt(i) <= ctlrphy_odt(0);
	end generate;

	process (ddr_b)
	begin
		for i in ddr_b'range loop
			for j in 0 to sdram_gear/2-1 loop
				ctlrphy_b(i*sdram_gear/2+j) <= ddr_b(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to sdram_gear/2-1 loop
				ctlrphy_a(i*sdram_gear/2+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
	tp_sel <= ('0', gpio_sw_s);

	idelayctrl_i : idelayctrl
	port map (
		rst    => iodctrl_rst,
		refclk => iodctrl_clk,
		rdy    => iodctrl_rdy);
	
	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		device     => hdo(settings)**".sdram.phy_data.device",
		bank_size  => ddr2_ba'length,
		addr_size  => ddr2_a'length,
		word_size  => ddr2_d'length,
		byte_size  => ddr2_d'length/ddr2_dm'length,
		gear       => sdram_gear,
		ba_latency => 1,
		loopback   => false,
		bypass     => false,
		taps       => natural(floor((64.0*200.0e6)/sdram_freq(settings**".sdram.dcm")))-1,
		dqs_highz  => false)
	port map (
		tp_sel     => tp_sel,
		tp         => tp_sdrphy,
		rst        => ctlr_rst,
		rst_shift  => ctlr_rst90,
		iod_clk    => sys_clk,
		clk        => ctlr_clk,
		clk_shift  => ctlr_clk90,
		clkx2      => ctlr_clkx2,
		clkx2_shift => ctlr_clk90x2,
		phy_frm    => ctlrphy_frm,
		phy_trdy   => ctlrphy_trdy,
		phy_rw     => ctlrphy_rw,
		phy_ini    => ctlrphy_ini,
		phy_locked => ctlrphy_locked,

		phy_cmd    => ctlrphy_cmd,
		phy_wlreq  => ctlrphy_wlreq,
		phy_wlrdy  => ctlrphy_wlrdy,
		phy_rlreq  => ctlrphy_rlreq,
		phy_rlrdy  => ctlrphy_rlrdy,

		sys_cke    => ctlrphy_cke,
		sys_cs     => ctlrphy_cs,
		sys_ras    => ctlrphy_ras,
		sys_cas    => ctlrphy_cas,
		sys_we     => ctlrphy_we,
		sys_b      => ctlrphy_b,
		sys_a      => ctlrphy_a,

		sys_dqst   => ctlrphy_dqst,
		sys_dqsi   => ctlrphy_dqso,
		sys_dmi    => ctlrphy_dmo,
		sys_dmo    => ctlrphy_dmi,
		sys_dqi    => ctlrphy_dqo,
		sys_dqt    => ctlrphy_dqt,
		sys_dqo    => ctlrphy_dqi,
		sys_odt    => ctlrphy_odt,
		sys_dqv    => ctlrphy_dqv,
		sys_sti    => ctlrphy_sto,
		sys_sto    => ctlrphy_sti,
		sdram_clk  => ddr2_clk,
		sdram_cke  => ddr2_cke,
		sdram_cs   => ddr2_cs,
		sdram_ras  => ddr2_ras,
		sdram_cas  => ddr2_cas,
		sdram_we   => ddr2_we,
		sdram_b    => ddr2_ba,
		sdram_a    => ddr2_a,
		sdram_odt  => ddr2_odt,

		sdram_dm   => ddr2_dm(ddr2_dm'length-1 downto 0),
		sdram_dq   => ddr2_d,
		sdram_dqst => ddr2_dqst,
		sdram_dqs  => ddr2_dqsi,
		sdram_dqso => ddr2_dqso);

	dviio_b : block
		signal xclk : std_logic;
	begin
		process (video_clk)
		begin
			if rising_edge(video_clk) then
				dvi_de <= not video_blank;
				dvi_h  <= video_hzsync;
				dvi_v  <= video_vtsync;
			end if;
		end process;

		xclkp_i : oddr
		port map (
			c => video_clk,
			ce => '1',
			s  => '0',
			r  => '0',
			d1 => '1',
			d2 => '0',
			q  => xclk);
	
		diff_i: obufds
		generic map (
			iostandard => "LVDS_25")
		port map (
			i  => xclk,
			o  => dvi_xclk_p,
			ob => dvi_xclk_n);
	
	
		d_g : for i in dvi_d'range generate
			oddr_i : oddr
			port map (
				c => video_clk,
				ce => '1',
				s  => '0',
				r  => '0',
				d1 => video_pixel(i),
				d2 => video_pixel(i+dvi_d'length),
				q  => dvi_d(i));
		end generate;

		dvi_reset_b <= video_lckd;
	end block;

	ddrio_b : block
	begin
		ddr_clk_g : for i in ddr2_clk'range generate
			ddr_ck_obufds : obufds
			generic map (
				iostandard => "DIFF_SSTL18_II")
			port map (
				i  => ddr2_clk(i),
				o  => ddr2_clk_p(i),
				ob => ddr2_clk_n(i));
		end generate;

		ddr_dqs_g : for i in ddr2_dqs_p'range generate
		begin
			dqsiobuf_i : iobufds
			generic map (
				iostandard => "DIFF_SSTL18_II_DCI")
			port map (
				t   => ddr2_dqst(i),
				i   => ddr2_dqso(i),
				o   => ddr2_dqsi(i),
				io  => ddr2_dqs_p(i),
				iob => ddr2_dqs_n(i));
		end generate;

	end block;

	phy_txc_gtxclk_i : oddr
	port map (
		c  => gtx_clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => '1',
		d2 => '0',
		q  => phy_txc_gtxclk);
	
	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			gpio_led <= tp_sdrphy(1 to 8);
		end if;
	end process;

	gpio_led_c <= ctlrphy_locked;


	(gpio_led_w, gpio_led_n, gpio_led_e, gpio_led_s) <= std_logic_vector'(1 to 4 => '0');

	phy_mdc    <= '0';
	phy_mdio   <= '0';

	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	dvi_gpio1  <= '1';
	ddr2_scl   <= '0';

	bus_error <= (others => '0');
	iic_sda_video <= 'Z';
	iic_scl_video <= 'Z';

end;
