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

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx4m_ld is

	---------------------------------------
	-- Set of profiles                   --
	type apps is (
	--	Interface_SdramSpeed_PixelFormat --
		mii_166MHz_480p24bpp,            --
		mii_200MHz_480p24bpp,            --
		mii_250MHz_480p24bpp);           --
	---------------------------------------

	---------------------------------------------
	-- Set your profile here                   --
	constant app : apps := mii_250MHz_480p24bpp;
	---------------------------------------------

	constant sys_freq    : real    := 25.0e6;

	constant fpga        : natural := spartan3;
	constant mark        : natural := M7E;

	constant sclk_phases : natural := 1;
	constant sclk_edges  : natural := 1;
	constant data_phases : natural := 1;
	constant data_edges  : natural := 1;
	constant cmmd_gear   : natural := 1;
	constant data_gear   : natural := 1;
	constant bank_size   : natural := ddram_ba'length;
	constant addr_size   : natural := ddram_a'length;
	constant coln_size   : natural := 9;
	constant word_size   : natural := ddram_dq'length;
	constant byte_size   : natural := 8;

	signal sys_rst       : std_logic;
	signal sys_clk       : std_logic;

	signal ddrsys_rst    : std_logic;
	signal ddrsys_clks   : std_logic_vector(0 to 0);

	signal ddram_lck     : std_logic;

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic;
	signal ctlrphy_wlreq : std_logic;
	signal ctlrphy_wlrdy : std_logic;
	signal ctlrphy_cs    : std_logic;
	signal ctlrphy_ras   : std_logic;
	signal ctlrphy_cas   : std_logic;
	signal ctlrphy_we    : std_logic;
	signal ctlrphy_odt   : std_logic;
	signal ctlrphy_b     : std_logic_vector(ddram_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(ddram_a'length-1 downto 0);
	signal ctlrphy_dsi   : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_dst   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dso   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_rst    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cs     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cke    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_odt    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_ras    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cas    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_we     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_b      : std_logic_vector(cmmd_gear*ddram_ba'length-1 downto 0);
	signal ddrphy_a      : std_logic_vector(cmmd_gear*ddram_a'length-1 downto 0);

	signal ddram_dst     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddram_dso     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddram_dqt     : std_logic_vector(ddram_dq'range);
	signal ddram_do      : std_logic_vector(ddram_dq'range);

	type pll_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos2_div : natural;
		clkos3_div : natural;
	end record;

	type video_modes is (
		mode480p24,
		mode600p16,
		modedebug);

	type pixel_types is (
		rgb565,
		rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug  => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 10), pixel => rgb888, mode => pclk_debug),
		mode480p24 => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 10), pixel => rgb888, mode => pclk25_00m640x480at60),
		mode600p16 => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 10), pixel => rgb565, mode => pclk40_00m800x600at60));

	signal video_clk      : std_logic;
	signal videoio_clk    : std_logic;
	signal video_lck      : std_logic;
	signal video_shft_clk : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_blank    : std_logic;
    signal video_on       : std_logic;
    signal video_dot      : std_logic;
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	type ddram_speed is (
		sdram400MHz,
		sdram450MHz,
		sdram500MHz);

	type ddram_params is record
		pll : pll_params;
		cas : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (ddram_speed) of ddram_params;
	constant ddram_tab : sdramparams_vector := (
		sdram200MHz => (pll => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos2_div => 2, clkos3_div => 0), cas => "011"),
		sdram225MHz => (pll => (clkos_div => 2, clkop_div => 27, clkfb_div => 1, clki_div => 1, clkos2_div => 3, clkos3_div => 0), cas => "011"),
		sdram250MHz => (pll => (clkos_div => 2, clkop_div => 20, clkfb_div => 1, clki_div => 1, clkos2_div => 2, clkos3_div => 0), cas => "011"));

	alias ctlr_clk     : std_logic is ddrsys_clks(0);

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

	type io_iface is (
		io_hdlc,
		io_ipoe);

	type app_record is record
		iface : io_iface;
		mode  : video_modes;
		speed : ddram_speed;
	end record;

	type app_vector is array (apps) of app_record;
	constant app_tab : app_vector := (
		mii_166MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => sdram166MHz),
		mii_200MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => sdram200MHz),
		mii_250MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => sdram250MHz));

	constant nodebug_videomode : video_modes := app_tab(app).mode;
	constant video_mode   : video_modes := video_modes'VAL(setif(debug,
		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode)));

    signal video_pixel    : std_logic_vector(0 to setif(
		video_tab(app_tab(app).mode).pixel=rgb565, 16, setif(
		video_tab(app_tab(app).mode).pixel=rgb888, 32, 0))-1);

	constant ddram_mode : ddram_speed := ddram_speed'VAL(setif(not debug,
		ddram_speed'POS(app_tab(app).speed),
		ddram_speed'POS(sdram133Mhz)));

	constant ddr_tcp  : natural := natural(
		(1.0e12*real(ddram_tab(ddram_mode).pll.clki_div*ddram_tab(ddram_mode).pll.clkos2_div))/
		(real(ddram_tab(ddram_mode).pll.clkfb_div*ddram_tab(ddram_mode).pll.clkop_div)*sys_freq));

	constant io_link : io_iface := app_tab(app).iface;

	alias  mii_rxc        : std_logic is rgmii_rx_clk;
	alias  mii_rxdv       : std_logic is rgmii_rx_dv;
	alias  mii_rxd        : std_logic_vector(rgmii_rxd'range) is rgmii_rxd;

	alias  mii_txc        : std_logic is rgmii_tx_clk;
	alias  sio_clk        : std_logic is mii_txc;
	alias  dmacfg_clk     : std_logic is mii_txc;
	signal mii_txen       : std_logic;
	signal mii_txd        : std_logic_vector(rgmii_txd'range);

begin

	sys_rst <= '0';
	videopll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOS2 : string;
		attribute FREQUENCY_PIN_CLKOS3 : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		constant video_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos2_div*1e6));

		constant video_shift_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos_div*1e6));

		constant videoio_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkos3_div*1e6));

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is ftoa(video_shift_freq, 10);
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is ftoa(video_freq,       10);
		attribute FREQUENCY_PIN_CLKOS3 of pll_i : label is ftoa(videoio_freq,     10);
		attribute FREQUENCY_PIN_CLKI   of pll_i : label is ftoa(sys_freq/1.0e6,   10);
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is ftoa(sys_freq/1.0e6,   10);

		signal clkfb : std_logic;

	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED",
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED",
			PLL_LOCK_MODE    =>  0,
			FEEDBK_PATH      => "CLKOP",
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0,
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => video_tab(video_mode).pll.clkop_div-1,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS_DIV        => video_tab(video_mode).pll.clkos_div,
			CLKOS2_DIV       => video_tab(video_mode).pll.clkos2_div,
			CLKOS3_DIV       => video_tab(video_mode).pll.clkos3_div,
			CLKOP_DIV        => video_tab(video_mode).pll.clkop_div,
			CLKFB_DIV        => video_tab(video_mode).pll.clkfb_div,
			CLKI_DIV         => video_tab(video_mode).pll.clki_div)
        port map (
			rst       => '0',
			clki      => clk_25mhz,
			CLKFB     => clkfb,
            PHASESEL0 => '0', PHASESEL1 => '0',
			PHASEDIR  => '0',
            PHASESTEP => '0', PHASELOADREG => '0',
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0',
			ENCLKOS   => '0',
			ENCLKOS2  => '0',
            ENCLKOS3  => '0',
			CLKOP     => clkfb,
			CLKOS     => video_shft_clk,
            CLKOS2    => video_clk,
            CLKOS3    => videoio_clk,
			LOCK      => video_lck,
            INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);

	end block;

	ctlrpll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOS2 : string;
		attribute FREQUENCY_PIN_CLKOS3 : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;


		constant ddram_freq  : real :=
			(real(ddram_tab(ddram_mode).pll.clkfb_div*ddram_tab(ddram_mode).pll.clkop_div)*sys_freq)/
			(real(ddram_tab(ddram_mode).pll.clki_div*ddram_tab(ddram_mode).pll.clkos2_div*1e6));

		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is ftoa(ddram_freq, 10);
		attribute FREQUENCY_PIN_CLKI   of pll_i : label is ftoa(sys_freq/1.0e6, 10);
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is ftoa(sys_freq/1.0e6, 10);

		signal clkfb : std_logic;

	begin

		assert false
		report real'image(ddram_freq)
		severity NOTE;

		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED",
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED",
			PLL_LOCK_MODE    =>  0,
			FEEDBK_PATH      => "CLKOP",
			CLKOS_ENABLE     => "DISABLED", CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0,
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => ddram_tab(ddram_mode).pll.clkop_div-1,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

