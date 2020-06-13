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

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3versa_ddr of testbench is

	signal rst    : std_logic;
	signal rstn   : std_logic;
	signal xtal   : std_logic := '0';

	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 10;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal dq    : std_logic_vector (data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs_p : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal addr  : std_logic_vector (addr_bits-1 downto 0) := (others => '0');
	signal ba    : std_logic_vector (bank_bits-1 downto 0);
	signal ddr_clk   : std_logic;
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

	component ecp3versa is
		port (
			clk  : in std_logic := 'Z';
			
			led   : out std_logic_vector(0 to 7);
			seg  : out std_logic_vector(0 to 14);
			
			ddr3_clk : out std_logic := 'Z';
--			ddr3_vref : out std_logic := 'Z';
			ddr3_rst : out std_logic := 'Z';
			ddr3_cke : out std_logic := 'Z';
			ddr3_cs  : out std_logic := 'Z';
			ddr3_ras : out std_logic := 'Z';
			ddr3_cas : out std_logic := 'Z';
			ddr3_we  : out std_logic := 'Z';
			ddr3_b   : out std_logic_vector( 2 downto 0) := (others => 'Z');
			ddr3_a   : out std_logic_vector(12 downto 0) := (others => 'Z');
			ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddr3_odt : inout std_logic;


			phy1_125clk : in std_logic;
			phy1_rst : out std_logic;
			phy1_coma : out std_logic;
			phy1_mdio : inout std_logic;
			phy1_mdc : out std_logic;
			phy1_gtxclk : out std_logic := '1';
			phy1_crs : out std_logic;
			phy1_col : out std_logic;
			phy1_txc : in std_logic := '0';
			phy1_tx_d : out std_logic_vector(0 to 8-1);
			phy1_tx_en : out std_logic;
			phy1_rxc : in std_logic;
			phy1_rx_er : in std_logic;
			phy1_rx_dv : in std_logic;
			phy1_rx_d : in std_logic_vector(0 to 8-1);

--			phy2_125clk : in std_logic;
--			phy2_rst : out std_logic := '0';
--			phy2_coma : out std_logic;
--			phy2_mdio: inout std_logic;
--			phy2_mdc : out std_logic;
--			phy2_gtxclk : out std_logic := '1';
--			phy2_crs : out std_logic;
--			phy2_col : out std_logic;
--			phy2_txc : out std_logic;
--			phy2_tx_d : out std_logic_vector(0 to 8-1);
--			phy2_tx_en : out std_logic;
--			phy2_rxc : in std_logic;
--			phy2_rx_er : in std_logic;
--			phy2_rx_dv : in std_logic;
--			phy2_rx_d : in std_logic_vector(0 to 8-1)
			fpga_gsrn : in std_logic);
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
			addr  : in std_logic_vector(addr_bits-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq    : inout std_logic_vector(16-1 downto 0);
			dqs   : inout std_logic_vector(2-1 downto 0);
			dqs_n : inout std_logic_vector(2-1 downto 0);
			tdqs_n : inout std_logic_vector(2-1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;

	signal phy1_125clk : std_logic := '0';

	signal mii_treq : std_logic := '0';
	signal mii_trdy : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 8-1);
	signal mii_rxc  : std_logic;

	constant sin_data  : std_logic_vector := 
		  x"170200007f"
		& x"18ff"
		& x"123456789abcdef123456789abcdef12"
		& x"23456789abcdef123456789abcdef123"
		& x"3456789abcdef123456789abcdef1234"
		& x"456789abcdef123456789abcdef12345"
		& x"56789abcdef123456789abcdef123456"
		& x"6789abcdef123456789abcdef1234567"
		& x"789abcdef123456789abcdef12345678"
		& x"89abcdef123456789abcdef123456789"
		& x"9abcdef123456789abcdef123456789a"
		& x"abcdef123456789abcdef123456789ab"
		& x"bcdef123456789abcdef123456789abc"
		& x"cdef123456789abcdef123456789abcd"
		& x"def123456789abcdef123456789abcde"
		& x"ef123456789abcdef123456789abcdef"
		& x"f123456789abcdef123456789abcdef1"
		& x"123456789abcdef123456789abcdef12"
		& x"1602000180"
		& x"ffff"
--		& x"170200007f"
--		& x"18ff"
--		& x"1234ffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffaabb"
--		& x"ccddffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffffffff"
--		& x"ffffffffffffffffffffffffffff6789"
--		& x"1602000000"
--		& x"ffff"
		;

begin

	rst    <= '1', '0' after (1 us+82.5 us);
	rstn  <= not rst;

	xtal   <= not xtal after 20 ns;

	phy1_125clk <= not phy1_125clk after 4 ns;
	mii_rxc     <= phy1_125clk;

	eth_e: entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(
			x"5555_5555_5555_55d5"  &
			x"00_40_00_01_02_03"    &
			x"00_00_00_00_00_00"    &
			x"0800"                 &
			x"4500"                 &    -- IP Version, TOS
			x"0000"                 &    -- IP Length
			x"0000"                 &    -- IP Identification
			x"0000"                 &    -- IP Fragmentation
			x"0511"                 &    -- IP TTL, protocol
			x"00000000"             &    -- IP Source IP address
			x"00000000"             &    -- IP Destiantion IP Address
			x"0000" &

			udp_checksummed (
				x"00000000",
				x"ffffffff",
				x"0044dea9"         &    -- UDP Source port, Destination port
				x"000f"             & -- UDP Length,
				x"0000"             & -- UPD checksum
				x"000000"           &
				sin_data)           &
			x"00000000"
		,8))
	port map (
		mii_txc  => mii_rxc,
		mii_treq => mii_treq,
		mii_trdy => mii_trdy,
		mii_txdv => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : ecp3versa
	port map (
		clk       => xtal,
		fpga_gsrn => rstn,

		phy1_125clk => phy1_125clk,
		phy1_rxc   => mii_rxc,
		phy1_rx_er => '-',
		phy1_rx_dv => mii_rxdv,
		phy1_rx_d  => mii_rxd,

		phy1_txc   => open,
		phy1_tx_en => open,

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

	dqs_n     <= not dqs_p;
	ddr_clk_p <=     ddr_clk;
	ddr_clk_n <= not ddr_clk;

	mt_u : ddr3_model
	port map (
		rst_n   => rst_n,
		Ck      => ddr_clk_p,
		Ck_n    => ddr_clk_n,
		Cke     => cke,
		Cs_n    => cs_n,
		Ras_n   => ras_n,
		Cas_n   => cas_n,
		We_n    => we_n,
		Ba      => ba,
		Addr    => addr,
		Dm_tdqs => dm,
		Dq      => dq,
		Dqs     => dqs_p,
		Dqs_n   => dqs_n,
		tdqs_n  => tdqs_n,
		Odt     => odt);
end;

library micron;

configuration ecp3versa_structure_md of testbench is
	for ecp3versa_ddr 
		for all: ecp3versa 
			use entity work.ecp3versa(structure);
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

library micron;

configuration ecp3versa_scope_md of testbench is
	for ecp3versa_ddr 
		for all: ecp3versa
			use entity work.ecp3versa(ddr);
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
