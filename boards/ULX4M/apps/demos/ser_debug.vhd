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
use hdl4fpga.base.all;
use hdl4fpga.videopkg.all;

library ecp5u;
use ecp5u.components.all;
library ieee;
use ieee.std_logic_1164.all;

library ecp5u;
use ecp5u.components.all;

architecture ser_debug of ulx4m_ld is

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
    signal video_pixel    : std_logic_vector(0 to setif(video_tab(video_mode).pixel=rgb565, 16, 32)-1);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
    signal video_vtsync    : std_logic;
    signal video_on        : std_logic;
	signal video_dot       : std_logic;
	signal dvid_crgb       : std_logic_vector(7 downto 0);

	signal dhcp_req        : std_logic := '0';

	signal sio_clk        : std_logic;
	signal sin_frm         : std_logic;
	signal sin_irdy        : std_logic;
	signal sin_data        : std_logic_vector(0 to 8-1);
	signal sout_frm        : std_logic;
	signal sout_irdy       : std_logic;
	signal sout_trdy       : std_logic;
	signal sout_data       : std_logic_vector(0 to 8-1);

	signal ser_frm         : std_logic;
	signal ser_irdy        : std_logic;
	signal ser_data        : std_logic_vector(0 to 8-1);

	signal tp : std_logic_vector(1 to 32);

	-----------------
	-- Select link --
	-----------------

	constant io_hdlc : natural := 0;
	constant io_ipoe : natural := 1;

	constant io_link : natural := io_ipoe;

	constant io_len : natural_vector := (8, 2);

	constant mem_size  : natural := 8*(1024*8);

	signal enatx : std_logic;
	signal enarx : std_logic;

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
			CLKOS     => video_shift_clk,
            CLKOS2    => video_clk,
            CLKOS3    => open,
			LOCK      => video_lck, 
            INTLOCK   => open, 
			REFCLK    => open,
			CLKINTFB  => open);

		led(6) <= video_lck;

	end block;

	hdlc_g : if io_link=io_hdlc generate

	--	constant uart_xtal : natural := natural(sys_freq);
	--	alias uart_clk     : std_logic is clk_25mhz;

		constant uart_xtal : natural := natural(videodot_freq);
		signal uart_clk    : std_logic;

		constant baudrate  : natural := 3000000;
	--	constant baudrate  : natural := 115200;

		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(0 to 8-1);
		signal uart_idle   : std_logic;
		signal uart_txen   : std_logic;
		signal uart_txd    : std_logic_vector(uart_rxd'range);

		signal tp          : std_logic_vector(1 to 32);

	begin

		uart_clk   <= video_clk;
		sio_clk    <= video_clk;

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

		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size  => mem_size)
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
			si_data   => sout_data,
			tp        => tp);

		process (sio_clk)
			variable t : std_logic;
			variable e : std_logic;
			variable i : std_logic;
		begin
			if rising_edge(sio_clk) then
				if i='1' and e='0' then
					t := not t;
				end if;
				e := i;
				i := ser_frm;

				led(0) <= t;
				led(1) <= not t;
			end if;
		end process;

		ser_frm  <= (uart_txen and enatx) or (uart_rxdv and enarx);
		ser_irdy <= '1';
		ser_data(0 to io_len(io_link)-1) <= wirebus(
			uart_txd & uart_rxd, (uart_txen and enatx) & (not (uart_txen and enatx) and (uart_rxdv and enarx)));
	end generate;

	ipoe_e : if io_link=io_ipoe generate
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

		signal mii_clk   : std_logic;
		signal mii_txc   : std_logic;
		signal mii_txen  : std_logic;
		signal mii_txd   : std_logic_vector(0 to 2-1);

		signal mii_rxc   : std_logic;
		signal mii_rxdv  : std_logic;
		signal mii_rxd   : std_logic_vector(0 to 2-1);

		signal ipv4acfg_req  : std_logic := '0';

		constant loopback : boolean := false;
	begin
	
		sio_clk <= mii_clk;
		mii_txc <= mii_clk;
		mii_rxc <= mii_clk;

		loopback_g : if loopback generate
--			mii_clk <= clk_25mhz;
			mii_clk <= rmii_nint;

			process (mii_clk)
			begin
				if rising_edge(mii_clk) then
					rmii_tx_en <= mii_txen;
					(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;
				end if;
			end process;

			eth_tb_e : entity hdl4fpga.eth_tb
			port map (
				mii_frm1   => right,
				mii_frm2   => left,
				mii_txc    => mii_rxc,
				mii_txen   => mii_rxdv,
				mii_txd    => mii_rxd);

			rmii_mdc  <= '0';
			rmii_mdio <= '0';
		end generate;

		LAN_g : if not loopback generate
			mii_clk <= rmii_nint;

			process (mii_clk)
			begin
				if rising_edge(mii_clk) then
					rmii_tx_en <= mii_txen;
					(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;

					mii_rxdv <= rmii_crs;
					mii_rxd  <= rmii_rx0 & rmii_rx1;
				end if;
			end process;

			rmii_mdc  <= '0';
			rmii_mdio <= '0';

		end generate;

		ipv4acfg_req <= not btn_pwr_n;
		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			default_ipv4a => x"c0_a8_00_0e")
		port map (
			ipv4acfg_req => ipv4acfg_req,

			phy_rxc   => mii_rxc,
			phy_rx_dv => mii_rxdv,
			phy_rx_d  => mii_rxd,

			phy_txc   => mii_txc,
			phy_tx_en => mii_txen,
			phy_tx_d  => mii_txd,
		
			sio_clk   => sio_clk,
			si_frm    => sout_frm,
			si_irdy   => sout_irdy,
			si_trdy   => sout_trdy,
			si_data   => sout_data,

			so_frm    => sin_frm,
			so_irdy   => sin_irdy,
			so_trdy   => '1',
			so_data   => sin_data);

		ser_frm  <= (mii_txen and enatx) or (mii_rxdv and enarx);
		ser_irdy <= '1';
		ser_data(0 to io_len(io_link)-1) <= wirebus(
			mii_txd & mii_rxd, (mii_txen and enatx) & (not (mii_txen and enatx) and (mii_rxdv and enarx)));

		process (sio_clk)
			variable t : std_logic;
			variable e : std_logic;
			variable i : std_logic;
		begin
			if rising_edge(sio_clk) then
				if i='1' and e='0' then
					t := not t;
				end if;
				e := i;
				i := ser_frm;

				led(0) <= t;
				led(1) <= not t;
			end if;
		end process;

		led(4) <= mii_txen;
		led(5) <= mii_rxdv;
	end generate;
	
	process (sio_clk)
		variable i : std_logic_vector(0 to 2-1);
		variable t : std_logic_vector(0 to 2-1) := (others => '1');
		variable e : std_logic_vector(0 to 2-1);
	begin
		if rising_edge(sio_clk) then
			for j in e'range loop
				if i(j)='1' and e(j)='0' then
					t(j) := not t(j);
				end if;
				e(j) := i(j);
			end loop;
			i(0) := fire1;
			i(1) := fire2;
			enatx <= '1'; --t(0);
			enarx <= '1'; --t(1);
		end if;
	end process;
	led(2) <= enarx;
	led(3) <= enatx;


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
		ser_data        => ser_data(0 to io_len(io_link)-1), 
		
		video_clk       => video_clk,
		video_shift_clk => video_shift_clk,
		video_hzsync    => video_hzsync,
		video_vtsync    => video_vtsync,
		video_pixel     => video_pixel,
		dvid_crgb       => dvid_crgb);

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

end;