--			CLKOS_DIV        => ddram_tab(ddram_mode).pll.clkos_div,
			CLKOS2_DIV       => ddram_tab(ddram_mode).pll.clkos2_div,
--			CLKOS3_DIV       => ddram_tab(ddram_mode).pll.clkos3_div,
			CLKOP_DIV        => ddram_tab(ddram_mode).pll.clkop_div,
			CLKFB_DIV        => ddram_tab(ddram_mode).pll.clkfb_div,
			CLKI_DIV         => ddram_tab(ddram_mode).pll.clki_div)
        port map (
			rst       => '0',
			clki      => clk_25mhz,
			CLKFB     => clkfb,
            PHASESEL0 => '0', PHASESEL1 => '0',
			PHASEDIR  => '0',
            PHASESTEP => '0', PHASELOADREG => '0',
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0',
			ENCLKOS   => '0',
			ENCLKOS2  => '0',
            ENCLKOS3  => '0',
			CLKOP     => clkfb,
			CLKOS     => open,
			CLKOS2    => ,
			CLKOS3    => open,
			LOCK      => ddram_lck,
            INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);
		ddram_clk <=
		
		ddrsys_rst <= not ddram_lck;

		ctlrphy_dso <= (others => not ctlr_clk) when ddram_mode/=sdram133MHz or debug=true else (others => ctlr_clk);

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
					if btn(0)='1' then
						dhcpcd_req <= not dhcpcd_rdy;
					end if;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => debug,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

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

		mii_txen <= miitx_frm and not miitx_end;
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				rgmii_tx_en <= mii_txen;
				rgmii_txd   <= mii_txd;
			end if;
		end process;

	end block;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		profile      => 2,

		ddr_tcp      => ddr_tcp,
		fpga         => fpga,
		mark         => mark,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_tab(video_mode).mode,
		red_length   => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		green_length => setif(video_tab(video_mode).pixel=rgb565, 6, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		blue_length  => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		fifo_size    => mem_size)

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
		video_shift_clk => video_shft_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clks(0) => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => ddram_tab(ddram_mode).cas,

		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke,
		ctlrphy_cs   => ctlrphy_cs,
		ctlrphy_ras  => ctlrphy_ras,
		ctlrphy_cas  => ctlrphy_cas,
		ctlrphy_we   => ctlrphy_we,
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dsi  => ctlrphy_dsi,
		ctlrphy_dst  => ctlrphy_dst,
		ctlrphy_dso  => open,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	ddrphy_rst <= (others => ctlrphy_rst);
	ddrphy_cs  <= (others => ctlrphy_cs);
	ddrphy_cke <= (others => ctlrphy_cke);
	ddrphy_ras <= (others => ctlrphy_ras);
	ddrphy_cas <= (others => ctlrphy_cas);
	ddrphy_we  <= (others => ctlrphy_we);
	ddrphy_odt <= (others => ctlrphy_odt);

	ddrphy_e : entity hdl4fpga.ecp5_ddrphy
	generic map (
		taps => 31,
		cmmd_gear     => cmmd_gear,
		data_gear     => data_gear,
		bank_size     => ddram_ba'length,
		addr_size     => ddram_a'length,
		word_size     => word_size,
		byte_size     => byte_size)
	port map (
		rst           => ddrsys_rst,
		eclk          => ctlr_clk,

		phy_wlreq     => ctlrphy_wlreq,
		phy_wlrdy     => ctlrphy_wlrdy,
		phy_rst       => (others =>'0'),
		phy_cs        => ddrphy_cs,
		phy_cke       => ddrphy_cke,
		phy_ras       => ddrphy_ras,
		phy_cas       => ddrphy_cas,
		phy_we        => ddrphy_we,
		phy_odt       => ddrphy_odt,
		phy_b         => ctlrphy_b,
		phy_a         => ctlrphy_a,
		phy_dqsi      => ctlrphy_dso,
		phy_dqst      => ctlrphy_dst,
		phy_dqso      => ctlrphy_dsi,
		phy_dmi       => ctlrphy_dmo,
		phy_dmt       => ctlrphy_dmt,
		phy_dmo       => ctlrphy_dmi,
		phy_dqi       => ctlrphy_dqo,
		phy_dqt       => ctlrphy_dqt,
		phy_dqo       => ctlrphy_dqi,
		phy_sti       => ctlrphy_sto,
		phy_sto       => ctlrphy_sti,

		ddr_ck        => ddram_clk,
		ddr_cke       => ddram_cke,
		ddr_cs        => ddram_cs_n,
		ddr_ras       => ddram_ras_n,
		ddr_cas       => ddram_cas_n,
		ddr_we        => ddram_we_n,
		ddr_odt       => ddram_odt,
		ddr_b         => ddram_ba,
		ddr_a         => ddram_a,

		ddr_dm        => ddram_dm,
		ddr_dq        => ddram_dq,
		ddr_dqs       => ddram_dqs);

	-- VGA --
	---------

	ddr_g : for i in 4-1 downto 0 generate
		signal q : std_logic;
	begin
		oddr_i : oddrx1f
		port map(
			sclk => video_shft_clk,
			rst  => '0',
			d0   => dvid_crgb(2*i),
			d1   => dvid_crgb(2*i+1),
			q    => q);
		olvds_i : olvds
		port map(
			a  => q,
			z  => gpdi_dp(i),
			zn => gpdi_dn(i));
	end generate;

	process (ctlr_clk)
		variable q : std_logic;
	begin
		if falling_edge(ctlr_clk) then
			q := not q;
			led(1)<= q;
		end if;
	end process;

end;
