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
		sdr375MHz_600p,
		sdr400MHz_600p);

	--------------------------------------
	--     Set your profile here        --
	constant app_profile : app_profiles := sdr400MHz_600p;  --
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
		sdr375MHz_600p => (io_ipoe, sdram375MHz, mode600p24bpp),
		sdr400MHz_600p => (io_ipoe, sdram400MHz, mode600p24bpp));

	type dcm_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type video_params is record
		id     : video_modes;
		dcm    : dcm_params;
		timing : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		(id => modedebug,     timing => pclk_debug,            dcm => (dcm_mul => 4, dcm_div => 2)),
		(id => mode480p24bpp, timing => pclk25_00m640x480at60, dcm => (dcm_mul => 1, dcm_div => 4)),
		(id => mode600p24bpp, timing => pclk40_00m800x600at60, dcm => (dcm_mul => 2, dcm_div => 5)));

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

	type pll_params is record
		clkfbout_mult : natural;
		divclk_divide : natural;
	end record;

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

		(sdram200MHz, pll => (clkfbout_mult =>  4, divclk_divide => 2), cl => "011"),
		(sdram225MHz, pll => (clkfbout_mult =>  9, divclk_divide => 4), cl => "011"),
		(sdram250MHz, pll => (clkfbout_mult =>  5, divclk_divide => 2), cl => "011"),
		(sdram275MHz, pll => (clkfbout_mult => 11, divclk_divide => 4), cl => "011"),
		(sdram300MHz, pll => (clkfbout_mult =>  3, divclk_divide => 1), cl => "111"),

		------------------------------------------------------------------------
		-- Frequency   -- 333 Mhz -- 350 Mhz -- 375 Mhz -- 400 Mhz -- 425 Mhz --
		-- Multiply by --  10     --   7     --  15     --   4     --  17     --
		-- Divide by   --   3     --   2     --   4     --   1     --   4     --
		------------------------------------------------------------------------

		(sdram333MHz, pll => (clkfbout_mult => 10, divclk_divide => 3), cl => "111"),
		(sdram350MHz, pll => (clkfbout_mult =>  7, divclk_divide => 2), cl => "101"),
		(sdram375MHz, pll => (clkfbout_mult => 15, divclk_divide => 4), cl => "110"),
		(sdram400MHz, pll => (clkfbout_mult =>  4, divclk_divide => 1), cl => "110"));

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
	constant sdram_tcp    : real := (real(sdram_params.pll.divclk_divide)*userclk_per)/real(sdram_params.pll.clkfbout_mult);

	constant bank_size    : natural := ddr2_ba'length;
	constant addr_size    : natural := ddr2_a'length;
	constant word_size    : natural := ddr2_d'length;
	constant byte_size    : natural := ddr2_d'length/ddr2_dm'length;
	-- constant bank_size    : natural := 2;
	-- constant addr_size    : natural := 13;
	-- constant word_size    : natural := byte_size*8;
	constant coln_size    : natural := 10;
	constant gear         : natural := 4;

	signal ddr_clk0       : std_logic;
	signal ddr_clk90      : std_logic;
	signal ddr_clk0x2     : std_logic;
	signal ddr_clk90x2    : std_logic;
	signal sdrsys_rst     : std_logic;

	signal ctlrphy_frm    : std_logic;
	signal ctlrphy_trdy   : std_logic;
	signal ctlrphy_locked : std_logic;
	signal ctlrphy_ini    : std_logic;
	signal ctlrphy_rw     : std_logic;

	signal ddr_b          : std_logic_vector(bank_size-1 downto 0);
	signal ddr_a          : std_logic_vector(addr_size-1 downto 0);

	signal ctlrphy_rst    : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_cke    : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_cs     : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_ras    : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_cas    : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_we     : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_odt    : std_logic_vector(0 to gear/2-1);
	signal ctlrphy_cmd    : std_logic_vector(0 to 3-1);
	signal ctlrphy_b      : std_logic_vector(gear/2*ddr_b'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector(gear/2*ddr_a'length-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqv    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(gear*word_size/byte_size-1 downto 0);

	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;

	signal ddr2_clk       : std_logic_vector(ddr2_clk_p'range);
	signal ddr2_dqst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqsi      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqo       : std_logic_vector(word_size-1 downto 0);
	signal ddr2_dqt       : std_logic_vector(word_size-1 downto 0);

	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_trdy        : std_logic;
	signal si_end         : std_logic;
	signal si_data        : std_logic_vector(0 to 8-1);
	signal so_frm         : std_logic;
	signal so_irdy        : std_logic;
	signal so_trdy        : std_logic;
	signal so_data        : std_logic_vector(0 to 8-1);

	signal video_clk      : std_logic;
	signal video_lckd     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
    signal video_blank    : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);
	signal videoio_clk    : std_logic;

	signal dd_hs          : std_logic;
	signal dd_vs          : std_logic;
	signal dd_pixel       : std_logic_vector(0 to 3-1);

	alias red             : std_logic is hdr1(0);
	alias green           : std_logic is hdr1(1);
	alias blue            : std_logic is hdr1(2);
	alias vs              : std_logic is hdr1(3);
	alias hs              : std_logic is hdr1(4);

	signal sys_rst        : std_logic;
	signal sdrphy_rst0    : std_logic;
	signal sdrphy_rst90   : std_logic;
	alias  iodctrl_rst    : std_logic is sys_rst;
	signal iodctrl_clk    : std_logic;
	signal iodctrl_rdy    : std_logic;

	signal gtx_rst        : std_logic;
	signal gtx_clk        : std_logic;

	alias  mii_txc        : std_logic is gtx_clk;
	alias  sio_clk        : std_logic is gtx_clk;
	alias  dmacfg_clk     : std_logic is gtx_clk;

	signal userclk_bufg   : std_logic;
	signal phyrxclk_bufg  : std_logic;
	signal phytxclk_bufg  : std_logic;

	signal tp_sel         : std_logic_vector(1 downto 0);
	signal tp_sdrphy      : std_logic_vector(1 to 32);
	signal mii_tp         : std_logic_vector(1 to 32);

begin

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => userclk_bufg);

	process (userclk_bufg)
		variable tmr : unsigned(0 to 8-1) := (others => '0');
	begin
		if rising_edge(userclk_bufg) then
			if tmr(0)='0' then
				tmr := tmr + 1;
			end if;
		end if;
		sys_rst <= not tmr(0);
	end process;
	
	videodcm_b : block
		signal clkfx      : std_logic;
		signal video_lckd : std_logic;
	begin
	
		dcm_i : dcm_base
		generic map (
			clk_feedback   => "NONE",
			clkin_period   => userclk_per*1.0e9,
			clkfx_divide   => videoparam(video_mode).dcm.dcm_div,
			clkfx_multiply => videoparam(video_mode).dcm.dcm_mul,
			dfs_frequency_mode => "LOW")
		port map (
			rst    => sys_rst,
			clkfb  => '0',
			clkin  => userclk_bufg,
			clkfx  => clkfx,
			locked => video_lckd);

		bufg_i : bufg
		port map (
			i => clkfx,
			o => video_clk);

	end block;

	iodctrl_b : block
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
			o => iodctrl_clk);
	end block;

	
	sdrampll_b : block

		signal ddr_clk0_mmce2    : std_logic;
		signal ddr_clk90_mmce2   : std_logic;
		signal ddr_clk0x2_mmce2  : std_logic;
		signal ddr_clk90x2_mmce2 : std_logic;
		signal ddr_clkfb         : std_logic;
		signal ddr_locked : std_logic;

	begin

		pll_i : pll_base
		generic map (
			divclk_divide  => sdram_params.pll.divclk_divide,
			clkfbout_mult  => 2*sdram_params.pll.clkfbout_mult,
			clkin_period   => userclk_per*1.0e9,
			clkout0_divide => gear/2,
			clkout1_divide => gear/2,
			clkout1_phase  => 90.0+180.0,
			clkout2_divide => gear,
			clkout3_divide => gear,
			clkout3_phase  => 90.0/real((gear/2))+270.0)
		port map (
			rst      => sys_rst,
			clkin    => userclk_bufg,
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

    	process (userclk_bufg)
    		variable tmr : unsigned(0 to 8-1) := (others => '0');
    	begin
    		if rising_edge(userclk_bufg) then
    			if (gpio_sw_c or not ddr_locked or sys_rst or not iodctrl_rdy)='1' then
    				tmr := (others => '0');
    			elsif tmr(0)='0' then
    				tmr := tmr + 1;
    			end if;
    		end if;
    		sdrsys_rst <= not tmr(0);
    	end process;
	
		process (ddr_clk0)
		begin
			if rising_edge(ddr_clk0) then
				if sdrsys_rst='1' then
					sdrphy_rst0 <= '1';
				else
					sdrphy_rst0 <= sdrsys_rst;
				end if;
			end if;
		end process;

		process (ddr_clk90)
		begin
			if rising_edge(ddr_clk90) then
				if sdrsys_rst='1' then
					sdrphy_rst90 <= '1';
				else
					sdrphy_rst90 <= sdrsys_rst;
				end if;
			end if;
		end process;

	end block;

	gtx_b : block
		signal clkfx  : std_logic;
		signal locked : std_logic;
	begin
		gtx_i : dcm_base
		generic map  (
			CLK_FEEDBACK   => "NONE",
			clkin_period   => userclk_per*1.0e9,
			clkfx_multiply => 5,
			clkfx_divide   => 4)
		port map (
			rst    => sys_rst,
			clkin  => userclk_bufg,
			clkfb  => '0',
			clkfx  => clkfx, 
			locked => locked);

		gtx_rst <= not locked;
		bufg_i : bufg
		port map (
			i => clkfx,
			o => gtx_clk);

	end block;

	phy_rxclk_bufg_i : bufg
	port map (
		i => phy_rxclk,
		o => phyrxclk_bufg);

	phy_txclk_bufg_i : bufg
	port map (
		i => phy_txclk,
		o => phytxclk_bufg);

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

	begin

		mii_rxc  <= gtx_clk;
		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			rxd_g : for i in mii_rxd'range generate 
				iddr_i : iddr 
				port map (
					c  => phyrxclk_bufg,
					ce => '1',
					d  => phy_rxd(i),
					q1 => rxc_rxbus(i+1));
			end generate;

			rxdv_i : iddr 
			port map (
				c  => phy_rxclk,
				ce => '1',
				d  => mii_rxdv,
				q1 => rxc_rxbus(0));

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
			type states is (s_request, s_wait);
			variable state : states;
		begin
			if rising_edge(mii_txc) then
				case state is
				when s_request =>
					if gpio_sw_n='1' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if gpio_sw_n='0' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => false,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => mii_tp,

			mii_clk    => sio_clk,
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

			so_clk     => sio_clk,
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
				phy_txctl_txen<= mii_txen;
				phy_txd(mii_rxd'range) <= mii_txd;
			end if;
		end process;

	end block;

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,
		gear         => gear,

		ena_burstref => false,
		debug => debug,
		profile      => 1,
		sdram_tcp    => 2.0*sdram_tcp,
		mark         => MT47H512M3,
		burst_length => 8,

		phy_latencies => xc5vg4_latencies,
		timing_id    => videoparam(video_mode).timing,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8,

		fifo_size    => 8*2048)

	port map (
		sin_clk       => sio_clk,
		sin_frm       => so_frm,
		sin_irdy      => so_irdy,
		sin_trdy      => so_trdy,
		sin_data      => so_data,
		sout_clk      => sio_clk,
		sout_frm      => si_frm,
		sout_irdy     => si_irdy,
		sout_trdy     => si_trdy,
		sout_end      => si_end,
		sout_data     => si_data,

		video_clk     => video_clk,
		video_shift_clk => video_shift_clk,
		video_hzsync  => video_hs,
		video_vtsync  => video_vs,
		video_blank   => video_blank,
		video_pixel   => video_pixel,
		dvid_crgb     => dvid_crgb,

		ctlr_clk      => ddr_clk0,
		ctlr_rst      => sdrphy_rst0,
		ctlr_rtt      => "11-",
		ctlr_al       => "000",
		ctlr_bl       => "011", -- Busrt length 8
		ctlr_cl       => sdram_params.cl,
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
		ctlrphy_odt   => ctlrphy_odt(0),
		ctlrphy_b     => ddr_b,
		ctlrphy_a     => ddr_a,
		ctlrphy_dqst  => ctlrphy_dqst,
		ctlrphy_dqso  => ctlrphy_dqso,
		ctlrphy_dmi   => ctlrphy_dmi,
		ctlrphy_dmo   => ctlrphy_dmo,
		ctlrphy_dqi   => ctlrphy_dqi,
		ctlrphy_dqt   => ctlrphy_dqt,
		ctlrphy_dqo   => ctlrphy_dqo,
		ctlrphy_sto   => ctlrphy_sto,
		ctlrphy_sti   => ctlrphy_sti,
		ctlrphy_dqv   => ctlrphy_dqv,
		tp            => open);

	cgear_g : for i in 1 to gear/2-1 generate
		ctlrphy_rst(i) <= ctlrphy_rst(0);
		ctlrphy_cke(i) <= ctlrphy_cke(0);
		ctlrphy_cs(i)  <= ctlrphy_cs(0);
		ctlrphy_ras(i) <= '1';
		ctlrphy_cas(i) <= '1';
		ctlrphy_we(i)  <= '1';
		ctlrphy_odt(i) <= ctlrphy_odt(0);
	end generate;

	process (ddr_b)
	begin
		for i in ddr_b'range loop
			for j in 0 to gear/2-1 loop
				ctlrphy_b(i*gear/2+j) <= ddr_b(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to gear/2-1 loop
				ctlrphy_a(i*gear/2+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
	tp_sel <= ('0', gpio_sw_s);

	idelayctrl_i : idelayctrl
	port map (
		rst    => iodctrl_rst,
		refclk => iodctrl_clk,
		rdy    => iodctrl_rdy);
	
	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		bank_size  => bank_size,
		addr_size  => addr_size,
		word_size  => word_size,
		byte_size  => byte_size,
		gear       => gear,
		ba_latency => 1,
		device     => xc5v,
		loopback   => false,
		bypass     => false,
		taps       => natural(floor(sdram_tcp*(64.0*200.0e6)))-1,
		dqs_highz  => false)
	port map (
		tp_sel     => tp_sel,
		tp         => tp_sdrphy,
		rst        => sdrphy_rst0,
		rst_shift  => sdrphy_rst90,
		iod_clk    => userclk_bufg,
		clk        => ddr_clk0,
		clk_shift  => ddr_clk90,
		clkx2      => ddr_clk0x2,
		clkx2_shift => ddr_clk90x2,
		phy_frm    => ctlrphy_frm,
		phy_trdy   => ctlrphy_trdy,
		phy_rw     => ctlrphy_rw,
		phy_ini    => ctlrphy_ini,
		phy_locked => ctlrphy_locked,

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
		sys_b      => ctlrphy_b,
		sys_a      => ctlrphy_a,

		sys_dqst   => ctlrphy_dqst,
		sys_dqsi   => ctlrphy_dqso,
		sys_dmi    => ctlrphy_dmo,
		sys_dmo    => ctlrphy_dmi,
		sys_dqi    => ctlrphy_dqo,
		sys_dqt    => ctlrphy_dqt,
		sys_dqo    => ctlrphy_dqi,
		sys_odt    => ctlrphy_odt,
		sys_dqv    => ctlrphy_dqv,
		sys_sti    => ctlrphy_sto,
		sys_sto    => ctlrphy_sti,
		sdram_clk  => ddr2_clk,
		sdram_cke  => ddr2_cke,
		sdram_cs   => ddr2_cs,
		sdram_ras  => ddr2_ras,
		sdram_cas  => ddr2_cas,
		sdram_we   => ddr2_we,
		sdram_b    => ddr2_ba(bank_size-1 downto 0),
		sdram_a    => ddr2_a(addr_size-1 downto 0),
		sdram_odt  => ddr2_odt,

		sdram_dm   => ddr2_dm(word_size/byte_size-1 downto 0),
		sdram_dq   => ddr2_d(word_size-1 downto 0),
		sdram_dqst => ddr2_dqst,
		sdram_dqs  => ddr2_dqsi,
		sdram_dqso => ddr2_dqso);

	dviio_b : block
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
			q  => xclk);
	
		diff_i: obufds
		generic map (
			iostandard => "LVDS_25")
		port map (
			i  => xclk,
			o  => dvi_xclk_p,
			ob => dvi_xclk_n);
	
	
		d_g : for i in dvi_d'range generate
			oddr_i : oddr
			port map (
				c => video_clk,
				ce => '1',
				s  => '0',
				r  => '0',
				d1 => video_pixel(i),
				d2 => video_pixel(i+dvi_d'length),
				q  => dvi_d(i));
		end generate;

		dvi_reset_b <= video_lckd;
	end block;

	ddrio_b : block
	begin

		ddr2_ba(ddr2_ba'left downto bank_size) <= (others => '0');
		ddr2_a(ddr2_a'left downto addr_size)   <= (others => '0');

		ddr_clk_g : for i in ddr2_clk'range generate
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

		ddr2_d(ddr2_d'left downto word_size) <= (others => 'Z');

	end block;

	serdebug_b : block
		signal ser_irdy : std_logic;
	begin
		ser_irdy <= si_irdy and si_trdy and not si_end;
		serdebug_e : entity hdl4fpga.ser_debug
    	generic map (
    		timing_id    => videoparam(mode600p24bpp).timing,
    		red_length   => 1,
    		green_length => 1,
    		blue_length  => 1)
    	port map (
    		ser_clk      => sio_clk,
    		ser_frm      => si_frm,
			ser_irdy     => ser_irdy,
    		ser_data     => si_data,

    		video_clk    => video_clk,
    		video_hzsync => dd_hs,
    		video_vtsync => dd_vs,
    		video_pixel  => dd_pixel);

    	process (video_clk)
    	begin
    		if rising_edge(video_clk) then
    			hs <= dd_hs;
    			vs <= dd_vs;
    			(red, green, blue) <= dd_pixel;
    		end if;
    	end process;
	end block;

	phy_txc_gtxclk_i : oddr
	port map (
		c  => gtx_clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => '1',
		d2 => '0',
		q  => phy_txc_gtxclk);
	
	process (userclk_bufg)
	begin
		if rising_edge(userclk_bufg) then
			gpio_led <= tp_sdrphy(1 to 8);
		end if;
	end process;

	gpio_led_c <= ctlrphy_locked;


	(gpio_led_w, gpio_led_n, gpio_led_e, gpio_led_s) <= std_logic_vector'(1 to 4 => '0');

	phy_mdc    <= '0';
	phy_mdio   <= '0';

	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	dvi_gpio1  <= '1';
	ddr2_scl   <= '0';

	bus_error <= (others => '0');
	iic_sda_video <= 'Z';
	iic_scl_video <= 'Z';

end;