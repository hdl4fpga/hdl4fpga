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
--use hdl4fpga.cgafont.all;

library unisim;
use unisim.vcomponents.all;

architecture scope of arty is
	constant sclk_phases : natural := 4;
	constant sclk_edges : natural := 2;
	constant data_phases : natural := 2;
	constant data_edges : natural := 2;
	constant cmd_phases : natural := 1;
	constant bank_size : natural := ddr3_ba'length;
	constant addr_size : natural := ddr3_a'length;
	constant word_size : natural := ddr3_dq'length;
	constant line_size : natural := 2*word_size;
	constant byte_size : natural := 8;
	constant data_gear : natural := line_size/word_size;
	constant uclk_period : real := 10.0;

	signal ictlr_clk : std_logic;
	signal ictlr_rdy : std_logic;

	signal sys_clk : std_logic;
	signal ddrs_rst  : std_logic;
	signal input_rst : std_logic;

	signal input_clk : std_logic;

	signal ddrs_clk0  : std_logic;
	signal ddrs_clk90 : std_logic;

	signal ddr3_dqst : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr3_dqso : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr3_dqsi : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr3_dqo  : std_logic_vector(word_size-1 downto 0);
	signal ddr3_dqt  : std_logic_vector(word_size-1 downto 0);
	signal ddr3_clk  : std_logic_vector(1-1 downto 0);

	signal tp1 : std_logic_vector(ddr3_dq'range) := (others  => 'Z');

	signal ddrphy_cke : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_cs : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_ras : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_cas : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_we : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_odt : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_b : std_logic_vector(cmd_phases*bank_size-1 downto 0);
	signal ddrphy_a : std_logic_vector(cmd_phases*addr_size-1 downto 0);
	signal ddrphy_dqsi : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqst : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqso : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmi : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmt : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmo : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqi : std_logic_vector(line_size-1 downto 0);
	signal ddrphy_dqi2 : std_logic_vector(line_size-1 downto 0);
	signal ddrphy_dqt : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqo : std_logic_vector(line_size-1 downto 0);
	signal ddrphy_sto : std_logic_vector(0 to line_size/byte_size-1);
	signal ddrphy_sti : std_logic_vector(0 to line_size/byte_size-1);
	signal ddrphy_ini : std_logic;
	signal ddrphy_wlreq : std_logic;
	signal ddrphy_wlrdy : std_logic;
	signal ddrphy_wlcal : std_logic;
	signal ddrphy_rw : std_logic;
	signal ddrphy_cmd_req : std_logic;
	signal ddrphy_cmd_rdy : std_logic;

	signal mii_rxdv : std_logic;
	signal mii_rxc  : std_logic;
	signal mii_rxd  : std_logic_vector(eth_rxd'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(eth_txd'range);

	signal vga_clk : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);
	signal dvdelay : std_logic_vector(0 to 2);

	signal sys_rst   : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   4     --   9     --
	-- Divide by   --   3     --   1     --   2     --
	--------------------------------------------------

	constant ddr_mul   : natural := 10;
	constant ddr_div   : natural :=  3;
	constant ddr_fbdiv : natural := 1;

	signal ictlr_clk_ibufg : std_logic;
	signal ictlr_rst : std_logic;
