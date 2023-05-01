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

architecture s3estarter_graphics of testbench is
	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	component s3estarter is
		generic (
			debug : boolean);
		port (
			xtal       : in std_logic := '0';
			sw0        : in std_logic := '1';
			btn_west   : in std_logic := '1';

			--------------
			-- switches --

			led0 : out std_logic := '0';
			led1 : out std_logic := '0';
			led2 : out std_logic := '0';
			led3 : out std_logic := '0';
			led4 : out std_logic := '0';
			led5 : out std_logic := '0';
			led6 : out std_logic := '0';
			led7 : out std_logic := '0';

			------------------------------
			-- MII ethernet Transceiver --

			e_txd  	 : out std_logic_vector(0 to 3) := (others => 'Z');
			e_txen   : out std_logic := 'Z';
			e_txd_4  : out std_logic;

			e_tx_clk : in  std_logic := 'Z';

			e_rxd    : in std_logic_vector(0 to 4-1) := (others => 'Z');
			e_rx_dv  : in std_logic := 'Z';
			e_rx_er  : in std_logic := 'Z';
			e_rx_clk : in std_logic := 'Z';

			e_crs    : in std_logic := 'Z';
			e_col    : in std_logic := 'Z';

			e_mdc    : out std_logic := 'Z';
			e_mdio   : inout std_logic := 'Z';

			---------
			-- VGA --
		
			vga_red   : out std_logic;
			vga_green : out std_logic;
			vga_blue  : out std_logic;
			vga_hsync : out std_logic;
			vga_vsync : out std_logic;

			---------
			-- SPI --

			spi_sck  : out std_logic;
			spi_miso : in  std_logic;
			spi_mosi : out std_logic;

			---------
			-- AMP --

			amp_cs   : out std_logic := '0';
			amp_shdn : out std_logic := '0';
			amp_dout : in  std_logic;

			---------
			-- ADC --

			ad_conv  : out std_logic;


			-------------
			-- DDR RAM --

			sd_a          : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => '0');
			sd_dq         : inout std_logic_vector(16-1 downto 0);
			sd_ba         : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => '0');
			sd_ras        : out std_logic := '1';
			sd_cas        : out std_logic := '1';
			sd_we         : out std_logic := '0';
			sd_dm         : inout std_logic_vector(2-1 downto 0);
			sd_dqs        : inout std_logic_vector(2-1 downto 0);
			sd_cs         : out std_logic := '1';
			sd_cke        : out std_logic := '1';
			sd_ck_n       : out std_logic := '0';
			sd_ck_p       : out std_logic := '1';
			sd_ck_fb      : in std_logic := '0');

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
	signal xtal       : std_logic := '0';

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

	signal mii_refclk : std_logic := '0';
	signal mii_rxdv   : std_logic;
	signal mii_rxd    : std_logic_vector(0 to 4-1);
	signal mii_txen   : std_logic;
	signal mii_txd    : std_logic_vector(0 to 4-1);

begin

	xtal <= not xtal after 10 ns;
	rst  <= '0', '1' after 300 ns;

	mii_refclk <= not mii_refclk after 20 ns;

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

	du_e : s3estarter
	generic map (
		debug => true)
	port map (
		btn_west => rst,
		xtal     => xtal,

		spi_miso => '-',
		amp_dout => '-',
		e_tx_clk => mii_refclk,
		e_rx_clk => mii_refclk,
		e_rx_dv => mii_rxdv,
		e_rxd => mii_rxd,
		e_txen => mii_txen,
		-------------
		-- DDR RAM --

		sd_ck_p => clk_p,
		sd_ck_n => clk_n,
		sd_cke => cke,
		sd_cs  => cs_n,
		sd_ras => ras_n,
		sd_cas => cas_n,
		sd_we  => we_n,
		sd_ba  => ba,
		sd_a   => addr,
		sd_dm  => dm,
		sd_dqs => dqs,
		sd_dq  => dq);

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

configuration s3estarter_structure_md of testbench is
	for s3estarter_graphics
		for all : s3estarter
			use entity work.s3estarter(structure);
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

configuration s3estarter_graphics_md of testbench is
	for s3estarter_graphics
		for all : s3estarter 
			use entity work.s3estarter(graphics);
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
