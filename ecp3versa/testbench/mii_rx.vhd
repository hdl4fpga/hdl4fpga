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

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_textio.all;

architecture scope of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 10;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal reset_n      : std_logic;
	signal rst          : std_logic;
	signal led7         : std_logic;

	signal dq           : std_logic_vector(data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs_p        : std_logic_vector(data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n        : std_logic_vector(data_bytes-1 downto 0) := (others => 'Z');
	signal addr         : std_logic_vector(addr_bits-1  downto 0) := (others => '0');
	signal ba           : std_logic_vector(bank_bits-1  downto 0);
	signal ddr_clk      : std_logic;
	signal ddr_clk_p    : std_logic;
	signal ddr_clk_n    : std_logic;
	signal cke          : std_logic;
	signal rst_n        : std_logic;
	signal cs_n         : std_logic;
	signal ras_n        : std_logic;
	signal cas_n        : std_logic;
	signal we_n         : std_logic;
	signal dm           : std_logic_vector(data_bytes-1 downto 0);
	signal odt          : std_logic;
	signal scl          : std_logic;
	signal sda          : std_logic;
	signal tdqs_n       : std_logic_vector(dqs_p'range);

	signal mii_refclk   : std_logic := '0';
	signal mii_treq     : std_logic := '0';
	signal mii_rxdv     : std_logic;
	signal mii_rxd      : std_logic_vector(0 to 8-1);
	signal mii_rxdv_d   : std_logic;
	signal mii_rxd_d    : std_logic_vector(0 to 8-1);
	signal mii_rxc      : std_logic;
	signal mii_txen     : std_logic;
	signal mii_trdy     : std_logic;
	signal mii_strt     : std_logic;

	component ecp3versa is
		port (
			clk         : in std_logic := 'Z';
--			clk_n       : in std_logic := 'Z';
--			pclk        : in std_logic;
--			pclk_n      : in std_logic;
			
			led         : out std_logic_vector(0 to 7);
			seg         : out std_logic_vector(0 to 14);
			
			ddr3_clk    : out std_logic := 'Z';
--			ddr3_vref   : out std_logic := 'Z';
			ddr3_rst    : out std_logic := 'Z';
			ddr3_cke    : out std_logic := 'Z';
			ddr3_cs     : out std_logic := 'Z';
			ddr3_ras    : out std_logic := 'Z';
			ddr3_cas    : out std_logic := 'Z';
			ddr3_we     : out std_logic := 'Z';
			ddr3_b      : out std_logic_vector( 2 downto 0) := (others => 'Z');
			ddr3_a      : out std_logic_vector(12 downto 0) := (others => 'Z');
			ddr3_dm     : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs    : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dq     : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddr3_odt    : inout std_logic;

			phy1_125clk : in  std_logic;
			phy1_rst    : out std_logic;
			phy1_coma   : out std_logic;
			phy1_mdio   : inout std_logic;
			phy1_mdc    : out std_logic;
			phy1_gtxclk : out std_logic := '1';
			phy1_crs    : out std_logic;
			phy1_col    : out std_logic;
			phy1_txc    : in  std_logic := '0';
			phy1_tx_d   : out std_logic_vector(0 to 8-1);
			phy1_tx_en  : out std_logic;
			phy1_rxc    : in  std_logic;
			phy1_rx_er  : in  std_logic;
			phy1_rx_dv  : in  std_logic;
			phy1_rx_d   : in  std_logic_vector(0 to 8-1);

--			phy2_125clk : in std_logic;
--			phy2_rst    : out std_logic := '0';
--			phy2_coma   : out std_logic;
--			phy2_mdio   : inout std_logic;
--			phy2_mdc    : out std_logic;
--			phy2_gtxclk : out std_logic := '1';
--			phy2_crs    : out std_logic;
--			phy2_col    : out std_logic;
--			phy2_txc    : out std_logic;
--			phy2_tx_d   : out std_logic_vector(0 to 8-1);
--			phy2_tx_en  : out std_logic;
--			phy2_rxc    : in std_logic;
--			phy2_rx_er  : in std_logic;
--			phy2_rx_dv  : in std_logic;
--			phy2_rx_d   : in std_logic_vector(0 to 8-1)
			fpga_gsrn   : in std_logic);
	end component;

	constant delay : time := 1 ns;

	signal xtal   : std_logic := '0';
	signal xtal_n : std_logic := '0';
	signal xtal_p : std_logic := '0';
	signal phy1_125clk : std_logic := '0';

begin

	xtal <= not xtal after 5 ns;
	rst   <= '1', '0' after 1.1 us;
	reset_n <= not rst;

	phy1_125clk <= not phy1_125clk after 4 ns;
	mii_rxc <= phy1_125clk;
	mii_refclk <= phy1_125clk;

	mii_strt <= '0', '1' after 1 us;
	process (mii_refclk, mii_strt)
		variable edge : std_logic;
		variable cnt  : natural := 0;
	begin
		if mii_strt='0' then
			mii_treq <= '0';
			edge := '0';
		elsif rising_edge(mii_refclk) then
			if mii_trdy='1' then
				if edge='0' then
					mii_treq <= '0';
				end if;
			elsif cnt < 2 then
				mii_treq <= '1';
				if mii_treq='0' then
					cnt := cnt + 1;
				end if;
			end if;
			edge := mii_txen;
		end if;
	end process;

	eth_e: entity hdl4fpga.mii_mem
	generic map (
		mem_data => x"5555_5555_5555_55d5_00_00_00_01_02_03_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff_00000000_000000ff")
	port map (
		mii_txc  => mii_rxc,
		mii_treq => mii_treq,
		mii_txen => mii_rxdv_d,
		mii_trdy => mii_trdy,
		mii_txd  => mii_rxd_d);

		mii_rxdv <= mii_rxdv_d after 1 ns;
		mii_rxd  <= mii_rxd_d  after 1 ns;

	ecp3versa_e : ecp3versa
	port map (
		clk    => xtal,
--		clk_n  => xtal_n,
--		pclk   => '-',
--		pclk_n => '-',

		fpga_gsrn => reset_n,

		phy1_125clk => phy1_125clk,
		phy1_rxc   => mii_rxc,
		phy1_rx_er => '-',
		phy1_rx_dv => mii_rxdv,
		phy1_rx_d  => mii_rxd,

		phy1_txc   => open,
		phy1_tx_en => mii_txen,

--		phy2_125clk => phy1_125clk,
--		phy2_rxc   => '-',
--		phy2_rx_d  => (others => '-'),
--		phy2_rx_er => '-',
--		phy2_rx_dv => '-',

		--         --
		-- DDR RAM --
		--         --

		ddr3_rst => rst_n,
		ddr3_clk => ddr_clk,
		ddr3_cs  => cs_n,
		ddr3_cke => cke,
		ddr3_ras => ras_n,
		ddr3_cas => cas_n,
		ddr3_we  => we_n,
		ddr3_b   => ba,
		ddr3_a   => addr(12 downto 0),
		ddr3_dqs => dqs_p,
		ddr3_dq  => dq,
		ddr3_dm  => dm,
		ddr3_odt => odt);
end;
