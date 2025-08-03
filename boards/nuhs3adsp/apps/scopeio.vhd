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
use hdl4fpga.ipoepkg.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.xc3s_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture scopeio of nuhs3adsp is

	constant vt_step  : string := "1.220703125e-4"; --2.0V/2.0**14; -- real'image() does not work on Xilinx ISE
	constant settings : string := compact("{" &   
		"inputs:" & "2"                                                                           & ',' &
		"waveform:{"                                                                              &
			"video:{"                                                                             &
				"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'20mhz'.'150mhz'"))       & ',' &
				"timings:" & string'(hdl4fpga.videopkg.timings_db**".'1920x1080'.'@60'.'150mhz'") & ',' &
				"pixel:"   & "{R:8,G:8,B:8}}"                                                     & ',' &
			"max_delay:"       & natural'image(2**14)                                             & ',' &
			"min_storage:"     & "256"                                                            & ',' & -- samples, storage size will be equal or larger than this
			"num_of_segments:" & "4"                                                              & ',' &
			"grid:{"                                                                              &
				"width:"  & natural'image(50*32+1)                                                & ',' &
				"height:" & natural'image( 8*32+1)                                                & ',' &
				"color:"  & "0xff_ff_00_ff"                                                       & ',' &
				"background-color:" & "0xff_00_00_00}"                                            & ',' &
			"axis:{"                                                                              &
				"horizontal:{"                                                                    &
					"unit:"    & "250.0e-9"                                                       & ',' &
					"color:"   & "0xff_00_00_00"                                                  & ',' &
					"background-color:" & "0xff_00_ff_ff}"                                        & ',' &
				"vertical:{"                                                                      &
					"unit:"  & "5.0e-3"                                                           & ',' &
					"width:" & natural'image(6*8)                                                 & ',' &
					"color:" & "0xff_00_00_00"                                                    & ',' &
					"background-color : 0xff_00_ff_ff}},"                                         &
			"textbox:{"                                                                           &
				"width:"     & natural'image(33*8)                                                & ',' &
				"color:"     & "0xff_ff_00_ff"                                                    & ',' &
				"background-color:" & "0xff_00_00_00}"                                            & ',' &
			"main:{"                                                                              &
				"top:5, left:2, right:0, bottom:0, vertical:1, horizontal:1, background-color: 0xff_00_00_00}" & ',' &
			"segment:{"                                                                           &
				"top:1, left:1, right:1, bottom:1, vertical:0, horizontal:1, background-color: 0xff_ff_ff_ff}" & ',' &
			"vt:[" &
				"{text: J3," & "step:" & vt_step & ',' & "color:" & "0xff_00_ff_ff}"            & ',' &
				"{text: J4," & "step:" & vt_step & ',' & "color:" & "0xff_ff_ff_ff}]}"          & ',' &
		"sdram:{"                                                                                 &
			"dcm:"       & string'(hdl4fpga.xc3s_profiles.sdram_dcm(".'20mhz'.'133mhz'"))         & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT46V16M16M-6T")                              & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc3sg2")                                        & ',' &
			"cl:"        & "'010'}}");

	constant io_link   : string := "io_ipoe";

	constant sys_per    : real := 50.0;
	signal sys_rst      : std_logic;
	signal sys_clk      : std_logic;

	constant inputs      : natural := hdo(settings)**".inputs";
	alias  input_sample is adc_da;
	signal input_samples : std_logic_vector(inputs*input_sample'length-1 downto 0);
	signal input_clk     : std_logic;
	signal adc_clk       : std_logic;
	signal adcclk_n      : std_logic;

	alias  sio_clk is mii_txc;
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);
	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);
	signal dhcp_btn      : std_logic;

	signal video_clk    : std_logic;
	signal videoclk_n   : std_logic;
	signal video_hzsync : std_logic;
	signal video_vtsync : std_logic;
	signal video_vton   : std_logic;
	signal video_blank  : std_logic;
	signal video_pixel  : std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);

	constant sdram_freq  : real := sdram_freq(settings**".sdram.dcm");
	constant bank_length : natural := hdo(settings)**".sdram.chip_data.orgz.addr.ba=1";
	constant addr_length : natural := hdo(settings)**".sdram.chip_data.orgz.addr.row=1";
	constant data_mask   : natural := hdo(settings)**".sdram.chip_data.orgz.data.dm=1";
	constant data_length : natural := hdo(settings)**".sdram.chip_data.orgz.data.dq=1";
	constant sdram_gear  : natural := hdo(settings)**".sdram.phy_data.orgz.gear=1";

	signal ctlr_rst      : std_logic;
	signal ctlr_clk      : std_logic;
	signal ctlr_clk90    : std_logic;

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_cs    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_ras   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_cas   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_we    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_odt   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_b     : std_logic_vector((sdram_gear+1)/2*bank_length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector((sdram_gear+1)/2*addr_length-1 downto 0);
	signal ctlrphy_dqst  : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqsi  : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dqso  : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(sdram_gear*data_length-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(sdram_gear*data_length-1 downto 0);
	signal ctlrphy_dqv   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(sdram_gear*data_mask-1 downto 0);

	signal sdram_clk     : std_logic_vector(0 downto 0);

begin

	clkin_ibufg : ibufg
	port map (
		I => clk,
		O => sys_clk);

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rst <= not sw1;
		end if;
	end process;

	videodcm_g : if string'(settings**".waveform") /= "" generate
		videodcm_i : entity hdl4fpga.xc3s_videodcm
		generic map(
			settings => hdo(settings)**".waveform.video.dcm")
		port map(
			rst       => sys_rst,
			clk       => sys_clk,
			video_clk => video_clk);
	end generate;

	sdrdcm_g : if string'(settings**".sdram") /= "" generate
		signal ctlrdcm_locked : std_logic;
	begin
		sdramdcm_i : entity hdl4fpga.xc3s_sdramdcm
		generic map (
			settings  => settings**".sdram.dcm")
		port map (
			clk        => sys_clk,
			ctlr_clk   => ctlr_clk,
			ctlr_clk90 => ctlr_clk90,
			locked     => ctlrdcm_locked);
		ctlr_rst <= not ctlrdcm_locked;
	end generate;

	adcdfs_i : dcm_sp
	generic map(
		clk_feedback  => "NONE",
		clkin_period  => sys_per*1.0e9,
		clkdv_divide  => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_multiply => 32,
		clkfx_divide  => 5,
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

		rst      => '0',
		clkin    => sys_clk,
		clkfb    => '0',
		clkfx    => adc_clk);
	adcclk_n  <= not adc_clk;
	input_clk <= not adc_clkout;

	miidfs_e : dcm_sp
	generic map(
		clk_feedback  => "NONE",
		clkin_period  => sys_per*1.0e9,
		clkdv_divide  => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_multiply => 5,
		clkfx_divide  => 4,
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

		rst      => '0',
		clkin    => sys_clk,
		clkfb    => '0',
		clkfx    => mii_refclk);

	process (input_clk)
		variable adc_dab : std_logic_vector(input_samples'range);
	begin
		if rising_edge(input_clk) then
			input_samples <= adc_dab xor ((1 => '1', 2 to input_sample'length => '0') & ((1 => '1', 2 to adc_db'length => '0')));
			-- input_samples <= std_logic_vector(to_signed(2**13-1, input_sample'length) & to_signed(2**13, input_sample'length));
			adc_dab := adc_da & adc_db;
		end if;
	end process;

	dhcp_btn <= not sw1;
	mii_e : entity hdl4fpga.link_mii
	generic map (
		rmii          => false,
		default_mac   => x"00_40_00_01_02_03",
		default_ipv4a => aton("192.168.0.14"),
		n             => mii_rxd'length)
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
		dhcp_btn   => dhcp_btn,
		mii_txc    => mii_txc,
		mii_txen   => mii_txen,
		mii_txd    => mii_txd,

		mii_rxc    => mii_rxc,
		mii_rxdv   => mii_rxdv,
		mii_rxd    => mii_rxd);   

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		debug       => debug,
		profile     => 1,
		sdram_freq  => sdram_freq,
		settings    => settings)
	port map (
		sio_clk     => sio_clk,
		si_frm      => so_frm,
		si_irdy     => so_irdy,
		si_trdy     => so_trdy,
		si_data     => so_data,
		so_frm      => si_frm,
		so_irdy     => si_irdy,
		so_trdy     => si_trdy,
		so_end      => si_end,
		so_data     => si_data,
		input_clk   => input_clk,
		input_data  => input_samples,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => ctlr_rst,
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
		video_clk    => video_clk,
		video_pixel  => video_pixel,
		video_hzsync  => video_hzsync,
		video_vtsync  => video_vtsync,
		video_vton   => video_vton,
		video_blank  => video_blank);

	sdramphy_g : if string'(hdo(settings)**".sdram={}") /= "={}" generate
		signal ctlrphy_wlreq : std_logic;
		signal ctlrphy_wlrdy : std_logic;
		signal ctlrphy_rlreq : std_logic;
		signal ctlrphy_rlrdy : std_logic;
		signal sdram_cke     : std_logic_vector(0 to 0);
		signal sdram_cs      : std_logic_vector(0 to 0);
		signal ddr_odt       : std_logic_vector(0 to 0);
		signal st_dqs_open   : std_logic;
	begin
		ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
		ctlrphy_rlreq <= to_stdulogic(to_bit(ctlrphy_rlrdy));

		sdrphy_e : entity hdl4fpga.xc_sdrphy
		generic map (
			-- dqs_delay   => (0 to 0 => 0 ns),
			-- dqi_delay   => (0 to 0 => 0 ns),
			device      => hdo(settings)**".sdram.phy_data.device",
			bank_size   => ddr_ba'length,
			addr_size   => ddr_a'length,
			gear        => sdram_gear,
			word_size   => ddr_dq'length,
			byte_size   => ddr_dq'length/ddr_dm'length,
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
			sdram_clk     => sdram_clk,
			sdram_cke     => sdram_cke,
			sdram_cs      => sdram_cs,
			sdram_odt     => ddr_odt,
			sdram_ras     => ddr_ras,
			sdram_cas     => ddr_cas,
			sdram_we      => ddr_we,
			sdram_b       => ddr_ba,
			sdram_a       => ddr_a,

			sdram_dm      => open, --ddr_dm,
			sdram_dq      => ddr_dq,
			sdram_dqs     => ddr_dqs);

		ddr_cke <= sdram_cke(0);
		ddr_cs  <= sdram_cs(0);
		ddr_dm <= (others => '0');

		ddr_clk_i : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => sdram_clk(0),
			o  => ddr_ckp,
			ob => ddr_ckn);
	end generate;

	nosdram_g : if string'(hdo(settings)**".sdram=")="{}" generate
		ddr_clk_i : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => 'Z',
			o  => ddr_ckp,
			ob => ddr_ckn);
	
			ddr_st_dqs <= 'Z';
			ddr_cke    <= 'Z';
			ddr_cs     <= '1';
			ddr_ras    <= 'Z';
			ddr_cas    <= 'Z';
			ddr_we     <= 'Z';
			ddr_ba     <= (others => 'Z');
			ddr_a      <= (others => 'Z');
			ddr_dm     <= (others => 'Z');
			ddr_dqs    <= (others => 'Z');
			ddr_dq     <= (others => 'Z');
	end generate;

	process (video_clk)
		variable video_hzsync1 : std_logic;
		variable video_vtsync1 : std_logic;
		variable video_blank1  : std_logic;
		variable video_pixel1  : std_logic_vector(video_pixel'range);
	begin
		if rising_edge(video_clk) then
			red    <= multiplex(video_pixel1, 0, red'length);
			green  <= multiplex(video_pixel1, 1, green'length);
			blue   <= multiplex(video_pixel1, 2, blue'length);
			blankn <= not video_blank1;
			hsync  <= video_hzsync1;
			vsync  <= video_vtsync1;
			sync   <= not video_hzsync1 and not video_vtsync1;
			video_pixel1  := video_pixel;
			video_hzsync1 := video_hzsync;
			video_vtsync1 := video_vtsync;
			video_blank1  := video_blank;
		end if;
	end process;
	psave <= '1';

	adcclkab_e : oddr2
	port map (
		c0 => adc_clk,
		c1 => adcclk_n,
		ce => '1',
		d0 => '1',
		d1 => '0',
		q  => adc_clkab);

	videoclk_n <= not video_clk;
	videodac_i: oddr2
	port map (
		c0  => video_clk,
		c1  => videoclk_n,
		ce  => '1',
		d0  => '0',
		d1  => '1',
		q   => clk_videodac);

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= '0';

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
	-- mii_txen <= '0';
	-- mii_txd  <= (others => '0');

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

end;
