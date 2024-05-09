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
use hdl4fpga.base.all;

architecture nuhs3adsp_graphics of testbench is
	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	component nuhs3adsp is
		generic (
			debug : boolean := true);
		port (
			clk : in std_logic;
			sw1 : in std_logic := '1';

			hd_t_data  : inout std_logic := '1';
			hd_t_clock : in std_logic;

			dip : in std_logic_vector(0 to 7) := (others => 'Z');
			led18 : out std_logic := 'Z';
			led16 : out std_logic := 'Z';
			led15 : out std_logic := 'Z';
			led13 : out std_logic := 'Z';
			led11 : out std_logic := 'Z';
			led9  : out std_logic := 'Z';
			led8  : out std_logic := 'Z';
			led7  : out std_logic := 'Z';

			---------------
			-- Video DAC --

			hsync : out std_logic := '0';
			vsync : out std_logic := '0';
			clk_videodac : out std_logic := 'Z';
			blankn : out std_logic := 'Z';
			sync  : out std_logic := 'Z';
			psave : out std_logic := 'Z';
			red   : out std_logic_vector(8-1 downto 0) := (others => 'Z');
			green : out std_logic_vector(8-1 downto 0) := (others => 'Z');
			blue  : out std_logic_vector(8-1 downto 0) := (others => 'Z');

			---------
			-- ADC --

			adc_clkab : out std_logic := 'Z';
			adc_clkout : in std_logic := 'Z';
			adc_da : in std_logic_vector(14-1 downto 0) := (others => 'Z');
			adc_db : in std_logic_vector(14-1 downto 0) := (others => 'Z');
			adc_daac_enable : in std_logic := 'Z';

			-----------------------
			-- RS232 Transceiver --

			rs232_dcd : in std_logic := 'Z';
			rs232_dsr : in std_logic := 'Z';
			rs232_rd  : in std_logic := 'Z';
			rs232_rts : out std_logic := 'Z';
			rs232_td  : out std_logic := 'Z';
			rs232_cts : in std_logic := 'Z';
			rs232_dtr : out std_logic := 'Z';
			rs232_ri  : in std_logic := 'Z';

			------------------------------
			-- MII ethernet Transceiver --

			mii_rstn  : out std_logic := 'Z';
			mii_refclk : out std_logic := 'Z';
			mii_intrp  : in std_logic := 'Z';

			mii_mdc  : out std_logic := 'Z';
			mii_mdio : inout std_logic := 'Z';

			mii_txc  : in  std_logic := 'Z';
			mii_txen : out std_logic := 'Z';
			mii_txd  : out std_logic_vector(4-1 downto 0) := (others => 'Z');

			mii_rxc  : in std_logic := 'Z';
			mii_rxdv : in std_logic := 'Z';
			mii_rxer : in std_logic := 'Z';
			mii_rxd  : in std_logic_vector(4-1 downto 0) := (others => 'Z');

			mii_crs  : in std_logic := '0';
			mii_col  : in std_logic := '0';

			-------------
			-- DDR RAM --

			ddr_ckp : out std_logic := 'Z';
			ddr_ckn : out std_logic := 'Z';
			ddr_lp_ckp : in std_logic := 'Z';
			ddr_lp_ckn : in std_logic := 'Z';
			ddr_st_lp_dqs : in std_logic := 'Z';
			ddr_st_dqs : out std_logic := 'Z';
			ddr_cke : out std_logic := 'Z';
			ddr_cs  : out std_logic := 'Z';
			ddr_ras : out std_logic := 'Z';
			ddr_cas : out std_logic := 'Z';
			ddr_we  : out std_logic := 'Z';
			ddr_ba  : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => 'Z');
			ddr_a   : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => 'Z');
			ddr_dm  : inout std_logic_vector(0 to 2-1) := (0 to 2-1 => 'Z');
			ddr_dqs : inout std_logic_vector(0 to 2-1) := (0 to 2-1 => 'Z');
			ddr_dq  : inout std_logic_vector(16-1 downto 0) := (16-1 downto 0 => 'Z'));
	end component;

	component ddr_model is
		port (
			clk   : in std_logic;
			clk_n : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm    : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0));
	end component;

	constant snd_data  : std_logic_vector :=
		x"01007e" &
		x"18ff"   &
		x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
		x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
		x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
		x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
		x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
		x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
		x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
		x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
		x"1702_00000f_1603_0000_0000";
	constant req_data  : std_logic_vector :=
		x"010008_1702_00000f_1603_8000_0000";

	constant baudrate : natural := 1e6;

	signal rst        : std_logic;
	signal clk        : std_logic := '0';
	signal led7       : std_logic;
	signal sw1        : std_logic := '1';

	signal dq         : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal dqs        : std_logic_vector (1 downto 0) := "00";
	signal addr       : std_logic_vector (addr_bits - 1 downto 0);
	signal ba         : std_logic_vector (1 downto 0);
	signal clk_p      : std_logic := '0';
	signal clk_n      : std_logic := '0';
	signal cke        : std_logic := '1';
	signal cs_n       : std_logic := '1';
	signal ras_n      : std_logic;
	signal cas_n      : std_logic;
	signal we_n       : std_logic;
	signal dm         : std_logic_vector(1 downto 0);

	signal mii_refclk : std_logic;
	signal mii_rxdv   : std_logic;
	signal mii_rxd    : std_logic_vector(0 to 4-1);
	signal mii_txd    : std_logic_vector(0 to 4-1);
	signal mii_txen   : std_logic;

	signal ddr_lp_dqs : std_logic;

