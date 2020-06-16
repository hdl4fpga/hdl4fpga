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

architecture ddr of ulx3s is

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

	signal dmaicfg_req    : std_logic;
	signal dmaicfg_rdy    : std_logic;
	signal dmai_req       : std_logic;
	signal dmai_rdy       : std_logic;
	signal dmai_len       : std_logic_vector(dmactlr_len'range);
	signal dmai_addr      : std_logic_vector(dmactlr_addr'range);
	signal dmai_dv        : std_logic;

	signal dmaocfg_req    : std_logic;
	signal dmaocfg_rdy    : std_logic;
	signal dmao_req       : std_logic;
	signal dmao_rdy       : std_logic;
	signal dmao_len       : std_logic_vector(dmactlr_len'range);
	signal dmao_addr      : std_logic_vector(dmactlr_addr'range);

	signal dmacfg_req     : std_logic_vector(0 to 2-1);
	signal dmacfg_rdy     : std_logic_vector(0 to 2-1); 
	signal dev_len        : std_logic_vector(0 to 2*dmactlr_len'length-1);
	signal dev_addr       : std_logic_vector(0 to 2*dmactlr_addr'length-1);
	signal dev_we         : std_logic_vector(0 to 2-1);

	signal dev_req : std_logic_vector(0 to 2-1);
	signal dev_rdy : std_logic_vector(0 to 2-1); 

	signal ctlr_irdy      : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_act       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_ras       : std_logic;
	signal ctlr_cas       : std_logic;
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

	signal sdram_dqs      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal sdram_dqt      : std_logic_vector(sdram_d'range);
	signal sdram_do       : std_logic_vector(sdram_d'range);

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

--	alias uart_rxc     : std_logic is clk_25mhz;
--	alias uart_txc     : std_logic is clk_25mhz;
--	constant uart_xtal : natural := natural(10.0**9/real(sys_per));
--	constant baudrate  : natural := 115200;
--	constant baudrate  : natural := 1000000;

	alias uart_rxc     : std_logic is ctlr_clk;
	alias uart_txc     : std_logic is ctlr_clk;
	constant uart_xtal : natural := natural(
		real(sdram_tab(sdram_mode).clkfb_div*sdram_tab(sdram_mode).clkop_div)*1.0e9/
		real(sdram_tab(sdram_mode).clki_div*sdram_tab(sdram_mode).clkos3_div)/sys_per);
	constant baudrate  : natural := 3000000;

--	constant uart_xtal : natural := natural(10.0**9/(real(ddr_tcp)/1000.0));
--	constant baudrate  : natural := 115200_00;
--	constant video_mode : natural := modedebug;

	alias si_clk       : std_logic is uart_rxc;
	alias dmacfg_clk   : std_logic is uart_rxc;

	constant cmmd_latency  : boolean := sdram_mode=sdram200MHz;
	constant read_latency  : boolean := not (sdram_mode=sdram200MHz);
	constant write_latency : boolean := not (sdram_mode=sdram200MHz);

begin

	sys_rst <= '0';
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

	scopeio_export_b : block

		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(8-1 downto 0);

		signal uart_trdy   : std_logic;
		signal uart_txdv   : std_logic;
		signal uart_txd    : std_logic_vector(8-1 downto 0);

		signal si_frm       : std_logic;
		signal si_irdy      : std_logic;
		signal si_data      : std_logic_vector(uart_rxd'range);

		signal rgtr_id      : std_logic_vector(8-1 downto 0);
		signal rgtr_dv      : std_logic;
		signal rgtr_data    : std_logic_vector(32-1 downto 0);

		signal dmaia_dv     : std_logic;
		signal fifoi_frm    : std_logic;
		signal data_ena     : std_logic;

		signal data_ptr     : std_logic_vector(8-1 downto 0);
		signal dmaidata_ena : std_logic;
		signal dst_irdy     : std_logic;

		signal dmao_dv    : std_logic;
		signal fifoo_frm  : std_logic;
		signal fifoo_irdy : std_logic;
		signal fifoo_trdy : std_logic;
		signal fifoo_data : std_logic_vector(ctlr_do'range);
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

		scopeio_istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
		generic map (
			istream_esc => std_logic_vector(to_unsigned(character'pos('\'), 8)),
			istream_eos => std_logic_vector(to_unsigned(character'pos(NUL), 8)))
		port map (
			stream_clk  => uart_rxc,
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
			data_ptr  => data_ptr,
			data_ena  => data_ena,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		dmiaaddr_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmaaddr)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmaia_dv,
			data      => dmai_addr);

		dmailen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmalen)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmai_dv,
			data      => dmai_len);

		dmaidata_ena <= data_ena and setif(rgtr_id=rid_dmadata) and setif(data_ptr(1-1 downto 0)=(1-1 downto 0 => '0'));

		fifoi_frm <= not dmaia_dv;
		dmaidata_e : entity hdl4fpga.fifo
		generic map (
			size           => (8*2048)/ctlr_di'length,
			synchronous_rddata => not write_latency,
			gray_code      => false,
			overflow_check => false)
		port map (
			src_clk  => si_clk,
			src_frm  => fifoi_frm,
			src_irdy => dmaidata_ena,
			src_data => rgtr_data(16-1 downto 0),

			dst_clk  => ctlr_clk,
			dst_irdy => dst_irdy,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

		dmaicfg_p : process (si_clk)
			variable io_rdy : std_logic;
		begin
			if rising_edge(si_clk) then
				if ctlr_inirdy='0' then
					dmaicfg_req <= '0';
				elsif dmaicfg_req='0' then
					if dmai_dv='1' then
						dmaicfg_req <= '1';
					end if;
				elsif io_rdy='1' then
					dmaicfg_req <= '0';
				end if;
				io_rdy := dmai_rdy;
			end if;
		end process;

		ctlr_di_dv <= dst_irdy and ctlr_di_req; 
		ctlr_dm <= (others => '0');

		dmaoaddr_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => x"19")
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			data      => dmao_addr);

		dmaolen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => x"20")
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmao_dv,
			data      => dmao_len);

		dmaodata_e : entity hdl4fpga.fifo
		generic map (
			size           => (8*2048)/ctlr_di'length,
			synchronous_rddata => true,
			gray_code      => false,
			overflow_check => false)
		port map (
			src_clk  => ctlr_clk,
			src_irdy => ctlr_do_dv(0),
			src_data => ctlr_do,

			dst_clk  => si_clk,
			dst_frm  => fifoo_frm,
			dst_irdy => fifoo_irdy,
			dst_trdy => fifoo_trdy,
			dst_data => fifoo_data);

		dmaocfg_p : process (si_clk)
			variable io_rdy : std_logic;
		begin
			if rising_edge(si_clk) then
				if ctlr_inirdy='0' then
					dmaocfg_req <= '0';
					fifoo_frm   <= '0';
				elsif dmaocfg_req='0' then
					if dmao_dv='1' then
						dmaocfg_req <= '1';
						fifoo_frm   <= '1';
					end if;
				elsif io_rdy='1' then
					dmaocfg_req <= '0';
					fifoo_frm   <= fifoo_irdy;
				end if;
				io_rdy := dmao_rdy;
			end if;
		end process;

		uartdesser_e : entity hdl4fpga.desser
		port map (
			desser_clk => si_clk,
			desser_frm => fifoo_frm,
			des_irdy   => fifoo_irdy,
			des_trdy   => fifoo_trdy,
			des_data   => fifoo_data,

			ser_irdy   => uart_txdv,
			ser_data   => uart_txd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => uart_txc,
			uart_sout => ftdi_rxd,
			uart_trdy => uart_trdy,
			uart_txdv => uart_txdv,
			uart_txd  => uart_txd);

	end block;

	process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			dmao_req <= dmaocfg_rdy;
			dmai_req <= dmaicfg_rdy;
		end if;
	end process;

	dmacfg_req <= (0 => dmaocfg_req, 1 => dmaicfg_req);
	(0 => dmaocfg_rdy, 1 => dmaicfg_rdy) <= dmacfg_rdy;

	dev_req <= (0 => dmao_req, 1 => dmai_req);
	(0 => dmao_rdy, 1 => dmai_rdy) <= dev_rdy;
	dev_len    <= dmao_len  & dmai_len;
	dev_addr   <= dmao_addr & dmai_addr;
	dev_we     <= "1"       & "0";

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

end;
