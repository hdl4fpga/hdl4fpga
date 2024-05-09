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

architecture ulx3s_scopeio of testbench is
	constant debug      : boolean := true;

	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant data_bits  : natural := byte_bits*data_bytes;

	component ulx3s is
		generic (
			debug  : boolean := true);
		port (
			clk_25mhz      : in    std_logic;

			ftdi_rxd       : out   std_logic;
			ftdi_txd       : in    std_logic := '-';
			ftdi_nrts      : inout std_logic := '-';
			ftdi_ndtr      : inout std_logic := '-';
			ftdi_txden     : inout std_logic := '-';

			btn_pwr_n      : in  std_logic := 'U';
			fire1          : in  std_logic := 'U';
			fire2          : in  std_logic := 'U';
			up             : in  std_logic := 'U';
			down           : in  std_logic := 'U';
			left           : in  std_logic := 'U';
			right          : in  std_logic := 'U';

			led            : out   std_logic_vector(8-1 downto 0);
			sw             : in    std_logic_vector(4-1 downto 0) := (others => '-');


			oled_clk       : out   std_logic;
			oled_mosi      : out   std_logic;
			oled_dc        : out   std_logic;
			oled_resn      : out   std_logic;
			oled_csn       : out   std_logic;

			--flash_csn      : out   std_logic;
			--flash_clk      : out   std_logic;
			--flash_mosi     : out   std_logic;
			--flash_miso     : in    std_logic;
			--flash_holdn    : out   std_logic;
			--flash_wpn      : out   std_logic;

			sd_clk         : in    std_logic := '-';
			sd_cmd         : out   std_logic; -- sd_cmd=MOSI (out)
			sd_d           : inout std_logic_vector(4-1 downto 0) := (others => '-'); -- sd_d(0)=MISO (in), sd_d(3)=CSn (out)
			sd_wp          : in    std_logic := '-';
			sd_cdn         : in    std_logic := '-'; -- card detect not connected

			adc_csn        : out   std_logic;
			adc_mosi       : out   std_logic;
			adc_miso       : in    std_logic := '-';
			adc_sclk       : out   std_logic;

			audio_l        : out   std_logic_vector(4-1 downto 0);
			audio_r        : out   std_logic_vector(4-1 downto 0);
			audio_v        : out   std_logic_vector(4-1 downto 0);

			wifi_en        : out   std_logic := '1'; -- '0' disables ESP32
			wifi_rxd       : out   std_logic;
			wifi_txd       : in    std_logic := '-';
			wifi_gpio0     : out   std_logic := '1'; -- '0' requests ESP32 to upload "passthru" bitstream
			wifi_gpio5     : inout std_logic := '-';
			wifi_gpio16    : inout std_logic := '-';
			wifi_gpio17    : inout std_logic := '-';

			ant_433mhz     : out   std_logic;

			usb_fpga_dp    : inout std_logic := '-';
			usb_fpga_dn    : inout std_logic := '-';
			usb_fpga_bd_dp : inout std_logic := '-';
			usb_fpga_bd_dn : inout std_logic := '-';
			usb_fpga_pu_dp : inout std_logic := '-';
			usb_fpga_pu_dn : inout std_logic := '-';

			sdram_clk      : inout std_logic;
			sdram_cke      : out   std_logic;
			sdram_csn      : out   std_logic;
			sdram_wen      : out   std_logic;
			sdram_rasn     : out   std_logic;
			sdram_casn     : out   std_logic;
			sdram_a        : out   std_logic_vector(13-1 downto 0);
			sdram_ba       : out   std_logic_vector(2-1 downto 0);
			sdram_dqm      : inout std_logic_vector(2-1 downto 0) := (others => '-');
			sdram_d        : inout std_logic_vector(16-1 downto 0) := (others => '-');

			gpdi_d         : out   std_logic_vector(4-1 downto 0);
			gpdi_cec       : inout std_logic := '-';
			gpdi_sda       : inout std_logic := '-';
			gpdi_scl       : inout std_logic := '-';

			gp             : inout std_logic_vector(28-1 downto 0) := (others => '-');
			gn             : inout std_logic_vector(28-1 downto 0) := (others => '-');
			gp_i           : in    std_logic_vector(12 downto 9) := (others => '-');

			user_programn  : out   std_logic := '1'; -- '0' loads next bitstream from SPI FLASH (e.g. bootloader)
			shutdown       : out   std_logic := '0'); -- '1' power off the board, 10uA sleep
	end component;

	component mt48lc32m16a2 is
		port (
			clk   : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dqm   : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0));
	end component;

	constant usb_freq     : real := 12.0e6;
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

		x"1702_0000ff_1603_0000_0000";
	constant req_data  : std_logic_vector :=
		x"010008_1702_0000ff_1603_8000_0000";

	signal rst         : std_logic;
	signal xtal        : std_logic := '0';

	signal sdram_dq    : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal sdram_addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal sdram_ba    : std_logic_vector (1 downto 0);
	signal sdram_clk   : std_logic := '0';
	signal sdram_cke   : std_logic := '1';
	signal sdram_cs_n  : std_logic := '1';
	signal sdram_ras_n : std_logic;
	signal sdram_cas_n : std_logic;
	signal sdram_we_n  : std_logic;
	signal sdram_dqm   : std_logic_vector(1 downto 0);

	signal gp          : std_logic_vector(28-1 downto 0);
	signal gn          : std_logic_vector(28-1 downto 0) := (others => '0');

	signal usb_fpga_dp : std_logic;
	signal usb_fpga_dn : std_logic;
	signal ftdi_txd    : std_logic;
	signal ftdi_rxd    : std_logic;

	signal fire1       : std_logic;
	signal fire2       : std_logic;

	alias mii_refclk   : std_logic is gn(12);

	signal uart_clk    : std_logic := '0';
	signal usb_clk     : std_logic := '0';


	alias   mii_txen   : std_logic is gp(12);
	signal 	mii_txd    : std_logic_vector(0 to 2-1);
	alias   mii_rxdv   : std_logic is gn(10);
	signal 	mii_rxd    : std_logic_vector(0 to 2-1);

	signal adc_mosi    : std_logic;
	signal adc_miso    : std_logic;
