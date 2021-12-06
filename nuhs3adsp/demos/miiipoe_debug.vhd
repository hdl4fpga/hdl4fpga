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
use hdl4fpga.cgafonts.all;

library unisim;
use unisim.vcomponents.all;

architecture miiipoe_debug of nuhs3adsp is

	constant sys_freq : real := 100.0e6;

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

	constant video_mode    : video_modes := mode600p;

	signal video_clk      : std_logic;
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
	signal video_blank    : std_logic;
	signal video_pixel    : std_logic_vector(3-1 downto 0);

	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);

	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(so_data'range);

	signal sin_clk        : std_logic;
	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(so_data'range);

	signal tp  : std_logic_vector(1 to 32);
	alias data : std_logic_vector(0 to 8-1) is tp(3 to 3+8-1);

	-----------------
	-- Select link --
	-----------------

	constant io_hdlc : natural := 0;
	constant io_ipoe : natural := 1;

	constant io_link : natural := io_hdlc;

	constant mem_size  : natural := 8*(1024*8);

	signal sys_clk : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_refclk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 50.0,
		dfs_mul => video_tab(video_mode).pll.dcm_mul,
		dfs_div => video_tab(video_mode).pll.dcm_div)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => video_clk);


	ipoe_b : block
		signal mii_txcfrm : std_ulogic;
		signal mii_txcrxd : std_logic_vector(mii_rxd'range);

		signal miirx_frm  : std_ulogic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(0 to 8-1);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(miirx_data'range);

		signal plrx_frm   : std_logic := '0';
		signal plrx_irdy  : std_logic := '0';
		signal plrx_trdy  : std_logic := '0';
		signal plrx_data  : std_logic_vector(miirx_data'range);

		signal pltx_frm   : std_logic;
		signal pltx_irdy  : std_logic;
		signal pltx_trdy  : std_ulogic;
		signal pltx_end   : std_logic;
		signal pltx_data  : std_logic_vector(miirx_data'range);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal si_req     : bit;
		signal si_rdy     : bit;

		signal hxdv       : std_logic;
		signal hxd        : std_logic_vector(mii_rxd'range);

		signal htb_btn    : std_logic;

	begin

--		htb_btn <= not sw1;
--		htb_e : entity hdl4fpga.eth_tb
--		port map (
--			mii_frm1 => '0',
--			mii_frm2 => htb_btn,
--			mii_frm3 => '0',
--			mii_frm4 => '0',
--
--			mii_txc  => mii_txc,
--			mii_txen => hxdv,
--			mii_txd  => hxd);
--
		process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if si_frm='0' then
					si_req <= si_rdy xor not to_bit(sw1);
				elsif (si_trdy and si_end)='1' then
					si_rdy <= si_req;
				end if;
			end if;
		end process;
		si_frm <= '0'; --to_stdulogic(si_req xor si_rdy);

		eth2_e: entity hdl4fpga.sio_mux
		port map (
			mux_data => reverse(
				x"ff_ff_ff_ff_ff_ff" &  -- Destination MAC address
				x"ff_ff_ff_ff"       &  -- Destination IP address
				x"dea9"              &  -- UDP source port
				x"de00"              &  -- UDP destination port
				reverse(x"0001")     &  -- Payload length
				x"77",8),

			sio_clk  => mii_txc,
			sio_frm  => si_frm,
			sio_irdy => si_trdy,
			sio_trdy => si_irdy,
			so_end   => si_end,
			so_data  => si_data);

		sync_b : block
			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal dst_irdy : std_logic;
			signal dst_trdy : std_logic;
		begin

			process (sw1, hxdv, hxd, mii_rxc)
				variable q : std_logic_vector(rxc_rxbus'range);
			begin
				if rising_edge(mii_rxc) then
					q := mii_rxdv & mii_rxd;
				end if;
				case not sw1 is
				when '1' =>
					rxc_rxbus <= hxdv & hxd;
				when others =>
					rxc_rxbus <= q;
				end case;
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
					mii_txcfrm <= txc_rxbus(0);
					mii_txcrxd <= txc_rxbus(1 to mii_txcrxd'length);
				end if;
			end process;


		end block;

		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => mii_txc,
			serdes_frm => mii_txcfrm,
			ser_irdy   => '1',
			ser_trdy   => open,
			ser_data   => mii_txcrxd,

			des_frm    => miirx_frm,
			des_irdy   => miirx_irdy,
			des_trdy   => miirx_trdy,
			des_data   => miirx_data);

		process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
--					dhcpcd_req <= dhcpcd_rdy xor not sw1;
				end if;
			end if;
		end process;

		du_e : entity hdl4fpga.mii_ipoe
		generic map (
			default_ipv4a => x"c0_a8_00_0e")
		port map (
			tp => tp,
			mii_clk    => mii_txc,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => miirx_irdy,
			miirx_trdy => miirx_trdy,
			miirx_data => miirx_data,

			plrx_frm   => plrx_frm,
			plrx_irdy  => plrx_irdy,
			plrx_trdy  => plrx_trdy,
			plrx_data  => plrx_data,

			pltx_frm   => pltx_frm,
			pltx_irdy  => pltx_irdy,
			pltx_trdy  => pltx_trdy,
			pltx_end   => pltx_end,
			pltx_data  => pltx_data,

			miitx_frm  => miitx_frm,
			miitx_irdy => miitx_irdy,
			miitx_trdy => miitx_trdy,
			miitx_end  => miitx_end,
			miitx_data => miitx_data);

		sioflow_e : entity hdl4fpga.sio_flow
		port map (
			sio_clk => mii_txc,

			rx_frm  => plrx_frm,
			rx_irdy => plrx_irdy,
			rx_trdy => plrx_trdy,
			rx_data => plrx_data,

			so_frm  => so_frm,
			so_irdy => so_irdy,
			so_trdy => so_trdy,
			so_data => so_data,

			si_frm  => si_frm,
			si_irdy => si_irdy,
			si_trdy => si_trdy,
			si_end  => si_end,
			si_data => si_data,

			tx_frm  => pltx_frm,
			tx_irdy => pltx_irdy,
			tx_trdy => pltx_trdy,
			tx_end  => pltx_end,
			tx_data => pltx_data);

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

		sin_clk   <= mii_txc;
		sin_frm   <= tp(2); --miitx_frm;
		sin_irdy  <= tp(3); --miitx_irdy and miitx_trdy;
		sin_data  <= tp(4 to 4+8-1); --miitx_data;
	end block;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id    => video_tab(video_mode).mode,
		red_length   => 1,
		green_length => 1,
		blue_length  => 1)
	port map (
		ser_clk      => sin_clk,
		ser_frm      => sin_frm,
		ser_irdy     => sin_irdy,
		ser_data     => sin_data,

		video_clk    => video_clk,
		video_hzsync => video_hs,
		video_blank  => video_blank,
		video_vtsync => video_vs,
		video_pixel  => video_pixel);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			red    <= (red'range => video_pixel(2));
			green  <= (green'range => video_pixel(1));
			blue   <= (blue'range => video_pixel(0));
			blankn <= not video_blank;
			hsync  <= video_hs;
			vsync  <= video_vs;
			sync   <= not video_hs and not video_vs;
		end if;
	end process;

	psave <= '1';
	sync  <= 'Z';
	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => video_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

	hd_t_data <= 'Z';

	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0'; --tp(5);
	led11 <= '0'; --tp(4); -- '0';
	led9  <= '0'; --tp(3); -- txc_rxdv ;
	led8  <= not tp(1);
	led7  <= tp(1);

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

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => ddr_ckp,
		ob => ddr_ckn);

	ddr_st_dqs <= 'Z';
	ddr_cke    <= 'Z';
	ddr_cs     <= 'Z';
	ddr_ras    <= 'Z';
	ddr_cas    <= 'Z';
	ddr_we     <= 'Z';
	ddr_ba     <= (others => 'Z');
	ddr_a      <= (others => 'Z');
	ddr_dm     <= (others => 'Z');
	ddr_dqs    <= (others => 'Z');
	ddr_dq     <= (others => 'Z');

	adc_clkab <= 'Z';

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';


end;

