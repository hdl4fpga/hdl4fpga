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

library ecp3;
use ecp3.components.all;

architecture scope of ecp3versa is
	constant CMMD_GEAR : natural := 2;
	constant bank_size   : natural := 2;
	constant addr_size   : natural := 13;
	constant DATA_GEAR   : natural := 4;
	constant DATA_EDGES  : natural := 1;
	constant word_size   : natural := ddr3_dq'length;
	constant byte_size   : natural := ddr3_dq'length/ddr3_dqs'length;

	constant ns : natural := 1000;
	constant uclk_period : natural := 10*ns;

	signal sys_rst   : std_logic;
	signal sys_rst_n : std_logic;

	signal dcm_rst   : std_logic;
	signal ddrs_rst  : std_logic;
	signal mii_rst   : std_logic;
	signal vga_rst   : std_logic;

	signal dcm_lckd   : std_logic;
	signal video_lckd : std_logic;
	signal ddrs_lckd  : std_logic;

	---------------------------------------------
	-- Frequency - 400 Mhz - 450 Mhz - 500 Mhz --
	---------------------------------------------
	-- ddr_clki  -   1     -   2     -    1    --
	-- ddr_clkfb -   4     -   9     -    5	   --
	-- ddr_clkop -   2     -   2     -    2    --
	-- ddr_clkok -   2     -   2     -    2    --
	---------------------------------------------

	constant ddr_clki  : natural := 1;
	constant ddr_clkfb : natural := 5;
	constant ddr_clkop : natural := 2;
	constant ddr_clkok : natural := 2;

	signal ddr_sclk   : std_logic;
	signal ddr_sclk2x : std_logic;
	signal ddr_eclk   : std_logic;
	signal ddr_pha    : std_logic_vector(4-1 downto 0);

	signal ddrphy_rst : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cke : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cs  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_ras : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cas : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_we  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_odt : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_b   : std_logic_vector(CMMD_GEAR*ddr3_b'length-1 downto 0);
	signal ddrphy_a   : std_logic_vector(CMMD_GEAR*ddr3_a'length-1 downto 0);
	signal ddrphy_dqsi : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqst : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqso : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmi : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmt : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmo : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqi : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0) := x"f8_f7_f6_f5_f4_f3_f2_f1";
	signal ddrphy_dqt : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqo : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_sto : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_sti : std_logic_vector(DATA_GEAR*word_size/byte_size-1 downto 0);
	signal ddrphy_wlreq : std_logic;
	signal ddrphy_wlrdy : std_logic;
	signal ddrphy_pll : std_logic_vector(8-1 downto 0);

	signal input_rst  : std_logic;
	signal input_clk  : std_logic;
	signal input_rdy  : std_logic;
	signal input_req  : std_logic;
	signal input_data : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	constant g : std_logic_vector(input_data'length downto 1) := (64 => '1', 63 => '1', 61 => '1', 60 => '1', others => '0');

	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(phy1_rx_d'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(phy1_tx_d'range);

	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm   : std_logic;
	signal vga_red   : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

begin

	sys_rst   <= not fpga_gsrn;
	sys_rst_n <= not sys_rst;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_clki  => ddr_clki,
		ddr_clkfb => ddr_clkfb,
		ddr_clkop => ddr_clkop,
		ddr_clkok => ddr_clkok,
		sys_per => real(uclk_period/ns))
	port map (
		sys_rst    => sys_rst,
		sys_clk    => clk,

		ddr_eclk   => ddr_eclk,
		ddr_sclk   => ddr_sclk, 
		ddr_sclk2x => ddr_sclk2x, 
		ddr_rst    => ddrs_rst,
		ddr_pha    => ddr_pha,

		video_clk0 => vga_clk,
		video_rst  => vga_rst);
	input_clk <= clk;
	input_rst <= sys_rst;

	testpattern_e : entity hdl4fpga.lfsr_gen
	generic map (
		g => g)
	port map (
		clk => input_clk,
		rst => input_rst,
		req => input_req,
		so  => input_data);

	input_rdy <= not input_rst;
	ddrphy_rst(1) <= ddrphy_rst(0);
	scope_e : entity hdl4fpga.scope
	generic map (
		FPGA           => LatticeECP3,
		DDR_tCP        => (uclk_period*ddr_clki*ddr_clkok)/ddr_clkfb,
		DDR_CMMDGEAR   => CMMD_GEAR,
		DDR_DATAGEAR   => DATA_GEAR,
		DDR_SCLKPHASES => 1,
		DDR_SCLKEDGES  => 1,
		DDR_MARK       => M15E,
		DDR_STROBE     => "INTERNAL",
		DDR_DATAPHASES => DATA_GEAR,
		DDR_DATAEDGES  => 1,
		DDR_BANKSIZE   => ddr3_b'length,
		DDR_ADDRSIZE   => ddr3_a'length,
		DDR_CLMNSIZE   => 7,
		DDR_WORDSIZE   => word_size,
		DDR_BYTESIZE   => byte_size)
	port map (
		input_clk      => input_clk,
		input_req      => input_req,
		input_rdy      => input_rdy,
		input_data     => input_data,

		ddrs_rst     => ddrs_rst,
		ddrs_clks(0) => ddr_sclk,
		ddrs_cl      => "100",
		ddrs_cwl     => "001",
		ddrs_rtt     => "001",
		ddr_rst      => ddrphy_rst(0),
		ddr_cke      => ddrphy_cke(0),
		ddr_wlreq    => ddrphy_wlreq,
		ddr_wlrdy    => ddrphy_wlrdy,
		ddr_cs       => ddrphy_cs(0),
		ddr_ras      => ddrphy_ras(0),
		ddr_cas      => ddrphy_cas(0),
		ddr_we       => ddrphy_we(0),
		ddr_b        => ddrphy_b(ddr3_b'length-1 downto 0),
		ddr_a        => ddrphy_a(ddr3_a'length-1 downto 0),
		ddr_dmi      => ddrphy_dmi,
		ddr_dmt      => ddrphy_dmt,
		ddr_dmo      => ddrphy_dmo,
		ddr_dqst     => ddrphy_dqst,
		ddr_dqsi     => ddrphy_dqso,
		ddr_dqso     => ddrphy_dqsi,
		ddr_dqi      => ddrphy_dqo,
		ddr_dqt      => ddrphy_dqt,
		ddr_dqo      => ddrphy_dqi,
		ddr_odt      => ddrphy_odt(0),
		ddr_sto      => ddrphy_sti,
		ddr_sti      => ddrphy_sto,

		mii_rst      => sys_rst,
		mii_rxc      => phy1_rxc,
		mii_rxdv     => mii_rxdv,
		mii_rxd      => mii_rxd,
		mii_txc      => phy1_125clk,
		mii_txen     => mii_txen,
		mii_txd      => mii_txd);

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		tCP => (uclk_period*ddr_clki)/ddr_clkfb,
		BANK_SIZE => ddr3_b'length,
		ADDR_SIZE => ddr3_a'length,
		DATA_GEAR => DATA_GEAR,
		WORD_SIZE => word_size,
		BYTE_SIZE => byte_size)
	port map (
		sys_sclk => ddr_sclk,
		sys_sclk2x => ddr_sclk2x, 
		sys_eclk => ddr_eclk,
		phy_rst => ddrs_rst,

		sys_rst => ddrphy_rst, 
		sys_wlreq => ddrphy_wlreq,
		sys_wlrdy => ddrphy_wlrdy,
		sys_cke => ddrphy_cke,
		sys_cs  => ddrphy_cs,
		sys_ras => ddrphy_ras,
		sys_cas => ddrphy_cas,
		sys_we  => ddrphy_we,
		sys_b   => ddrphy_b,
		sys_a   => ddrphy_a,
		sys_dqsi => ddrphy_dqsi,
		sys_dqst => ddrphy_dqst,
		sys_dqso => ddrphy_dqso,
		sys_dmi => ddrphy_dmo,
		sys_dmt => ddrphy_dmt,
		sys_dmo => ddrphy_dmi,
		sys_dqi => ddrphy_dqi,
		sys_dqt => ddrphy_dqt,
		sys_dqo => ddrphy_dqo,
		sys_odt => ddrphy_odt,
		sys_sti => ddrphy_sti,
		sys_sto => ddrphy_sto,
		sys_pll => ddrphy_pll ,
		ddr_rst => ddr3_rst,
		ddr_ck  => ddr3_clk,
		ddr_cke => ddr3_cke,
		ddr_odt => ddr3_odt,
		ddr_cs => ddr3_cs,
		ddr_ras => ddr3_ras,
		ddr_cas => ddr3_cas,
		ddr_we  => ddr3_we,
		ddr_b   => ddr3_b,
		ddr_a   => ddr3_a,

--		ddr_dm  => ddr3_dm,
		ddr_dq  => ddr3_dq,
		ddr_dqs => ddr3_dqs);
	ddr3_dm <= (others => '0');

	phy1_rst  <= sys_rst_n;
	phy1_mdc  <= '0';
	phy1_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 8)
	port map (
		mii_rxc  => phy1_rxc,
		iob_rxdv => phy1_rx_dv,
		iob_rxd  => phy1_rx_d,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => phy1_125clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy1_tx_en,
		iob_txd  => phy1_tx_d,
		iob_gtxclk => phy1_gtxclk);

	process (ddr_sclk, sys_rst)
		variable led1 : std_logic_vector(led'range);
		variable led2 : std_logic_vector(led'range);
	begin
		if rising_edge(ddr_sclk) then
			led  <= led2;
			led2 := led1;
			led1 := (1 to 4 => '1') & not ddr_pha;
		end if;
	end process;

end;
