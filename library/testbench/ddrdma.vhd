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

	constant FPGA        : natural;
	constant MARK        : natural := M6T;
	constant TCP         : natural := 6000;

	constant CMMD_GEAR   : natural :=  1;
	constant BANK_SIZE   : natural :=  2;
	constant ADDR_SIZE   : natural := 13;
	constant SCLK_PHASES : natural :=  2;
	constant SCLK_EDGES  : natural :=  2;
	constant DATA_PHASES : natural :=  2;
	constant DATA_EDGES  : natural :=  2;
	constant DATA_GEAR   : natural :=  2;
	constant WORD_SIZE   : natural := 16;
	constant BYTE_SIZE   : natural :=  8;

	signal dmactlr_rst  : std_logic;
	signal dmactlr_clk  : std_logic;
	signal dmactlr_we   : std_logic;
	signal dmactlr_irdy : std_logic;
	signal dmactlr_trdy : std_logic;

	signal ctlr_irdy    : std_logic;
	signal ctlr_trdy    : std_logic;
	signal ctlr_rw      : std_logic;
	signal ctlr_act     : std_logic;
	signal ctlr_cas     : std_logic;
	signal ctlr_inirdy  : std_logic;
	signal ctlr_refreq  : std_logic;
	signal ctlr_b       : std_logic_vector(BANK_SIZE-1 downto 0);
	signal ctlr_a       : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ctlr_di      : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ctlr_do      : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ctlr_dm      : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ctlr_do_irdy : std_logic;
	signal ctlr_di_irdy : std_logic;
	signal ctlr_di_trdy : std_logic;

	signal dst_clk      : std_logic;
	signal dst_irdy     : std_logic;
	signal dst_trdy     : std_logic;
	signal dst_do       : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
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
		FPGA        => SPARTAN3;
		MARK        => M6T,
		TCP         => 6000,

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
		phy_cke      => ,
		phy_cs       => ,
		phy_ras      => ,
		phy_cas      => ,
		phy_we       => ,
		phy_b        => ,
		phy_a        => ,
		phy_odt      => ,
		phy_dmi      => ,
		phy_dmt      => ,
		phy_dmo      => ,

		phy_dqi      => ,
		phy_dqt      => ,
		phy_dqo      => ,
		phy_sti      => ,
		phy_sto      => ,

		phy_dqsi     => ,
		phy_dqso     => ,
		phy_dqst     => );

end;
