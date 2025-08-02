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
use hdl4fpga.xc7a_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of arty is

	constant settings : string := "{"                                                      &
		"io_link: io_ipoe,"                                                                &
		"video:{"                                                                          &
			"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'100mhz'.'40mhz'"))    & ',' &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'") & ',' &
			"pixel:"   & "{R:8,G:8,B:8}}"                                                  & ',' &
		"sdram:{"                                                                          &
			"dcm:"       & string'(hdl4fpga.xc5v_profiles.sdram_dcm(".'100mhz'.'400mhz'")) & ',' &
			"chip_data:" & string'(hdo(sdram_db)**"..MT41K128M16-125")                     & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc7vg4")                                 & ',' &
			"cl:"        & "'010'}}";
	constant sdram_gear   : natural := hdo(settings)**".sdram.phy_data.orgz.gear";
	constant io_link      : string  := settings**".io_link";

	signal ctlr_clk       : std_logic;
	signal ctlr_clkx2     : std_logic;
	signal ctlr_clk90     : std_logic;
	signal ctlr_clk90x2   : std_logic;
	signal sdrsys_rst     : std_logic;
	signal sdrphy_rst0    : std_logic;
	signal sdrphy_rst90   : std_logic;

	signal iodctrl_rst    : std_logic;
	signal iodctrl_clk    : std_logic;
	signal iodctrl_rdy    : std_logic;

	signal ctlrphy_frm    : std_logic;
	signal ctlrphy_trdy   : std_logic;
	signal ctlrphy_locked : std_logic;
	signal ctlrphy_ini    : std_logic;
	signal ctlrphy_rw     : std_logic;
	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;

	signal ddr_b          : std_logic_vector(ddr3_ba'range);
	signal ddr_a          : std_logic_vector(ddr3_a'range);
	signal ddr_cke        : std_logic_vector(0 to 0);
	signal ddr_cs         : std_logic_vector(0 to 0);
	signal ddr_odt        : std_logic_vector(0 to 0);

	signal ctlrphy_rst    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cke    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cs     : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_ras    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cas    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_we     : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_odt    : std_logic_vector(0 to sdram_gear/2-1);
	signal ctlrphy_cmd    : std_logic_vector(0 to 3-1);
	signal ctlrphy_b      : std_logic_vector(sdram_gear/2*ddr3_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector(sdram_gear/2*ddr3_a'length-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(sdram_gear*ddr3_dm'length-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(sdram_gear*ddr3_dm'length-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(sdram_gear*ddr3_dq'length-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(sdram_gear*ddr3_dq'length-1 downto 0);
	signal ctlrphy_dqv    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(sdram_gear*ddr3_dqs_p'length-1 downto 0);

	signal ddr3_clk       : std_logic_vector(1-1 downto 0);
	signal ddr3_dqst      : std_logic_vector(ddr3_dqs_p'length-1 downto 0);
	signal ddr3_dqso      : std_logic_vector(ddr3_dqs_p'length-1 downto 0);
	signal ddr3_dqsi      : std_logic_vector(ddr3_dqs_p'length-1 downto 0);
	signal ddr3_dqo       : std_logic_vector(ddr3_dq'length-1 downto 0);
	signal ddr3_dqt       : std_logic_vector(ddr3_dq'length-1 downto 0);

	signal video_clk      : std_logic := '0';
	signal video_lckd     : std_logic := '0';
	signal video_clkx2    : std_logic;
	signal video_shift_clk : std_logic;
	signal video_pixel     : std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);
	signal dvid_crgb       : std_logic_vector(4*settings**".video.gear=4" downto 0);
	signal videoio_clk    : std_logic;

	signal dd_hs          : std_logic;
	signal dd_vs          : std_logic;
	signal dd_pixel       : std_logic_vector(0 to 3-1);

	alias red             : std_logic is ja(1);
	alias green           : std_logic is ja(2);
	alias blue            : std_logic is ja(3);
	alias vs              : std_logic is ja(10);
	alias hs              : std_logic is ja(4);

	constant mem_size     : natural := 8*(1024*8);
	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(0 to 8-1);
	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);

	alias  mii_txc        : std_logic is eth_tx_clk;
	alias  sio_clk        : std_logic is mii_txc;

	signal sys_rst        : std_logic;
	alias sys_clk is gclk100;
	signal tp_sdrphy      : std_logic_vector(1 to 32);

	-----------------
	-- Select link --
	-----------------

	constant bufiog     : boolean  := true;

begin

	sys_rst <= btn0;

	videodcm_i : entity hdl4fpga.xc7a_videodcm
	generic map(
		settings => hdo(settings)**".dcm")
	port map(
		rst       => sys_rst,
		clk       => sys_clk,
		video_clk => video_clk);

	sdramdcm_i : entity hdl4fpga.xc7a_sdramdcm
	generic map (
		settings  => settings**".dcm")
	port map (
		rst          => sys_rst,
		clk          => sys_clk,
		ctlr_clk     => ctlr_clk,
		ctlr_clkx2   => ctlr_clkx2,
		ctlr_clk90   => ctlr_clk90,
		ctlr_clk90x2 => ctlr_clk90x2,
		ctlr_rst     => sdrphy_rst0,
		ctlr_rst90   => sdrphy_rst90);

	debug_q : if debug generate
		signal q : bit;
	begin
		q <= not q after 1 ns;
		eth_ref_clk <= to_stdulogic(q);
	end generate;

	nodebug_g : if not debug generate
		process (gclk100)
			variable div : unsigned(0 to 1) := (others => '0');
		begin
			if rising_edge(gclk100) then
				div := div + 1;
				eth_ref_clk <= div(0);
			end if;
		end process;
	end generate;


	iodctrl_b : block
		signal clkfb  : std_logic;
		signal locked : std_logic;
	begin
		pll_i :  plle2_base
		generic map (
			clkin1_period  => gclk100_per*1.0e9,
			clkfbout_mult  => 12,
			clkout0_divide => 6)
		port map (
			pwrdwn   => '0',
			rst      => sys_rst,
			clkin1   => gclk100,
			clkfbin  => clkfb,
			clkfbout => clkfb,
			clkout0  => iodctrl_clk,
			locked   => locked);
		iodctrl_rst <= not locked;

	end block;

	hdlc_g : if io_link="io_hdlc" generate

		constant uart_freq : real := 36.0e6;
		constant baudrate : natural := 3e6;

		signal uart_clk   : std_logic;
		signal uart_rxdv  : std_logic;
		signal uart_rxd   : std_logic_vector(0 to 8-1);
		signal uarttx_frm : std_logic;
		signal uart_idle  : std_logic;
		signal uart_txen  : std_logic;
		signal uart_txd   : std_logic_vector(uart_rxd'range);

		signal tp         : std_logic_vector(1 to 32);

		alias ftdi_txd    : std_logic is uart_txd_in;
		alias ftdi_rxd    : std_logic is uart_rxd_out;

		signal dummy_txd  : std_logic_vector(uart_rxd'range);
	begin

		nodebug_g : if not debug generate
			uart_clk <= video_clk;
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
			clk_rate => uart_freq)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_txd,
			uart_irdy => uart_rxdv,
			uart_data => uart_rxd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_freq)
		port map (
			uart_txc  => uart_clk,
			uart_frm  => video_lckd,
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

	ipoe_g : if io_link="io_ipoe" generate
    	mii_e : entity hdl4fpga.link_mii
    	generic map (
    		rmii          => false,
    		default_mac   => x"00_40_00_01_02_03",
    		default_ipv4a => aton("192.168.0.14"),
    		n             => eth_rxd'length)
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
    		dhcp_btn   => btn0,
    		mii_txc    => eth_tx_clk,
    		mii_txen   => eth_tx_en,
    		mii_txd    => eth_txd,

    		mii_rxc    => eth_rx_clk,
    		mii_rxdv   => eth_rx_dv, 
    		mii_rxd    => eth_rxd);   
	end generate;

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug => debug,
		profile      => 1,
		sdram_freq   => sdram_freq(settings**".sdram.dcm")/2.0,
		burst_length => 8,
		dvid_fifo    => true,
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
		video_shift_clk => video_shift_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => sdrphy_rst0,
		ctlr_bl      => "00",
		ctlr_cl      => settings**".sdram.cl",
		ctlr_cwl     => settings**".sdram.cwl",
		ctlr_rtt     => "001",
		ctlr_cmd     => ctlrphy_cmd,

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
		ctlrphy_b    => ddr_b,
		ctlrphy_a    => ddr_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		ctlrphy_dqv  => ctlrphy_dqv,
		tp           => open);

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

	idelayctrl_i : idelayctrl
	port map (
		rst    => iodctrl_rst,
		refclk => iodctrl_clk,
		rdy    => iodctrl_rdy);

	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
	    bank_size   => ddr3_ba'length,
	    addr_size   => ddr3_a'length,
	    word_size   => ddr3_dq'length,
		byte_size   => ddr3_dq'length/ddr3_dqs_p'length,
		gear        => sdram_gear,
		ba_latency  => 1,
		device     => hdo(settings)**".sdram.phy_data.device",
		taps        => natural(floor((32.0*2.0*gclk100_freq)/(sdram_freq(settings**".sdram.dcm")/2.0)))-1,
		dqs_highz   => false,
		bufio       => bufiog,
		bypass      => false,
		wr_fifo     => true)
		-- dqs_delay => (0 to 0 => 1.35 ns),
		-- dqi_delay => (0 to 0 => 0 ns),
	port map (

		tp_sel      => sw(1 downto 0),
		tp          => tp_sdrphy,

		rst         => sdrphy_rst0,
		rst_shift   => sdrphy_rst90,
		iod_clk     => gclk100,
		clk         => ctlr_clk,
		clk_shift   => ctlr_clk90,
		clkx2       => ctlr_clkx2,
		clkx2_shift => ctlr_clk90x2,

		phy_frm     => ctlrphy_frm,
		phy_trdy    => ctlrphy_trdy,
		phy_rw      => ctlrphy_rw,
		phy_ini     => ctlrphy_ini,

		phy_cmd     => ctlrphy_cmd,
		phy_wlreq   => ctlrphy_wlreq,
		phy_wlrdy   => ctlrphy_wlrdy,

		phy_rlreq   => ctlrphy_rlreq,
		phy_rlrdy   => ctlrphy_rlrdy,

		phy_locked   => ctlrphy_locked,

		sys_cke     => ctlrphy_cke,
		sys_rst     => ctlrphy_rst,
		sys_cs      => ctlrphy_cs,
		sys_ras     => ctlrphy_ras,
		sys_cas     => ctlrphy_cas,
		sys_we      => ctlrphy_we,
		sys_b       => ctlrphy_b,
		sys_a       => ctlrphy_a,

		sys_dqst    => ctlrphy_dqst,
		sys_dqsi    => ctlrphy_dqso,
		sys_dmi     => ctlrphy_dmo,
		sys_dmo     => ctlrphy_dmi,
		sys_dqo     => ctlrphy_dqi,
		sys_dqv     => ctlrphy_dqv,
		sys_dqt     => ctlrphy_dqt,
		sys_dqi     => ctlrphy_dqo,
		sys_odt     => ctlrphy_odt,
		sys_sti     => ctlrphy_sto,
		sys_sto     => ctlrphy_sti,

		sdram_rst   => ddr3_reset,
		sdram_clk   => ddr3_clk,
		sdram_cke   => ddr_cke,
		sdram_cs    => ddr_cs,
		sdram_ras   => ddr3_ras,
		sdram_cas   => ddr3_cas,
		sdram_we    => ddr3_we,
		sdram_b     => ddr3_ba,
		sdram_a     => ddr3_a,
		sdram_odt   => ddr_odt,
		-- sdram_dm    => ddr3_dm,
		sdram_dq    => ddr3_dq,
		sdram_dqst  => ddr3_dqst,
		sdram_dqs   => ddr3_dqsi,
		sdram_dqso  => ddr3_dqso);

	ddr3_cke <= ddr_cke(0);
	ddr3_cs  <= ddr_cs(0);
	ddr3_odt <= ddr_odt(0);
	ddr3_dm <= (others => '0');


	process (sio_clk, gclk100, ctlr_clk)
		variable d, e, q : std_logic := '0';
	begin
		if rising_edge(gclk100) then
			rgbled <= (others => '0');
			led    <= (others => '0');
			case sw is
			when others =>
				(led3, led2, led1, led0, led3_g, led2_g, led1_g, led0_g) <= tp_sdrphy(1 to 8);
				led3_r <= ctlrphy_ini;
			end case;
		end if;

	end process;

	-- VGA --
	---------

	hdmi_b : block
		signal q : std_logic_vector(0 to 4-1);
		signal p : std_logic_vector(q'range);
		signal n : std_logic_vector(p'range);
	begin
		oddr_i : entity hdl4fpga.ogbx
		generic map (
			device => hdo(settings)**".sdram.phy_data.device",
			size   => 4,
			gear   => hdo(settings)**".video.gear=4")
		port map (
			clk   => video_shift_clk,
			clkx2 => video_clkx2,
			d     => dvid_crgb,
			q     => q);

		hdmi_g : for i in q'range generate
			obufds_i : obufds
			generic map (
				iostandard => "LVDS_25")
			port map (
				i  => q(i),
				o  => p(i),
				ob => n(i));
		end generate;
		(jb(1), jb(3), jb(7), jb(9)) <= p;
		(jb(2), jb(4), jb(8), jb(10)) <= n;

	end block;

	ddrio_b : block
	begin
    	clk_g : for i in ddr3_clk'range generate
    		ddr_ck_obufds : obufds
    		generic map (
    			iostandard => "DIFF_SSTL135")
    		port map (
    			i  => ddr3_clk(i),
    			o  => ddr3_clk_p,
    			ob => ddr3_clk_n);
    	end generate;

    	dqs_g : for i in ddr3_dqs_p'range generate
    		iobuf_i : iobufds
    		generic map (
    			iostandard => "DIFF_SSTL135")
    		port map (
    			t   => ddr3_dqst(i),
    			i   => ddr3_dqso(i),
    			o   => ddr3_dqsi(i),
    			io  => ddr3_dqs_p(i),
    			iob => ddr3_dqs_n(i));

    	end generate;
	end block;

	serdebug_b : block
		signal ser_irdy : std_logic;
	begin
		ser_irdy <= si_irdy and si_trdy and not si_end;
		-- serdebug_e : entity hdl4fpga.ser_debug
		-- generic map (
			-- red_length   => 1,
			-- green_length => 1,
			-- blue_length  => 1)
		-- port map (
			-- ser_clk      => sio_clk,
			-- ser_frm      => si_frm,
			-- ser_irdy     => ser_irdy,
			-- ser_data     => si_data,
-- 
			-- video_clk    => video_clk,
			-- video_hzsync => dd_hs,
			-- video_vtsync => dd_vs,
			-- video_pixel  => dd_pixel);

    	process (video_clk)
    	begin
    		if rising_edge(video_clk) then
    			red   <= multiplex(dd_pixel, std_logic_vector(to_unsigned(0,2)), 1)(0);
    			green <= multiplex(dd_pixel, std_logic_vector(to_unsigned(1,2)), 1)(0);
    			blue  <= multiplex(dd_pixel, std_logic_vector(to_unsigned(2,2)), 1)(0);
    			vs    <= dd_vs;
    			hs    <= dd_hs;
    		end if;
		end process;
	end block;
  
	eth_rstn <= not iodctrl_rst;
	eth_mdc  <= '0';
	eth_mdio <= '0';

end;
