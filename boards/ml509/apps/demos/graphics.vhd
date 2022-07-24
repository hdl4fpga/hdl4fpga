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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_db.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of ml509 is

	type profiles is (
		mode900p_ddr200MHz,
		mode900p_ddr225MHz,
		mode900p_ddr250MHz,
		mode900p_ddr275MHz,
		mode900p_ddr300MHz,
		mode900p_ddr333MHz,
		mode900p_ddr350MHz,
		mode900p_ddr375MHz,
		mode900p_ddr400MHz,
		mode900p_ddr425MHz,
		mode900p_ddr450MHz,
		mode900p_ddr475MHz,
		mode900p_ddr500MHz,
		mode900p_ddr525MHz,
		mode900p_ddr550MHz,
		mode900p_ddr575MHz,
		mode900p_ddr600MHz);

	constant profile : profiles := mode900p_ddr333MHz;

	type pll_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type ddr_params is record
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
	end record;

	type ddr_speeds is (
		ddr200MHz,
		ddr225MHz,
		ddr250MHz,
		ddr275MHz,
		ddr300MHz,
		ddr333MHz,
		ddr350MHz,
		ddr375MHz,
		ddr400MHz,
		ddr425MHz,
		ddr450MHz,
		ddr475MHz,
		ddr500MHz,
		ddr525MHz,
		ddr550MHz,
		ddr575MHz,
		ddr600MHz);

	type ddram_vector is array (ddr_speeds) of ddr_params;

	constant ddr_tab : ddram_vector := (

		------------------------------------------------------------------------
		-- Frequency   -- 300 Mhz -- 275 Mhz -- 250 Mhz -- 225 Mhz -- 200 Mhz --
		-- Multiply by --   3     --  11     --  15     --   4     --  17     --
		-- Divide by   --   1     --   4     --   4     --   1     --   4     --
		------------------------------------------------------------------------

		ddr200MHz => (pll => (dcm_mul =>  2, dcm_div => 1), cl => "001", cwl => "000"),
		ddr225MHz => (pll => (dcm_mul =>  9, dcm_div => 4), cl => "010", cwl => "000"),
		ddr250MHz => (pll => (dcm_mul =>  5, dcm_div => 2), cl => "010", cwl => "000"),
		ddr275MHz => (pll => (dcm_mul => 11, dcm_div => 4), cl => "010", cwl => "000"),
		ddr300MHz => (pll => (dcm_mul =>  3, dcm_div => 1), cl => "011", cwl => "001"),

		------------------------------------------------------------------------
		-- Frequency   -- 333 Mhz -- 350 Mhz -- 375 Mhz -- 400 Mhz -- 425 Mhz --
		-- Multiply by --  10     --   7     --  15     --   4     --  17     --
		-- Divide by   --   3     --   2     --   4     --   1     --   4     --
		------------------------------------------------------------------------

		ddr333MHz => (pll => (dcm_mul => 10, dcm_div => 3), cl => "001", cwl => "000"),
		ddr350MHz => (pll => (dcm_mul =>  7, dcm_div => 2), cl => "010", cwl => "000"),
		ddr375MHz => (pll => (dcm_mul => 15, dcm_div => 4), cl => "010", cwl => "000"),
		ddr400MHz => (pll => (dcm_mul =>  4, dcm_div => 1), cl => "010", cwl => "000"),
		ddr425MHz => (pll => (dcm_mul => 17, dcm_div => 4), cl => "011", cwl => "001"),

		------------------------------------------------------------------------
		-- Frequency   -- 450 Mhz -- 475 Mhz -- 500 Mhz -- 525 Mhz -- 550 Mhz --
		-- Multiply by --   9     --  19     --   5     --  21     --  22     --
		-- Divide by   --   2     --   4     --   1     --   4     --   4     --
		------------------------------------------------------------------------

		ddr450MHz => (pll => (dcm_mul =>  9, dcm_div => 2), cl => "011", cwl => "001"),
		ddr475MHz => (pll => (dcm_mul => 19, dcm_div => 4), cl => "011", cwl => "001"),
		ddr500MHz => (pll => (dcm_mul =>  5, dcm_div => 1), cl => "011", cwl => "001"),
		ddr525MHz => (pll => (dcm_mul => 21, dcm_div => 4), cl => "011", cwl => "001"),
		ddr550MHz => (pll => (dcm_mul => 11, dcm_div => 2), cl => "101", cwl => "010"),  -- latency 9
		
		---------------------------------------
		-- Frequency   -- 575 Mhz -- 600 Mhz --
		-- Multiply by --  23     --   6     --
		-- Divide by   --   4     --   1     --
		---------------------------------------

		ddr575MHz => (pll => (dcm_mul => 23, dcm_div => 4), cl => "101", cwl => "010"),  -- latency 9
		ddr600MHz => (pll => (dcm_mul =>  6, dcm_div => 1), cl => "101", cwl => "010")); -- latency 9

	type video_modes is (
		modedebug,
		mode900p);

	type profile_param is record
		ddr_speed  : ddr_speeds;
		video_mode : video_modes;
		profile    : natural;
	end record;

	type profileparam_vector is array (profiles) of profile_param;
	constant profile_tab : profileparam_vector := (
		mode900p_ddr200MHz => (ddr200MHz, mode900p, 1),
		mode900p_ddr225MHz => (ddr225MHz, mode900p, 1),
		mode900p_ddr250MHz => (ddr250MHz, mode900p, 1),
		mode900p_ddr275MHz => (ddr275MHz, mode900p, 1),
		mode900p_ddr300MHz => (ddr300MHz, mode900p, 1),
		mode900p_ddr333MHz => (ddr333MHz, mode900p, 1),
		mode900p_ddr350MHz => (ddr350MHz, mode900p, 1),
		mode900p_ddr375MHz => (ddr375MHz, mode900p, 1),
		mode900p_ddr400MHz => (ddr400MHz, mode900p, 1),
		mode900p_ddr425MHz => (ddr425MHz, mode900p, 1),
		mode900p_ddr450MHz => (ddr450MHz, mode900p, 1),
		mode900p_ddr475MHz => (ddr475MHz, mode900p, 1),
		mode900p_ddr500MHz => (ddr500MHz, mode900p, 1),
		mode900p_ddr525MHz => (ddr525MHz, mode900p, 1),
		mode900p_ddr550MHz => (ddr550MHz, mode900p, 1),
		mode900p_ddr575MHz => (ddr575MHz, mode900p, 1),
		mode900p_ddr600MHz => (ddr600MHz, mode900p, 1));

	type video_params is record
		pll  : pll_params;
		mode : videotiming_ids;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug => (mode => pclk_debug,              pll => (dcm_mul => 1, dcm_div => 32)),
		mode900p  => (mode => pclk108_00m1600x900at60, pll => (dcm_mul => 1, dcm_div => 11)));

	constant ddr_speed : ddr_speeds := profile_tab(profile).ddr_speed;
	constant ddr_param : ddr_params := ddr_tab(ddr_speed);

	constant sys_per  : real := 10.0e-9;
	constant ddr_tcp   : real := (sys_per*real(ddr_param.pll.dcm_div))/real(ddr_param.pll.dcm_mul); -- 1 ns /1ps

	constant video_mode : video_modes :=profile_tab(profile).video_mode; --'val(
