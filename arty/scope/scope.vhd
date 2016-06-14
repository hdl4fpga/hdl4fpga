-                                                                            --
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
	constant UCLK_PERIOD : real    := 10.0;

	constant SCLK_PHASES : natural := 4;
	constant SCLK_EDGES  : natural := 2;
	constant DATA_PHASES : natural := 2;
	constant DATA_EDGES  : natural := 2;
	constant CMD_PHASES  : natural := 1;
	constant DATA_GEAR   : natural := 2;

	constant BANK_SIZE   : natural := ddr3_ba'length;
	constant ADDR_SIZE   : natural := ddr3_a'length;
	constant WORD_SIZE   : natural := ddr3_dq'length;
	constant BYTE_SIZE   : natural := ddr3_dq'length/ddr3_dqs_p'length;
	constant LINE_SIZE   : natural := data_gear*word_size;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 350 Mhz -- 400 Mhz --
	-- Multiply by --  10     --   7     --   4     --
	-- Divide by   --   3     --   2     --   1     --
	--------------------------------------------------

	constant DDR_MUL : natural := 7;
	constant DDR_DIV : natural := 2;

	signal sys_rst   : std_logic;
	signal sys_clk   : std_logic;

	signal iodctrl_rst : std_logic;
	signal iodctrl_clk : std_logic;
	signal iodctrl_rdy : std_logic;

	signal dcm_rst   : std_logic;
	signal ddr_rst   : std_logic;
	signal ddrs_rst  : std_logic;
	signal input_rst : std_logic;

	signal input_clk : std_logic;

	signal ddrs_clk0  : std_logic;
	signal ddrs_clk90 : std_logic;

	signal ddr3_dqst : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr3_dqso : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr3_dqsi : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr3_dqo  : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr3_dqt  : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr3_clk  : std_logic_vector(1-1 downto 0);

	signal tp1 : std_logic_vector(ddr3_dq'range) := (others  => 'Z');

	signal ddrphy_cke     : std_logic_vector(CMD_PHASES-1 downto 0);
	signal ddrphy_cs      : std_logic_vector(CMD_PHASES-1 downto 0);
	signal ddrphy_ras     : std_logic_vector(CMD_PHASES-1 downto 0);
	signal ddrphy_cas     : std_logic_vector(CMD_PHASES-1 downto 0);
	signal ddrphy_we      : std_logic_vector(CMD_PHASES-1 downto 0);
	signal ddrphy_odt     : std_logic_vector(CMD_PHASES-1 downto 0);
	signal ddrphy_b       : std_logic_vector(CMD_PHASES*BANK_SIZE-1 downto 0);
	signal ddrphy_a       : std_logic_vector(CMD_PHASES*ADDR_SIZE-1 downto 0);
	signal ddrphy_dqsi    : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqst    : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqso    : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmi     : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmt     : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmo     : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqi     : std_logic_vector(LINE_SIZE-1 downto 0);
	signal ddrphy_dqt     : std_logic_vector(LINE_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqo     : std_logic_vector(LINE_SIZE-1 downto 0);
	signal ddrphy_sto     : std_logic_vector(0 to LINE_SIZE/BYTE_SIZE-1);
	signal ddrphy_sti     : std_logic_vector(0 to LINE_SIZE/BYTE_SIZE-1);
	signal ddrphy_ini     : std_logic;
	signal ddrphy_rlreq   : std_logic;
	signal ddrphy_rlrdy   : std_logic;
	signal ddrphy_rlcal   : std_logic;
	signal ddrphy_rw      : std_logic;
	signal ddrphy_cmd_req : std_logic;
	signal ddrphy_cmd_rdy : std_logic;

	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(eth_rxd'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(eth_txd'range);

	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm   : std_logic;
	signal vga_red   : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

begin
		
	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

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
		DDR_MUL => DDR_MUL,
		DDR_DIV => DDR_DIV, 
		SYS_PER => UCLK_PERIOD)
	port map (
		sys_rst     => dcm_rst,
		sys_clk     => sys_clk,
		input_clk   => input_clk,
		iodctrl_clk => iodctrl_clk,
		iodctrl_rst => iodctrl_rst,
		ddr_clk0    => ddrs_clk0,
		ddr_clk90   => ddrs_clk90,
		ddr_rst     => ddr_rst);

	idelayctrl_i : idelayctrl
	port map (
		rst    => iodctrl_rst,
		refclk => iodctrl_clk,
		rdy    => iodctrl_rdy);

	sys_rst  <= not iodctrl_rdy;
	ddrs_rst <= sys_rst and ddr_rst;

	ddrphy_dqsi <= (others => ddrs_clk0);
	scope_e : entity hdl4fpga.scope
	generic map (
		FPGA           => VIRTEX5,
		DDR_MARK       => M125,
		DDR_TCP        => integer(UCLK_PERIOD*1000.0)*DDR_DIV/DDR_MUL,
		DDR_SCLKEDGES  => SCLK_EDGES,
		DDR_STROBE     => "INTERNAL",
		DDR_CLMNSIZE   => 7,
		DDR_BANKSIZE   => BANK_SIZE,
		DDR_ADDRSIZE   => ADDR_SIZE,
		DDR_SCLKPHASES => SCLK_PHASES,
		DDR_DATAPHASES => DATA_PHASES,
		DDR_DATAEDGES  => DATA_EDGES,
		DDR_LINESIZE   => LINE_SIZE,
		DDR_WORDSIZE   => WORD_SIZE,
		DDR_BYTESIZE   => BYTE_SIZE)
	port map (
--		input_rst => input_rst,
		input_clk => input_clk,

		ddrs_rst => ddrs_rst,
		ddrs_clks(0) => ddrs_clk0,
		ddrs_clks(1) => ddrs_clk90,
		ddrs_bl  => "011",
		ddrs_cl  => "101",
		ddrs_rtt => "11",

		ddr_cke    => ddrphy_cke(0),
		ddr_rlreq  => ddrphy_rlreq,
		ddr_rlrdy  => ddrphy_rlrdy,
		ddr_rlcal  => ddrphy_rlcal,
		ddr_phyini => ddrphy_ini,
		ddr_phyrw  => ddrphy_rw,
		ddr_phycmd_req => ddrphy_cmd_req,
		ddrs_cmd_rdy => ddrphy_cmd_rdy,

		ddr_cs   => ddrphy_cs(0),
		ddr_ras  => ddrphy_ras(0),
		ddr_cas  => ddrphy_cas(0),
		ddr_we   => ddrphy_we(0),
		ddr_b    => ddrphy_b,
		ddr_a    => ddrphy_a,
		ddr_dmi  => ddrphy_dmi,
		ddr_dmt  => ddrphy_dmt,
		ddr_dmo  => ddrphy_dmo,
		ddr_dqst => ddrphy_dqst,
		ddr_dqsi => ddrphy_dqsi,
		ddr_dqso => ddrphy_dqso,
		ddr_dqi  => ddrphy_dqi,
		ddr_dqt  => ddrphy_dqt,
		ddr_dqo  => ddrphy_dqo,
		ddr_odt  => ddrphy_odt(0),
		ddr_sto  => ddrphy_sto,
		ddr_sti  => ddrphy_sti,

--		mii_rst  => mii_rst,
		mii_rxc  => eth_rx_clk,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => eth_tx_clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,

--		vga_rst   => vga_rst,
		vga_clk   => vga_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_frm   => vga_frm,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue);

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		BANK_SIZE => BANK_SIZE,
        ADDR_SIZE => ADDR_SIZE,
		DATA_GEAR => DATA_GEAR,
		WORD_SIZE => WORD_SIZE,
		BYTE_SIZE => BYTE_SIZE)
	port map (
		sys_tp    => tp1,

		sys_rst   => sys_rst,
		sys_clk0  => ddrs_clk0,
		sys_clk90 => ddrs_clk90, 
		sysiod_clk => iodctrl_clk,

		sys_wlreq => ddrphy_wlreq,
		sys_wlrdy => ddrphy_wlrdy,

		sys_rlreq => ddrphy_rlreq,
		sys_rlrdy => ddrphy_rlrdy,
		sys_rlcal => ddrphy_rlcal,

		phy_rst  => ddrs_rst,
		phy_ini  => ddrphy_ini,
		phy_rw   => ddrphy_rw,
		phy_cmd_rdy => ddrphy_cmd_rdy,
		phy_cmd_req => ddrphy_cmd_req,

		sys_cke   => ddrphy_cke,
		sys_cs    => ddrphy_cs,
		sys_ras   => ddrphy_ras,
		sys_cas   => ddrphy_cas,
		sys_we    => ddrphy_we,
		sys_b     => ddrphy_b,
		sys_a     => ddrphy_a,

		sys_dqst => ddrphy_dqst,
		sys_dqso => ddrphy_dqso,
		sys_dmi  => ddrphy_dmo,
		sys_dmt  => ddrphy_dmt,
		sys_dmo  => ddrphy_dmi,
		sys_dqi  => ddrphy_dqi,
		sys_dqt  => ddrphy_dqt,
		sys_dqo  => ddrphy_dqo,
		sys_odt  => ddrphy_odt,
		sys_sti  => ddrphy_sto,
		sys_sto  => ddrphy_sti,

		ddr_clk  => ddr3_clk,
		ddr_cke  => ddr3_cke,
		ddr_cs   => ddr3_cs,
		ddr_ras  => ddr3_ras,
		ddr_cas  => ddr3_cas,
		ddr_we   => ddr3_we,
		ddr_b    => ddr3_ba,
		ddr_a    => ddr3_a,
		ddr_odt  => ddr3_odt,
		ddr_dm   => ddr3_dm,
		ddr_dqo  => ddr3_dqo,
		ddr_dqi  => ddr3_dq,
		ddr_dqt  => ddr3_dqt,
		ddr_dqst => ddr3_dqst,
		ddr_dqsi => ddr3_dqsi,
		ddr_dqso => ddr3_dqso);

	eth_rstn <= not sys_rst;
	eth_mdc  <= '0';
	eth_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 4)
	port map (
		mii_rxc  => eth_rx_clk,
		iob_rxdv => eth_rx_dv,
		iob_rxd  => eth_rxd,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => eth_tx_clk,
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

	rgbled  <= (others => '1');

	tp_g : for i in 2-1 downto 0 generate
		led(i+4) <= tp1(i*2+1) when btn(1)='1' else tp1(i*2+2) when btn(2)='1' else tp1(i*2+0) when btn(3)='1' else tp1(i*2+5) ;
	end generate;

end;
