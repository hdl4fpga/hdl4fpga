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
use  hdl4fpga.std.all;

architecture ddrdma of testbench is

	signal clk : std_logic := '1';
	signal rst : std_logic := '0';

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 150 Mhz -- 166 Mhz --
	-- Multiply by --   8     --   3     --  10     --
	-- Divide by   --   3     --   1     --   3     --
	--------------------------------------------------

	constant sys_per     : real    := 20.0;
	constant ddr_mul     : natural := 8;
	constant ddr_div     : natural := 3;

	constant FPGA        : natural := SPARTAN3;
	constant MARK        : natural := M6T;
	constant TCP         : natural := (natural(sys_per)*ddr_div*1 ns)/(ddr_mul*1 ps);

	constant SCLK_PHASES : natural := 4;
	constant SCLK_EDGES  : natural := 2;
	constant CMMD_GEAR   : natural := 1;
	constant DATA_PHASES : natural := 2;
	constant DATA_EDGES  : natural := 2;
	constant BANK_SIZE   : natural := 2;
	constant ADDR_SIZE   : natural := 13;
	constant DATA_GEAR   : natural := 2;
	constant WORD_SIZE   : natural := 16;
	constant BYTE_SIZE   : natural := 8;

	signal dmactlr_rst   : std_logic;
	signal dmactlr_clk   : std_logic;
	signal dmactlr_we    : std_logic;
	signal dmactlr_irdy  : std_logic;
	signal dmactlr_trdy  : std_logic;

	signal ctlr_irdy     : std_logic;
	signal ctlr_trdy     : std_logic;
	signal ctlr_rw       : std_logic;
	signal ctlr_act      : std_logic;
	signal ctlr_cas      : std_logic;
	signal ctlr_inirdy   : std_logic;
	signal ctlr_refreq   : std_logic;
	signal ctlr_b        : std_logic_vector(BANK_SIZE-1 downto 0);
	signal ctlr_a        : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ctlr_di       : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ctlr_do       : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ctlr_dm       : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ctlr_do_irdy  : std_logic;
	signal ctlr_di_irdy  : std_logic;
	signal ctlr_di_trdy  : std_logic;

	signal phy_cke  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal phy_cs   : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal phy_ras  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal phy_cas  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal phy_we   : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal phy_odt  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal phy_b    : std_logic_vector(CMMD_GEAR*sd_ba'length-1 downto 0);
	signal phy_a    : std_logic_vector(CMMD_GEAR*sd_a'length-1 downto 0);
	signal phy_dqsi : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dqst : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dqso : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dmi  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dmt  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dmo  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dqi  : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal phy_dqt  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_dqo  : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal phy_sto  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal phy_sti  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);

	signal dst_clk       : std_logic;
	signal dst_irdy      : std_logic;
	signal dst_trdy      : std_logic;
	signal dst_do        : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);