begin

	rst      <= '1', '0' after 10 us;
	xtal     <= not xtal after 20 ns;
	uart_clk <= not uart_clk after 0.1 ns /2 when debug else not uart_clk after 12.5 ns;
	usb_clk <= not usb_clk after 1 sec/(2.0*usb_freq);

	mii_refclk <= not mii_refclk after 1000 ns / 50 /2;
	fire1    <= '0';
	fire2    <= '0';

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
		payload_segments => (0 => snd_data'length),
		payload   => snd_data)
	port map (
		rst     => rst,
		usb_clk => usb_clk,
		usb_dp  => usb_fpga_dp,
		usb_dn  => usb_fpga_dn);

	mii_rxd <= (gp(10), gn(9));
	(gn(11), gp(11)) <= mii_txd;
    ipoetb_e : entity work.ipoe_tb
	generic map (
		delay1   => 10 us,
		snd_data => snd_data,
		req_data => req_data)
	port map (
		mii_clk   => mii_refclk,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,

		mii_txen  => mii_txen,
		mii_txd   => mii_txd); 

	adc_miso <= adc_mosi;
	du_e : ulx3s
	generic map (
		debug => debug)
	port map (
		clk_25mhz  => xtal,
		usb_fpga_dp => usb_fpga_dp,
		usb_fpga_dn => usb_fpga_dn,
		ftdi_txd   => ftdi_txd,
		ftdi_rxd   => ftdi_rxd,
		up         => '0',
		fire1      => fire1,
		fire2      => fire2,
		gp         => gp,
		gn         => gn,
		adc_mosi   => adc_mosi,
		adc_miso   => adc_mosi,
		sdram_clk  => sdram_clk,
		sdram_cke  => sdram_cke,
		sdram_csn  => sdram_cs_n,
		sdram_rasn => sdram_ras_n,
		sdram_casn => sdram_cas_n,
		sdram_wen  => sdram_we_n,
		sdram_ba   => sdram_ba,
		sdram_a    => sdram_addr,
		sdram_dqm  => sdram_dqm,
		sdram_d    => sdram_dq);

	sdr_model_g: mt48lc32m16a2
	port map (
		clk   => sdram_clk,
		cke   => sdram_cke,
		cs_n  => sdram_cs_n,
		ras_n => sdram_ras_n,
		cas_n => sdram_cas_n,
		we_n  => sdram_we_n,
		ba    => sdram_ba,
		addr  => sdram_addr,
		dqm   => sdram_dqm,
		dq    => sdram_dq);
end;

library micron;

configuration ulx3s_scopeio_structure_md of testbench is
	for ulx3s_scopeio
		for all : ulx3s
			use entity work.ulx3s(structure);
		end for;
		for all: mt48lc32m16a2
			use entity micron.mt48lc32m16a2
			port map (
				clk   => sdram_clk,
				cke   => sdram_cke,
				cs_n  => sdram_cs_n,
				ras_n => sdram_ras_n,
				cas_n => sdram_cas_n,
				we_n  => sdram_we_n,
				ba    => sdram_ba,
				addr  => sdram_addr,
				dqm   => sdram_dqm,
				dq    => sdram_dq);
		end for;
	end for;
end;

library micron;

configuration ulx3s_scopeio_md of testbench is
	for ulx3s_scopeio
		for all : ulx3s
			use entity work.ulx3s(scopeio);
		end for;
			for all : mt48lc32m16a2
			use entity micron.mt48lc32m16a2
			port map (
				clk   => sdram_clk,
				cke   => sdram_cke,
				cs_n  => sdram_cs_n,
				ras_n => sdram_ras_n,
				cas_n => sdram_cas_n,
				we_n  => sdram_we_n,
				ba    => sdram_ba,
				addr  => sdram_addr,
				dqm   => sdram_dqm,
				dq    => sdram_dq);
		end for;
	end for;
end;
