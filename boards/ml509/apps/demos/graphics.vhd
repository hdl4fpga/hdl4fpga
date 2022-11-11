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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of ml509 is

	type app_profiles is (
		sdr200MHz_600p,
		sdr225MHz_600p,
		sdr250MHz_600p,
		sdr275MHz_600p,
		sdr300MHz_600p,
		sdr333MHz_600p,
		sdr350MHz_600p,
		sdr400MHz_600p);

	----------------------------------------------------------
	constant app_profile : app_profiles := sdr333Mhz_600p;  --
	----------------------------------------------------------

	type profileparam_vector is array (app_profiles) of profile_params;
	constant profile_tab : profileparam_vector := (
		sdr200MHz_600p => (io_ipoe, sdram200MHz, mode600p24bpp),
		sdr225MHz_600p => (io_ipoe, sdram225MHz, mode600p24bpp),
		sdr250MHz_600p => (io_ipoe, sdram250MHz, mode600p24bpp),
		sdr275MHz_600p => (io_ipoe, sdram275MHz, mode600p24bpp),
		sdr300MHz_600p => (io_ipoe, sdram300MHz, mode600p24bpp),
		sdr333MHz_600p => (io_ipoe, sdram333MHz, mode600p24bpp),
		sdr350MHz_600p => (io_ipoe, sdram350MHz, mode600p24bpp),
		sdr400MHz_600p => (io_ipoe, sdram400MHz, mode600p24bpp));

	type pll_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type video_params is record
		id     : video_modes;
		pll    : pll_params;
		timing : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		(id => modedebug,     timing => pclk_debug,            pll => (dcm_mul => 4, dcm_div => 2)),
		(id => mode480p24bpp, timing => pclk25_00m640x480at60, pll => (dcm_mul => 1, dcm_div => 4)),
		(id => mode600p24bpp, timing => pclk40_00m800x600at60, pll => (dcm_mul => 2, dcm_div => 5)));

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

	constant video_mode : video_modes := setdebug(debug, profile_tab(app_profile).video_mode);

	type sdramparams_record is record
		id  : sdram_speeds;
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (

		------------------------------------------------------------------------
		-- Frequency   -- 300 Mhz -- 275 Mhz -- 250 Mhz -- 225 Mhz -- 200 Mhz --
		-- Multiply by --   3     --  11     --  15     --   4     --  17     --
		-- Divide by   --   1     --   4     --   4     --   1     --   4     --
		------------------------------------------------------------------------

		(sdram200MHz, pll => (dcm_mul =>  4, dcm_div => 2), cl => "001"),
		(sdram225MHz, pll => (dcm_mul =>  9, dcm_div => 4), cl => "010"),
		(sdram250MHz, pll => (dcm_mul =>  5, dcm_div => 2), cl => "010"),
		(sdram275MHz, pll => (dcm_mul => 11, dcm_div => 4), cl => "010"),
		(sdram300MHz, pll => (dcm_mul =>  3, dcm_div => 1), cl => "101"),

		------------------------------------------------------------------------
		-- Frequency   -- 333 Mhz -- 350 Mhz -- 375 Mhz -- 400 Mhz -- 425 Mhz --
		-- Multiply by --  10     --   7     --  15     --   4     --  17     --
		-- Divide by   --   3     --   2     --   4     --   1     --   4     --
		------------------------------------------------------------------------

		(sdram333MHz, pll => (dcm_mul => 10, dcm_div => 3), cl => "101"),
		(sdram350MHz, pll => (dcm_mul =>  7, dcm_div => 2), cl => "110"),
		(sdram400MHz, pll => (dcm_mul =>  4, dcm_div => 1), cl => "110"));

	function sdramparams (
		constant id  : sdram_speeds)
		return sdramparams_record is
		constant tab : sdramparams_vector := sdram_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>sdramparams<<< : sdram speed not enabled"
		severity failure;

		return tab(tab'left);
	end;

	constant sdram_speed  : sdram_speeds := profile_tab(app_profile).sdram_speed;
	constant sdram_params : sdramparams_record := sdramparams(sdram_speed);
	constant sdram_tcp    : real := (real(sdram_params.pll.dcm_div)*user_per)/real(sdram_params.pll.dcm_mul);

	signal sys_clk        : std_logic;

	signal video_clk      : std_logic;
	signal video_lckd     : std_logic;
	signal videoio_clk    : std_logic;
	signal video_lck      : std_logic;
	signal video_shf_clk  : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_blank    : std_logic;
    signal video_vs       : std_logic;
	signal video_hs       : std_logic;
    signal video_bk       : std_logic;
    signal video_on       : std_logic;
    signal video_dot      : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);
    signal video_spixel   : std_logic_vector(0 to 3-1);
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	alias red             : std_logic is hdr1(0);
	alias green           : std_logic is hdr1(1);
	alias blue            : std_logic is hdr1(2);
	alias vs              : std_logic is hdr1(3);
	alias hs              : std_logic is hdr1(4);

	constant sclk_phases  : natural := 1;
	constant sclk_edges   : natural := 1;
	constant data_edges   : natural := 1;
	constant cmmd_gear    : natural := 2;
	constant data_gear    : natural := 4;
	constant data_phases  : natural := data_gear;

	-- constant sclk_phases  : natural := 4;
	-- constant sclk_edges   : natural := 2;
	-- constant data_edges   : natural := 2;
	-- constant cmmd_gear    : natural := 1;
	-- constant data_gear    : natural := 2;
	-- constant data_phases  : natural := 2;

	constant bank_size    : natural := ddr2_ba'length;
	constant addr_size    : natural := ddr2_a'length;
	constant coln_size    : natural := 7;
	-- constant word_size    : natural := ddr2_d'length;
	-- constant byte_size    : natural := ddr2_d'length/ddr2_dqs_p'length;
	constant word_size    : natural := 8*1;
	constant byte_size    : natural := 8;

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
	signal ctlr_inirdy    : std_logic;
	signal ctlrphy_synced : std_logic;
	signal ctlrphy_ini    : std_logic;
	signal ctlrphy_rw     : std_logic;
	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;
	signal ctlrphy_rlcal  : std_logic;
	signal ctlrphy_rlseq  : std_logic;

	signal ctlr_clks      : std_logic_vector(0 to 2-1);
	alias  ddr_clk0       : std_logic is ctlr_clks(0);
	alias  ddr_clk90      : std_logic is ctlr_clks(1);
	signal ddr_clk0x2     : std_logic;
	signal ddr_clk90x2    : std_logic;
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
	signal ctlrphy_sto    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

	signal ddr2_clk       : std_logic_vector(ddr2_clk_p'range);
	signal ddr2_dqst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqsi      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqo       : std_logic_vector(word_size-1 downto 0);
	signal ddr2_dqt       : std_logic_vector(word_size-1 downto 0);

	signal gtx_clk        : std_logic;
	signal gtx_rst        : std_logic;

	signal sys_rst        : std_logic;
	signal sys_clks       : std_logic_vector(0 to 5-1);
	signal phy_rsts       : std_logic_vector(0 to 3-1);
	signal sdrphy_rst     : std_logic;

	signal iod_rdy        : std_logic;

	signal phy_rxclk_bufg : std_logic;
	signal phy_txclk_bufg : std_logic;

	alias  mii_txc        : std_logic is gtx_clk;
	alias  sio_clk        : std_logic is gtx_clk;
	alias  dmacfg_clk     : std_logic is gtx_clk;

	signal tp_delay       : std_logic_vector(word_size/byte_size*6-1 downto 0);
	signal tp_bit         : std_logic_vector(word_size/byte_size*5-1 downto 0);
	signal tst            : std_logic;
	signal tp_sel         : std_logic_vector(0 to unsigned_num_bits(WORD_SIZE/BYTE_SIZE-1)-1);

	signal ddr_d          : std_logic_vector(word_size-1 downto 0);
	signal ddr_dqst       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso       : std_logic_vector(word_size/byte_size-1 downto 0);

	signal tp             : std_logic_vector(1 to 32);
	signal mii_tp         : std_logic_vector(1 to 32);
	signal ser_clk        : std_logic;
	signal ser_frm        : std_logic;
	signal ser_data       : std_logic_vector(0 to 8-1);

begin

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	-- gpio_led_c <= gpio_sw_c;
	-- (gpio_led_w, gpio_led_n, gpio_led_e, gpio_led_s) <= mii_tp(2 to 5);
	process (gpio_sw_c, sys_clk)
		variable tmr : unsigned(0 to 8-1) := (others => '0');
	begin
		if gpio_sw_c='1' then
			tmr := (others => '0');
		elsif rising_edge(sys_clk) then
			if tmr(0)='0' then
				tmr := tmr + 1;
			end if;
		end if;
		sys_rst <= not tmr(0);
	end process;
	
	iod_b : block
		signal iod_clk  : std_logic;
		signal clk_fpga : std_logic;
	begin

		idelay_ibufg_i : IBUFGDS_LVPECL_25
		port map (
			I  => clk_fpga_p,
			IB => clk_fpga_n,
			O  => clk_fpga);
	
		bufg_i : bufg
		port map (
			i => clk_fpga,
			o => iod_clk);

		idelayctrl_i : idelayctrl
		port map (
			rst    => sys_rst,
			refclk => iod_clk,
			rdy    => iod_rdy);
	
	end block;
	
	ddr_b : block

		signal ddr_clk    : std_logic;
		signal ddr_clk180 : std_logic;
		signal dcm_rst    : std_logic;
		signal locked     : std_logic;
		signal ddr_locked : std_logic;
	begin

		gbx4_g : if data_gear=4 generate 
			signal ddr_clkfb         : std_logic;
			signal ddr_clk0x2_mmce2  : std_logic;
			signal ddr_clk90x2_mmce2 : std_logic;
			signal ddr_clk0_mmce2    : std_logic;
			signal ddr_clk90_mmce2   : std_logic;
		begin
			ddr_i : pll_base
			generic map (
				divclk_divide  => sdram_params.pll.dcm_div,
				clkfbout_mult  => 2*sdram_params.pll.dcm_mul,
				clkin_period   => user_per*1.0e9,
				clkout0_divide => data_gear/2,
				clkout1_divide => data_gear/2,
				clkout1_phase  => 90.0+180.0,
				clkout2_divide => data_gear,
				clkout3_divide => data_gear,
				clkout3_phase  => 90.0/real((data_gear/2))+270.0)
			port map (
				rst      => sys_rst,
				clkin    => sys_clk,
				clkfbin  => ddr_clkfb,
				clkfbout => ddr_clkfb,
				clkout0  => ddr_clk0x2_mmce2,
				clkout1  => ddr_clk90x2_mmce2,
				clkout2  => ddr_clk0_mmce2,
				clkout3  => ddr_clk90_mmce2,
				locked   => ddr_locked);

			ddr_clk0x2_bufg : bufg
			port map (
				i => ddr_clk0x2_mmce2,
				o => ddr_clk0x2);

			ddr_clk90x2_bufg : bufg
			port map (
				i => ddr_clk90x2_mmce2,
				o => ddr_clk90x2);

			ddr_clk0_bufg : bufg
			port map (
				i => ddr_clk0_mmce2,
				o => ddr_clk0);

			ddr_clk90_bufg : bufg
			port map (
				i => ddr_clk90_mmce2,
				o => ddr_clk90);

			ctlrphy_dqsi <= (others => ddr_clk90);

		end generate;

		gbx2_g : if  data_gear=2 generate 

			dfs_b : block
				signal clk_fx    : std_logic;
				signal clk_fx180 : std_logic;
			begin
				dfs_i : dcm_base
				generic map (
					clk_feedback   => "NONE",
					clkin_period   => user_per*1.0e9,
					clkfx_divide   => sdram_params.pll.dcm_div,
					clkfx_multiply => sdram_params.pll.dcm_mul,
					dfs_frequency_mode => "HIGH")
				port map (
					rst      => sys_rst,
					clkfb    => '0',
					clkin    => sys_clk,
					clkfx    => clk_fx,
					clkfx180 => clk_fx180,
					locked   => locked);
	
				bufg0_i : bufg
				port map (
					i => clk_fx,
					o => ddr_clk);
	
				bufg180_i : bufg
				port map (
					i => clk_fx180,
					o => ddr_clk180);
			end block;

			process (ddr_clk0, locked)
				variable cntr : unsigned(0 to 2);
			begin
				if locked='0' then
					cntr := (others => '0');
				elsif rising_edge(ddr_clk0) then
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
					clk_feedback => "1X",
					clkin_period => sdram_tcp*1.0e9,
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

			-- ctlrphy_dqsi <= (others => ddr_clk0); --IDDR
			-- ctlrphy_dqsi <= (others => ddr_clk90);
		end generate;

		process (sys_clk)
			variable tmr : unsigned(0 to 8-1) := (others => '0');
		begin
			if rising_edge(sys_clk) then
				if (not ddr_locked or sys_rst or not iod_rdy)='1' then
					tmr := (others => '0');
				elsif tmr(0)='0' then
					tmr := tmr + 1;
				end if;
			end if;
			ddrsys_rst <= not tmr(0);
		end process;
	
		process (ddr_clk0)
		begin
			if rising_edge(ddr_clk0) then
				if ddrsys_rst='1' then
					sdrphy_rst <= '1';
				else
					sdrphy_rst <= ddrsys_rst;
				end if;
			end if;
		end process;

	end block;

	videodcm_b : block
		signal clk_fx     : std_logic;
		signal video_lckd : std_logic;
	begin
	
		dfs_i : dcm_base
		generic map (
			clk_feedback   => "NONE",
			clkin_period   => user_per*1.0e9,
			clkfx_divide   => videoparam(video_mode).pll.dcm_div,
			clkfx_multiply => videoparam(video_mode).pll.dcm_mul,
			dfs_frequency_mode => "LOW")
		port map (
			rst    => sys_rst,
			clkfb  => '0',
			clkin  => sys_clk,
			clkfx  => clk_fx,
			locked => video_lckd);

		bufg_i : bufg
		port map (
			i => clk_fx,
			o => video_clk);

	end block;

	gtx_b : block
		signal gtx_clk_dcm : std_logic;
		signal gtx_lck : std_logic;
	begin
		gtx_i : dcm_base
		generic map  (
			CLK_FEEDBACK   => "NONE",
			clkin_period   => user_per*1.0e9,
			clkfx_multiply => 5,
			clkfx_divide   => 4)
		port map (
			rst    => sys_rst,
			clkin  => sys_clk,
			clkfb  => '0',
			clkfx  => gtx_clk_dcm, 
			locked => gtx_lck);
			gtx_rst <= not gtx_lck;

		bufg_i : bufg
		port map (
			i => gtx_clk_dcm,
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

		signal mii_rxc    : std_logic;
		alias  mii_rxdv   : std_logic is phy_rxctl_rxdv;
		alias  mii_rxd    : std_logic_vector(phy_rxd'range) is phy_rxd;

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal mii_txen   : std_logic;
		signal mii_txd    : std_logic_vector(mii_rxd'range);
		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

		signal mii_txcrxd : std_logic_vector(mii_rxd'range);

		signal ser_pause : std_logic := '1';
	begin

		mii_rxc  <= gtx_clk; --phy_rxclk_bufg;
		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			rxd_g : for i in mii_rxd'range generate 
				iddr_i : iddr 
				port map (
					c => phy_rxclk_bufg,
					ce => '1',
					q1 => rxc_rxbus(i+1),
					d => phy_rxd(i));
			end generate;

			rxdv_i : iddr 
			port map (
				c  => phy_rxclk,
				ce => '1',
				q1 => rxc_rxbus(0),
				d  => mii_rxdv);

			-- process (mii_rxc)
				-- variable q : std_logic_vector(rxc_rxbus'range);
			-- begin
				-- if rising_edge(mii_rxc) then
					-- rxc_rxbus <= q;
					-- q := mii_rxdv & mii_rxd;
				-- end if;
			-- end process;

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
			type states is (north, south);
			variable state : states;
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					case state is
					when north =>
						if gpio_sw_n='1' then 
							dhcpcd_req <= not dhcpcd_rdy;
							state := south;
						end if;
					when south =>
						if gpio_sw_s='1' then 
							dhcpcd_req <= not dhcpcd_rdy;
							state := north;
						end if;
					end case;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => false,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => mii_tp,

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

		ser_clk  <= gtx_clk;
		ser_frm  <= ('0' or miirx_frm) and ser_pause;
		ser_data <= word2byte(miitx_data & miirx_data, miirx_frm);

		pause_p : process(mii_txc)
			type states is (west, east);
			variable state : states;
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					case state is
					when west =>
						if gpio_sw_w='1' then 
							ser_pause <= '0';
							state := east;
						end if;
					when east =>
						if gpio_sw_e='1' then 
							ser_pause <= '1';
							state := west;
						end if;
					end case;
				end if;
			end if;
		end process;

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
				phy_txctl_txen<= mii_txen;
				phy_txd(mii_rxd'range) <= mii_txd;
			end if;
		end process;

		toggle_b : block
			alias clk_w : std_logic is miirx_frm;
			alias clk_e : std_logic is miitx_frm;
		begin
			process (clk_e)
				variable q : std_logic;
			begin
				if rising_edge(clk_e) then
					-- gpio_led_e <= q;
					q := not q;
				end if;
			end process;
			-- gpio_led_e <= miitx_frm;
	
			process (clk_w)
				variable q : std_logic;
			begin
				if rising_edge(clk_w) then
					-- gpio_led_w <= q;
					q := not q;
				end if;
			end process;
		end block;

		process (phy_rxclk_bufg)
			variable q : std_logic;
		begin
			if rising_edge(phy_rxclk_bufg) then
				-- gpio_led <= (others => '0');
			end if;
		end process;
				gpio_led(0 to 8-1) <= tp(1 to 8);


	end block;

	graphics_e : entity hdl4fpga.demo_graphics
	generic map (
		debug => debug,
		profile      => 1,
		sdram_tcp    => 2.0*sdram_tcp,
		-- sdram_tcp    => sdram_tcp,
		fpga         => xc5v,
		mark         => MT47H512M3,
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
		-- burst_length => 4,
		burst_length => 8,

		timing_id    => videoparam(video_mode).timing,
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

		video_clk     => '0', --video_clk,
		video_shift_clk => '0', --video_shf_clk,
		video_hzsync  => video_hzsync,
		video_vtsync  => video_vtsync,
		video_blank   => video_blank,
		video_pixel   => video_pixel,
		dvid_crgb     => dvid_crgb,

		ctlr_clks     => ctlr_clks(0 to sclk_phases/sclk_edges-1),
		ctlr_rst      => sdrphy_rst, --ddrsys_rst,
		ctlr_cwl      => b"0_11",
		ctlr_rtt      => b"11",
		ctlr_al       => "001",
		-- ctlr_bl       => "010", -- Busrt length 4
		ctlr_bl       => "011", -- Busrt length 8
		ctlr_cl       => sdram_params.cl,
		ctlr_cmd      => ctlrphy_cmd,
		ctlr_inirdy   => ctlr_inirdy,
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
		ctlrphy_odt   => ctlrphy_odt(0),
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

	videoio_b : block
		signal xclk : std_logic;
	begin
		process (video_clk)
		begin
			if rising_edge(video_clk) then
				dvi_de <= not video_blank;
				dvi_h  <= video_hzsync;
				dvi_v  <= video_vtsync;
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
			q  => xclk);
	
		diff_i: obufds
		generic map (
			iostandard => "LVDS_25")
		port map (
			i  => xclk,
			o  => dvi_xclk_p,
			ob => dvi_xclk_n);
	
	
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

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id    => videoparam(mode600p24bpp).timing,
		red_length   => 1,
		green_length => 1,
		blue_length  => 1)
	port map (
		-- ser_clk      => phy_rxclk_bufg,
		-- ser_frm      => mii_tp(1),
		-- ser_data     => phy_rxd,
		ser_clk      => ser_clk,
		ser_frm      => ser_frm,
		ser_data     => ser_data,


		ser_irdy     => '1',

		video_clk    => video_clk,
		video_hzsync => video_hs,
		video_blank  => video_bk,
		video_vtsync => video_vs,
		video_pixel  => video_spixel);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			hs <= video_hs;
			vs <= video_vs;
			(red, green, blue) <= video_spixel;
		end if;
	end process;


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

	ctlrphy_rst(1) <= ctlrphy_rst(0);
	ctlrphy_cke(1) <= ctlrphy_cke(0);
	ctlrphy_cs(1)  <= ctlrphy_cs(0);
	ctlrphy_ras(1) <= '1';
	ctlrphy_cas(1) <= '1';
	ctlrphy_we(1)  <= '1';
	ctlrphy_odt(1) <= ctlrphy_odt(0);

	ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			gpio_led_w <= 'Z'; --ctlrphy_rlreq;
			gpio_led_e <= 'Z'; --ctlrphy_rlrdy;
			gpio_led_n <= 'Z';
			gpio_led_s <= 'Z';
		end if;
	end process;
	
	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		-- dqs_delay   => (0 => 0.954 ns, 1 => 6.954 ns),
		-- dqi_delay   => (0 => 0.937 ns, 1 => 6.937 ns),
		device      => xc5v,
		bufio       => false,
		bypass      => false,
		taps        => natural(floor(sdram_tcp*(64.0*200.0e6)))-1,
		bank_size   => bank_size,
		addr_size   => addr_size,
		cmmd_gear   => cmmd_gear,
		data_gear   => data_gear,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		tp_sel     => gpio_sw_w,
		tp         => tp,
		rst        => sdrphy_rst,
		iod_clk    => sys_clk,
		clk0       => ddr_clk0,
		clk90      => ddr_clk90,
		clk0x2     => ddr_clk0x2,
		clk90x2    => ddr_clk90x2,
		phy_frm    => ctlrphy_frm,
		phy_trdy   => ctlrphy_trdy,
		phy_rw     => ctlrphy_rw,
		phy_ini    => ctlrphy_ini,
		phy_synced => ctlrphy_synced,

		phy_cmd    => ctlrphy_cmd,
		phy_wlreq  => ctlrphy_wlreq,
		phy_wlrdy  => ctlrphy_wlrdy,
		phy_rlreq  => ctlrphy_rlreq,
		phy_rlrdy  => ctlrphy_rlrdy,

		sys_cke    => ctlrphy_cke,
		sys_cs     => ctlrphy_cs,
		sys_ras    => ctlrphy_ras,
		sys_cas    => ctlrphy_cas,
		sys_we     => ctlrphy_we,
		sys_b      => ctlrphy_ba,
		sys_a      => ctlrphy_a,

		sys_dqst   => ctlrphy_dqst,
		sys_dqsi   => ctlrphy_dqso,
		sys_dmi    => ctlrphy_dmo,
		sys_dmt    => ctlrphy_dmt,
		sys_dmo    => ctlrphy_dmi,
		sys_dqi    => ctlrphy_dqo,
		sys_dqt    => ctlrphy_dqt,
		sys_dqo    => ctlrphy_dqi,
		sys_odt    => ctlrphy_odt,
		sys_sti    => ctlrphy_sto,
		sys_sto    => ctlrphy_sti,
		sdram_clk  => ddr2_clk,
		sdram_cke  => ddr2_cke,
		sdram_cs   => ddr2_cs,
		sdram_ras  => ddr2_ras,
		sdram_cas  => ddr2_cas,
		sdram_we   => ddr2_we,
		sdram_b    => ddr2_ba,
		sdram_a    => ddr2_a,
		sdram_odt  => ddr2_odt,

		sdram_dm   => ddr2_dm(word_size/byte_size-1 downto 0),
		sdram_dqo  => ddr2_dqo,
		sdram_dqi  => ddr2_d(word_size-1 downto 0),
		sdram_dqt  => ddr2_dqt,
		sdram_dqst => ddr2_dqst,
		sdram_dqsi => ddr2_dqsi,
		sdram_dqso => ddr2_dqso);

	gpio_led_c <= ctlr_inirdy;

	ddr2_scl   <= '0';

	phy_mdc    <= '0';
	phy_mdio   <= '0';

	phy_txc_gtxclk_i : oddr
	port map (
		c  => gtx_clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => '1',
		d2 => '0',
		q  => phy_txc_gtxclk);
	
	ddrio_b : block
	begin

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

			true_g : if i < word_size/byte_size generate
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

			false_g : if not (i < word_size/byte_size) generate
				dqsiobuf_i : iobufds
				generic map (
					iostandard => "DIFF_SSTL18_II_DCI")
				port map (
					t   => '1',
					i   => '-',
					o   => open,
					io  => ddr2_dqs_p(i),
					iob => ddr2_dqs_n(i));
			end generate;

		end generate;

		ddr_d_g : for i in ddr2_d'range generate
			process (ddr2_dqo, ddr2_dqt)
			begin
				if i < word_size then
					if ddr2_dqt(i)='0' then
						ddr2_d(i) <= ddr2_dqo(i);
					else
						ddr2_d(i) <= 'Z';
					end if;
				else
					ddr2_d(i) <= 'Z';
				end if;
			end process;

		end generate;

	end block;
	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	dvi_gpio1  <= '1';
	dvi_reset_b <= video_lckd;

	bus_error <= (others => '0');
	iic_sda_video <= 'Z';
	iic_scl_video <= 'Z';

end;