--		setif(debug, video_modes'pos(modedebug), video_modes'pos(profile_tab(profile).video_mode)));
	signal video_clk      : std_logic;
	signal videoio_clk    : std_logic;
	signal video_lck      : std_logic;
	signal video_shf_clk  : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_blank    : std_logic;
    signal video_on       : std_logic;
    signal video_dot      : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);


	constant sclk_phases  : natural := 4;
	constant sclk_edges   : natural := 2;
	constant cmmd_gear    : natural := 1;
	constant data_phases  : natural := 2;
	constant data_edges   : natural := 2;
	constant data_gear    : natural := 2;

	constant bank_size    : natural := ddr2_ba'length;
	constant addr_size    : natural := ddr2_a'length;
	constant coln_size    : natural := 7;
	constant word_size    : natural := ddr2_d'length;
	constant byte_size    : natural := ddr2_d'length/ddr2_dqs_p'length;

	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(0 to 8-1);

	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);

	signal ddrsys_rst     : std_logic;

	signal ctlrphy_frm    : std_logic;
	signal ctlrphy_trdy   : std_logic;
	signal ctlrphy_ini    : std_logic;
	signal ctlrphy_rw     : std_logic;
	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;
	signal ctlrphy_rlcal  : std_logic;
	signal ctlrphy_rlseq  : std_logic;

	signal ddr_clk0  : std_logic;
	signal ddr_clk90 : std_logic;
	signal ddr_ba         : std_logic_vector(ddr2_ba'range);
	signal ddr_a          : std_logic_vector(ddr2_a'range);
	signal ctlrphy_rst    : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cke    : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cs     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_ras    : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cas    : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_we     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_odt    : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cmd    : std_logic_vector(0 to 3-1);
	signal ctlrphy_ba     : std_logic_vector(cmmd_gear*ddr2_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector(cmmd_gear*ddr2_a'length-1 downto 0);
	signal ctlrphy_dqsi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(0 to data_gear*word_size/byte_size-1);
	signal ctlrphy_sti    : std_logic_vector(0 to data_gear*word_size/byte_size-1);

	signal sys_clk        : std_logic;

	signal ddr2_clk       : std_logic_vector(ddr2_clk_p'range);
	signal ddr2_dqst      : std_logic_vector(ddr2_dqs_p'range);
	signal ddr2_dqso      : std_logic_vector(ddr2_dqs_p'range);
	signal ddr2_dqsi      : std_logic_vector(ddr2_dqs_p'range);
	signal ddr2_dqo       : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr2_dqt       : std_logic_vector(WORD_SIZE-1 downto 0);

	signal gtx_clk        : std_logic;
	signal gtx_rst        : std_logic;

	signal sys_rst        : std_logic;
	signal sys_clks       : std_logic_vector(0 to 5-1);
	signal phy_rsts       : std_logic_vector(0 to 3-1);
	signal phy_iodrst     : std_logic;

	signal iod_clk        : std_logic;
	signal iod_rst        : std_logic;

	signal phy_rxclk_bufg : std_logic;
	signal phy_txclk_bufg : std_logic;

	alias  mii_txc        : std_logic is phy_txclk_bufg;
	alias  sio_clk        : std_logic is phy_txclk_bufg;
	alias  dmacfg_clk     : std_logic is phy_txclk_bufg;

	signal tp_delay       : std_logic_vector(WORD_SIZE/BYTE_SIZE*6-1 downto 0);
	signal tp_bit         : std_logic_vector(WORD_SIZE/BYTE_SIZE*5-1 downto 0);
	signal tst            : std_logic;
	signal tp_sel         : std_logic_vector(0 to unsigned_num_bits(WORD_SIZE/BYTE_SIZE-1)-1);

	constant ddr_bytes    : std_logic_vector(ddr2_d'length/BYTE_SIZE-1 downto 0) := (0 => '1', 7 => '1', others => '0');
	signal ddr_cs         : std_logic;
	signal ddr_cke        : std_logic;
	signal ddr_odt        : std_logic;
	signal ddr_d          : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr_dmi        : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dmo        : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dmt        : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dqst       : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dqso       : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);

begin

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	iod_b : block
		signal iod_rdy : std_logic;
	begin

		idelay_ibufg_i : IBUFGDS_LVPECL_25
		port map (
			I  => clk_fpga_p,
			IB => clk_fpga_n,
			O  => iod_clk);
	
		process (gpio_sw_c, iod_clk)
			variable tmr : unsigned(0 to 8-1) := (others => '0');
		begin
			if gpio_sw_c='1' then
				tmr := (others => '0');
			elsif rising_edge(iod_clk) then
				if tmr(0)='0' then
					tmr := tmr + 1;
				end if;
			end if;
			iod_rst <= not tmr(0);
		end process;
	
		idelayctrl_i : idelayctrl
		port map (
			rst    => iod_rst,
			refclk => iod_clk,
			rdy    => iod_rdy);
	
		sys_rst <= not iod_rdy;
	end block;

	dcm_b : block
	begin

		gtx_b : block
			signal gtx_clk_bufg : std_logic;
		begin
			gtx_i : dcm_base
			generic map  (
				CLK_FEEDBACK   => "NONE",
				clkin_period   => sys_per*1.0e9,
				clkfx_multiply => 5,
				clkfx_divide   => 4)
			port map (
				rst    => '0',
				clkin  => sys_clk,
				clkfb  => '0',
				clkfx  => gtx_clk_bufg);

			bufg_i : bufg
			port map (
				i => gtx_clk_bufg,
				o => gtx_clk);

		end block;
	
		ddr_b : block

			signal ddr_clk   : std_logic;
			signal locked    : std_logic;
			signal dcm_rst   : std_logic;
			signal ddr_locked : std_logic;
		begin
			dfs_b : block
				signal ddr_clkfx_bufg : std_logic;
			begin
				dfs_i : dcm_base
				generic map (
					clk_feedback   => "NONE",
					clkin_period   => sys_per*1.0e9,
					clkfx_divide   => ddr_param.pll.dcm_div,
					clkfx_multiply => ddr_param.pll.dcm_mul,
					dfs_frequency_mode => "HIGH")
				port map (
					rst    => '0',
					clkfb  => sys_clk,
					clkin  => sys_clk,
					clkfx  => ddr_clkfx_bufg,
					locked => locked);

				bufg_i : bufg
				port map (
					i => ddr_clkfx_bufg,
					o => ddr_clk);

			end block;

			process (sys_clk, locked)
				variable cntr : unsigned(0 to 2);
			begin
				if locked='0' then
					cntr := (others => '0');
				elsif rising_edge(sys_clk) then
					if cntr(0)='0' then
						cntr := cntr + 1;
					end if;
				end if;
				dcm_rst <= not cntr(0);
			end process;

			dcm_b : block
				signal ddr_clk0_bufg  : std_logic;
				signal ddr_clk90_bufg : std_logic;
			begin
				dcm_i : dcm_base
				generic map (
					clk_feedback       => "NONE",
					clkin_period       => ddr_tcp*1.0e9,
					dll_frequency_mode => "HIGH")
				port map (
					rst    => dcm_rst,
					clkin  => ddr_clk,
					clkfb  => ddr_clk,
					clk0   => ddr_clk0_bufg,
					clk90  => ddr_clk90_bufg,
					locked => ddr_locked);
   
				bufg0_i : bufg
				port map (
					i => ddr_clk0_bufg,
					o => ddr_clk0);

				bufg90_i : bufg
				port map (
					i => ddr_clk90_bufg,
					o => ddr_clk90);

			end block;

			ctlrphy_dqsi <= (others => ddr_clk0);
			ddrsys_rst   <= not ddr_locked or iod_rst;

		end block;

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
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

		signal mii_txcrxd : std_logic_vector(mii_rxd'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
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
					miirx_data <= txc_rxbus(1 to mii_txcrxd'length);
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
			debug         => false,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

			sio_clk    => sio_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => '1', --miirx_irdy,
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
				phy_txctl_txen <= mii_txen;
				phy_txd  <= mii_txd;
			end if;
		end process;

	end block;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		debug => debug,
		profile      => profile_tab(profile).profile,
		ddr_tcp      => natural(ddr_tcp*1.0e12),
		fpga         => virtex5,
		mark         => M3,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		cmmd_gear    => cmmd_gear,
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
		sio_clk       => sio_clk,
		sin_frm       => so_frm,
		sin_irdy      => so_irdy,
		sin_trdy      => so_trdy,
		sin_data      => so_data,
		sout_frm      => si_frm,
		sout_irdy     => si_irdy,
		sout_trdy     => si_trdy,
		sout_end      => si_end,
		sout_data     => si_data,

		video_clk     => video_clk,
		video_shift_clk => video_shf_clk,
		video_pixel   => video_pixel,
		dvid_crgb     => dvid_crgb,

		ctlr_clks(0)  => ddr_clk0,
		ctlr_clks(1)  => ddr_clk90,
		ctlr_rst      => ddrsys_rst,
		ctlr_cwl      => b"0_11",
		ctlr_rtt      => b"0_11",
		ctlr_bl       => "011", --"001",
		ctlr_cl       => "101", --ddr_param.cl,
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
		ctlrphy_b     => ddr_ba,
		ctlrphy_a     => ddr_a,
		ctlrphy_dsi   => ctlrphy_dqsi,
		ctlrphy_dst   => ctlrphy_dqst,
		ctlrphy_dso   => ctlrphy_dqso,
		ctlrphy_dmi   => ctlrphy_dmi,
		ctlrphy_dmt   => ctlrphy_dmt,
		ctlrphy_dmo   => ctlrphy_dmo,
		ctlrphy_dqi   => ctlrphy_dqi,
		ctlrphy_dqt   => ctlrphy_dqt,
		ctlrphy_dqo   => ctlrphy_dqo,
		ctlrphy_sto   => ctlrphy_sto,
		ctlrphy_sti   => ctlrphy_sti,
		tp => open);

	gear_g : for i in 1 to CMMD_GEAR-1 generate
		ctlrphy_cke(i) <= ctlrphy_cke(0);
		ctlrphy_cs(i)  <= ctlrphy_cs(0);
		ctlrphy_ras(i) <= '1';
		ctlrphy_cas(i) <= '1';
		ctlrphy_we(i)  <= '1';
		ctlrphy_odt(i) <= ctlrphy_odt(0);
	end generate;

	process (ddr_ba)
	begin
		for i in ddr_ba'range loop
			for j in 0 to CMMD_GEAR-1 loop
				ctlrphy_ba(i*CMMD_GEAR+j) <= ddr_ba(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to CMMD_GEAR-1 loop
				ctlrphy_a(i*CMMD_GEAR+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	process (sys_rst, sys_clk)
	begin
		if sys_rst='1' then
			phy_iodrst <= '1';
		elsif rising_edge(sys_clk) then
			phy_iodrst <= sys_rst;
		end if;
	end process;

	ddrphy_e : entity hdl4fpga.xc5v_ddrphy
	generic map (
		taps        => natural(floor(ddr_tcp*(64.0*200.0e6)))-1,
		data_edge   => true,
		BANK_SIZE   => BANK_SIZE,
		ADDR_SIZE   => ADDR_SIZE,
		DATA_GEAR   => DATA_GEAR,
		WORD_SIZE   => WORD_SIZE,
		BYTE_SIZE   => BYTE_SIZE)
	port map (
		iod_rst     => phy_iodrst,
		iod_clk     => sys_clk,
		clk0        => ddr_clk0,
		clk90       => ddr_clk90,
		phy_frm     => ctlrphy_frm,
		phy_trdy    => ctlrphy_trdy,
		phy_rw      => ctlrphy_rw,
		phy_ini     => ctlrphy_ini,

		phy_cmd     => ctlrphy_cmd,
		phy_rlreq   => ctlrphy_rlreq,
		phy_rlrdy   => ctlrphy_rlrdy,

		sys_cke     => ctlrphy_cke,
		sys_cs      => ctlrphy_cs,
		sys_ras     => ctlrphy_ras,
		sys_cas     => ctlrphy_cas,
		sys_we      => ctlrphy_we,
		sys_b       => ctlrphy_ba,
		sys_a       => ctlrphy_a,

		sys_dqst    => ctlrphy_dqst,
		sys_dqsi    => ctlrphy_dqso,
		sys_dqso    => ctlrphy_dqsi,
		sys_dmi     => ctlrphy_dmo,
		sys_dmt     => ctlrphy_dmt,
		sys_dmo     => ctlrphy_dmi,
		sys_dqi     => ctlrphy_dqo,
		sys_dqt     => ctlrphy_dqt,
		sys_dqo     => ctlrphy_dqi,
		sys_odt     => ctlrphy_odt,
		sys_sti     => ctlrphy_sto,
		sys_sto     => ctlrphy_sti,
		ddr_clk     => ddr2_clk,
		ddr_cke     => ddr_cke,
		ddr_cs      => ddr_cs,
		ddr_ras     => ddr2_ras,
		ddr_cas     => ddr2_cas,
		ddr_we      => ddr2_we,
		ddr_b       => ddr2_ba,
		ddr_a       => ddr2_a,
		ddr_odt     => ddr_odt,

		ddr_dmt     => ddr_dmt,
		ddr_dmi     => ddr_dmi,
		ddr_dmo     => ddr_dmo,
		ddr_dqo     => ddr2_dqo,
		ddr_dqi     => ddr2_d,
		ddr_dqt     => ddr2_dqt,
		ddr_dqst    => ddr2_dqst,
		ddr_dqsi    => ddr2_dqsi,
		ddr_dqso    => ddr2_dqso);

	ddr2_cs  <= (others => ddr_cs);
	ddr2_cke <= (others => ddr_cke);
	ddr2_odt <= (others => ddr_odt);

	phy_mdc  <= '0';
	phy_mdio <= '0';

	phy_txc_gtxclk_i : oddr
	port map (
		c => gtx_clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => '0',
		d2 => '1',
		q  => phy_txc_gtxclk);
	
	ddriob_b : block
	begin

--		ddr2_scl <= '0';
		ddr_clks_g : for i in ddr2_clk'range generate
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
			ddr2_dm(i) <= '0'; --ddr_dmo(i) when ddr_dmt(i)='0' else 'Z';

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

		ddr_d_g : for i in ddr2_d'range generate
			ddr2_d(i) <= ddr2_dqo(i) when ddr2_dqt(i)='0' else 'Z';
		end generate;

	end block;
	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	dvi_gpio1  <= '1';
	dvi_reset  <= '0';
	dvi_xclk_p <= 'Z';
	dvi_xclk_n <= 'Z';
	dvi_v      <= 'Z';
	dvi_h      <= 'Z';
	dvi_de     <= 'Z';
	dvi_d      <= (others => 'Z');

	gpio_led <= (others => '0');
	bus_error <= (others => 'Z');
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';

end;
