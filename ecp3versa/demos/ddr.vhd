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

library ecp3;
use ecp3.components.all;

architecture ddr of ecp3versa is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	constant sys_per      : real    := 1000.0 / 100.0;

	type pll_param is record
		ddr_clki  : natural;
		ddr_clkfb : natural;
		ddr_clkop : natural;
		ddr_clkok : natural;
	end record;

	type ddrMHz is (ddr400MHz, ddr450Mhz, ddr500MHz);
	type ddrpll_param is array(ddrMhz) of pll_param;

	---------------------------------------------
	-- Frequency - 400 Mhz - 450 Mhz - 500 Mhz --
	---------------------------------------------
	-- ddr_clki  -   1     -   2     -    1    --
	-- ddr_clkfb -   4     -   9     -    5	   --
	-- ddr_clkop -   2     -   2     -    2    --
	-- ddr_clkok -   2     -   2     -    2    --
	---------------------------------------------

	constant ddrpll_tab : ddrpll_param := (
		ddr400MHz => (ddr_clki => 1, ddr_clkfb => 4, ddr_clkop => 2, ddr_clkok => 2),
		ddr450MHz => (ddr_clki => 2, ddr_clkfb => 9, ddr_clkop => 2, ddr_clkok => 2),
		ddr500MHz => (ddr_clki => 1, ddr_clkfb => 5, ddr_clkop => 2, ddr_clkok => 2));

	constant ddrclk    : ddrMHz := ddr500MHz;
	constant ctlr_tcp   : natural := 
		(1000*natural(sys_per)*ddrpll_tab(ddrclk).ddr_clki*ddrpll_tab(ddrclk).ddr_clkok)/
		(ddrpll_tab(ddrclk).ddr_clkfb);
	constant ddrphy_tcp   : natural := 
		(1000*natural(sys_per)*ddrpll_tab(ddrclk).ddr_clki)/
		(ddrpll_tab(ddrclk).ddr_clkfb);

	constant fpga         : natural := LatticeECP3;
	constant mark         : natural := M15E;

	constant bank_size   : natural := 3;
	constant addr_size   : natural := 13;
	constant coln_size   : natural := 7;
	constant word_size   : natural := ddr3_dq'length;
	constant byte_size   : natural := ddr3_dq'length/ddr3_dqs'length;
	constant cmmd_gear   : natural := 2;
	constant sclk_phases : natural := 1;
	constant sclk_edges  : natural := 1;
	constant data_gear   : natural := 4;
	constant data_phases : natural := data_gear;
	constant data_edges  : natural := 1;

	signal dmactlr_len   : std_logic_vector(25-1 downto 0);
	signal dmactlr_addr  : std_logic_vector(25-1 downto 0);

	signal dmacfgio_req  : std_logic;
	signal dmacfgio_rdy  : std_logic;
	signal dmaio_req     : std_logic := '0';
	signal dmaio_rdy     : std_logic;
	signal dmaio_len     : std_logic_vector(dmactlr_len'range);
	signal dmaio_addr    : std_logic_vector(dmactlr_addr'range);
	signal dmaio_dv      : std_logic;

	signal sdram_dqs     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlr_irdy     : std_logic;
	signal ctlr_trdy     : std_logic;
	signal ctlr_rw       : std_logic;
	signal ctlr_act      : std_logic;
	signal ctlr_inirdy   : std_logic;
	signal ctlr_refreq   : std_logic;
	signal ctlr_b        : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a        : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_r        : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di       : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do       : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_dm       : std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv    : std_logic;
	signal ctlr_di_req   : std_logic;
	signal ctlr_dio_req  : std_logic;

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic;
	signal ctlrphy_cs    : std_logic;
	signal ctlrphy_ras   : std_logic;
	signal ctlrphy_cas   : std_logic;
	signal ctlrphy_we    : std_logic;
	signal ctlrphy_odt   : std_logic;
	signal ctlrphy_wlreq : std_logic;
	signal ctlrphy_wlrdy : std_logic;
	signal ctlrphy_dqsi  : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqst  : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso  : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_pll    : std_logic_vector(8-1 downto 0);
	signal ddrphy_rst    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cs     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cke    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_odt    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_ras    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cas    : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_we     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_b      : std_logic_vector(cmmd_gear*ddr3_b'length-1 downto 0);
	signal ddrphy_a      : std_logic_vector(cmmd_gear*ddr3_a'length-1 downto 0);

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

	signal ddr_rst     : std_logic;
	signal ddr_sclk    : std_logic;
	signal ddr_eclk    : std_logic;
	signal ddr_sclk2x  : std_logic;
	signal ddrpll_pha  : std_logic_vector(4-1 downto 0);
	alias  ctlr_clk    : std_logic is ddr_sclk;
	signal ctlr_rst    : std_logic;

	alias si_clk       : std_logic is phy1_rxc;
	alias dmacfg_clk   : std_logic is phy1_rxc;

	attribute oddrapps : string;
	attribute oddrapps of gtx_clk_i : label is "SCLK_ALIGNED";
	
begin

	sys_rst <= '0';
	ddrpll_e : entity hdl4fpga.ddrpll
	generic map (
		ddr_clki  => ddrpll_tab(ddrclk).ddr_clki,
		ddr_clkfb => ddrpll_tab(ddrclk).ddr_clkfb,
		ddr_clkop => ddrpll_tab(ddrclk).ddr_clkop,
		ddr_clkok => ddrpll_tab(ddrclk).ddr_clkok)
	port map (
		sys_rst    => sys_rst,
		sys_clk    => clk,
		phy_clk    => phy1_125clk,

		ddr_eclk   => ddr_eclk,
		ddr_sclk   => ddr_sclk, 
		ddr_sclk2x => ddr_sclk2x, 
		ddr_rst    => ddr_rst,
		ddr_pha    => ddrpll_pha);

	scopeio_export_b : block

		signal ipcfg_req  : std_logic;
		signal si_frm      : std_logic;
		signal si_irdy     : std_logic;
		signal si_data     : std_logic_vector(phy1_rx_d'range);

		signal rgtr_id     : std_logic_vector(8-1 downto 0);
		signal rgtr_dv     : std_logic;
		signal rgtr_data   : std_logic_vector(64-1 downto 0);

		signal data_ena    : std_logic;
		signal fifo_rst    : std_logic;
		signal src_frm     : std_logic;
		signal data_ptr    : std_logic_vector(8-1 downto 0);
		signal dmadata_ena : std_logic;
		signal dst_irdy    : std_logic;

	begin

		ipcfg_req <= not fpga_gsrn;
		udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
		port map (
			ipcfg_req   => ipcfg_req,

			phy_rxc     => phy1_rxc,
			phy_rx_dv   => phy1_rx_dv,
			phy_rx_d    => phy1_rx_d,

			phy_txc     => phy1_125clk,
			phy_tx_en   => phy1_tx_en,
			phy_tx_d    => phy1_tx_d,
		
			chaini_sel  => '0',

			chaini_data => si_data,

			chaino_frm  => si_frm,
			chaino_irdy => si_irdy,
			chaino_data => si_data);
	
		scopeio_sin_e : entity hdl4fpga.scopeio_sin
		port map (
			sin_clk   => si_clk,
			sin_frm   => si_frm,
			sin_irdy  => si_irdy,
			sin_data  => si_data,
			data_ptr  => data_ptr,
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
			rgtr_data => rgtr_data(32-1 downto 0),
			dv        => fifo_rst,
			data      => dmaio_addr);

		dmalen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmalen)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data(32-1 downto 0),
			dv        => dmaio_dv,
			data      => dmaio_len);

		dmadata_ena <= data_ena and setif(rgtr_id=rid_dmadata) and setif(data_ptr(3-1 downto 0)=(3-1 downto 0 => '0'));

		src_frm <= not fifo_rst;
		dmadata_e : entity hdl4fpga.fifo
		generic map (
			size           => (8*4096)/ctlr_di'length,
			synchronous_rddata => true,
			gray_code      => false,
			overflow_check => false)
		port map (
			src_clk  => si_clk,
			src_frm  => src_frm,
			src_irdy => dmadata_ena,
			src_data => rgtr_data,

			dst_clk  => ctlr_clk,
			dst_irdy => dst_irdy,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

		ctlr_di_dv <= dst_irdy and ctlr_di_req; 
		ctlr_dm <= (others => '0');

		dmacfgio_p : process (si_clk)
			variable io_rdy : std_logic;
		begin
			if rising_edge(si_clk) then
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

	process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			dmavideo_req <= dmacfgvideo_rdy;
			dmavideo_req <= '0';
			dmaio_req    <= dmacfgio_rdy;
		end if;
	end process;

--	dmacfg_req <= (0 => dmacfgvideo_req, 1 => dmacfgio_req);
	dmacfg_req <= (0 => '0', 1 => dmacfgio_req);
	(0 => dmacfgvideo_rdy, 1 => dmacfgio_rdy) <= dmacfg_rdy;

--	dev_req <= (0 => dmavideo_req, 1 => dmaio_req);
	dev_req <= (0 => '0', 1 => dmaio_req);
	(0 => dmavideo_rdy, 1 => dmaio_rdy) <= dev_rdy;
	dev_len    <= dmavideo_len  & dmaio_len;
	dev_addr   <= dmavideo_addr & dmaio_addr;
	dev_we     <= "1"           & "0";

	dmactlr_e : entity hdl4fpga.dmactlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => ctlr_tcp,

		bank_size   => ddr3_b'length,
		addr_size   => ddr3_a'length,
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
		tcp          => ctlr_tcp,

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
		ctlr_rst     => ddr_rst,
		ctlr_clks(0) => ctlr_clk,

		ctlr_bl      => "000",
		ctlr_cl      => "100",

		ctlr_cwl     => "001",
		ctlr_wr      => "101",
		ctlr_rtt     => "001",

		ctlr_inirdy  => ctlr_inirdy,
		ctlr_wlreq  => ctlrphy_wlreq,
		ctlr_wlrdy  => ctlrphy_wlrdy,

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
		ctlr_dm      => ctlr_dm,
		ctlr_do_dv   => ctlr_do_dv,
		ctlr_do      => ctlr_do,
		ctlr_refreq  => ctlr_refreq,
		ctlr_dio_req => ctlr_dio_req,

		phy_rst      => ctlrphy_rst,
		phy_cke      => ctlrphy_cke,
		phy_cs       => ctlrphy_cs,
		phy_ras      => ctlrphy_ras,
		phy_cas      => ctlrphy_cas,
		phy_we       => ctlrphy_we,
		phy_b        => ddrphy_b(ddr3_b'range),
		phy_a        => ddrphy_a(ddr3_a'range),
		phy_dmi      => ctlrphy_dmi,
		phy_dmt      => ctlrphy_dmt,
		phy_dmo      => ctlrphy_dmo,
                               
		phy_dqi      => ctlrphy_dqi,
		phy_dqt      => ctlrphy_dqt,
		phy_dqo      => ctlrphy_dqo,
		phy_sti      => ctlrphy_sti,
		phy_sto      => ctlrphy_sto,
                                
		phy_dqsi     => ctlrphy_dqsi,
		phy_dqso     => ctlrphy_dqso,
		phy_dqst     => ctlrphy_dqst);

	ddrphy_rst <= (others => ctlrphy_rst);
	ddrphy_cs  <= (others => ctlrphy_cs);
	ddrphy_cke <= (others => ctlrphy_cke);
	ddrphy_ras <= (others => ctlrphy_ras);
	ddrphy_cas <= (others => ctlrphy_cas);
	ddrphy_we  <= (others => ctlrphy_we);
	ddrphy_odt <= (others => ctlrphy_odt);

	ddrphy_e : entity hdl4fpga.ecp3_ddrphy
	generic map (
		tCP       => ddrphy_tcp,
		cmmd_gear => cmmd_gear,
		bank_size => ddr3_b'length,
		addr_size => ddr3_a'length,
		data_gear => DATA_GEAR,
		word_size => word_size,
		byte_size => byte_size)
	port map (
		sys_sclk   => ddr_sclk,
		sys_sclk2x => ddr_sclk2x, 
		sys_eclk   => ddr_eclk,
		phy_rst    => ddr_rst,

		sys_rst   => ddrphy_rst,
		sys_wlreq => ctlrphy_wlreq,
		sys_wlrdy => ctlrphy_wlrdy,
		sys_cke   => ddrphy_cke,
		sys_cs    => ddrphy_cs,
		sys_ras   => ddrphy_ras,
		sys_cas   => ddrphy_cas,
		sys_we    => ddrphy_we,
		sys_b     => ddrphy_b,
		sys_a     => ddrphy_a,
		sys_dqsi  => ctlrphy_dqso,
		sys_dqst  => ctlrphy_dqst,
		sys_dqso  => ctlrphy_dqsi,
		sys_dmi   => ctlrphy_dmo,
		sys_dmt   => ctlrphy_dmt,
		sys_dmo   => ctlrphy_dmi,
		sys_dqi   => ctlrphy_dqo,
		sys_dqt   => ctlrphy_dqt,
		sys_dqo   => ctlrphy_dqi,
		sys_odt   => ddrphy_odt,
		sys_sti   => ctlrphy_sto,
		sys_sto   => ctlrphy_sti,
		sys_pll   => ddrphy_pll ,

		ddr_rst   => ddr3_rst,
		ddr_ck    => ddr3_clk,
		ddr_cke   => ddr3_cke,
		ddr_odt   => ddr3_odt,
		ddr_cs    => ddr3_cs,
		ddr_ras   => ddr3_ras,
		ddr_cas   => ddr3_cas,
		ddr_we    => ddr3_we,
		ddr_b     => ddr3_b,
		ddr_a     => ddr3_a,

--		ddr_dm    => ddr3_dm,
		ddr_dq    => ddr3_dq,
		ddr_dqs   => ddr3_dqs);
	ddr3_dm <= (others => '0');

	phy1_rst  <= not fpga_gsrn;
	phy1_mdc  <= '0';
	phy1_mdio <= '0';

	gtx_clk_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

	process (ddr_sclk, sys_rst)
		variable led1 : std_logic_vector(led'range);
		variable led2 : std_logic_vector(led'range);
	begin
		if rising_edge(ddr_sclk) then
			led  <= led2;
			led2 := led1;
			led1 := (1 to 4 => '1') & not ddrpll_pha;
		end if;
	end process;

end;
