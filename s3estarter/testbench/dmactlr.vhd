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

architecture dmactlr of s3Estarter is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	-------------------------------------------------------------
	-- Frequency   -- 133 Mhz -- 150 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --   8     --   3     --  10     --   4     --
	-- Divide by   --   3     --   1     --   3     --   1     --
	-------------------------------------------------------------

	constant sys_per     : real    := 20.0;
	constant ddr_mul     : natural := 4; --(4/1) 200 (10/3) 166, (3/1) 150, (8/3) 133
	constant ddr_div     : natural := 1;

	constant g           : std_logic_vector(32 downto 1) := (
		32 => '1', 30 => '1', 26 => '1', 25 => '1', others => '0');
	signal g_ena         : std_logic;
	signal g_load        : std_logic;
	signal g_data        : std_logic_vector(g'range);

	constant fpga        : natural := spartan3;
	constant mark        : natural := m6t;
	constant tcp         : natural := (natural(sys_per)*ddr_div*1000)/(ddr_mul); -- 1 ns /1ps

	constant sclk_phases : natural := 4;
	constant sclk_edges  : natural := 2;
	constant cmmd_gear   : natural := 1;
	constant data_phases : natural := 2;
	constant data_edges  : natural := 2;
	constant bank_size   : natural := sd_ba'length;
	constant addr_size   : natural := sd_a'length;
	constant data_gear   : natural := 2;
	constant word_size   : natural := sd_dq'length;
	constant byte_size   : natural := 8;

	signal ddrsys_lckd   : std_logic;
	signal ddrsys_rst    : std_logic;

	constant clk0        : natural := 0;
	constant clk90       : natural := 1;
	signal ddrsys_clks   : std_logic_vector(0 to 2-1);

	alias dmactlr_clk     : std_logic is ddrsys_clks(clk0);
	signal dmatrans_we    : std_logic;
	signal dmatrans_req   : std_logic;
	signal dmatrans_rdy   : std_logic;

	signal dmactlr_len    : std_logic_vector(26-1 downto 2) := x"0000_03";
	signal dmactlr_addr   : std_logic_vector(26-1 downto 2) := b"00" & b"0" & x"000" & b"1" & x"fe";
	signal dmactlr_addrdv : std_logic;
	signal dmactlr_lendv  : std_logic;


	signal dmatrans_iaddr   : std_logic_vector(dmactlr_addr'range);
	signal dmatrans_ilen    : std_logic_vector(dmactlr_len'range);

	signal dmatrans_taddr   : std_logic_vector(dmactlr_addr'range);
	signal dmatrans_tlen    : std_logic_vector(dmactlr_len'range);

	signal ctlr_irdy     : std_logic;
	signal ctlr_trdy     : std_logic;
	signal ctlr_rw       : std_logic;
	signal ctlr_act      : std_logic;
	signal ctlr_pre      : std_logic;
	signal ctlr_idl      : std_logic;
	signal ctlr_inirdy   : std_logic;
	signal ctlr_refreq   : std_logic;
	signal ctlr_b        : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a        : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di       : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do       : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_dm       : std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv    : std_logic := '1';
	signal ctlr_di_req   : std_logic;

	signal ddrphy_rst    : std_logic;
	signal ddrphy_cke    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cs     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_ras    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cas    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_we     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_odt    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_b      : std_logic_vector(cmmd_gear*sd_ba'length-1 downto 0);
	signal ddrphy_a      : std_logic_vector(cmmd_gear*sd_a'length-1 downto 0);
	signal ddrphy_dqsi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqst   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqso   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmi    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmt    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmo    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqi    : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ddrphy_dqt    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqo    : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ddrphy_sto    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_sti    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

	signal ddr_clk       : std_logic_vector(0 downto 0);
	signal ddr_dqst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt       : std_logic_vector(sd_dq'range);
	signal ddr_dqo       : std_logic_vector(sd_dq'range);

	signal dst_clk       : std_logic;
	signal dst_irdy      : std_logic;
	signal dst_trdy      : std_logic;
	signal dst_do        : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);

	alias  si_clk   : std_logic is e_rx_clk;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(e_rxd'range);

	signal toudpdaisy_frm  : std_logic;
	signal toudpdaisy_irdy : std_logic;
	signal toudpdaisy_data : std_logic_vector(e_rxd'range);

	signal dev_req       : std_logic_vector(0 to 2-1) := "10";
	signal dma_gnt    : std_logic_vector(dev_req'range);
	signal dma_booked    : std_logic_vector(dev_req'range);
	signal dma_req    : std_logic_vector(dev_req'range);
	signal trans_rid     : std_logic_vector(0 to unsigned_num_bits(dma_gnt'length-1)-1);
	signal dmactlr_rid   : std_logic_vector(trans_rid'range) := (others => '0');

	constant no_latency : boolean := false;
begin

	sys_rst <= btn_west;
	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

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

		signal rgtr_id   : std_logic_vector(8-1 downto 0);
		signal rgtr_dv   : std_logic;
		signal rgtr_data : std_logic_vector(32-1 downto 0);

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

			dv   => dmactlr_addrdv,
			data => dmactlr_addr);

		dmalen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmalen)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,

			dv        => dmactlr_lendv,
			data      => dmactlr_len);

	end block;

	dmargtrgnt_e : entity hdl4fpga.grant
	port map (
		gnt_clk => si_clk,
		gnt_rst => ,
		gnt_rdy => ,

		dev_clk => (0 => video_clk),
		dev_req => (0 => video_req),
		dev_gnt => dma_rid,
		dev_rdy => dev_rdy);

	process (si_clk)
		variable dv : std_logic;
	begin
		if rising_edge(si_clk) then
			dmactlr_addr   <= word2byte (video_addr, dev_gnt);
			dmargtr_id     <= encoder(dma_rid);
			dmartgr_addrdv <= setif(dev_gnt/=(dev_gnt'range => '0') and not dv;
			dv := setif(dev_gnt/=(dev_gnt'range => '0') and not dv;
		end if;
	end process;

	dmatrans_req <= setif(dma_gnt /= (dma_gnt'range => '0')) and ctlr_inirdy;
	dma_req      <= not dma_served and dma_booked;

	dmaaddr_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => si_clk,
		wr_ena  => dmactlr_addrdv,
		wr_addr => dmactlr_rid,
		wr_data => dmactlr_addr,

		rd_clk  => dmactlr_clk,
		rd_addr => trans_rid,
		rd_data => dmatrans_iaddr);

	dmalen_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => dmactlr_clk,
		wr_addr => dmactlr_rid,
		wr_ena  => dmactlr_lendv,
		wr_data => dmactlr_len,

		rd_clk  => dmactlr_clk,
		rd_addr => trans_rid,
		rd_data => dmatrans_ilen);

	dmatrans_e : entity hdl4fpga.dmatrans
	generic map (
		no_latency   => no_latency,
		size => 256)
	port map (
		dmatrans_clk   => dmactlr_clk,
		dmatrans_req   => dmatrans_req,
		dmatrans_rdy   => dmatrans_rdy,
		dmatrans_we    => dmatrans_we,
		dmatrans_iaddr => dmatrans_iaddr,
		dmatrans_ilen  => dmatrans_ilen,
		dmatrans_taddr => dmatrans_taddr,
		dmatrans_tlen  => dmatrans_tlen,

		ctlr_inirdy    => ctlr_inirdy,
		ctlr_refreq    => ctlr_refreq,

		ctlr_irdy      => ctlr_irdy,
		ctlr_trdy      => ctlr_trdy,
		ctlr_rw        => ctlr_rw,
		ctlr_act       => ctlr_act,
		ctlr_pre       => ctlr_pre,
		ctlr_idl       => ctlr_idl,
		ctlr_b         => ctlr_b,
		ctlr_a         => ctlr_a,
		ctlr_di_req    => ctlr_di_req,
		ctlr_di        => ctlr_di,
		ctlr_dm        => ctlr_dm,
		ctlr_do_trdy   => ctlr_do_dv,
		ctlr_do        => ctlr_do,

		dst_clk        => dst_clk,
		dst_irdy       => dst_irdy,
		dst_trdy       => dst_trdy,
		dst_do         => dst_do);

	g_load <= not ctlr_inirdy;
	g_ena  <= ctlr_di_req;
	testpattern_e : entity hdl4fpga.lfsr
	generic map (
		g    => g)
	port map (
		clk  => ddrsys_clks(clk0), --sys_clk,
		load => g_load,
		ena  => g_ena,
		data => g_data);

	dmatrans_we  <= '0';

	dst_clk     <= sys_clk;
	dst_irdy    <= '1';
	dst_trdy    <= '1';
	dst_do      <= (others => '-');

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
		ctlr_idl      => ctlr_idl,
--		ctlr_di      => ctlr_di,
		ctlr_di      => g_data,
		ctlr_dm      => (ctlr_dm'range => '0'),
		ctlr_do_dv   => ctlr_do_dv,
		ctlr_do      => ctlr_do,
		ctlr_refreq  => ctlr_refreq,

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
		rgstrd_dout => false,
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

	vga_red   <= 'Z';
	vga_green <= 'Z';
	vga_blue  <= 'Z';
	vga_vsync <= 'Z';
	vga_hsync <= 'Z';

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

	amp_shdn    <= 'Z';
	dac_clr     <= 'Z';
	sf_ce0      <= 'Z';
	fpga_init_b <= 'Z';
	spi_ss_b    <= 'Z';

end;
