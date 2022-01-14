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

architecture arty_graphics of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 14;
	constant cols_bits  : natural := 10;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal reset_n : std_logic;
	signal rst   : std_logic;
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs_p : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal addr  : std_logic_vector (addr_bits-1 downto 0) := (others => '0');
	signal ba    : std_logic_vector (bank_bits-1 downto 0);
	signal ddr_clk_p : std_logic;
	signal ddr_clk_n : std_logic;
	signal cke   : std_logic;
	signal rst_n : std_logic;
	signal cs_n  : std_logic;
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(data_bytes-1 downto 0);
	signal odt   : std_logic;
	signal scl   : std_logic;
	signal sda   : std_logic;
	signal tdqs_n : std_logic_vector(dqs_p'range);

	signal mii_refclk : std_logic;
	signal mii_req : std_logic := '0';
	signal ping_req : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 4-1);
	signal mii_txd  : std_logic_vector(0 to 4-1);
	signal mii_txc  : std_logic;
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;

	component arty is
		port (
			btn : in std_logic_vector(4-1 downto 0) := (others => '-');
			sw  : in std_logic_vector(4-1 downto 0) := (others => '-');
			led : out std_logic_vector(8-1 downto 4);
			RGBled : out std_logic_vector(4*3-1 downto 0);

			gclk100   : in std_logic;
			eth_rstn  : out std_logic;
			eth_ref_clk : out std_logic;
			eth_mdio  : inout std_logic;
			eth_mdc   : out std_logic;
			eth_crs   : in std_logic;
			eth_col   : in std_logic;
			eth_tx_clk  : in std_logic;
			eth_tx_en : out std_logic;
			eth_txd   : out std_logic_vector(0 to 4-1);
			eth_rx_clk  : in std_logic;
			eth_rxerr : in std_logic;
			eth_rx_dv : in std_logic;
			eth_rxd   : in std_logic_vector(0 to 4-1);

			ddr3_reset : out std_logic := '0';
			ddr3_clk_p : out std_logic := '0';
			ddr3_clk_n : out std_logic := '0';
			ddr3_cke : out std_logic := '0';
			ddr3_cs  : out std_logic := '1';
			ddr3_ras : out std_logic := '1';
			ddr3_cas : out std_logic := '1';
			ddr3_we  : out std_logic := '1';
			ddr3_ba  : out std_logic_vector( 3-1 downto 0) := (others => '1');
			ddr3_a   : out std_logic_vector(14-1 downto 0) := (others => '1');
			ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs_p : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs_n : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddr3_odt : out std_logic := '1');

	end component;

	component ddr3_model is
		port (
			rst_n : in std_logic;
			ck    : in std_logic;
			ck_n  : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(3-1 downto 0);
			addr  : in std_logic_vector(13-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq    : inout std_logic_vector(16-1 downto 0);
			dqs   : inout std_logic_vector(2-1 downto 0);
			dqs_n : inout std_logic_vector(2-1 downto 0);
			tdqs_n : inout std_logic_vector(2-1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;

	signal xtal   : std_logic := '0';
	signal xtal_n : std_logic := '0';
	signal xtal_p : std_logic := '0';

begin

	rst   <= '1', '0' after 1.1 us;
	reset_n <= not rst;

	xtal   <= not xtal after 5 ns;
	xtal_p <= not xtal after 5 ns;
	xtal_n <=     xtal after 5 ns;

	mii_rxc <= mii_refclk;
	mii_txc <= mii_refclk;


	mii_req <= '0', '1' after 21 us, '0' after 27 us; --, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
--	process
--	begin
--		wait for 206 us;
--		loop
--			if ping_req='1' then
--				ping_req <= '0' after 5.8 us;
--			else
--				ping_req <= '1' after 250 ns;
--			end if;
--			wait on ping_req;
--		end loop;
--	end process;

	htb_e : entity hdl4fpga.eth_tb
	generic map (
		debug =>false)
	port map (
		mii_data4 => x"01007e_1702_00003f_1603_8000_03ff",
		mii_frm1 => '0',
		mii_frm2 => ping_req,
		mii_frm3 => '0',
		mii_frm4 => mii_req,

		mii_txc  => mii_rxc,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : arty
	port map (
		btn(0) => rst,
		btn(4-1 downto 1) => (1 to 3 => '-'),

		gclk100     => xtal,
		eth_rstn    => open,
		eth_ref_clk => mii_refclk,
		eth_mdc     => open,
		eth_crs     => '-',
		eth_col     => '-',
		eth_tx_clk  => mii_rxc,
		eth_tx_en   => mii_txen,
		eth_txd     => open,
		eth_rx_clk  => mii_rxc,
		eth_rxerr   => '-',
		eth_rx_dv   => mii_rxdv,
		eth_rxd     => mii_rxd,

		-- DDR RAM --

		ddr3_reset => rst_n,
		ddr3_clk_p => ddr_clk_p,
		ddr3_clk_n => ddr_clk_n,
		ddr3_cke   => cke,
		ddr3_cs    => cs_n,
		ddr3_ras   => ras_n,
		ddr3_cas   => cas_n,
		ddr3_we    => we_n,
		ddr3_ba    => ba,
		ddr3_a     => addr,
		ddr3_dqs_p => dqs_p,
		ddr3_dqs_n => dqs_n,
		ddr3_dq    => dq,
		ddr3_dm    => dm,
		ddr3_odt   => odt);


	mt_u : ddr3_model
	port map (
		rst_n => rst_n,
		Ck    => ddr_clk_p,
		Ck_n  => ddr_clk_n,
		Cke   => cke,
		Cs_n  => cs_n,
		Ras_n => ras_n,
		Cas_n => cas_n,
		We_n  => we_n,
		Ba    => ba,
		Addr  => addr(13-1 downto 0),
		Dm_tdqs  => dm,
		Dq    => dq,
		Dqs   => dqs_p,
		Dqs_n => dqs_n,
		tdqs_n => tdqs_n,
		Odt   => odt);
end;

library micron;

configuration arty_structure_md of testbench is
	for arty_graphics
		for all: arty
			use entity work.arty(structure);
		end for;

		for all : ddr3_model
			use entity micron.ddr3
			port map (
				rst_n => rst_n,
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr(13-1 downto 0),
				Dm_tdqs  => dm,
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				tdqs_n => tdqs_n,
				Odt   => odt);
		end for;
	end for;
end;

library micron;

configuration arty_graphics_md of testbench is
	for arty_graphics
		for all: arty
			use entity work.arty(graphics);
		end for;

		for all: ddr3_model
			use entity micron.ddr3
			port map (
				rst_n => rst_n,
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm_tdqs  => dm,
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				tdqs_n => tdqs_n,
				Odt   => odt);
		end for;
	end for;
end;
