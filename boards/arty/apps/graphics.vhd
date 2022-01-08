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

library unisim;
use unisim.vcomponents.all;

architecture graphics of arty is

	constant sys_freq : real := 100.0e6;

	constant sclk_phases  : natural := 1;
	constant sclk_edges   : natural := 1;
	constant data_edges   : natural := 1;
	constant cmmd_gear    : natural := 2;
	constant data_gear    : natural := 4;

	constant bank_size    : natural := ddr3_ba'length;
	constant addr_size    : natural := ddr3_a'length;
	constant word_size    : natural := ddr3_dq'length;
	constant byte_size    : natural := ddr3_dq'length/ddr3_dqs_p'length;

	type video_modes is (
		mode480p,
		mode600p,
		mode1080p);

	type video_params is record
		timing_id : videotiming_ids;
		dcm_mul   : natural;
		dcm_div   : natural;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		mode480p  => (timing_id => pclk25_00m640x480at60,    dcm_mul =>  6, dcm_div => 24),
		mode600p  => (timing_id => pclk40_00m800x600at60,    dcm_mul =>  6, dcm_div => 15),
		mode1080p => (timing_id => pclk140_00m1920x1080at60, dcm_mul => 12, dcm_div => 8));

	constant video_mode    : video_modes := mode600p;
	constant videodot_freq : natural := (video_tab(video_mode).dcm_mul*natural(sys_freq))/(video_tab(video_mode).dcm_div);

	signal sys_clk        : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal eth_rxclk_bufg : std_logic;
	signal video_clk      : std_logic;
	signal video_lckd     : std_logic;
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
	signal video_pixel    : std_logic_vector(3-1 downto 0);

	signal miirx_frm      : std_ulogic;
	signal miirx_irdy     : std_logic;
	signal miirx_trdy     : std_logic;
	signal miirx_data     : std_logic_vector(0 to 8-1);

	signal miitx_frm      : std_logic;
	signal miitx_irdy     : std_logic;
	signal miitx_trdy     : std_logic;
	signal miitx_end      : std_logic;
	signal miitx_data     : std_logic_vector(miirx_data'range);

	signal sin_clk        : std_logic;
	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(miitx_data'range);
--	signal sin_data       : std_logic_vector(eth_rxd'range);
	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(0 to 8-1);

	signal tp  : std_logic_vector(1 to 32);
	signal tp1  : std_logic_vector(1 to 32);
	alias data : std_logic_vector(0 to 8-1) is tp(3 to 3+8-1);

	signal vbtn2 : std_logic_vector(2-1 downto 0);
	signal vbtn3 : std_logic_vector(2-1 downto 0);

	-----------------
	-- Select link --
	-----------------

	constant io_hdlc : natural := 0;
	constant io_ipoe : natural := 1;

	constant io_link : natural := io_hdlc;

	constant mem_size  : natural := 8*(1024*8);

begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	eth_rx_clk_ibufg : ibufg
	port map (
		I => eth_rx_clk,
		O => eth_rxclk_bufg);

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);

	dcm_b : block
	begin

		ioctrl_b : block
		begin
			ioctrl_i :  mmcme2_base
			generic map (
				clkfbout_mult_f => 8.0,		-- 200 MHz
				clkin1_period => sys_per,
				clkout0_divide_f => 4.0,
				bandwidth => "LOW")
			port map (
				pwrdwn   => '0',
				rst      => sys_rst,
				clkin1   => sys_clk,
				clkfbin  => ioctrl_clkfb,
				clkfbout => ioctrl_clkfb,
				clkout0  => ioctrl_clk,
				locked   => ioctrl_lckd);
		end block;

		ddr_b : block
		begin
			ddr_i : mmcme2_base
			generic map (
				divclk_divide => ddr_div,
				clkfbout_mult_f => 2.0*ddr_mul,
				clkin1_period => sys_per,
				clkout1_phase => 90.0+180.0,
				clkout3_phase => 90.0/real((DDR_GEAR/2))+270.0,
				clkout0_divide_f => real(DDR_GEAR/2),
				clkout1_divide => DDR_GEAR/2,
				clkout2_divide => DDR_GEAR,
				clkout3_divide => DDR_GEAR)
			port map (
				pwrdwn   => '0',
				rst      => sys_rst,
				clkin1   => sys_clk,
				clkfbin  => ddr_clkfb,
				clkfbout => ddr_clkfb,
				clkout0  => ddr_clk0_mmce2,
				clkout1  => ddr_clk90_mmce2,
				clkout2  => ddr_clk0div_mmce2,
				clkout3  => ddr_clk90div_mmce2,
				locked   => ddr_lckd);

			ddr_clk0_bufg : bufio
			port map (
				i => ddr_clk0_mmce2,
				o => ddr_clk0);

			ddr_clk90_bufg : bufio
			port map (
				i => ddr_clk90_mmce2,
				o => ddr_clk90);

			ddr_clk0div_bufg : bufg
			port map (
				i => ddr_clk0div_mmce2,
				o => ddr_clk0div);

			ddr_clk90div_bufg : bufg
			port map (
				i => ddr_clk90div_mmce2,
				o => ddr_clk90div);

			sys_clks <= (
				clk0div  => ddrs_clk0div,
				clk90div => ddrs_clk90div,
				iodclk   => sys_clk,
				clk0     => ddrs_clk0,
				clk90    => ddrs_clk90);

		end block;

		video_b :  block
			signal video_clkfb : std_logic;
		begin
			video_dcm_i : mmcme2_base
			generic map (
				clkin1_period    => 10.0,
				clkfbout_mult_f  => real(video_tab(video_mode).dcm_mul),
				clkout0_divide_f => real(video_tab(video_mode).dcm_div),
				bandwidth        => "LOW")
			port map (
				pwrdwn   => '0',
				rst      => '0',
				clkin1   => sys_clk,
				clkfbin  => video_clkfb,
				clkfbout => video_clkfb,
				locked   => video_lckd,
				clkout0  => video_clk);
		end block;

	end block;

	ipoe_b : block

		alias mii_rxc     : std_logic is eth_rxclk_bufg;
		alias mii_rxdv    : std_logic is eth_rx_dv;
		alias mii_rxd     : std_logic_vector(eth_rxd'range) is eth_rxd;

		alias mii_txc     : std_logic is eth_txclk_bufg;
		alias mii_txen    : std_logic is eth_tx_en;
		alias mii_txd     : std_logic_vector(eth_txd'range) is eth_txd;

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
			--		dhcpcd_req <= dhcpcd_rdy xor not sw1;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => tp,

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

	end block;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		profile      => profile_tab(profile).profile,
		ddr_tcp      => ddr_tcp,
		fpga         => virtex7,
		mark         => mark,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_tab(video_mode).mode,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8,

		fifo_size    => 8*2048)

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
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel,

		dmacfg_clk   => dmacfg_clk,
		ctlr_clks    => ctlr_clks,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "001",
		ctlr_cl      => ddr_param.cas,
		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dsi  => ctlrphy_dqsi,
		ctlrphy_dst  => ctlrphy_dqst,
		ctlrphy_dso  => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		tp => open);

	ddrphy_e : entity hdl4fpga.xc7a_ddrphy
	generic map (
		tcp          => integer(uclk_period*1000.0*real(ddr_div)/ddr_mul),
		tap_delay    => 78,
		bank_size    => bank_size,
        addr_size    => addr_size,
		cmmd_gear    => cmmd_gear,
		data_gear    => data_gear,
		word_size    => word_size,
		byte_size    => byte_size)
	port map (

		tp_sel    => sw(3),
		tp_delay  => tp_delay,
		tp1       => tp1,
		tp_bit    => tp_bit,

		sys_clks => sys_clks,
		phy_rsts => phy_rsts,
		phy_ini      => ddrphy_ini,
		phy_rw       => ddrphy_rw,
		phy_cmd_rdy  => ddrphy_cmd_rdy,
		phy_cmd_req  => ddrphy_cmd_req,
		sys_act      => ddrphy_act,

		sys_wlreq    => ddrphy_wlreq,
		sys_wlrdy    => ddrphy_wlrdy,

		sys_rlreq    => ddrphy_rlreq,
		sys_rlrdy    => ddrphy_rlrdy,
		sys_rlcal    => ddrphy_rlcal,
		sys_rlseq    => ddrphy_rlseq,

		sys_cke      => ddrphy_cke,
		sys_rst      => ddrphy_rst,
		sys_cs       => ddrphy_cs,
		sys_ras      => ddrphy_ras,
		sys_cas      => ddrphy_cas,
		sys_we       => ddrphy_we,
		sys_b        => ddrphy_b,
		sys_a        => ddrphy_a,

		sys_dqst     => ddrphy_dqst,
		sys_dqso     => ddrphy_dqso,
		sys_dmi      => ddrphy_dmo,
		sys_dmt      => ddrphy_dmt,
		sys_dmo      => ddrphy_dmi,
		sys_dqo      => ddrphy_dqo,
		sys_dqt      => ddrphy_dqt,
		sys_dqi      => ddrphy_dqi,
		sys_odt      => ddrphy_odt,
		sys_sti      => ddrphy_sto,
		sys_sto      => ddrphy_sti,

		ddr_rst      => ddr3_reset,
		ddr_clk      => ddr3_clk,
		ddr_cke      => ddr3_cke,
		ddr_cs       => ddr3_cs,
		ddr_ras      => ddr3_ras,
		ddr_cas      => ddr3_cas,
		ddr_we       => ddr3_we,
		ddr_b        => ddr3_ba,
		ddr_a        => ddr3_a,
		ddr_odt      => ddr3_odt,
--		ddr_dm       => ddr3_dm,
		ddr_dqo      => ddr3_dqo,
		ddr_dqi      => ddr3_dq,
		ddr_dqt      => ddr3_dqt,
		ddr_dqst     => ddr3_dqst,
		ddr_dqsi     => ddr3_dqsi,
		ddr_dqso     => ddr3_dqso);
	ddr3_dm <= (others => '0');

	ddrphy_dqsi <= (others => ddrs_clk90div);

	-- VGA --
	---------

	hdmi_b : block
		signal q : std_logic_vecto(0 to 4-1);
		signal p : std_logic_vecto(q'range);
		signal n : std_logic_vecto(p'range);
	begin
		oddr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 4,
			GEAR => 2)
		port map (
			clk(0) => video_shft_clkin,
			clk(1) => '-',
			d      => dvid_crgb,
			q      => q);

		p <= jb(1) & jb(3) & jb(7) & jb(9);
		n <= jb(2) & jb(4) & jb(8) & jb(10);
		hdmi_g : for i in q'range generate
			obufds_i : obufds
			generic map (
				iostandard => "LVDS")
			port map (
				i  => q(i),
				o  => p(i),
				ob => n(i));
		end generate;

	end block;

	eth_rstn <= video_lckd;
	eth_mdc  <= '0';
	eth_mdio <= '0';

end;
