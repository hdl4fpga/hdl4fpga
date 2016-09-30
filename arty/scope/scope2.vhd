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
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_db.all;

library unisim;
use unisim.vcomponents.all;

architecture scope of arty is
	constant clk0div   : natural := 0; 
	constant clk90div  : natural := 1;
	constant iodclk    : natural := 2;
	constant clk0      : natural := 3; 
	constant clk90     : natural := 4;
	constant clk270div : natural := 5;

	constant rst0div  : natural := 0;
	constant rst90div : natural := 1;
	constant rstiod   : natural := 2;

	constant UCLK_PERIOD  : real    := 10.0;

	constant SCLK_PHASES  : natural := 1;
	constant SCLK_EDGES   : natural := 1;
	constant DATA_EDGES   : natural := 1;
	constant CMMD_GEAR    : natural := 2;
	constant DATA_GEAR    : natural := 4;

	constant BANK_SIZE    : natural := ddr3_ba'length;
	constant ADDR_SIZE    : natural := ddr3_a'length;
	constant WORD_SIZE    : natural := ddr3_dq'length;
	constant BYTE_SIZE    : natural := ddr3_dq'length/ddr3_dqs_p'length;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 350 Mhz -- 400 Mhz --
	-- Multiply by --  10     --   7     --   4     --
	-- Divide by   --   3     --   2     --   1     --
	--------------------------------------------------

	constant DDR_MUL      : real    := 17.0; --18;
	constant DDR_DIV      : natural := 4;  --4;

	signal sys_rst        : std_logic;
	signal sys_clk        : std_logic;

	signal eth_rxclk_bufg : std_logic;
	signal eth_txclk_bufg : std_logic;

	signal ioctrl_rst     : std_logic;
	signal ioctrl_clk     : std_logic;
	signal ioctrl_rdy     : std_logic;

	signal dcm_rst        : std_logic;
	signal ddr0div_rst    : std_logic;
	signal ddr90div_rst   : std_logic;
	signal ddrs0div_rst   : std_logic;
	signal ddrs90div_rst  : std_logic;
	signal ddrsiod_rst    : std_logic;
	signal input_rst      : std_logic;

	signal input_clk      : std_logic;

	signal ddrs_clk0      : std_logic;
	signal ddrs_clk0div   : std_logic;
	signal ddrs_clk90div  : std_logic;
	signal ddrs_clk90     : std_logic;
	signal ddrs_clks      : std_logic_vector(0 to 2-1);

	signal ddr3_dqst      : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr3_dqso      : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr3_dqsi      : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr3_dqo       : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr3_dqt       : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr3_clk       : std_logic_vector(1-1 downto 0);

	signal ddr_b          : std_logic_vector(ddr3_ba'range);
	signal ddr_a          : std_logic_vector(ddr3_a'range);
	signal ddrphy_act     : std_logic;
	signal ddrphy_rst     : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_cke     : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_cs      : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_ras     : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_cas     : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_we      : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_odt     : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddrphy_b       : std_logic_vector(CMMD_GEAR*BANK_SIZE-1 downto 0);
	signal ddrphy_a       : std_logic_vector(CMMD_GEAR*ADDR_SIZE-1 downto 0);
	signal ddrphy_dqsi    : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqst    : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqso    : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmi     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmt     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmo     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqi     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_dqt     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqo     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_sto     : std_logic_vector(0 to DATA_GEAR*WORD_SIZE/BYTE_SIZE-1);
	signal ddrphy_sti     : std_logic_vector(0 to DATA_GEAR*WORD_SIZE/BYTE_SIZE-1);
	signal ddrphy_ini     : std_logic;
	signal ddrphy_wlreq   : std_logic;
	signal ddrphy_wlrdy   : std_logic;
	signal ddrphy_rlreq   : std_logic;
	signal ddrphy_rlrdy   : std_logic;
	signal ddrphy_rlcal   : std_logic;
	signal ddrphy_rlseq   : std_logic;
	signal ddrphy_rw      : std_logic;
	signal ddrphy_cmd_req : std_logic;
	signal ddrphy_cmd_rdy : std_logic;

	signal mii_rxdv       : std_logic;
	signal mii_rxd        : std_logic_vector(eth_rxd'range);
	signal mii_txen       : std_logic;
	signal mii_txd        : std_logic_vector(eth_txd'range);

	signal sys_clks       : std_logic_vector(0 to 5-1);
	signal phy_rsts       : std_logic_vector(0 to 3-1);

	signal tp_bit         : std_logic_vector(WORD_SIZE/BYTE_SIZE*5-1 downto 0) := (others  => 'Z');
	signal tp1            : std_logic_vector(6-1 downto 0);
	signal tp_delay       : std_logic_vector(WORD_SIZE/BYTE_SIZE*5-1 downto 0);

begin
		
	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	eth_rx_clk_ibufg : ibufg
	port map (
		I => eth_rx_clk,
		O => eth_rxclk_bufg);

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);

	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	process (btn(0), sys_clk)
		variable tmr : unsigned(0 to 8-1);
	begin
		if btn(0)='1' then
			tmr := (others => '0');
		elsif rising_edge(sys_clk) then
			if tmr(0)='0' then
				tmr := tmr + 1;
			end if;
		end if;
		dcm_rst <= not tmr(0);
	end process;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		DDR_MUL       => DDR_MUL,
		DDR_DIV       => DDR_DIV, 
		DDR_GEAR      => DATA_GEAR, 
		SYS_PER       => UCLK_PERIOD)
	port map (
		sys_rst       => dcm_rst,
		sys_clk       => sys_clk,
		input_clk     => input_clk,
		ioctrl_clk    => ioctrl_clk,
		ioctrl_rst    => ioctrl_rst,
		ddr_clk0      => ddrs_clk0,
		ddr_clk0div   => ddrs_clk0div,
		ddr_clk90     => ddrs_clk90,
		ddr_clk90div  => ddrs_clk90div,
		ddr0div_rst   => ddr0div_rst,
		ddr90div_rst  => ddr90div_rst);

	idelayctrl_i : idelayctrl
	port map (
		rst    => ioctrl_rst,
		refclk => ioctrl_clk,
		rdy    => ioctrl_rdy);

	sys_rst       <= not ioctrl_rdy;
	ddrs0div_rst  <= sys_rst or ddr0div_rst;
	ddrs90div_rst <= sys_rst or ddr90div_rst;
	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			ddrsiod_rst <= sys_rst;
		end if;
	end process;
	

	scope_e : entity hdl4fpga.scope
	generic map (
		FPGA           => VIRTEX5,
		DDR_CMMDGEAR   => CMMD_GEAR,
		DDR_DATAGEAR   => DATA_GEAR,
		DDR_MARK       => M15E,
		DDR_TCP        => integer(UCLK_PERIOD*1000.0*2.0*real(DDR_DIV)/DDR_MUL),
		DDR_SCLKEDGES  => SCLK_EDGES,
		DDR_STROBE     => "INTERNAL",
		DDR_CLMNSIZE   => 7,
		DDR_BANKSIZE   => BANK_SIZE,
		DDR_ADDRSIZE   => ADDR_SIZE,
		DDR_SCLKPHASES => SCLK_PHASES,
		DDR_DATAPHASES => DATA_GEAR,
		DDR_DATAEDGES  => DATA_EDGES,
		DDR_WORDSIZE   => WORD_SIZE,
		DDR_BYTESIZE   => BYTE_SIZE)
	port map (
--		input_rst => input_rst,
		input_clk => input_clk,

		ddrs_rst       => ddrs0div_rst,
		ddrs_clks(0)   => ddrs_clk0div,
		ddrs_bl        => "000",
--		ddrs_cl        => "010",	-- 400 Mhz --
--		ddrs_cwl       => "000",	-- 400 Mhz --
--		ddrs_cl        => "011",	-- 425 Mhz --
--		ddrs_cwl       => "001",	-- 425 Mhz --
		ddrs_cl        => "100",	-- 500 Mhz --
		ddrs_cwl       => "001",	-- 500 Mhz --
--		ddrs_cl        => "101",	-- 550 Mhz --
--		ddrs_cwl       => "010",	-- 550 Mhz --
--		ddrs_cl        => "110",	-- 600 Mhz --
--		ddrs_cwl       => "010",	-- 600 Mhz --
		ddrs_rtt       => "001",

		ddr_wlreq      => ddrphy_wlreq,
		ddr_wlrdy      => ddrphy_wlrdy,
		ddr_rlreq      => ddrphy_rlreq,
		ddr_rlrdy      => ddrphy_rlrdy,
		ddr_rlcal      => ddrphy_rlcal,
		ddr_rlseq      => ddrphy_rlseq,
		ddr_phyini     => ddrphy_ini,
		ddr_phyrw      => ddrphy_rw,
		ddr_phycmd_req => ddrphy_cmd_req,
		ddrs_cmd_rdy   => ddrphy_cmd_rdy,
		ddrs_act       => ddrphy_act,

		ddr_rst        => ddrphy_rst(0),
		ddr_cke        => ddrphy_cke(0),
		ddr_cs         => ddrphy_cs(0),
		ddr_ras        => ddrphy_ras(0),
		ddr_cas        => ddrphy_cas(0),
		ddr_we         => ddrphy_we(0),
		ddr_b          => ddr_b,
		ddr_a          => ddr_a,
		ddr_odt        => ddrphy_odt(0),
		ddr_dmi        => ddrphy_dmi,
		ddr_dmt        => ddrphy_dmt,
		ddr_dmo        => ddrphy_dmo,
		ddr_dqst       => ddrphy_dqst,
		ddr_dqsi       => ddrphy_dqsi,
		ddr_dqso       => ddrphy_dqso,
		ddr_dqi        => ddrphy_dqo,
		ddr_dqt        => ddrphy_dqt,
		ddr_dqo        => ddrphy_dqi,
		ddr_sto        => ddrphy_sto,
		ddr_sti        => ddrphy_sti,

--		mii_rst        => mii_rst,
		mii_rxc        => eth_rxclk_bufg,
		mii_rxdv       => mii_rxdv,
		mii_rxd        => mii_rxd,
		mii_txc        => eth_txclk_bufg,
		mii_txen       => mii_txen,
		mii_txd        => mii_txd);


	ddrphy_rst(1) <= ddrphy_rst(0);
	ddrphy_cke(1) <= ddrphy_cke(0);
	ddrphy_cs(1)  <= ddrphy_cs(0);
	ddrphy_ras(1) <= '1';
	ddrphy_cas(1) <= '1';
	ddrphy_we(1)  <= '1';
	ddrphy_odt(1) <= ddrphy_odt(0);

	process (ddr_b)
	begin
		for i in ddr_b'range loop
			for j in 0 to CMMD_GEAR-1 loop
				ddrphy_b(i*CMMD_GEAR+j) <= ddr_b(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to CMMD_GEAR-1 loop
				ddrphy_a(i*CMMD_GEAR+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	sys_clks <= (
		clk0div   => ddrs_clk0div,
		clk90div  => ddrs_clk90div,
		iodclk    => sys_clk,
		clk0      => ddrs_clk0,
		clk90     => ddrs_clk90);

	phy_rsts <= (rst0div => ddrs0div_rst, rst90div => ddrs90div_rst, rstiod => ddrsiod_rst);

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (

		TCP          => integer(UCLK_PERIOD*1000.0*real(DDR_DIV)/DDR_MUL),
		TAP_DELAY    => 78,
		BANK_SIZE    => BANK_SIZE,
        ADDR_SIZE    => ADDR_SIZE,
		CMMD_GEAR    => CMMD_GEAR,
		DATA_GEAR    => DATA_GEAR,
		WORD_SIZE    => WORD_SIZE,
		BYTE_SIZE    => BYTE_SIZE)
	port map (
	
		tp_sel    => sw(3),
		tp_delay  => tp_delay,
		tp1       => tp1,
		tp_bit    => tp_bit,

		sys_clks => sys_clks,
		phy_rsts => phy_rsts,
		phy_ini      => ddrphy_ini,
		phy_rw       => ddrphy_rw,
		phy_cmd_rdy  => ddrphy_cmd_rdy,
		phy_cmd_req  => ddrphy_cmd_req,
		sys_act      => ddrphy_act,

		sys_wlreq    => ddrphy_wlreq,
		sys_wlrdy    => ddrphy_wlrdy,

		sys_rlreq    => ddrphy_rlreq,
		sys_rlrdy    => ddrphy_rlrdy,
		sys_rlcal    => ddrphy_rlcal,
		sys_rlseq    => ddrphy_rlseq,

		sys_cke      => ddrphy_cke,
		sys_rst      => ddrphy_rst,
		sys_cs       => ddrphy_cs,
		sys_ras      => ddrphy_ras,
		sys_cas      => ddrphy_cas,
		sys_we       => ddrphy_we,
		sys_b        => ddrphy_b,
		sys_a        => ddrphy_a,

		sys_dqst     => ddrphy_dqst,
		sys_dqso     => ddrphy_dqso,
		sys_dmi      => ddrphy_dmo,
		sys_dmt      => ddrphy_dmt,
		sys_dmo      => ddrphy_dmi,
		sys_dqo      => ddrphy_dqo,
		sys_dqt      => ddrphy_dqt,
		sys_dqi      => ddrphy_dqi,
		sys_odt      => ddrphy_odt,
		sys_sti      => ddrphy_sto,
		sys_sto      => ddrphy_sti,

		ddr_rst      => ddr3_reset,
		ddr_clk      => ddr3_clk,
		ddr_cke      => ddr3_cke,
		ddr_cs       => ddr3_cs,
		ddr_ras      => ddr3_ras,
		ddr_cas      => ddr3_cas,
		ddr_we       => ddr3_we,
		ddr_b        => ddr3_ba,
		ddr_a        => ddr3_a,
		ddr_odt      => ddr3_odt,
--		ddr_dm       => ddr3_dm,
		ddr_dqo      => ddr3_dqo,
		ddr_dqi      => ddr3_dq,
		ddr_dqt      => ddr3_dqt,
		ddr_dqst     => ddr3_dqst,
		ddr_dqsi     => ddr3_dqsi,
		ddr_dqso     => ddr3_dqso);
	ddr3_dm <= (others => '0');

	ddrphy_dqsi <= (others => ddrs_clk90div);
	eth_rstn <= not sys_rst;
	eth_mdc  <= '0';
	eth_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 4)
	port map (
		mii_rxc  => eth_rxclk_bufg,
		iob_rxdv => eth_rx_dv,
		iob_rxd  => eth_rxd,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => eth_txclk_bufg,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => eth_tx_en,
		iob_txd  => eth_txd);

	iob_b : block
	begin

		ddr_clks_g : for i in ddr3_clk'range generate
			ddr_ck_obufds : obufds
			generic map (
				iostandard => "DIFF_SSTL135")
			port map (
				i  => ddr3_clk(i),
				o  => ddr3_clk_p,
				ob => ddr3_clk_n);
		end generate;

		ddr_dqs_g : for i in ddr3_dqs_p'range generate
			dqsiobuf_i : iobufds
			generic map (
				iostandard => "DIFF_SSTL135")
			port map (
				t   => ddr3_dqst(i),
				i   => ddr3_dqso(i),
				o   => ddr3_dqsi(i),
				io  => ddr3_dqs_p(i),
				iob => ddr3_dqs_n(i));

		end generate;

		ddr_d_g : for i in ddr3_dq'range generate
			ddr3_dq(i) <= ddr3_dqo(i) when ddr3_dqt(i)='0' else 'Z';
		end generate;

	end block;

	process (tp_delay)
		variable aux1 : std_logic_vector(3 downto 0);
		variable aux0 : std_logic_vector(3 downto 0);
		variable sel  : std_logic_vector(2-1 downto 0);

	begin
		rgbled <= (others => '0');
		aux1 := "00" & tp_delay(5 downto 4);
		aux0 := tp_delay(3 downto 0);
		sel(0) := btn(1);
		for i in 4-1 downto 0 loop
			if btn(1)='1' then
				rgbled(3*i+2) <= aux1(i);
			else
				rgbled(3*i+2) <= aux0(i);
			end if;
		end loop;
	end process;

	tp_g : for i in 2-1 downto 0 generate
		led(i+0) <= tp1(i+4) when btn(3)='1' else tp_bit(i*5+2) when btn(1)='1' else tp_bit(i*5+3);
		led(i+2) <= tp1(i+2) when btn(3)='1' else tp_bit(i*5+1) when btn(1)='1' else tp_bit(i*5+0);
	end generate;

end;
