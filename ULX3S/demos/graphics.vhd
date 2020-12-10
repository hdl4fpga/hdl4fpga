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

	constant sys_per      : real    := 1000.0 / 25.0;

	constant fpga         : natural := spartan3;
	constant mark         : natural := M7E;

	constant sclk_phases  : natural := 1;
	constant sclk_edges   : natural := 1;
	constant data_phases  : natural := 1;
	constant data_edges   : natural := 1;
	constant data_gear    : natural := 1;
	constant bank_size    : natural := sdram_ba'length;
	constant addr_size    : natural := sdram_a'length;
	constant coln_size    : natural := 10;
	constant word_size    : natural := sdram_d'length;
	constant byte_size    : natural := 8;

	signal ddrsys_rst     : std_logic;
	signal ddrsys_clks    : std_logic_vector(0 to 0);

	signal dmactlr_len    : std_logic_vector(24-1 downto 0);
	signal dmactlr_addr   : std_logic_vector(24-1 downto 0);

	signal dmacfgio_req   : std_logic;
	signal dmacfgio_rdy   : std_logic;
	signal dmaio_req      : std_logic := '0';
	signal dmaio_rdy      : std_logic;
	signal dmaio_len      : std_logic_vector(dmactlr_len'range);
	signal dmaio_addr     : std_logic_vector(dmactlr_addr'range);
	signal dmaio_trdy     : std_logic;
	signal dmaiolen_irdy  : std_logic;
	signal dmaioaddr_irdy : std_logic;


	signal sdram_dqs      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlr_irdy      : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_act       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_r         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(word_size-1 downto 0);
	signal ctlr_dm        : std_logic_vector(word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv     : std_logic;
	signal ctlr_di_req    : std_logic;
	signal ctlr_dio_req   : std_logic;

	signal ctlrphy_rst    : std_logic;
	signal ctlrphy_cke    : std_logic;
	signal ctlrphy_cs     : std_logic;
	signal ctlrphy_ras    : std_logic;
	signal ctlrphy_cas    : std_logic;
	signal ctlrphy_we     : std_logic;
	signal ctlrphy_odt    : std_logic;
	signal ctlrphy_b      : std_logic_vector(sdram_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector(sdram_a'length-1 downto 0);
	signal ctlrphy_dsi    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_dst    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dso    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(word_size-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal sdrphy_sti     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal sdram_st_dqs_open : std_logic;

	signal sdram_dst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqt      : std_logic_vector(sdram_d'range);
	signal sdram_do       : std_logic_vector(sdram_d'range);

	signal video_clk      : std_logic;
	signal video_shift_clk : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_vton     : std_logic;
    signal video_blank     : std_logic;
    signal video_on       : std_logic;
    signal video_pixel    : std_logic_vector(0 to ctlr_di'length-1);
    signal base_addr      : std_logic_vector(dmactlr_addr'range);
	signal dvid_crgb      : std_logic_vector(7 downto 0);

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

	constant modedebug : natural := 0;
	constant mode600p  : natural := 1;

	type video_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos3_div : natural;
		mode       : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug  => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos3_div => 2, mode => pclk_debug),
		mode600p   => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos3_div => 2, mode => pclk40_00m800x600at60));
	constant video_mode : natural := mode600p;


	type sdram_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos3_div : natural;
		cas        : std_logic_vector(0 to 3-1);
	end record;

	type sdram_vector is array (natural range <>) of sdram_params;
	constant sdram133MHz : natural := 0;
	constant sdram200MHz : natural := 1;

	type sdramparams_vector is array (natural range <>) of sdram_params;
	constant sdram_tab : sdramparams_vector := (
		sdram133MHz => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos3_div => 3, cas => "010"),
		sdram200MHz => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos3_div => 2, cas => "011"));

--	constant sdram_mode : natural := sdram133MHz;
	constant sdram_mode : natural := sdram200MHz;

	constant ddr_tcp   : natural := 
		(1000*natural(sys_per)*sdram_tab(sdram_mode).clki_div*sdram_tab(sdram_mode).clkos3_div)/
		(sdram_tab(sdram_mode).clkfb_div*sdram_tab(sdram_mode).clkop_div);
	alias ctlr_clk     : std_logic is ddrsys_clks(0);

	alias uart_rxc     : std_logic is clk_25mhz;
	constant uart_xtal : natural := natural(10.0**9/real(sys_per));
	constant baudrate  : natural := 3000000;
--	constant baudrate  : natural := 115200;

--	alias uart_rxc     : std_logic is video_clk;
--	constant uart_xtal : natural := natural(
--		real(video_tab(video_mode).clkfb_div*video_tab(video_mode).clkop_div)*1.0e9/
--		real(video_tab(video_mode).clki_div)/10.0/sys_per);
--	constant baudrate  : natural := 2_000_000;

--	alias uart_rxc     : std_logic is ctlr_clk;
--	constant uart_xtal : natural := natural(
--		real(sdram_tab(sdram_mode).clkfb_div*sdram_tab(sdram_mode).clkop_div)*1.0e9/
--		real(sdram_tab(sdram_mode).clki_div*sdram_tab(sdram_mode).clkos3_div)/sys_per);
--	constant baudrate  : natural := 3_000_000;

--	alias uart_rxc     : std_logic is ctlr_clk;
--	constant uart_xtal : natural := natural(10.0**9/(real(ddr_tcp)/1000.0));
--	constant baudrate  : natural := 115200_00;
--	constant video_mode : natural := modedebug;

	signal uart_rxdv   : std_logic;
	signal uart_rxd    : std_logic_vector(8-1 downto 0);
	signal uart_idle   : std_logic;
	signal uart_txen   : std_logic;
	signal uart_txd    : std_logic_vector(8-1 downto 0);


	alias sio_clk      : std_logic is uart_rxc;
	signal sio_frm : std_logic;
	alias dmacfg_clk   : std_logic is uart_rxc;

	constant cmmd_latency  : boolean := sdram_mode=sdram200MHz;
	constant read_latency  : boolean := not (sdram_mode=sdram200MHz);
	constant write_latency : boolean := not (sdram_mode=sdram200MHz);

begin

	sys_rst <= '0';
	videopll_b : block

		signal clkfb : std_logic;

		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKOS : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is  "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is  "25.000000";

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is "200.000000";
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is  "40.000000";

	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED", 
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED", 
			PLL_LOCK_MODE    =>  0, 
			FEEDBK_PATH      => "CLKOP",
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => 15,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0, 
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS3_DIV       => video_tab(video_mode).clkos3_div, 
			CLKOS2_DIV       =>  10, 
			CLKOS_DIV        => video_tab(video_mode).clkos_div,
			CLKOP_DIV        => video_tab(video_mode).clkop_div,
			CLKFB_DIV        => video_tab(video_mode).clkfb_div,
			CLKI_DIV         => video_tab(video_mode).clki_div)
        port map (
			rst       => '0', 
			clki      => clk_25mhz,
			CLKFB     => clkfb, 
            PHASESEL0 => '0', PHASESEL1 => '0', 
			PHASEDIR  => '0', 
            PHASESTEP => '0', PHASELOADREG => '0', 
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0', 
			ENCLKOS   => '0',
			ENCLKOS2  => '0', 
            ENCLKOS3  => '0', 
			CLKOP     => clkfb,
			CLKOS     => video_shift_clk,
            CLKOS2    => video_clk,
			LOCK      => open, 
            INTLOCK   => open, 
			REFCLK    => open, --REFCLK, 
			CLKINTFB  => open);

	end block;

	ctlrpll_b : block

		signal clkfb : std_logic;
		signal lock  : std_logic;
		signal dqs   : std_logic;

		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKOS : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is  "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is  "25.000000";

		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is "200.000000";
--		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is "133.333333";

		signal clkos : std_logic;
	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED", 
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED", 
			PLL_LOCK_MODE    =>  0, 
			FEEDBK_PATH      => "CLKOP",
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => 15,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0, 
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 4, CLKOS3_CPHASE => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKI_DIV         => sdram_tab(sdram_mode).clki_div,
			CLKFB_DIV        => sdram_tab(sdram_mode).clkfb_div,
			CLKOP_DIV        => sdram_tab(sdram_mode).clkop_div,
			CLKOS_DIV        => sdram_tab(sdram_mode).clkos_div,
			CLKOS2_DIV       => sdram_tab(sdram_mode).clkos3_div, 
			CLKOS3_DIV       => sdram_tab(sdram_mode).clkos3_div) 
        port map (
			rst       => '0', 
			clki      => clk_25mhz,
			CLKFB     => clkfb, 
            PHASESEL0 => '0', PHASESEL1 => '0', 
			PHASEDIR  => '0', 
            PHASESTEP => '0', PHASELOADREG => '0', 
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0', 
			ENCLKOS   => '0',
			ENCLKOS2  => '0', 
            ENCLKOS3  => '0', 
			CLKOP     => clkfb,
			CLKOS     => clkos,
			CLKOS2    => ctlr_clk,
			CLKOS3    => dqs, 
			LOCK      => lock, 
            INTLOCK   => open, 
			REFCLK    => open, --REFCLK, 
			CLKINTFB  => open);

		ddrsys_rst <= not lock;

		ctlrphy_dso <= (others => not ctlr_clk) when sdram_mode=sdram200MHz else (others => ctlr_clk);

	end block;

	sio_b : block

		constant fifo_depth  : natural := 2;

		constant rid_dmaaddr : std_logic_vector := x"16";
		constant rid_dmalen  : std_logic_vector := x"17";
		constant rid_dmadata : std_logic_vector := x"18";

		signal rgtr_frm      : std_logic;
		signal rgtr_irdy     : std_logic;
		signal rgtr_idv      : std_logic;
		signal rgtr_id       : std_logic_vector(8-1 downto 0);
		signal rgtr_lv       : std_logic;
		signal rgtr_len      : std_logic_vector(8-1 downto 0);
		signal rgtr_dv       : std_logic;
		signal rgtr_data     : std_logic_vector(32-1 downto 0);
		signal data_frm      : std_logic;
		signal data_irdy     : std_logic;
		signal data_ptr      : std_logic_vector(8-1 downto 0);

		signal sigrgtr_frm   : std_logic;

		signal sigram_irdy   : std_logic;
		signal ack_data      : std_logic_vector(8-1 downto 0);

		signal dmadata_irdy  : std_logic;
		signal dmadata_trdy  : std_logic;
		signal ctlrdata_trdy  : std_logic;
		signal dmaaddr_irdy  : std_logic;
		signal dmaaddr_trdy  : std_logic;
		signal dmalen_irdy   : std_logic;
		signal dmalen_trdy   : std_logic;
		signal dst_irdy      : std_logic;

		signal sin_frm       : std_logic;
		signal sin_irdy      : std_logic;
		signal sin_data      : std_logic_vector(8-1 downto 0);
		signal sou_frm       : std_logic;
		signal sou_irdy      : std_logic_vector(0 to 0); -- Xilinx ISE Bug;
		signal sou_trdy      : std_logic;
		signal sou_data      : std_logic_vector(8-1 downto 0);
		signal sig_data      : std_logic_vector(8-1 downto 0);
		signal sig_trdy      : std_logic;
		signal sig_end       : std_logic;
		signal siodmaio_irdy : std_logic;
		signal siodmaio_trdy : std_logic;
		signal siodmaio_end  : std_logic;
		signal sio_dmaio     : std_logic_vector(0 to ((2+4)+(2+4))*8-1);
		signal siodmaio_data : std_logic_vector(sou_data'range);

		signal tp1 : std_logic_vector(32-1 downto 0);
		signal tp2 : std_logic_vector(32-1 downto 0);

	begin

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => uart_rxc,
			uart_sin  => ftdi_txd,
			uart_rxdv => uart_rxdv,
			uart_rxd  => uart_rxd);

		siodayahdlc_e : entity hdl4fpga.sio_dayahdlc
		port map (
			uart_clk  => uart_rxc,
			uart_rxdv => uart_rxdv,
			uart_rxd  => uart_rxd,
			uart_idle => uart_idle,
			uart_txd  => uart_txd,
			uart_txen => uart_txen,
			sio_clk   => uart_rxc,
			si_data   => sin_data,
			so_frm    => sin_frm,
			so_irdy   => sin_irdy,
			so_data   => sin_data);

		scopeio_sin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => sin_frm,
			sin_irdy  => sin_irdy,
			sin_data  => sin_data,
			data_ptr  => data_ptr,
			data_frm  => data_frm,
			rgtr_irdy => rgtr_irdy,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		base_addr_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => x"19")
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			data      => base_addr);

		dmaaddr_irdy <= setif(rgtr_id=rid_dmaaddr) and rgtr_dv and rgtr_irdy;
		dmaaddr_e : entity hdl4fpga.fifo
		generic map (
			max_depth => fifo_depth,
			out_rgtr  => false,
			check_sov => true,
			check_dov => true,
			gray_code => true)
		port map (
			src_clk  => sio_clk,
			src_frm  => sio_frm,
			src_irdy => dmaaddr_irdy,
			src_trdy => dmaaddr_trdy,
			src_data => rgtr_data(dmaio_addr'length-1 downto 0),

			dst_clk  => dmacfg_clk,
			dst_irdy => dmaioaddr_irdy,
			dst_trdy => dmaio_trdy,
			dst_data => dmaio_addr);


		dmalen_irdy <= setif(rgtr_id=rid_dmalen) and rgtr_dv and rgtr_irdy;
		dmalen_e : entity hdl4fpga.fifo
		generic map (
			max_depth => fifo_depth,
			out_rgtr  => false,
			check_sov => true,
			check_dov => true,
			gray_code => true)
		port map (
			src_clk  => sio_clk,
			src_frm  => sio_frm,
			src_irdy => dmalen_irdy,
			src_trdy => dmalen_trdy,
			src_data => rgtr_data(dmaio_len'length-1 downto 0),

			dst_clk  => dmacfg_clk,
			dst_irdy => dmaiolen_irdy,
			dst_trdy => dmaio_trdy,
			dst_data => dmaio_len);

		dmadata_irdy <= data_irdy and setif(rgtr_id=rid_dmadata) and setif(data_ptr(1-1 downto 0)=(1-1 downto 0 => '0'));
--		dmadata_e : entity hdl4fpga.fifo
--		generic map (
--			max_depth => fifo_depth*(256/(ctlr_di'length/8)),
--			out_rgtr  => true,
--			check_sov => true,
--			check_dov => true,
--			gray_code => true)
--		port map (
--			src_clk  => sio_clk,
--			src_frm  => sio_frm,
--			src_irdy => dmadata_irdy,
--			src_trdy => dmadata_trdy,
--			src_data => rgtr_data(ctlr_di'length-1 downto 0),
--
--			dst_clk  => ctlr_clk,
--			dst_irdy => ctlr_di_dv,
----			dst_trdy => ctlr_di_req,
--			dst_trdy => ctlrdata_trdy,
--			dst_data => ctlr_di);
--
--		process (ctlr_di_req, ctlr_clk)
--			variable q : std_logic;
--		begin
--			if rising_edge(ctlr_clk) then
--				if ctlr_di_req='1' then
--					if ctlr_di_dv='0' then
--						q := '1';
--					end if;
--				else
--					q := '0';
--				end if;
--			end if;
--			ctlrdata_trdy <= ctlr_di_req or q;
--		end process;

		dmadata_e : entity hdl4fpga.fifo
		generic map (
			max_depth => fifo_depth*(256/(ctlr_di'length/8)),
			out_rgtr  => not write_latency,
			check_sov => false,
			check_dov => false,
			gray_code => false)
		port map (
			src_clk  => sio_clk,
			src_frm  => sio_frm,
			src_irdy => dmadata_irdy,
			src_data => rgtr_data(ctlr_di'length-1 downto 0),

			dst_clk  => ctlr_clk,
			dst_irdy => dst_irdy,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

		ctlr_di_dv <= dst_irdy and ctlr_di_req; 
		ctlr_dm <= (others => '0');

		dmacfgio_p : process (dmacfg_clk)
			variable dmaio_rdy1 : std_logic;
			variable dmaio_rdy2 : std_logic;
			variable io_rdy1    : std_logic;
			variable io_rdy2    : std_logic;
		begin
			if rising_edge(dmacfg_clk) then
				sio_frm <= '1';
				if ctlr_inirdy='0' then
					dmacfgio_req <= '0';
					dmaio_trdy   <= '0';
					sio_frm <= '0';
				elsif dmacfgio_req='0' then
					if dmaio_rdy2='1' then
						if dmaio_trdy='0' then
							dmacfgio_req <= not dmacfgio_rdy;
						end if;
					end if;
					dmaio_trdy <= '0';
				elsif io_rdy1='1' then
					if io_rdy2='0' then
						dmacfgio_req <= '0';
						dmaio_trdy   <= '1';
					else
						dmaio_trdy   <= '1';
					end if;
				else
					dmaio_trdy <= '0';
				end if;
				io_rdy2 := io_rdy1;
				io_rdy1 := dmaio_rdy;
				
				dmaio_rdy2 := dmaio_rdy1;
				dmaio_rdy1 := dmaiolen_irdy and dmaioaddr_irdy;
			end if;
		end process;

	end block;

	mii_debug_e : entity hdl4fpga.mii_debug
	generic map (
		default_ipv4a => x"00_00_00_00",
		cga_bitrom => to_ascii("Ready Steady GO!"),
		timing_id  => video_tab(video_mode).timing_id)
	port map (
		mii_rxc   => mii_rxc,
		mii_rxd   => mii_rxd,
		mii_rxdv  => mii_rxdv,

		mii_txc   => mii_txc,
		dhcp_req  => dhcp_req,
		mii_txd   => mii_txd,
		mii_txen  => mii_txen,
		tp => tp,

		video_clk => video_clk, 
		video_dot => video_dot,
		video_on  => video_on,
		video_hs  => video_hzsync,
		video_vs  => video_vtsync);

--	adapter_b : block
--		constant mode : videotiming_ids := video_tab(video_mode).mode;
--		constant sync_lat : natural := 4;
--		signal hzcntr : std_logic_vector(unsigned_num_bits(modeline_tab(mode)(3)-1)-1 downto 0);
--		signal vtcntr : std_logic_vector(unsigned_num_bits(modeline_tab(mode)(7)-1)-1 downto 0);
--		signal hzsync : std_logic;
--		signal vtsync : std_logic;
--		signal hzon   : std_logic;
--		signal vton   : std_logic;
--
--		signal graphics_di : std_logic_vector(ctlr_do'range);
--		signal graphics_dv : std_logic;
--		signal pixel  : std_logic_vector(video_pixel'range);
--	begin
--		sync_e : entity hdl4fpga.video_sync
--		generic map (
--			timing_id => mode)
--		port map (
--			video_clk     => video_clk,
--			video_hzcntr  => hzcntr,
--			video_vtcntr  => vtcntr,
--			video_hzsync  => hzsync,
--			video_vtsync  => vtsync,
--			video_hzon    => hzon,
--			video_vton    => vton);
--
--		tographics_e : entity hdl4fpga.align
--		generic map (
--			n => ctlr_do'length+1,
--			d => (0 to ctlr_do'length => 1))
--		port map (
--			clk => ctlr_clk,
--			di(0 to ctlr_do'length-1) => ctlr_do,
--			di(ctlr_do'length) => ctlr_do_dv(0),
--			do(0 to ctlr_do'length-1) => graphics_di,
--			do(ctlr_do'length) => graphics_dv);
--
--		graphics_e : entity hdl4fpga.graphics
--		generic map (
--			video_width => modeline_tab(video_tab(video_mode).mode)(0))
--		port map (
--			ctlr_clk     => ctlr_clk,
--			ctlr_di_dv   => graphics_dv,
--			ctlr_di      => graphics_di,
--			base_addr    => base_addr,
--			dma_req      => dmacfgvideo_req,
--			dma_rdy      => dmavideo_rdy,
--			dma_len      => dmavideo_len,
--			dma_addr     => dmavideo_addr,
--			video_clk    => video_clk,
--			video_hzon   => hzon,
--			video_vton   => vton,
--			video_pixel  => pixel);
--
--		topixel_e : entity hdl4fpga.align
--		generic map (
--			n => pixel'length,
--			d => (0 to pixel'length-1 => sync_lat-1))
--		port map (
--			clk => video_clk,
--			di  => pixel,
--			do  => video_pixel);
--
--		tosync_e : entity hdl4fpga.align
--		generic map (
--			n => 4,
--			d => (0 to 4-1 => sync_lat))
--		port map (
--			clk => video_clk,
--			di(0) => hzon,
--			di(1) => vton,
--			di(2) => hzsync,
--			di(3) => vtsync,
--			do(0) => video_hzon,
--			do(1) => video_vton,
--			do(2) => video_hzsync,
--			do(3) => video_vtsync);
--
--		video_blank <= not video_hzon or not video_vton;
--	end block;

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
		tcp          => ddr_tcp,

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
		ctlr_act    => ctlr_act);

	ddrctlr_e : entity hdl4fpga.ddr_ctlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => ddr_tcp,

		cmmd_gear    => 1,
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
		ctlr_bl      => "000",
		ctlr_cl      => sdram_tab(sdram_mode).cas,

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
		phy_b        => ctlrphy_b,
		phy_a        => ctlrphy_a,
		phy_dmi      => ctlrphy_dmi,
		phy_dmt      => ctlrphy_dmt,
		phy_dmo      => ctlrphy_dmo,
                               
		phy_dqi      => ctlrphy_dqi,
		phy_dqt      => ctlrphy_dqt,
		phy_dqo      => ctlrphy_dqo,
		phy_sti      => ctlrphy_sti,
		phy_sto      => ctlrphy_sto,
                                
		phy_dqsi     => ctlrphy_dsi,
		phy_dqso     => open,
		phy_dqst     => ctlrphy_dst);

	sdram_sti : entity hdl4fpga.align
	generic map (
		n => sdrphy_sti'length,
		d => (0 to sdrphy_sti'length-1 => setif(sdram_mode=sdram200MHz, 1, 0)))
	port map (
		clk => ctlr_clk,
		di  => ctlrphy_sto,
		do  => sdrphy_sti);
	
	sdrphy_e : entity hdl4fpga.sdrphy
	generic map (
		cmmd_latency  => sdram_mode=sdram200MHz,
		read_latency  => not (sdram_mode=sdram200MHz),
		write_latency => write_latency, 
		bank_size   => sdram_ba'length,
		addr_size   => sdram_a'length,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		sys_clk     => ctlr_clk,
		sys_rst     => ddrsys_rst,

		phy_cs      => ctlrphy_cs,
		phy_cke     => ctlrphy_cke,
		phy_ras     => ctlrphy_ras,
		phy_cas     => ctlrphy_cas,
		phy_we      => ctlrphy_we,
		phy_b       => ctlrphy_b,
		phy_a       => ctlrphy_a,
		phy_dsi     => ctlrphy_dso,
		phy_dst     => ctlrphy_dst,
		phy_dso     => ctlrphy_dsi,
		phy_dmi     => ctlrphy_dmo,
		phy_dmt     => ctlrphy_dmt,
		phy_dmo     => ctlrphy_dmi,
		phy_dqi     => ctlrphy_dqo,
		phy_dqt     => ctlrphy_dqt,
		phy_dqo     => ctlrphy_dqi,
		phy_sti     => sdrphy_sti,
		phy_sto     => ctlrphy_sti,

		sdr_clk     => sdram_clk,
		sdr_cke     => sdram_cke,
		sdr_cs      => sdram_csn,
		sdr_ras     => sdram_rasn,
		sdr_cas     => sdram_casn,
		sdr_we      => sdram_wen,
		sdr_b       => sdram_ba,
		sdr_a       => sdram_a,

		sdr_dm      => sdram_dqm,
		sdr_dq      => sdram_d);

	process (uart_rxc)
		variable t : std_logic;
		variable e : std_logic;
		variable i : std_logic;
	begin
		if rising_edge(uart_rxc) then
			if uart_rxdv='1' then
				led <= uart_rxd;
			end if;
		end if;
	end process;

	-- VGA --
	---------

	dvi_b : block
		signal dvid_blank : std_logic;
	begin
		dvid_blank <= video_blank;

		vga2dvid_e : entity hdl4fpga.vga2dvid
		generic map (
			C_shift_clock_synchronizer => '0',
			C_ddr   => '1',
			C_depth => 5)
		port map (
			clk_pixel => video_clk,
			clk_shift => video_shift_clk,
			in_red    => video_pixel(0   to  0+5-1),
			in_green  => video_pixel(0+5 to  5+5-1),
			in_blue   => video_pixel(6+5 to 11+5-1),
			in_hsync  => video_hzsync,
			in_vsync  => video_vtsync,
			in_blank  => dvid_blank,
			out_clock => dvid_crgb(7 downto 6),
			out_red   => dvid_crgb(5 downto 4),
			out_green => dvid_crgb(3 downto 2),
			out_blue  => dvid_crgb(1 downto 0));

		ddr_g : for i in gpdi_dp'range generate
			signal q : std_logic;
		begin
			oddr_i : oddrx1f
			port map(
				sclk => video_shift_clk,
				rst  => '0',
				d0   => dvid_crgb(2*i),
				d1   => dvid_crgb(2*i+1),
				q    => q);
			olvds_i : olvds 
			port map(
				a  => q,
				z  => gpdi_dp(i),
				zn => gpdi_dn(i));
		end generate;
	end block;

end;
