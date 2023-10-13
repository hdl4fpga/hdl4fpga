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
use hdl4fpga.ipoepkg.all;

architecture ulx4mld_graphics of testbench is

	constant debug          : boolean := false;

	constant bank_bits      : natural := 3;
	constant addr_bits      : natural := 16;
	constant cols_bits      : natural := 9;
	constant data_bytes     : natural := 2;
	constant byte_bits      : natural := 8;
	constant data_bits      : natural := byte_bits*data_bytes;

	component ulx4m_ld is
		generic (
			debug           : boolean := debug);
		port (
			clk_25mhz       : in    std_logic;
			btn             : in    std_logic_vector(1 to 3) := (others => '-');
			led             : out   std_logic_vector(0 to 8-1) := (others => 'Z');

			sd_clk          : in    std_logic := '-';
			sd_cmd          : out   std_logic; 
			sd_d            : inout std_logic_vector(4-1 downto 0) := (others => '-');
			sd_wp           : in    std_logic := '-';
			sd_cdn          : in    std_logic := '-';

			usb_fpga_dp     : inout std_logic := '-';
			usb_fpga_dn     : inout std_logic := '-';
			usb_fpga_bd_dp  : inout std_logic := '-';
			usb_fpga_bd_dn  : inout std_logic := '-';
			usb_fpga_pu_dp  : inout std_logic := '-';
			usb_fpga_pu_dn  : inout std_logic := '-';
			usb_fpga_otg_dp : inout std_logic := 'Z';
			usb_fpga_otg_dn : inout std_logic := 'Z';
			n_extrst        : inout std_logic := 'Z';

			eth_resetn      : out   std_logic;
			-- rgmii_ref_clk  : in    std_logic;
			eth_mdio        : inout std_logic := '-';
			eth_mdc         : out   std_logic;
	
			rgmii_tx_clk    : out    std_logic := '-';
			rgmii_tx_en     : buffer std_logic;
			rgmii_txd       : buffer std_logic_vector(0 to 4-1);
			rgmii_rx_clk    : in    std_logic := '-';
			rgmii_rx_dv     : in    std_logic := '-';
			rgmii_rxd       : in    std_logic_vector(0 to 4-1) := (others => '-');

			ddram_clk       : inout std_logic;
			ddram_reset_n   : out   std_logic;
			ddram_cke       : out   std_logic;
			ddram_cs_n      : out   std_logic;
			ddram_ras_n     : out   std_logic;
			ddram_cas_n     : out   std_logic;
			ddram_we_n      : out   std_logic;
			ddram_odt       : out   std_logic;
			ddram_a         : out   std_logic_vector(16-1 downto 0);
			ddram_ba        : out   std_logic_vector( 3-1 downto 0);
			ddram_dm        : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
			ddram_dq        : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddram_dqs       : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');

    		ftdi_txd        : in    std_logic;
    		ftdi_txden      : out   std_logic := 'Z';
    		ftdi_rxd        : out   std_logic := 'Z';

            gpdi_d          : out   std_logic_Vector(8-1 downto 0) := (others => 'Z');
            gpdi_cec        : out   std_logic;

            gpio_scl        : out   std_logic;
            cam_scl         : out   std_logic;

			user_programn   : out   std_logic := '1';
			shutdown        : out   std_logic := '0');
	end component;

	component ddr3_model is
		port (
			rst_n   : in std_logic;
			ck      : in std_logic;
			ck_n    : in std_logic;
			cke     : in std_logic;
			cs_n    : in std_logic;
			ras_n   : in std_logic;
			cas_n   : in std_logic;
			we_n    : in std_logic;
			ba      : in std_logic_vector(3-1 downto 0);
			addr    : in std_logic_vector(16-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq      : inout std_logic_vector(16-1 downto 0);
			dqs     : inout std_logic_vector(2-1 downto 0);
			dqs_n   : inout std_logic_vector(2-1 downto 0);
			tdqs_n  : inout std_logic_vector(2-1 downto 0);
			odt     : in std_logic);
	end component;

	constant usb_freq     : real := 12.0e6;
	constant snd_data : std_logic_vector := 
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
		x"1702_0000ff_1603_0000_0000";
	-- constant req_data : std_logic_vector := x"010000_1702_0000ff_1603_8000_0000";
	constant req_data  : std_logic_vector :=
		x"010008_1702_00003f_1603_8000_0000";

	signal rst_n      : std_logic;
	signal cke        : std_logic;
	signal ddr_clk    : std_logic;
	signal ddr_clk_p  : std_logic;
	signal ddr_clk_n  : std_logic;
	signal cs_n       : std_logic;
	signal ras_n      : std_logic;
	signal cas_n      : std_logic;
	signal we_n       : std_logic;
	signal ba         : std_logic_vector(bank_bits-1 downto 0);
	signal addr       : std_logic_vector(addr_bits-1 downto 0) := (others => '0');
	signal dq         : std_logic_vector(data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs        : std_logic_vector(data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n      : std_logic_vector(dqs'range) := (others => 'Z');
	signal dm         : std_logic_vector(data_bytes-1 downto 0);
	signal odt        : std_logic;
	signal scl        : std_logic;
	signal sda        : std_logic;
	signal tdqs_n     : std_logic_vector(dqs'range);

	signal gmii_rxc  : std_logic := '0';
	signal rgmii_rxc  : std_logic := '0';
	signal rgmii_rxdv : std_logic;
	signal rgmii_rxd  : std_logic_vector(0 to 4-1);
	signal gmii_rxdv  : std_logic;
	signal gmii_rxd   : std_logic_vector(0 to 8-1);

	signal rgmii_txc  : std_logic;
	signal rgmii_txen : std_logic;
	signal rgmii_txd  : std_logic_vector(0 to 4-1);
	signal gmii_txen  : std_logic;
	signal gmii_txd   : std_logic_vector(0 to 8-1);

	signal usb_fpga_dp : std_logic;
	signal usb_fpga_dn : std_logic;

	signal ftdi_txd   : std_logic;
	signal ftdi_rxd   : std_logic;

	signal uart_clk   : std_logic := '0';
	signal usb_clk     : std_logic := '0';

	signal rst        : std_logic;
	signal xtal       : std_logic := '0';

	signal txc : std_logic;
begin

	rst      <= '1', '0' after 17.5 us when debug else '1', '0' after 10 us;
	xtal     <= not xtal after 20 ns;
	uart_clk <= not uart_clk after 0.1 ns /2 when debug else not uart_clk after 12.5 ns;
	usb_clk <= not usb_clk after 1 sec/(2.0*usb_freq);

	hdlctb_e : entity work.hdlc_tb
	generic map (
		debug     => debug,
		baudrate  =>    3e6,
		uart_freq => 40.0e6,
		payload_segments => (0 => snd_data'length, 1 => req_data'length),
		payload   => snd_data & req_data)
	port map (
		rst       => rst,
		uart_clk  => uart_clk,
		uart_sin  => ftdi_rxd,
		uart_sout => ftdi_txd);

	usb_fpga_dp <= 'H';
	usb_fpga_dn <= 'L';

	usbtb_e : entity work.usb_tb
	generic map (
		debug   => debug,
		-- payload_segments => (0 => snd_data'length, 1 => req_data'length),
		-- payload   => snd_data & req_data)
		payload_segments => (0 => req_data'length),
		payload   => req_data)
	port map (
		rst     => rst,
		usb_clk => usb_clk,
		usb_dp  => usb_fpga_dp,
		usb_dn  => usb_fpga_dn);

    ipoetb_e : entity work.ipoe_tb
	generic map (
		ipaddress => aton("192.168.1.50"),
		delay1   => 35 us,
		snd_data => snd_data,
		req_data => req_data)
	port map (
		mii_clk   => gmii_rxc,
		mii_rxdv  => gmii_txen,
		mii_rxd   => gmii_txd,

		mii_txen  => gmii_rxdv,
		mii_txd   => gmii_rxd);


	gmii_rxc   <= not gmii_rxc after 1 sec/125.0e6/2.0;
	rgmii_rxc  <= gmii_rxc after 1 ps;
	rgmii_rxd  <= transport multiplex(gmii_rxd(0 to 4-1) & gmii_rxd(4 to 8-1),  not gmii_rxc);
	rgmii_rxdv <= transport multiplex(gmii_rxdv          & '0',                 not gmii_rxc);

	txc <= rgmii_txc after 1 ns;
	process (txc)
	begin
		if rising_edge(txc) then
			gmii_txen <= rgmii_txen;
			gmii_txd(0 to 4-1) <= rgmii_txd;
		end if;
		if falling_edge(txc) then
			gmii_txd(4 to 8-1) <= rgmii_txd;
		end if;
	end process;

	du_e : ulx4m_ld
	generic map (
		-- debug => debug)
		debug => true)
	port map (
		clk_25mhz    => xtal,
		btn(1)       => '0',
		btn(2 to 3)  => (others => '-'),

		usb_fpga_dp => usb_fpga_dp,
		usb_fpga_dn => usb_fpga_dn,
		eth_resetn   => open,
		eth_mdc      => open,
		rgmii_tx_clk => rgmii_txc,
		rgmii_tx_en  => rgmii_txen,
		rgmii_txd    => rgmii_txd,
		rgmii_rx_clk => rgmii_rxc,
		rgmii_rx_dv  => rgmii_rxdv,
		rgmii_rxd    => rgmii_rxd,

		ftdi_txd     => ftdi_txd,
		ftdi_rxd     => ftdi_rxd,
		ddram_reset_n => rst_n,
		ddram_clk    => ddr_clk,
		ddram_cke    => cke,
		ddram_cs_n   => cs_n,
		ddram_ras_n  => ras_n,
		ddram_cas_n  => cas_n,
		ddram_we_n   => we_n,
		ddram_ba     => ba,
		ddram_a      => addr,
		ddram_dqs    => dqs,
		ddram_dq     => dq,
		ddram_dm     => dm,
		ddram_odt    => odt);

	ddr_clk_p <= ddr_clk;
	ddr_clk_n <= not ddr_clk;
	dqs_n     <= not dqs;

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
		Addr  => addr,
		Dm_tdqs => dm,
		Dq    => dq,
		Dqs   => dqs,
		Dqs_n => dqs_n,
		tdqs_n => tdqs_n,
		Odt   => odt);

end;

library micron;

configuration ulx4mld_graphics_structure_md of testbench is
	for ulx4mld_graphics
		for all : ulx4m_ld
			use entity work.ulx4m_ld(structure);
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

library micron;

configuration ulx4mld_graphics_md of testbench is
	for ulx4mld_graphics
		for all : ulx4m_ld
			use entity work.ulx4m_ld(graphics);
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