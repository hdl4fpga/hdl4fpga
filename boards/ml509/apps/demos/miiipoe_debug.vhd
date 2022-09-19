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
use hdl4fpga.profiles.all;
use hdl4fpga.app_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture miiipoe_debug of ml509 is

	constant sys_freq : real := 100.0e6;

	type pll_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type video_params is record
		id   : video_modes;
		pll    : pll_params;
		timing : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		(id => modedebug,      timing => pclk_debug,               pll => (dcm_mul =>  4, dcm_div => 2)),
		(id => mode480p24bpp,  timing => pclk25_00m640x480at60,    pll => (dcm_mul =>  1, dcm_div => 4)),
		(id => mode600p24bpp,  timing => pclk40_00m800x600at60,    pll => (dcm_mul =>  2, dcm_div => 5)));

	function videoparam (
		constant id  : video_modes)
		return video_params is
		constant tab : videoparams_vector := video_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>videoparam<<< : video id not available"
		severity failure;

		return tab(tab'left);
	end;

	constant video_mode : video_modes :=mode600p24bpp;

	signal gtx_rst        : std_logic;
	signal gtx_clk        : std_logic;
	signal phy_rxclk_bufg : std_logic;
	signal phy_txclk_bufg : std_logic;
	alias  mii_txc        : std_logic is phy_txclk_bufg;

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
		I => user_clk ,
		O => sys_clk);

	videodcm_b : block
		signal clkfx_bufg : std_logic;
	begin
	
		dfs_i : dcm_base
		generic map (
			clk_feedback   => "NONE",
			clkin_period   => user_per*1.0e9,
			clkfx_divide   => videoparam(video_mode).pll.dcm_div,
			clkfx_multiply => videoparam(video_mode).pll.dcm_mul,
			dfs_frequency_mode => "LOW")
		port map (
			rst    => '0',
			clkfb  => '0',
			clkin  => sys_clk,
			clkfx  => clkfx_bufg);

		bufg_i : bufg
		port map (
			i => clkfx_bufg,
			o => video_clk);

	end block;

	gtx_b : block
		signal clk_fx : std_logic;
		signal locked : std_logic;
	begin
		gtx_i : dcm_base
		generic map  (
			CLK_FEEDBACK   => "NONE",
			clkin_period   => user_per*1.0e9,
			clkfx_multiply => 5,
			clkfx_divide   => 4)
		port map (
			rst    => '0',
			clkin  => sys_clk,
			clkfb  => '0',
			clkfx  => clk_fx,
			locked => locked);

		gtx_rst <= not locked;
		bufg_i : bufg
		port map (
			i => clk_fx,
			o => gtx_clk);

	end block;
	
	phy_rxclk_bufg_i : bufg
	port map (
		i => phy_rxclk,
		o => phy_rxclk_bufg);

	phy_txclk_bufg_i : bufg
	port map (
		i => phy_txclk,
		o => phy_txclk_bufg);

	ipoe_b : block

		alias  mii_rxc    : std_logic is phy_rxclk_bufg;
		alias  mii_rxdv   : std_logic is phy_rxctl_rxdv;
		alias  mii_rxd    : std_logic_vector(phy_rxd'range) is phy_rxd;
		signal mii_txd    : std_logic_vector(phy_txd'range);
		signal mii_txen   : std_logic;

		signal miirx_frm  : std_ulogic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal plrx_frm   : std_logic := '0';
		signal plrx_irdy  : std_logic := '0';
		signal plrx_trdy  : std_logic := '0';
		signal plrx_data  : std_logic_vector(0 to 8-1);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(plrx_data'range);

		signal pltx_frm   : std_logic;
		signal pltx_irdy  : std_logic;
		signal pltx_trdy  : std_ulogic;
		signal pltx_end   : std_logic;
		signal pltx_data  : std_logic_vector(plrx_data'range);

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal si_req     : bit;
		signal si_rdy     : bit;

		signal hxdv       : std_logic;
		signal hxd        : std_logic_vector(mii_rxd'range);

		signal htb_btn    : std_logic;

	begin

		process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if si_frm='0' then
					si_req <= si_rdy xor not to_bit(gpio_sw_c);
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
			signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal dst_irdy : std_logic;
			signal dst_trdy : std_logic;
		begin

			process (gpio_sw_c, hxdv, hxd, mii_rxc)
				variable q : std_logic_vector(rxc_rxbus'range);
			begin
				if rising_edge(mii_rxc) then
					q := mii_rxdv & mii_rxd;
				end if;
				case not gpio_sw_c is
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
					miirx_frm  <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_rxd'length);
				end if;
			end process;


		end block;

		process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					dhcpcd_req <= dhcpcd_rdy xor not gpio_sw_c;
				end if;
			end if;
		end process;

		du_e : entity hdl4fpga.mii_ipoe
		generic map (
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => x"c0_a8_00_0e")
		port map (
			tp => tp,
			hdplx => '1',
			mii_clk    => mii_txc,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
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
				phy_txctl_txen <= mii_txen;
				phy_txd  <= mii_txd;
			end if;
		end process;

		sin_clk   <= mii_txc;
		sin_frm   <= miitx_frm;
		sin_irdy  <= miitx_irdy and miitx_trdy;
		sin_data  <= miitx_data;
	end block;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id    => videoparam(video_mode).timing,
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


	videoio_b : block
		signal xclk : std_logic;
	begin
		process (video_clk)
		begin
			if rising_edge(video_clk) then
				dvi_de <= not video_blank;
				dvi_h  <= video_hs;
				dvi_v  <= video_vs;
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
			q  => dvi_xclk_p);
	
		dvi_xclk_n <= '0';
	
		d_g : for i in dvi_d'range generate
		begin
			oddr_i : oddr
			port map (
				c => video_clk,
				ce => '1',
				s  => '0',
				r  => '0',
				d1 => '1', --video_pixel(i),
				d2 => '1', --video_pixel(i+dvi_d'length),
				q  => dvi_d(i));
	
		end generate;

	end block;

	phy_txc_gtxclk_i : oddr
	port map (
		c => gtx_clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => '0',
		d2 => '1',
		q  => phy_txc_gtxclk);
	
	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	ddr2_clk_p <= (others => 'Z');
	ddr2_clk_n <= (others => 'Z');
	ddr2_cs    <= (others => 'Z');
	ddr2_cke   <= (others => 'Z');
	ddr2_ras   <= 'Z';
	ddr2_cas   <= 'Z';
	ddr2_we    <= 'Z';
	ddr2_a     <= (others => 'Z');
	ddr2_ba    <= (others => 'Z');
	ddr2_dqs_p <= (others => 'Z');
	ddr2_dqs_n <= (others => 'Z');
	ddr2_dm    <= (others => 'Z');
	ddr2_d     <= (others => 'Z');
	ddr2_odt   <= (others => 'Z');
	dvi_gpio1  <= '1';
	dvi_reset  <= '0';
	gpio_led_c <= '0';
	gpio_led_e <= '0';
	gpio_led_n <= '0';
	gpio_led_s <= '0';
	gpio_led_w <= '0';
	gpio_led <= (others => '0');
	bus_error <= (others => '0');
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';

end;

