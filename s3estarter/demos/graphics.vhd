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
use hdl4fpga.scopeiopkg.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of s3Estarter is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	constant sys_per      : real    := 20.0;

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --   8     --  10     --   4     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------
	constant ddr_mul      : natural := 4;
	constant ddr_div      : natural := 1;

	constant g            : std_logic_vector(32 downto 1) := (
		32 => '1', 30 => '1', 26 => '1', 25 => '1', others => '0');
	signal g_ena          : std_logic;
	signal g_load         : std_logic;
	signal g_data         : std_logic_vector(g'range);

	constant fpga         : natural := spartan3;
	constant mark         : natural := m6t;
	constant tcp          : natural := (natural(sys_per)*ddr_div*1000)/(ddr_mul); -- 1 ns /1ps

	constant sclk_phases  : natural := 4;
	constant sclk_edges   : natural := 2;
	constant cmmd_gear    : natural := 1;
	constant data_phases  : natural := 2;
	constant data_edges   : natural := 2;
	constant bank_size    : natural := sd_ba'length;
	constant addr_size    : natural := sd_a'length;
	constant data_gear    : natural := 2;
	constant word_size    : natural := sd_dq'length;
	constant byte_size    : natural := 8;

	signal ddrsys_lckd    : std_logic;
	signal ddrsys_rst     : std_logic;

	constant clk0         : natural := 0;
	constant clk90        : natural := 1;
	signal ddrsys_clks    : std_logic_vector(0 to 2-1);

	signal dmactlr_len    : std_logic_vector(26-1 downto 2);
	signal dmactlr_addr   : std_logic_vector(26-1 downto 2);

	signal dmacfgio_req   : std_logic;
	signal dmacfgio_rdy   : std_logic;
	signal dmaio_req      : std_logic;
	signal dmaio_rdy      : std_logic;
	signal dmaio_len      : std_logic_vector(dmactlr_len'range)  := x"0000_03";
	signal dmaio_addr     : std_logic_vector(dmactlr_addr'range) := b"00" & b"0" & x"000" & b"1" & x"fe";
	signal dmaio_dv       : std_logic;

	signal ctlr_irdy      : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_act       : std_logic;
	signal ctlr_pre       : std_logic;
	signal ctlr_idl       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_dm        : std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv     : std_logic := '1';
	signal ctlr_di_req    : std_logic;
	signal ctlr_dio_req   : std_logic;

	signal ddrphy_rst     : std_logic;
	signal ddrphy_cke     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cs      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_ras     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cas     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_we      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_odt     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_b       : std_logic_vector(cmmd_gear*sd_ba'length-1 downto 0);
	signal ddrphy_a       : std_logic_vector(cmmd_gear*sd_a'length-1 downto 0);
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

	signal ddr_clk        : std_logic_vector(0 downto 0);
	signal ddr_dqst       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt        : std_logic_vector(sd_dq'range);
	signal ddr_dqo        : std_logic_vector(sd_dq'range);

	alias  si_clk         : std_logic is e_rx_clk;
	signal si_frm         : std_logic;
	signal si_irdy        : std_logic;
	signal si_data        : std_logic_vector(e_rxd'range);

	signal toudpdaisy_frm  : std_logic;
	signal toudpdaisy_irdy : std_logic;
	signal toudpdaisy_data : std_logic_vector(e_rxd'range);

	signal video_clk      : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_hzon     : std_logic;
    signal video_vton     : std_logic;
    signal video_pixel    : std_logic_vector(0 to 8-1);

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

	constant no_latency : boolean := false;
	type display_param is record
		mode    : natural;
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type layout_mode is (
		mode480p,
		mode600p, 
		mode1080p);

	type displayparam_vector is array (layout_mode) of display_param;
	constant video_params : displayparam_vector := (
		mode480p    => (mode => 0, dcm_mul => 3, dcm_div => 5),
		mode600p    => (mode => 1, dcm_mul => 4, dcm_div => 5),
		mode1080p   => (mode => 7, dcm_mul => 3, dcm_div => 1));

	constant video_mode : layout_mode := mode600p;

	alias dma_clk : std_logic is sys_clk;

begin

	sys_rst <= btn_west;
	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 20.0,
		dfs_mul => video_params(video_mode).dcm_mul,
		dfs_div => video_params(video_mode).dcm_div)
	port map(
		dcm_rst => sys_rst,
		dcm_clk => sys_clk,
		dfs_clk => video_clk);

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst   => sys_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => ddrsys_clks(clk0),
		dfsdcm_clk90 => ddrsys_clks(clk90),
		dfsdcm_lckd  => ddrsys_lckd);
	ddrsys_rst <= not ddrsys_lckd;

	scopeio_export_b : block

		signal rgtr_id     : std_logic_vector(8-1 downto 0);
		signal rgtr_dv     : std_logic;
		signal rgtr_data   : std_logic_vector(32-1 downto 0);

		signal data_ena    : std_logic;
		signal data_len    : std_logic_vector(8-1 downto 0);
		signal dmadata_ena : std_logic;

	begin

		udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
		port map (
			ipcfg_req   => '0',

			phy_rxc     => e_rx_clk,
			phy_rx_dv   => e_rx_dv,
			phy_rx_d    => e_rxd,

			phy_txc     => e_tx_clk,
			phy_tx_en   => e_txen,
			phy_tx_d    => e_txd,
		
			chaini_sel  => '0',

			chaini_frm  => toudpdaisy_frm,
			chaini_irdy => toudpdaisy_irdy,
			chaini_data => toudpdaisy_data,

			chaino_frm  => si_frm,
			chaino_irdy => si_irdy,
			chaino_data => si_data);
	
		scopeio_sin_e : entity hdl4fpga.scopeio_sin
		port map (
			sin_clk   => si_clk,
			sin_frm   => si_frm,
			sin_irdy  => si_irdy,
			sin_data  => si_data,
			data_len  => data_len,
			data_ena  => data_ena,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		dmaaddr_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmaaddr)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			data      => dmaio_addr);

		dmalen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmalen)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmaio_dv,
			data      => dmaio_len);

		dmadata_ena <= data_ena and setif(rgtr_id=rid_dmadata) and setif(data_len(2-1 downto 0)=(2-1 downto 0 => '1'));

		dmadata_e : entity hdl4fpga.fifo
		generic map (
			size           => 256,
			gray_code      => false,
			overflow_check => false)
		port map (
			src_clk  => si_clk,
			src_irdy => dmadata_ena,
			src_data => rgtr_data,

			dst_clk  => ddrsys_clks(clk0),
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

--		dmacfgio_p : process (si_clk)
--		begin
--			if rising_edge(si_clk) then
--				if dmacfgio_req/='1' then
--					dmacfgio_req <= dmaio_dv;
--				elsif dmacfgio_rdy='1' then
--					dmacfgio_req <= '0';
--				end if;
--			end if;
--		end process;
--		dmaio_req <= '0';

		dmacfgio_p : process (dma_clk)
		begin
			if rising_edge(dma_clk) then
				if dmacfgio_req/='1' then
					dmacfgio_req <= dmaio_dv;
					dmaio_req <= '0';
				elsif dmacfgio_rdy/='0' then
					dmacfgio_req <= '0';
					dmaio_req    <= '1';
				elsif dmaio_rdy='1' then
					dmacfgio_req <= '0';
					dmaio_req <= '0';
				end if;
			end if;
		end process;

	end block;

	graphics_e : entity hdl4fpga.graphics
	generic map (
		video_mode => video_params(video_mode).mode)
	port map (
		dma_req      => dmacfgvideo_req,
		dma_rdy      => dmavideo_rdy,
		dma_len      => dmavideo_len,
		dma_addr     => dmavideo_addr,
		ctlr_clk     => ddrsys_clks(clk0),
		ctlr_di_dv   => ctlr_do_dv(0),
		ctlr_di      => ctlr_do,
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_hzon   => video_hzon,
		video_vton   => video_vton,
		video_pixel  => video_pixel);

	videodmacfg_p : process (dma_clk)
	begin
		if rising_edge(dma_clk) then
			if dmacfgvideo_rdy/='0' then
				dmavideo_req <= '1';
			elsif dmavideo_rdy='1' then
				dmavideo_req <= '0';
			end if;
		end if;
	end process;

	dmacfg_req <= (0 => dmacfgvideo_req, 1 => dmacfgio_req);
	(0 => dmacfgvideo_rdy, 1 => dmacfgio_rdy) <= dmacfg_rdy;

	dev_req <= (0 => dmavideo_req, 1 => dmaio_req);
	(0 => dmavideo_rdy, 1 => dmaio_rdy) <= dev_rdy;
	dev_len    <= dmavideo_len  & dmaio_len;
	dev_addr   <= dmavideo_addr & dmaio_addr;
	dev_we     <= "1"           & "0";


--	dmacfg_req <= (0 => '0', 1 => dmacfgio_req);
--	dev_req <= (0 => '0', 1 => dmaio_req);

	dmactlr_e : entity hdl4fpga.dmactlr
	generic map (
		no_latency => no_latency)
	port map (
		dma_clk     => dma_clk,
		dmacfg_req  => dmacfg_req,
		dmacfg_rdy  => dmacfg_rdy,
		dev_len     => dev_len,
		dev_addr    => dev_addr,
		dev_we      => dev_we,

		dev_req     => dev_req,
		dev_rdy     => dev_rdy,

		ctlr_clk    => ddrsys_clks(clk0),

		ctlr_inirdy => ctlr_inirdy,
		ctlr_refreq => ctlr_refreq,
                                  
		ctlr_irdy   => ctlr_irdy,
		ctlr_trdy   => ctlr_trdy,
		ctlr_rw     => ctlr_rw,
		ctlr_b      => ctlr_b,
		ctlr_a      => ctlr_a,
		ctlr_dio_req => ctlr_dio_req,
		ctlr_act    => ctlr_act,
		ctlr_pre    => ctlr_pre,
		ctlr_idl    => ctlr_idl);

	ddrctlr_e : entity hdl4fpga.ddr_ctlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => tcp,

		no_latency   => no_latency,
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
		ctlr_di_dv   => ctlr_di_req, --'1', --ctlr_di_irdy,
		ctlr_di_req  => ctlr_di_req,
		ctlr_act     => ctlr_act,
		ctlr_pre     => ctlr_pre,
		ctlr_idl     => ctlr_idl,
		ctlr_di      => ctlr_di,
--		ctlr_di      => g_data,
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

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		gate_delay  => 2,
		loopback    => false,
		rgtr_dout   => false,
		bank_size   => sd_ba'length,
		addr_size   => sd_a'length,
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

		ddr_clk     => ddr_clk,
		ddr_cke     => sd_cke,
		ddr_cs      => sd_cs,
		ddr_ras     => sd_ras,
		ddr_cas     => sd_cas,
		ddr_we      => sd_we,
		ddr_b       => sd_ba,
		ddr_a       => sd_a,

		ddr_dm      => sd_dm,
		ddr_dqt     => ddr_dqt,
		ddr_dqi     => sd_dq,
		ddr_dqo     => ddr_dqo,
		ddr_dqst    => ddr_dqst,
		ddr_dqsi    => sd_dqs,
		ddr_dqso    => ddr_dqso);

	ddr_dqs_g : for i in sd_dqs'range generate
		sd_dqs(i) <= ddr_dqso(i) when ddr_dqst(i)='0' else 'Z';
	end generate;

	process (ddr_dqt, ddr_dqo)
	begin
		for i in sd_dq'range loop
			sd_dq(i) <= 'Z';
			if ddr_dqt(i)='0' then
				sd_dq(i) <= ddr_dqo(i);
			end if;
		end loop;
	end process;

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_clk(0),
		o  => sd_ck_p,
		ob => sd_ck_n);

	-- VGA --
	---------

	vga_red   <= video_pixel(0);
	vga_green <= video_pixel(1);
	vga_blue  <= video_pixel(2);
	vga_hsync <= video_hzsync;
	vga_vsync <= video_vtsync;

	-- LEDs --
	----------
		
	led0 <= sys_rst;
	led1 <= '0';
	led2 <= '0';
	led3 <= '0';
	led4 <= '0';
	led5 <= '0';
	led6 <= '0';
	led7 <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_dte_txd <= 'Z';
	rs232_dce_txd <= 'Z';

	-- Ethernet Transceiver --
	--------------------------

	e_mdc       <= 'Z';
	e_mdio      <= 'Z';
	e_txd_4     <= 'Z';

	e_txd  	    <= (others => 'Z');
	e_txen      <= 'Z';

	-- misc --
	----------

	ad_conv     <= 'Z';
	spi_sck     <= 'Z';
	dac_cs      <= 'Z';
	amp_cs      <= 'Z';
	spi_mosi    <= 'Z';

	amp_shdn    <= 'Z';
	dac_clr     <= 'Z';
	sf_ce0      <= 'Z';
	fpga_init_b <= 'Z';
	spi_ss_b    <= 'Z';

end;
