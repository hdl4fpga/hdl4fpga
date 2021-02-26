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
use hdl4fpga.videopkg.all;

library ecp5u;
use ecp5u.components.all;
library ieee;
use ieee.std_logic_1164.all;

library ecp5u;
use ecp5u.components.all;

architecture sio_debug of ulx3s is

	constant sys_freq   : real    := 25.0e6;

	constant modedebug  : natural := 0;
	constant mode600p   : natural := 1;
	constant mode600p18 : natural := 2;
	constant mode600p24 : natural := 3;
	constant mode900p   : natural := 4;
	constant mode1080p  : natural := 5;

	type pll_params is record
		clkos_div   : natural;
		clkop_div   : natural;
		clkfb_div   : natural;
		clki_div    : natural;
		clkos2_div  : natural;
		clkos3_div  : natural;
	end record;

	type pixel_types is (rgb565, rgb666, rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug  => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk_debug),
		mode600p   => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk40_00m800x600at60),
		mode600p18 => (pll => (clkos_div => 3, clkop_div => 29,  clkfb_div => 1, clki_div => 1, clkos2_div => 18, clkos3_div => 2), pixel => rgb666, mode => pclk40_00m800x600at60),
		mode600p24 => (pll => (clkos_div => 2, clkop_div => 25,  clkfb_div => 1, clki_div => 1, clkos2_div => 16, clkos3_div => 2), pixel => rgb888, mode => pclk40_00m800x600at60),
		mode900p   => (pll => (clkos_div => 1, clkop_div => 20,  clkfb_div => 1, clki_div => 1, clkos2_div =>  5, clkos3_div => 2), pixel => rgb565, mode => pclk100_00m1600x900at60),
		mode1080p  => (pll => (clkos_div => 1, clkop_div => 24,  clkfb_div => 1, clki_div => 1, clkos2_div =>  5, clkos3_div => 2), pixel => rgb565, mode => pclk120_00m1920x1080at50));

	constant nodebug_videomode : natural := mode600p;
	constant videodot_freq : natural := 
		(video_tab(nodebug_videomode).pll.clkfb_div*video_tab(nodebug_videomode).pll.clkop_div*natural(sys_freq))/
		(video_tab(nodebug_videomode).pll.clki_div*video_tab(nodebug_videomode).pll.clkos2_div);

	constant video_mode : natural := setif(debug, modedebug, nodebug_videomode);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
    signal video_on        : std_logic;
	signal video_dot       : std_logic;
	signal dvid_crgb       : std_logic_vector(7 downto 0);

	-- RMII pins as labeled on the board and connected to ULX3S with pins down and flat cable
	alias rmii_tx_en : std_logic is gn(10);
	alias rmii_tx0   : std_logic is gp(10);
	alias rmii_tx1   : std_logic is gn(9);

	alias rmii_rx0   : std_logic is gn(11);
	alias rmii_rx1   : std_logic is gp(11);

	alias rmii_crs   : std_logic is gp(12);

	alias rmii_nint  : std_logic is gn(12);
	alias rmii_mdio  : std_logic is gn(13);
	alias rmii_mdc   : std_logic is gp(13);

	signal mii_txc   : std_logic;
	signal mii_txen  : std_logic;
	signal mii_txd   : std_logic_vector(0 to 2-1);

	signal mii_rxc   : std_logic;
	signal mii_rxdv  : std_logic;
	signal mii_rxd   : std_logic_vector(0 to 2-1);

	signal dhcp_req  : std_logic := '0';

	signal ser_irdy : std_logic;

--	constant uart_xtal : natural := natural(sys_freq);
--	alias uart_clk     : std_logic is clk_25mhz;

	constant uart_xtal : natural := natural(videodot_freq);
	alias uart_clk     : std_logic is video_clk;

	constant baudrate  : natural := 3000000;

	signal uart_rxdv   : std_logic;
	signal uart_rxd    : std_logic_vector(0 to 8-1);
	signal uart_idle   : std_logic;
	signal uart_txen   : std_logic;
	signal uart_txd    : std_logic_vector(0 to 8-1);

	alias sio_clk      : std_logic is uart_clk;

	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(8-1 downto 0);
	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(8-1 downto 0);