begin

	rst <= '1', '0' after 20 ns;
	clk <= not clk after 3 ns;

	dmactlr_rst <= rst;
	dmactlr_clk <= clk;
	dmactrl_we  <= '0';

	dst_clk     <= clk;
	dst_irdy    <= '1';
	dst_trdy    <= '1';
	dst_do      <= dmactlr_clk;

	du1 : entity hdl4fpga.ddrctlr
	port map (
		dmactlr_rst   => dmactlr_rst,
		dmactlr_clk   => dmactlr_clk,
		dmactlr_irdy  => dmactlr_irdy,
		dmactlr_trdy  => dmactlr_trdy,
		dmactlr_we    => dmactlr_we,
		dmactlr_iaddr => ,
		dmactlr_ilen  => ,
		dmactlr_taddr => ,
		dmactlr_tlen  => ,

		ctlr_inirdy   => ctlr_inirdy,
		ctlr_refreq   => ctlr_refreq,

		ctlr_irdy     => ctlr_irdy,
		ctlr_trdy     => ctlr_trdy,
		ctlr_rw       => ctlr_rw,
		ctlr_act      => ctlr_act,
		ctlr_cas      => ctlr_cas,
		ctlr_b        => ctlr_b,
		ctlr_a        => ctlr_a,
		ctlr_di_irdy  => ctlr_di_irdy,
		ctlr_di_trdy  => ctlr_di_trdy,
		ctlr_di       => ctlr_di,
		ctlr_dm       => ctlr_dm,
		ctlr_do_irdy  => ctlr_do_irdy,
		ctlr_do       => ctlr_do,

		dst_clk       => dst_clk,
		dst_irdy      => dst_irdy,
		dst_trdy      => dst_trdy,
		dst_do        => dst_do);

	du2 : entity hdl4fpga.ddr_ctlr
	generic map (
		FPGA        => FPGA,
		MARK        => MARK,
		TCP         => TCP,

		CMMD_GEAR   => CMMD_GEAR,
		BANK_SIZE   => BANK_SIZE,
		ADDR_SIZE   => ADDR_SIZE,
		SCLK_PHASES => SCLK_PHASES,
		SCLK_EDGES  => SCLK_EDGES,
		DATA_PHASES => DATA_PHASES,
		DATA_EDGES  => DATA_EDGES,
		DATA_GEAR   => DATA_GEAR,
		WORD_SIZE   => WORD_SIZE,
		BYTE_SIZE   => BYTE_SIZE)
	port map (
		ctlr_bl      => ,
		ctlr_cl      => ,
		ctlr_cwl     => ,
		ctlr_wr      => ,
		ctlr_rtt     => ,

		ctlr_rst     => dmactlr_rst,
		ctlr_clks    => ,
		ctlr_inirdy  => ,

		ctlr_wlrdy   => ,
		ctlr_wlreq   => ,
		ctlr_rlcal   => ,
		ctlr_rlseq   => ,

		ctlr_irdy    => ctlr_irdy,
		ctlr_trdy    => ctlr_trdy,
		ctlr_rw      => ctlr_rw,
		ctlr_b       => ctlr_b,
		ctlr_a       => ctlr_a,
		ctlr_di_irdy => ctlr_di_irdy,
		ctlr_di_trdy => ctlr_di_trdy,
		ctlr_act     => ctlr_act,
		ctlr_cas     => ctlr_cas,
		ctlr_di      => ctlr_di,
		ctlr_dm      => ctlr_dm,
		ctlr_do_irdy => ctlr_do_irdy,
		ctlr_do      => ctlr_do,
		ctlr_refreq  => ctlr_refreq,

		phy_rst      => ,
		phy_cke      => ddrphy_cke,
		phy_cs       => ddrphy_cs,
		phy_ras      => ddrphy_ras,
		phy_cas      => ddrphy_cas,
		phy_we       => ddrphy_we,
		phy_b        => ddrphy_b,
		phy_a        => ddrphy_a,
		phy_odt      => ddrphy_odt,
		phy_dmi      => ddrphy_dmi,
		phy_dmt      => ddrphy_dmt,
		phy_dmo      => ddrphy_dmo,
                               
		phy_dqi      => ddrphy_dqi,
		phy_dqt      => ddrphy_dqt,
		phy_dqo      => ddrphy_dqo,
		phy_sti      => ddrphy_sti,
		phy_sto      => ddrphy_sto,
                                
		phy_dqsi     => ddrphy_dqsi,
		phy_dqso     => ddrphy_dqso,
		phy_dqst     => ddrphy_dqst);

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		gate_delay => 2,
		loopback => false,
		registered_dout => false,
		BANK_SIZE => sd_ba'length,
		ADDR_SIZE => sd_a'length,
		cmmd_gear => CMMD_GEAR,
		data_gear => DATA_GEAR,
		WORD_SIZE => word_size,
		BYTE_SIZE => byte_size)
	port map (
		ddrphy_clks => ddrs_clks,
		ddrphy_rst  => ddrs_rst,

		phy_cke  => ddrphy_cke,
		phy_cs   => ddrphy_cs,
		phy_ras  => ddrphy_ras,
		phy_cas  => ddrphy_cas,
		phy_we   => ddrphy_we,
		phy_b    => ddrphy_b,
		phy_a    => ddrphy_a,
		phy_dqsi => ddrphy_dqsi,
		phy_dqst => ddrphy_dqst,
		phy_dqso => ddrphy_dqso,
		phy_dmi  => ddrphy_dmo,
		phy_dmt  => ddrphy_dmt,
		phy_dmo  => ddrphy_dmi,
		phy_dqi  => ddrphy_dqi,
		phy_dqt  => ddrphy_dqt,
		phy_dqo  => ddrphy_dqo,
		phy_odt  => ddrphy_odt,
		phy_sti  => ddrphy_sti,
		phy_sto  => ddrphy_sto,

		ddr_clk  => ddr_clk,
		ddr_cke  => sd_cke,
		ddr_cs   => sd_cs,
		ddr_ras  => sd_ras,
		ddr_cas  => sd_cas,
		ddr_we   => sd_we,
		ddr_b    => sd_ba,
		ddr_a    => sd_a,

		ddr_dm   => sd_dm,
		ddr_dqt  => ddr_dqt,
		ddr_dqi  => sd_dq,
		ddr_dqo  => ddr_dqo,
		ddr_dqst => ddr_dqst,
		ddr_dqsi => sd_dqs,
		ddr_dqso => ddr_dqso);

end;
