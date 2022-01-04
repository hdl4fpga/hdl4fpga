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
use hdl4fpga.ipoepkg.all;

library ecp5u;
use ecp5u.components.all;

architecture miiipoe_debug of ulx3s is

	constant sys_freq   : real    := 25.0e6;

	type video_modes is (
		mode600p,
		modedebug);

	type pll_params is record
		clkos_div   : natural;
		clkop_div   : natural;
		clkfb_div   : natural;
		clki_div    : natural;
		clkos2_div  : natural;
		clkos3_div  : natural;
	end record;

	type pixel_types is (rgb565, rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		mode600p   => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk40_00m800x600at60),
		modedebug  => (pll => (clkos_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1, clkos2_div => 10, clkos3_div => 2), pixel => rgb565, mode => pclk_debug));

	constant nodebug_videomode : video_modes := mode600p;
	constant videodot_freq : natural :=
		(video_tab(nodebug_videomode).pll.clkfb_div*video_tab(nodebug_videomode).pll.clkop_div*natural(sys_freq))/
		(video_tab(nodebug_videomode).pll.clki_div*video_tab(nodebug_videomode).pll.clkos2_div);

	constant video_mode   : video_modes := video_modes'VAL(setif(debug,
--		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode),
		video_modes'POS(nodebug_videomode)));

    signal video_pixel    : std_logic_vector(0 to setif(video_tab(video_mode).pixel=rgb565, 16, 32)-1);

	signal sys_rst        : std_logic;
	signal sys_clk        : std_logic;

	signal video_clk      : std_logic;
	signal video_shft_clk : std_logic;
	signal video_lck      : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_on       : std_logic;
	signal video_dot      : std_logic;
	signal dvid_crgb      : std_logic_vector(7 downto 0);

	-- RMII pins as labeled on the board and connected to ULX3S with pins down and flat cable
  	alias rmii_tx_en      : std_logic is gn(10);
  	alias rmii_tx0        : std_logic is gp(10);
  	alias rmii_tx1        : std_logic is gn(9);

  	alias rmii_rx0        : std_logic is gn(11);
  	alias rmii_rx1        : std_logic is gp(11);

  	alias rmii_crs        : std_logic is gp(12);

  	alias rmii_nint       : std_logic is gn(12);
  	alias rmii_mdio       : std_logic is gn(13);
  	alias rmii_mdc        : std_logic is gp(13);

  	signal mii_clk        : std_logic;

	alias mii_txc         : std_logic is mii_clk;
  	signal mii_txen       : std_logic;
  	signal mii_txd        : std_logic_vector(0 to 2-1);

	alias mii_rxc         : std_logic is mii_clk;
  	signal mii_rxdv       : std_logic;
  	signal mii_rxd        : std_logic_vector(0 to 2-1);

	alias sio_clk         : std_logic is mii_clk;
	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(0 to 8-1);
	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(0 to 8-1);

	signal ser_frm        : std_logic;
	signal ser_irdy       : std_logic;
	signal ser_data       : std_logic_vector(0 to 2-1);

	signal tp             : std_logic_vector(1 to 32);
	alias rx_data : std_logic_vector(0 to 8-1) is tp(9 to 16);

	-----------------
	-- Select link --
	-----------------

	constant mem_size  : natural := 8*(1024*8);

begin

	sys_rst <= '0';

	videopll_b : block
		signal clkfb : std_logic;

		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;
		attribute FREQUENCY_PIN_CLKOS  : string;
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
			CLKOS     => video_shft_clk,
            CLKOS2    => video_clk,
            CLKOS3    => open,
			LOCK      => video_lck,
            INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);

	end block;

		mii_clk <= rmii_nint;
--		mii_clk <= clk_25mhz;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			rmii_tx_en <= mii_txen;
			(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;
		end if;
	end process;

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			mii_rxdv <= rmii_crs;
			mii_rxd  <= rmii_rx0 & rmii_rx1;
		end if;
	end process;

	rmii_mdc  <= '0';
	rmii_mdio <= '0';

	ipoe_b : block
		signal plrx_data  : std_logic_vector(0 to 8-1);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal pltx_data  : std_logic_vector(plrx_data'range);
		signal miitx_data : std_logic_vector(plrx_data'range);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';
		signal rxntx      : std_logic := '0';
		signal fltr_on    : std_logic := '0';
		signal myhwa_vld  : std_logic;

	begin
		wifi_en <= '0';
		dhcp_p : process(mii_clk)
		begin
			if rising_edge(mii_clk) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					dhcpcd_req <= dhcpcd_rdy xor ((fire2 and dhcpcd_rdy) or (fire1 and not dhcpcd_rdy));
				end if;
			end if;
		end process;
		led(0) <= dhcpcd_rdy;
		led(7) <= not dhcpcd_rdy;

		du_e : entity hdl4fpga.mii_ipoe
		generic map (
			default_ipv4a => aton("192.168.1.1"))
		port map (
			hdplx => '1',
			tp         => tp,
			mii_clk    => mii_txc,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			myhwa_vld  => myhwa_vld,
			miirx_frm  => mii_rxdv,
			miirx_data => mii_rxd,

			plrx_frm   => open,
			plrx_irdy  => open,
			plrx_trdy  => '1',
			plrx_data  => plrx_data,

			pltx_frm   => '0',
			pltx_irdy  => '0',
			pltx_trdy  => open,
			pltx_end   => '1',
			pltx_data  => pltx_data,

			miitx_frm  => miitx_frm,
			miitx_irdy => miitx_irdy,
			miitx_trdy => miitx_trdy,
			miitx_end  => miitx_end,
			miitx_data => miitx_data);

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

		rxtx_p : process(mii_clk)
		begin
			if rising_edge(mii_clk) then
				rxntx <= rxntx xor ((left and rxntx) or (right and not rxntx));
			end if;
		end process;
		led(4) <= rxntx;

		fltr_on_p : process(mii_clk)
		begin
			if rising_edge(mii_clk) then
				fltr_on <=fltr_on xor ((down and fltr_on) or (up and not fltr_on));
			end if;
		end process;
		led(2) <= fltr_on;

		ser_frm  <= word2byte(mii_txen & std_logic'(word2byte(tp(17) & myhwa_vld, fltr_on)), rxntx);
		ser_irdy <= '1';
		ser_data <= word2byte(mii_txd  & mii_rxd,  rxntx);

	end block;


	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id       => video_tab(video_mode).mode,
		red_length      => 5,
		green_length    => 6,
		blue_length     => 5)
	port map (
		ser_clk         => sio_clk,
		ser_frm         => ser_frm,
		ser_irdy        => ser_irdy,
		ser_data        => ser_data,

		video_clk       => video_clk,
		video_shift_clk => video_shft_clk,
		video_hzsync    => video_hzsync,
		video_vtsync    => video_vtsync,
		video_pixel     => video_pixel,
		dvid_crgb       => dvid_crgb);

	ddr_g : for i in gpdi_dp'range generate
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

end;