begin

    mii_txc <= not rmii_nint;
	process(mii_txc)
	begin
		if rising_edge(mii_txc) then
			rmii_tx_en <= mii_txen;
			(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;
		end if;
	end process;

    mii_rxc <= not rmii_nint;
	process(mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			mii_rxdv <= rmii_crs;
			mii_rxd  <= rmii_rx0 & rmii_rx1;
		end if;
	end process;

	rmii_mdc  <= 'Z';
	rmii_mdio <= 'Z';

	sys_rst <= '0';

	videopll_b : block
		signal clkfb : std_logic;

		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKOS : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is  "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is  "25.000000";

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is "200.000000";
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is  "40.000000";
	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED", 
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED", 
			PLL_LOCK_MODE    =>  0, 
			FEEDBK_PATH      => "CLKOP",
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => video_tab(video_mode).pll.clkop_div-1,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0, 
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS3_DIV       => video_tab(video_mode).pll.clkos3_div, 
			CLKOS2_DIV       => video_tab(video_mode).pll.clkos2_div, 
			CLKOS_DIV        => video_tab(video_mode).pll.clkos_div,
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
			CLKOS     => video_shift_clk,
            CLKOS2    => video_clk,
			LOCK      => open, 
            INTLOCK   => open, 
			REFCLK    => open, --REFCLK, 
			CLKINTFB  => open);
	end block;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if btn(1)='1' then
				if mii_txen='0' then
					dhcp_req <= '1';
				end if;
			elsif mii_txen='0' then
				dhcp_req <= '0';
			end if;
		end if;
	end process;

	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => uart_xtal)
	port map (
		uart_rxc  => uart_clk,
		uart_sin  => ftdi_txd,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

	uarttx_e : entity hdl4fpga.uart_tx
	generic map (
		baudrate => baudrate,
		clk_rate => uart_xtal)
	port map (
		uart_txc  => uart_clk,
		uart_sout => ftdi_rxd,
		uart_idle => uart_idle,
		uart_txen => uart_txen,
		uart_txd  => uart_txd);

	siodayahdlc_e : entity hdl4fpga.sio_dayhdlc
	port map (
		uart_clk  => uart_clk,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd,
		uart_idle => uart_idle,
		uart_txd  => uart_txd,
		uart_txen => uart_txen,
		sio_clk   => sio_clk,
		so_frm    => sin_frm,
		so_irdy   => sin_irdy,
		so_data   => sin_data,

		si_frm    => sout_frm,
		si_irdy   => sout_irdy,
		si_trdy   => sout_trdy,
		si_data   => sout_data);

--	ser_irdy <= uart_rxdv;
	ser_irdy <= uart_txen and uart_idle;

	video_b : block
		signal hzsync : std_logic;
		signal vtsync : std_logic;
		signal von    : std_logic;
	begin

		mii_debug_e : entity hdl4fpga.mii_display
		generic map (
			code_spce   => to_ascii(" "),
			code_digits => to_ascii("0123456789abcdef"),
			cga_bitrom  => to_ascii("Ready Steady GO!"),
			timing_id   => video_tab(video_mode).mode)
		port map (
			phy_clk     => sio_clk,
			phy_frm     => '1',
			phy_irdy    => ser_irdy,
	--		phy_data    => uart_rxd,
			phy_data    => uart_txd,

			video_clk   => video_clk, 
			video_dot   => video_dot,
			video_on    => von,
			video_hs    => hzsync,
			video_vs    => vtsync);

		video_lat_e : entity hdl4fpga.align
		generic map (
			n => 3,
			d => (0 to 3-1 => 4))
		port map (
			clk => video_clk,
			di(0) => von,
			di(1) => hzsync,
			di(2) => vtsync,
			do(0) => video_on,
			do(1) => video_hzsync,
			do(2) => video_vtsync);

	end block;

	-- VGA --
	---------

	dvi_b : block
		signal video_blank : std_logic;
		signal in_dots    : std_logic_vector(5-1 downto 0);
	begin

		video_blank <= not video_on;
		in_dots <= (others => video_dot);

		vga2dvid_e : entity hdl4fpga.vga2dvid
		generic map (
			C_shift_clock_synchronizer => '0',
			C_ddr   => '1',
			C_depth => 5)
		port map (
			clk_pixel => video_clk,
			clk_shift => video_shift_clk,
			in_red    => in_dots,
			in_green  => in_dots,
			in_blue   => in_dots,
			in_hsync  => video_hzsync,
			in_vsync  => video_vtsync,
			in_blank  => video_blank,
			out_clock => dvid_crgb(7 downto 6),
			out_red   => dvid_crgb(5 downto 4),
			out_green => dvid_crgb(3 downto 2),
			out_blue  => dvid_crgb(1 downto 0));

		ddr_g : for i in gpdi_dp'range generate
			signal q : std_logic;
		begin
			oddr_i : oddrx1f
			port map(
				sclk => video_shift_clk,
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
	end block;

end;