begin
		
		
--	idelay_ibufg_i : IBUFGDS_LVPECL_25
--	port map (
--		I  => clk_fpga_p,
--		IB => clk_fpga_n,
--		O  => ictlr_clk_ibufg );

	idelay_bufg_i : BUFG
	port map (
		i => ictlr_clk_ibufg,
		o => ictlr_clk);

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	process (btn(0), ictlr_clk)
		variable tmr : unsigned(0 to 8-1);
	begin
		if btn(0)='1' then
			tmr := (others => '0');
		elsif rising_edge(ictlr_clk) then
			if tmr(0)='0' then
				tmr := tmr + 1;
			end if;
		end if;
		ictlr_rst <= not tmr(0);
	end process;

	idelayctrl_i : idelayctrl
	port map (
		rst => ictlr_rst,
		refclk => ictlr_clk,
		rdy => ictlr_rdy);
	sys_rst <= not ictlr_rdy;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => uclk_period)
	port map (
		sys_rst => sys_rst,
		sys_clk => sys_clk,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => open,
		video_clk90 => open,
		ddr_rst => ddrs_rst);

	ddrphy_dqsi <= (others => ddrs_clk0);
	scope_e : entity hdl4fpga.scope
	generic map (
		fpga => virtex5,
		DDR_MARK => M3,
		DDR_TCP => integer(uclk_period*1000.0)*ddr_div*ddr_fbdiv/ddr_mul,
		DDR_SCLKEDGES => sclk_edges,
		DDR_STROBE => "INTERNAL",
		DDR_CLMNSIZE => 7,
		DDR_BANKSIZE => BANK_SIZE, --ddr3_ba'length,
		DDR_ADDRSIZE => ADDR_SIZE,
		DDR_SCLKPHASES => sclk_phases,
		DDR_DATAPHASES => data_phases,
		DDR_DATAEDGES => data_edges,
		DDR_LINESIZE => line_size,
		DDR_WORDSIZE => word_size,
		DDR_BYTESIZE => byte_size)
	port map (

--		input_rst => input_rst,
		input_clk => input_clk,

		ddrs_rst => ddrs_rst,
		ddrs_clks(0) => ddrs_clk0,
		ddrs_clks(1) => ddrs_clk90,
		ddrs_bl  => "011",
		ddrs_cl  => "101",
		ddrs_rtt => "11",
		ddr_cke  => ddrphy_cke(0),
		ddr_wlreq => ddrphy_wlreq,
		ddr_wlrdy => ddrphy_wlrdy,
		ddr_wlcal => ddrphy_wlcal,
		ddr_phyini => ddrphy_ini,
		ddr_phyrw => ddrphy_rw,
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
		ddr_dqi  => ddrphy_dqi2,
		ddr_dqt  => ddrphy_dqt,
		ddr_dqo  => ddrphy_dqo,
		ddr_odt  => ddrphy_odt(0),
		ddr_sto  => ddrphy_sto,
		ddr_sti  => ddrphy_sti,

--		mii_rst  => mii_rst,
		mii_rxc  => mii_rxc,
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


	ddrphy_dqi2 <= ddrphy_dqi;

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		BANK_SIZE => BANK_SIZE,
        ADDR_SIZE => ADDR_SIZE,
		data_gear => data_gear,
		WORD_SIZE => word_size,
		BYTE_SIZE => byte_size)
	port map (
		sys_rst => sys_rst,
		sys_clk0 => ddrs_clk0,
		sys_clk90 => ddrs_clk90, 
		phy_rst => ddrs_rst,

		sys_cke => ddrphy_cke,
		sys_cs  => ddrphy_cs,
		sys_ras => ddrphy_ras,
		sys_cas => ddrphy_cas,
		sys_we  => ddrphy_we,
		sys_b   => ddrphy_b,
		sys_a   => ddrphy_a,

		sys_wlreq => ddrphy_wlreq,
		sys_wlrdy => ddrphy_wlrdy,
		sys_wlcal => ddrphy_wlcal,
		phy_ini => ddrphy_ini,
		phy_rw => ddrphy_rw,
		phy_cmd_rdy => ddrphy_cmd_rdy,
		phy_cmd_req => ddrphy_cmd_req,
		sys_dqst => ddrphy_dqst,
		sys_dqso => ddrphy_dqso,
		sys_dmi => ddrphy_dmo,
		sys_dmt => ddrphy_dmt,
		sys_dmo => ddrphy_dmi,
		sys_dqi => ddrphy_dqi,
		sys_dqt => ddrphy_dqt,
		sys_dqo => ddrphy_dqo,
		sys_odt => ddrphy_odt,
		sys_sti => ddrphy_sto,
		sys_sto => ddrphy_sti,
		sysiod_clk => ictlr_clk,
		sys_tp => tp1,
		ddr_clk => ddr3_clk,
		ddr_cke => ddr3_cke,
		ddr_cs  => ddr3_cs,
		ddr_ras => ddr3_ras,
		ddr_cas => ddr3_cas,
		ddr_we  => ddr3_we,
		ddr_b   => ddr3_ba,
		ddr_a   => ddr3_a,
		ddr_odt => ddr3_odt,

		ddr_dm   => ddr3_dm,
		ddr_dqo  => ddr3_dqo,
		ddr_dqi  => ddr3_dq,
		ddr_dqt  => ddr3_dqt,
		ddr_dqst => ddr3_dqst,
		ddr_dqsi => ddr3_dqsi,
		ddr_dqso => ddr3_dqso);


	eth_rstn <= not sys_rst;
	mii_rxc <= eth_rx_clk;

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 4)
	port map (
		mii_rxc  => mii_rxc,
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
	rgbled  <= (others => '0');
	eth_mdc  <= '0';
	eth_mdio <= '0';


	tp_g : for i in 2-1 downto 0 generate
		led(i+4) <= tp1(i*2+1) when btn(1)='1' else tp1(i*2+2) when btn(2)='1' else tp1(i*2+0) when btn(3)='1' else tp1(i*2+5) ;
	end generate;

end;
