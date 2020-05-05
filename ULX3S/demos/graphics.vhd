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

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx3s is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --  20     --  25     --  10     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------

	constant sys_per      : real    := 50.0;
	constant ddr_mul      : natural := 25; --(10/1) 200 (25/3) 166, (20/3) 133
	constant ddr_div      : natural := 3;

	constant fpga         : natural := spartan3;
	constant mark         : natural := m6t;
	constant tcp          : natural := (natural(sys_per)*ddr_div*1000)/(ddr_mul); -- 1 ns /1ps

	constant sclk_phases  : natural := 4;
	constant sclk_edges   : natural := 2;
	constant cmmd_gear    : natural := 1;
	constant data_phases  : natural := 2;
	constant data_edges   : natural := 2;
	constant bank_size    : natural := sdram_ba'length;
	constant addr_size    : natural := sdram_a'length;
	constant coln_size    : natural := 10;
	constant data_gear    : natural := 2;
	constant word_size    : natural := sdram_d'length;
	constant byte_size    : natural := 8;

	signal ddrsys_lckd    : std_logic;
	signal ddrsys_rst     : std_logic;

	constant clk0         : natural := 0;
	constant clk90        : natural := 1;
	signal ddrsys_clks    : std_logic_vector(0 to 2-1);

	signal dmactlr_len    : std_logic_vector(24-1 downto 2);
	signal dmactlr_addr   : std_logic_vector(24-1 downto 2);

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
	signal ctlr_pre       : std_logic;
	signal ctlr_idl       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_r         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal graphics_di    : std_logic_vector(data_gear*word_size-1 downto 0);
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
	signal ddrphy_b       : std_logic_vector(cmmd_gear*sdram_ba'length-1 downto 0);
	signal ddrphy_a       : std_logic_vector(cmmd_gear*sdram_a'length-1 downto 0);
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
	signal sdram_st_dqs_open : std_logic;

	signal sdram_dst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqt      : std_logic_vector(sdram_d'range);
	signal sdram_do       : std_logic_vector(sdram_d'range);

	signal video_clk      : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_hzon     : std_logic;
    signal video_vton     : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);

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
		mode      : natural;
		clkok_div : natural;
		clkop_div : natural;
		clkfb_div : natural;
		clki_div  : natural;
	end record;

	constant modedebug : natural := 0;
	constant mode600p  : natural := 1;
	constant mode1080p : natural := 2;

	type displayparam_vector is array (natural range <>) of display_param;
	constant video_params : displayparam_vector := (
		modedebug => (mode => 16, clkok_div => 2, clkop_div =>  4, clkfb_div => 3, clki_div => 2),
		mode600p  => (mode => 1, clkok_div => 2, clkop_div => 16, clkfb_div => 2, clki_div => 5),
		mode1080p => (mode => 7, clkok_div => 2, clkop_div =>  4, clkfb_div => 3, clki_div => 2));

	constant video_mode : natural := modedebug;

	alias dmacfg_clk : std_logic is sys_clk;
	alias ctlr_clk : std_logic is ddrsys_clks(clk0);

	constant baudrate      : natural := 115200;

begin

	sys_rst <= '0';
	sys_clk <= clk_25mhz;

	video_b : block

		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKI  of PLL_I : label is "25.000000";
		attribute FREQUENCY_PIN_CLKOP of PLL_I : label is "150.000000";

	begin
		PLL_I : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			PLL_LOCK_MODE    =>  0, 
			INTFB_WAKE       => "DISABLED", 
			FEEDBK_PATH      => "CLKOP",
			STDBY_ENABLE     => "DISABLED", DPHASE_SOURCE  => "DISABLED", 
			CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 0, CLKOS3_CPHASE =>  99,
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE =>   8,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  =>  14, 
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  =>   2,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS3_DIV       =>  100, 
			CLKOS_DIV        => video_params(video_mode).clkok_div,
			CLKOP_DIV        => video_params(video_mode).clkop_div,
			CLKFB_DIV        => video_params(video_mode).clkfb_div,
			CLKI_DIV         => video_params(video_mode).clki_div)
        port map (
			rst       => '0', 
			clki      => clk_25mhz,
			CLKFB     => video_clk, 
            PHASESEL0 => '0', PHASESEL1 => '0', 
			PHASEDIR  => '0', 
            PHASESTEP => '0', PHASELOADREG => '0', 
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0', 
			ENCLKOS   => '0',
			ENCLKOS2  => '0', 
            ENCLKOS3  => '0', 
			CLKOP     => video_clk, 
			CLKOS     => open, --CLKOS_t, 
            CLKOS2    => open, --CLKOS2_t, 
			CLKOS3    => open, --CLKOS3_t, 
			LOCK      => open, --LOCK, 
            INTLOCK   => open, 
			REFCLK    => open, --REFCLK, 
			CLKINTFB  => open);

	end block;

--	ddrdcm_e : entity hdl4fpga.dfsdcm
--	generic map (
--		dcm_per => sys_per,
--		dfs_mul => ddr_mul,
--		dfs_div => ddr_div)
--	port map (
--		dfsdcm_rst   => sys_rst,
--		dfsdcm_clkin => sys_clk,
--		dfsdcm_clk0  => ddrsys_clks(clk0),
--		dfsdcm_clk90 => ddrsys_clks(clk90),
--		dfsdcm_lckd  => ddrsys_lckd);
	ddrsys_rst <= not ddrsys_lckd;

	scopeio_export_b : block

		alias  uart_rxc    : std_logic_vector is sys_clk;
		signal uart_ena    : std_logic;
		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(8-1 downto 0);

		alias  si_clk      : std_logic_vector is sys_clk;
		signal si_frm      : std_logic;
		signal si_irdy     : std_logic;
		signal si_data     : std_logic_vector(uart_rxd'range);

		signal rgtr_id     : std_logic_vector(8-1 downto 0);
		signal rgtr_dv     : std_logic;
		signal rgtr_idv    : std_logic;
		signal rgtr_data   : std_logic_vector(32-1 downto 0);

		signal data_ena    : std_logic;
		signal data_len    : std_logic_vector(8-1 downto 0);
		signal dmadata_ena : std_logic;

	begin

		process (uart_rxc)
			constant max_count : natural := (25*10**6+16*baudrate/2)/(16*baudrate);
			variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
		begin
			if rising_edge(uart_rxc) then
				if cntr = max_count-1 then
					uart_ena <= '1';
					cntr := (others => '0');
				else
					uart_ena <= '0';
					cntr := cntr + 1;
				end if;
			end if;
		end process;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => 16*baudrate)
		port map (
			uart_rxc  => uart_rxc,
			uart_sin  => ftdi_txd,
			uart_ena  => uart_ena,
			uart_rxdv => uart_rxdv,
			uart_rxd  => uart_rxd);

		scopeio_istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
		generic map (
			istream_esc => std_logic_vector(to_unsigned(character'pos('\'), 8)),
			istream_eos => std_logic_vector(to_unsigned(character'pos(NUL), 8)))
		port map (
			stream_clk  => uart_rxc,
			stream_ena  => uart_ena,
			stream_dv   => uart_rxdv,
			stream_data => uart_rxd,

			chaini_data => uart_rxd,

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
			rgtr_idv  => rgtr_idv,
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
			size           => 64,
			gray_code      => false,
			overflow_check => false)
		port map (
			src_clk  => si_clk,
			src_irdy => dmadata_ena,
			src_data => rgtr_data,

			dst_clk  => ctlr_clk,
			dst_irdy => ctlr_di_dv,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

--		ctlr_di_dv <= ctlr_di_req;
--		ctlr_di <= x"00ffff00"; --(others => '1');

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

	graphics_di <= ctlr_do;
--	graphics_di <= ctlr_r(8-1 downto 0) & ctlr_r(8-1 downto 0) & ctlr_r(8-1 downto 0) & ctlr_r(8-1 downto 0);
	graphics_e : entity hdl4fpga.graphics
	generic map (
		video_mode => video_params(video_mode).mode)
	port map (
		dma_req      => dmacfgvideo_req,
		dma_rdy      => dmavideo_rdy,
		dma_len      => dmavideo_len,
		dma_addr     => dmavideo_addr,
		ctlr_clk     => ctlr_clk,
		ctlr_di_dv   => ctlr_do_dv(0),
		ctlr_di      => graphics_di,
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_hzon   => video_hzon,
		video_vton   => video_vton,
		video_pixel  => video_pixel);

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
		bank_size   => sdram_ba'length,
		addr_size   => sdram_a'length,
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
		ctlr_act    => ctlr_act,
		ctlr_pre    => ctlr_pre,
		ctlr_idl    => ctlr_idl);

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
		ctlr_pre     => ctlr_pre,
		ctlr_idl     => ctlr_idl,
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

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		loopback    => false,
		rgtr_dout   => false,
		bank_size   => sdram_ba'length,
		addr_size   => sdram_a'length,
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

		ddr_sto(0)  => sdram_st_dqs,
		ddr_sto(1)  => sdram_st_dqs_open,
		ddr_sti(0)  => sdram_st_lp_dqs,
		ddr_sti(1)  => sdram_st_lp_dqs,
		ddr_clk     => sdram_clk,
		ddr_cke     => sdram_cke,
		ddr_cs      => sdram_csn,
		ddr_ras     => sdram_rasn,
		ddr_cas     => sdram_casn,
		ddr_we      => sdram_wen,
		ddr_b       => sdram_ba,
		ddr_a       => sdram_a,

		ddr_dm      => sdram_dqm,
		ddr_dqt     => sdram_dqt,
		ddr_dqi     => sdram_d,
		ddr_dqo     => sdram_do,
		ddr_dqst    => sdram_dst,
		ddr_dqsi    => sdram_ds,
		ddr_dqso    => sdram_dso);

	sdram_dqs_g : for i in sdram_ds'range generate
		sdram_ds(i) <= sdram_dso(i);
	end generate;

	process (sdram_dqt, sdram_do)
	begin
		for i in sdram_d'range loop
			sdram_d(i) <= 'Z';
			if sdram_dqt(i)='0' then
				sdram_d(i) <= sdram_do(i);
			end if;
		end loop;
	end process;

	sdram_clk : oddrxd1
	port map (
		sclk => ctlr_clk,
		da   => '0',
		db   => '1',
		q    => sdram_clk);


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

	process (si_clk)
		variable t : std_logic;
		variable e : std_logic;
		variable i : std_logic;
	begin
		if rising_edge(si_clk) then
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

end;