begin

	rst <= '0', '1' after 300 ns;
	clk <= not clk after 25 ns;

    ipoetb_e : entity work.ipoe_tb
	generic map (
		snd_data => snd_data,
		req_data => req_data)
	port map (
		mii_clk  => mii_refclk,
		mii_rxdv => mii_txen,
		mii_rxd  => mii_txd,

		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : nuhs3adsp
	port map (
		clk => clk,
		sw1  => sw1,
		led7 => led7,
		dip => b"0000_0001",

		---------
		-- ADC --

		adc_da => (others => '0'),
		adc_db => (others => '0'),


		hd_t_clock => rst,

		mii_refclk => mii_refclk,
		mii_rxc    => mii_refclk,
		mii_rxdv   => mii_rxdv,
		mii_rxd    => mii_rxd,
		mii_txc    => mii_refclk,
		mii_txen   => mii_txen,
		mii_txd    => mii_txd,
		-------------
		-- DDR RAM --

		ddr_ckp    => clk_p,
		ddr_ckn    => clk_n,
		ddr_lp_ckp => clk_p,
		ddr_lp_ckn => clk_n,
		ddr_st_lp_dqs => ddr_lp_dqs,
		ddr_st_dqs => ddr_lp_dqs,
		ddr_cke    => cke,
		ddr_cs     => cs_n,
		ddr_ras    => ras_n,
		ddr_cas    => cas_n,
		ddr_we     => we_n,
		ddr_ba     => ba,
		ddr_a      => addr,
		ddr_dm     => dm,
		ddr_dqs    => dqs,
		ddr_dq     => dq);

	ddr_model_g: ddr_model
	port map (
		Clk   => clk_p,
		Clk_n => clk_n,
		Cke   => cke,
		Cs_n  => cs_n,
		Ras_n => ras_n,
		Cas_n => cas_n,
		We_n  => we_n,
		Ba    => ba,
		Addr  => addr,
		Dm    => dm,
		Dq    => dq,
		Dqs   => dqs);

end;

library micron;

configuration nuhs3adsp_graphic_structure_md of testbench is
	for nuhs3adsp_graphics
		for all : nuhs3adsp
			use entity work.nuhs3adsp(structure);
		end for;
		for all: ddr_model
			use entity micron.ddr_model
			port map (
				Clk   => clk_p,
				Clk_n => clk_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm    => dm,
				Dq    => dq,
				Dqs   => dqs);
		end for;
	end for;
end;

library micron;

configuration nuhs3adsp_graphics_md of testbench is
	for nuhs3adsp_graphics
		for all : nuhs3adsp
			use entity work.nuhs3adsp(graphics);
		end for;
			for all : ddr_model
			use entity micron.ddr_model
			port map (
				Clk   => clk_p,
				Clk_n => clk_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm    => dm,
				Dq    => dq,
				Dqs   => dqs);

		end for;
	end for;
end;
