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
use hdl4fpga.videopkg.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of nuhs3adsp is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --  20     --  25     --  10     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------

	constant sys_per      : real    := 50.0;
	constant ddr_mul      : natural := 10; --25; --(10/1) 200 (25/3) 166, (20/3) 133
	constant ddr_div      : natural := 1; --3;

	constant fpga         : natural := spartan3;
	constant mark         : natural := m6t;
	constant tcp          : natural := (natural(sys_per)*ddr_div*1000)/(ddr_mul); -- 1 ns /1ps


	constant sclk_phases  : natural := 4;
	constant sclk_edges   : natural := 2;
	constant cmmd_gear    : natural := 1;
	constant data_phases  : natural := 2;
	constant data_edges   : natural := 2;
	constant bank_size    : natural := ddr_ba'length;
	constant addr_size    : natural := ddr_a'length;
	constant coln_size    : natural := 10;
	constant data_gear    : natural := 2;
	constant word_size    : natural := ddr_dq'length;
	constant byte_size    : natural := 8;

	signal ddrsys_lckd    : std_logic;
	signal ddrsys_rst     : std_logic;

	constant clk0         : natural := 0;
	constant clk90        : natural := 1;
	signal ddrsys_clks    : std_logic_vector(0 to 2-1);

	signal dmactlr_len    : std_logic_vector(25-1 downto 2);
	signal dmactlr_addr   : std_logic_vector(25-1 downto 2);

	signal dmacfgio_req   : std_logic;
	signal dmacfgio_rdy   : std_logic;
	signal dmaio_req      : std_logic := '0';
	signal dmaio_rdy      : std_logic;
	signal dmaio_len      : std_logic_vector(dmactlr_len'range);
	signal dmaio_addr     : std_logic_vector(dmactlr_addr'range);
	signal dmaio_dv       : std_logic;

	signal ctlr_irdy      : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_act       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_r         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_dm        : std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv     : std_logic;
	signal ctlr_di_req    : std_logic;
	signal ctlr_dio_req   : std_logic;

	signal ddrphy_rst     : std_logic;
	signal ddrphy_cke     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cs      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_ras     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cas     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_we      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_odt     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_b       : std_logic_vector(cmmd_gear*ddr_ba'length-1 downto 0);
	signal ddrphy_a       : std_logic_vector(cmmd_gear*ddr_a'length-1 downto 0);
	signal ddrphy_dqsi    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqst    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqso    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmi     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmo     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqi     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ddrphy_dqt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqo     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ddrphy_sto     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_sti     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddr_st_dqs_open : std_logic;

	signal ddr_clk        : std_logic_vector(0 downto 0);
	signal ddr_dqst       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt        : std_logic_vector(ddr_dq'range);
	signal ddr_dqo        : std_logic_vector(ddr_dq'range);

	signal mii_clk        : std_logic;
	signal video_clk      : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_hzon     : std_logic;
    signal video_vton     : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);
    signal base_addr      : std_logic_vector(dmactlr_addr'range);

	signal dmacfgvideo_req : std_logic;
	signal dmacfgvideo_rdy : std_logic;
	signal dmavideo_req   : std_logic;
	signal dmavideo_rdy   : std_logic;
	signal dmavideo_len   : std_logic_vector(dmactlr_len'range);
	signal dmavideo_addr  : std_logic_vector(dmactlr_addr'range);

	signal dmacfg_req     : std_logic_vector(0 to 2-1);
	signal dmacfg_rdy     : std_logic_vector(0 to 2-1); 
	signal dev_len        : std_logic_vector(0 to 2*dmactlr_len'length-1);
	signal dev_addr       : std_logic_vector(0 to 2*dmactlr_addr'length-1);
	signal dev_we         : std_logic_vector(0 to 2-1);

	signal dev_req : std_logic_vector(0 to 2-1);
	signal dev_rdy : std_logic_vector(0 to 2-1); 

	signal ctlr_ras : std_logic;
	signal ctlr_cas : std_logic;

	type display_param is record
		mode    : videotiming_ids;
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type video_modes is (
		modedebug,
		mode480p,
		mode600p,
		mode900p,
		mode1080p);

	type displayparam_vector is array (video_modes) of display_param;
	constant video_tab : displayparam_vector := (
		modedebug   => (mode => pclk_debug, dcm_mul => 4, dcm_div => 2),
		mode480p    => (mode => pclk25_00m640x480at60,    dcm_mul => 5, dcm_div => 4),
		mode600p    => (mode => pclk40_00m800x600at60,    dcm_mul => 2, dcm_div => 1),
		mode900p    => (mode => pclk100_00m1600x900at60,  dcm_mul => 5, dcm_div => 1),
		mode1080p   => (mode => pclk140_00m1920x1080at60, dcm_mul => 7, dcm_div => 1));

	function setif (
		constant expr  : boolean; 
		constant true  : video_modes;
		constant false : video_modes)
		return video_modes is
	begin
		if expr then
			return true;
		end if;
		return false;
	end;

	constant video_mode : video_modes := setif(debug, modedebug, mode1080p);

	alias dmacfg_clk : std_logic is sys_clk;
	alias ctlr_clk : std_logic is ddrsys_clks(clk0);

	constant uart_xtal : natural := natural(5.0*10.0**9/real(sys_per*4.0));
	alias sio_clk : std_logic is mii_txc;

	constant baudrate  : natural := 1000000;
--	constant baudrate  : natural := 115200;

begin

	sys_rst <= not hd_t_clock;
	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 50.0,
		dfs_mul => video_tab(video_mode).dcm_mul,
		dfs_div => video_tab(video_mode).dcm_div)
	port map(
		dcm_rst => sys_rst,
		dcm_clk => sys_clk,
		dfs_clk => video_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_clk);

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst   => sys_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => ctlr_clk,
		dfsdcm_clk90 => ddrsys_clks(clk90),
		dfsdcm_lckd  => ddrsys_lckd);
	ddrsys_rst <= not ddrsys_lckd;

	si_b : block

		signal rgtr_id     : std_logic_vector(8-1 downto 0);
		signal rgtr_dv     : std_logic;
		signal rgtr_data   : std_logic_vector(32-1 downto 0);

		signal data_ena    : std_logic;
		signal data_ptr    : std_logic_vector(8-1 downto 0);
		signal dmadata_ena : std_logic;
		signal fifo_rst    : std_logic;
		signal src_frm     : std_logic;

		signal so_frm      : std_logic;
		signal so_irdy     : std_logic;
		signal so_data     : std_logic_vector(8-1 downto 0); --mii_rxd'range);
		signal no_sidata   : std_logic_vector(8-1 downto 0); --mii_rxd'range);

		signal ipv4acfg_req : std_logic;

		constant rid_dmaaddr  : std_logic_vector := x"16";
		constant rid_dmalen   : std_logic_vector := x"17";
		constant rid_dmadata  : std_logic_vector := x"18";

	begin

		no_sidata <= reverse(so_data,8);
		ipv4acfg_req <= not sw1;
		udpdaisy_e : entity hdl4fpga.sio_dayudp
		port map (
			ipv4acfg_req => ipv4acfg_req,

			phy_rxc   => mii_rxc,
			phy_rx_dv => mii_rxdv,
			phy_rx_d  => mii_rxd,

			phy_txc   => mii_txc,
			phy_tx_en => mii_txen,
			phy_tx_d  => mii_txd,
		
			sio_clk   => sio_clk,
			si_data   => no_sidata,

			so_frm  => so_frm,
			so_irdy => so_irdy,
			so_data => so_data);
	
		siosin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => so_frm,
			sin_irdy  => so_irdy,
			sin_data  => so_data,
			data_ptr  => data_ptr,
			data_ena  => data_ena,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		dmaaddr_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => rid_dmaaddr)
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => fifo_rst,
			data      => dmaio_addr);

		dmalen_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => rid_dmalen)
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmaio_dv,
			data      => dmaio_len);

		base_addr_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => x"19")
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			data      => base_addr);

		dmadata_ena <= data_ena and setif(rgtr_id=rid_dmadata) and setif(data_ptr(2-1 downto 0)=(2-1 downto 0 => '0'));

		src_frm <= not fifo_rst;
		dmadata_e : entity hdl4fpga.fifo
		generic map (
			mem_size  => (8*2048)/ctlr_di'length,
			gray_code => false)
		port map (
			src_clk  => sio_clk,
			src_frm  => src_frm,
			src_irdy => dmadata_ena,
			src_data => rgtr_data,

			dst_clk  => ctlr_clk,
			dst_irdy => ctlr_di_dv,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

		dmacfgio_p : process (sio_clk)
			variable io_rdy : std_logic;
		begin
			if rising_edge(sio_clk) then
				if ctlr_inirdy='0' then
					dmacfgio_req <= '0';
				elsif dmacfgio_req='0' then
					if dmaio_dv='1' then
						dmacfgio_req <= '1';
					end if;
				elsif io_rdy='1' then
					dmacfgio_req <= '0';
				end if;
				io_rdy := dmaio_rdy;
			end if;
		end process;
	end block;

	adapter_b : block
		constant mode : videotiming_ids := video_tab(video_mode).mode;
		signal hzcntr : std_logic_vector(unsigned_num_bits(modeline_tab(mode)(3)-1)-1 downto 0);
		signal vtcntr : std_logic_vector(unsigned_num_bits(modeline_tab(mode)(7)-1)-1 downto 0);
		signal hzsync : std_logic;
		signal vtsync : std_logic;
		signal hzon   : std_logic;
		signal vton   : std_logic;

		signal graphics_di : std_logic_vector(ctlr_do'range);
		signal graphics_dv : std_logic;
		signal pixel  : std_logic_vector(video_pixel'range);
	begin
		sync_e : entity hdl4fpga.video_sync
		generic map (
			timing_id => mode)
		port map (
			video_clk     => video_clk,
			video_hzcntr  => hzcntr,
			video_vtcntr  => vtcntr,
			video_hzsync  => hzsync,
			video_vtsync  => vtsync,
			video_hzon    => hzon,
			video_vton    => vton);

		tographics_e : entity hdl4fpga.align
		generic map (
			n => ctlr_do'length+1,
			d => (0 to ctlr_do'length => 1))
		port map (
			clk => ctlr_clk,
			di(0 to ctlr_do'length-1) => ctlr_do,
			di(ctlr_do'length)        => ctlr_do_dv(0),
			do(0 to ctlr_do'length-1) => graphics_di,
			do(ctlr_do'length)        => graphics_dv);

		graphics_e : entity hdl4fpga.graphics
		generic map (
			video_width => modeline_tab(video_tab(video_mode).mode)(0))
		port map (
			ctlr_clk    => ctlr_clk,
			ctlr_di_dv  => graphics_dv,
			ctlr_di     => graphics_di,
			base_addr   => base_addr,
			dma_req     => dmacfgvideo_req,
			dma_rdy     => dmavideo_rdy,
			dma_len     => dmavideo_len,
			dma_addr    => dmavideo_addr,
			video_clk   => video_clk,
			video_hzon  => hzon,
			video_vton  => vton,
			video_pixel => pixel);

		topixel_e : entity hdl4fpga.align
		generic map (
			n => pixel'length,
			d => (0 to pixel'length-1 => 4-1))
		port map (
			clk => video_clk,
			di  => pixel,
			do  => video_pixel);

		tosync_e : entity hdl4fpga.align
		generic map (
			n => 4,
			d => (0 to 4-1 => 4))
		port map (
			clk => video_clk,
			di(0) => hzon,
			di(1) => vton,
			di(2) => hzsync,
			di(3) => vtsync,
			do(0) => video_hzon,
			do(1) => video_vton,
			do(2) => video_hzsync,
			do(3) => video_vtsync);

	end block;

	process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			dmavideo_req <= dmacfgvideo_rdy;
			dmaio_req    <= dmacfgio_rdy;
		end if;
	end process;

	dmacfg_req <= (0 => dmacfgvideo_req, 1 => dmacfgio_req);
	(0 => dmacfgvideo_rdy, 1 => dmacfgio_rdy) <= dmacfg_rdy;

	dev_req <= (0 => dmavideo_req, 1 => dmaio_req);
	(0 => dmavideo_rdy, 1 => dmaio_rdy) <= dev_rdy;
	dev_len    <= dmavideo_len  & dmaio_len;
	dev_addr   <= dmavideo_addr & dmaio_addr;
	dev_we     <= "1"           & "0";

	dmactlr_e : entity hdl4fpga.dmactlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => tcp,

		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		coln_size   => coln_size)
	port map (
		devcfg_clk  => dmacfg_clk,
		devcfg_req  => dmacfg_req,
		devcfg_rdy  => dmacfg_rdy,
		dev_len     => dev_len,
		dev_addr    => dev_addr,
		dev_we      => dev_we,

		dev_req     => dev_req,
		dev_rdy     => dev_rdy,

		ctlr_clk    => ctlr_clk,

		ctlr_inirdy => ctlr_inirdy,
		ctlr_refreq => ctlr_refreq,
                                  
		ctlr_irdy   => ctlr_irdy,
		ctlr_trdy   => ctlr_trdy,
		ctlr_ras    => ctlr_ras,
		ctlr_cas    => ctlr_cas,
		ctlr_rw     => ctlr_rw,
		ctlr_b      => ctlr_b,
		ctlr_a      => ctlr_a,
		ctlr_r      => ctlr_r,
		ctlr_dio_req => ctlr_dio_req,
		ctlr_act    => ctlr_act);

	ddrctlr_e : entity hdl4fpga.ddr_ctlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => tcp,

		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		word_size    => word_size,
		byte_size    => byte_size)
	port map (
		ctlr_bl      => "001",
--		ctlr_cl      => "010",	-- 2   133 Mhz
--		ctlr_cl      => "110",	-- 2.5 166 Mhz
		ctlr_cl      => "011",	-- 3   200 Mhz

		ctlr_cwl     => "000",
		ctlr_wr      => "101",
		ctlr_rtt     => "--",

		ctlr_rst     => ddrsys_rst,
		ctlr_clks    => ddrsys_clks,
		ctlr_inirdy  => ctlr_inirdy,

		ctlr_irdy    => ctlr_irdy,
		ctlr_trdy    => ctlr_trdy,
		ctlr_rw      => ctlr_rw,
		ctlr_b       => ctlr_b,
		ctlr_a       => ctlr_a,
		ctlr_ras     => ctlr_ras,
		ctlr_cas     => ctlr_cas,
		ctlr_di_dv   => ctlr_di_dv,
		ctlr_di_req  => ctlr_di_req,
		ctlr_act     => ctlr_act,
		ctlr_di      => ctlr_di,
		ctlr_dm      => (ctlr_dm'range => '0'),
		ctlr_do_dv   => ctlr_do_dv,
		ctlr_do      => ctlr_do,
		ctlr_refreq  => ctlr_refreq,
		ctlr_dio_req => ctlr_dio_req,

		phy_rst      => ddrphy_rst,
		phy_cke      => ddrphy_cke(0),
		phy_cs       => ddrphy_cs(0),
		phy_ras      => ddrphy_ras(0),
		phy_cas      => ddrphy_cas(0),
		phy_we       => ddrphy_we(0),
		phy_b        => ddrphy_b,
		phy_a        => ddrphy_a,
		phy_odt      => ddrphy_odt(0),
		phy_dmi      => ddrphy_dmi,
		phy_dmt      => ddrphy_dmt,
		phy_dmo      => ddrphy_dmo,
                               
		phy_dqi      => ddrphy_dqi,
		phy_dqt      => ddrphy_dqt,
		phy_dqo      => ddrphy_dqo,
		phy_sti      => ddrphy_sto,
		phy_sto      => ddrphy_sti,
                                
		phy_dqsi     => ddrphy_dqsi,
		phy_dqso     => ddrphy_dqso,
		phy_dqst     => ddrphy_dqst);

	ddrphy_e : entity hdl4fpga.xcs3_ddrphy
	generic map (
		gate_delay  => 2,
		loopback    => true,
		rgtr_dout => false,
		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		cmmd_gear   => cmmd_gear,
		data_gear   => data_gear,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		sys_clks    => ddrsys_clks,
		sys_rst     => ddrsys_rst,

		phy_cke     => ddrphy_cke,
		phy_cs      => ddrphy_cs,
		phy_ras     => ddrphy_ras,
		phy_cas     => ddrphy_cas,
		phy_we      => ddrphy_we,
		phy_b       => ddrphy_b,
		phy_a       => ddrphy_a,
		phy_dqsi    => ddrphy_dqso,
		phy_dqst    => ddrphy_dqst,
		phy_dqso    => ddrphy_dqsi,
		phy_dmi     => ddrphy_dmo,
		phy_dmt     => ddrphy_dmt,
		phy_dmo     => ddrphy_dmi,
		phy_dqi     => ddrphy_dqo,
		phy_dqt     => ddrphy_dqt,
		phy_dqo     => ddrphy_dqi,
		phy_odt     => ddrphy_odt,
		phy_sti     => ddrphy_sti,
		phy_sto     => ddrphy_sto,

		ddr_sto(0) => ddr_st_dqs,
		ddr_sto(1) => ddr_st_dqs_open,
		ddr_sti(0) => ddr_st_lp_dqs,
		ddr_sti(1) => ddr_st_lp_dqs,
		ddr_clk     => ddr_clk,
		ddr_cke     => ddr_cke,
		ddr_cs      => ddr_cs,
		ddr_ras     => ddr_ras,
		ddr_cas     => ddr_cas,
		ddr_we      => ddr_we,
		ddr_b       => ddr_ba,
		ddr_a       => ddr_a,

		ddr_dm      => ddr_dm,
		ddr_dqt     => ddr_dqt,
		ddr_dqi     => ddr_dq,
		ddr_dqo     => ddr_dqo,
		ddr_dqst    => ddr_dqst,
		ddr_dqsi    => ddr_dqs,
		ddr_dqso    => ddr_dqso);

	ddr_dqs_g : for i in ddr_dqs'range generate
		ddr_dqs(i) <= ddr_dqso(i) when ddr_dqst(i)='0' else 'Z';
	end generate;

	process (ddr_dqt, ddr_dqo)
	begin
		for i in ddr_dq'range loop
			ddr_dq(i) <= 'Z';
			if ddr_dqt(i)='0' then
				ddr_dq(i) <= ddr_dqo(i);
			end if;
		end loop;
	end process;

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_clk(0),
		o  => ddr_ckp,
		ob => ddr_ckn);

	-- VGA --
	---------

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			red    <= word2byte(video_pixel, std_logic_vector(to_unsigned(0,2)), 8);
			green  <= word2byte(video_pixel, std_logic_vector(to_unsigned(1,2)), 8);
			blue   <= word2byte(video_pixel, std_logic_vector(to_unsigned(2,2)), 8);
			blankn <= video_hzon and video_vton;
			hsync  <= video_hzsync;
			vsync  <= video_vtsync;
			sync   <= not video_hzsync and not video_vtsync;
		end if;
	end process;
	psave <= '1';

--	adcclkab_e : entity hdl4fpga.ddro
--	port map (
--		clk => '0', --adc_clk,
--		dr  => '1',
--		df  => '0',
--		q   => adc_clkab);
	adc_clkab <= 'Z';

	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => video_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

--	clk_mii_e : entity hdl4fpga.ddro
--	port map (
--		clk => mii_clk,
--		dr => '0',
--		df => '1',
--		q => mii_refclk);
	mii_refclk <= mii_clk;	

	hd_t_data <= 'Z';

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
			i := dmaio_dv;
			i := dmaio_rdy;

			led18 <= t;
			led16 <= not t;
		end if;
	end process;

	process (ctlr_clk)
		variable t : std_logic;
		variable e : std_logic;
		variable i : std_logic;
	begin
		if rising_edge(ctlr_clk) then
			i := dmavideo_rdy;
			if i='1' and e='0' then
				t := not t;
			end if;
			e := i;
			led13 <= t;
			led15 <= not t;
		end if;
	end process;

	-- LEDs --
	----------
		
--	led18 <= '0';
--	led16 <= '0';
--	led15 <= '0';
--	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
--	led7  <= '0';

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

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

end;
