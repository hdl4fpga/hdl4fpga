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

library micron;

architecture ml509_miiipoe_debug of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 14;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 8;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal reset_n    : std_logic;
	signal rst        : std_logic;
	signal led7       : std_logic;


	signal clk_p : std_logic_vector(2-1 downto 0) := (others => '1');
	signal clk_n : std_logic_vector(2-1 downto 0) := (others => '1');
	signal cke   : std_logic_vector (2-1 downto 0) := (others => '1');
	signal cs_n  : std_logic_vector (2-1 downto 0) := (others => '1');
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal ba    : std_logic_vector (bank_bits-1 downto 0);
	signal addr  : std_logic_vector (addr_bits-1 downto 0);
	signal dm    : std_logic_vector(data_bytes-1 downto 0);
	signal dq    : std_logic_vector (data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector (data_bytes-1 downto 0) := (others => '1');
	signal dqs_n : std_logic_vector (data_bytes-1 downto 0) := (others => '1');
	signal rdqs_n : std_logic_vector(dqs'range);
	signal odt   : std_logic_vector(2-1 downto 0);

	signal scl   : std_logic;
	signal sda   : std_logic;

	signal mii_refclk : std_logic;
	signal mii_req    : std_logic;
	signal mii_rxdv   : std_logic;
	signal mii_rxd    : std_logic_vector(0 to 8-1);
	signal mii_txd    : std_logic_vector(0 to 8-1);
	signal mii_txc    : std_logic;
	signal mii_rxc    : std_logic;
	signal mii_txen   : std_logic;

	component ml509 is
		generic (
			debug : boolean := true);
		port (
			bus_error : out std_logic_vector(2 downto 1);
	
--			cfg_addr_out : in std_logic_vector(2-1 downto 0);
--			cpld_io_1 : in std_logic;
	
			clk_27mhz_fpga : in std_logic := '-';
			clk_33mhz_fpga : in std_logic := '-';
			clk_fpga_p     : in std_logic := '-';
			clk_fpga_n     : in std_logic := '-';
	
			ddr2_clk_p     : out std_logic_vector(2-1 downto 0);
			ddr2_clk_n     : out std_logic_vector(2-1 downto 0);
			ddr2_cs        : out std_logic_vector(2-1 downto 0);
			ddr2_cke       : out std_logic_vector( 2-1 downto 0);
			ddr2_ras       : out std_logic;
			ddr2_cas       : out std_logic;
			ddr2_we        : out std_logic;
			ddr2_a         : out std_logic_vector(14-1 downto 0);
			ddr2_ba        : out std_logic_vector( 3-1 downto 0);
			ddr2_dqs_p     : inout std_logic_vector(8-1 downto 0);
			ddr2_dqs_n     : inout std_logic_vector(8-1 downto 0);
			ddr2_dm        : inout std_logic_vector( 8-1 downto 0);
			ddr2_d         : inout std_logic_vector(64-1 downto 0);
			ddr2_odt       : out std_logic_vector( 2-1 downto 0);
--			ddr2_scl       : out std_logic;
--			ddr2_sda       : in  std_logic;
	
			dvi_xclk_n     : out std_logic;
			dvi_xclk_p     : out std_logic;
			dvi_reset_b    : out std_logic;
			dvi_gpio1      : inout std_logic;
			dvi_de         : out std_logic;
			dvi_d          : out std_logic_vector(12-1 downto 0);
			dvi_v          : inout std_logic;
			dvi_h          : inout std_logic;
	
--			fan_alert      : out std_logic;
	
			fpga_diff_clk_out_p : out std_logic;
			fpga_diff_clk_out_n : out std_logic;
--			fpga_rotary_inca : in std_logic;
--			fpga_rotary_incb : in std_logic;
--			fpga_rotary_push : in std_logic;
			fpga_serial_rx : in std_logic_vector(1 to 2) := (others => 'Z');
--			fpga_serial_tx : out std_logic_vector(1 to 2);
	
--			gpio_dip_sw    : in std_logic_vector(8 downto 1);
			gpio_led       : out std_logic_vector(8-1 downto 0);
			gpio_led_c     : out std_logic;
			gpio_led_e     : out std_logic;
			gpio_led_n     : out std_logic;
			gpio_led_s     : out std_logic;
			gpio_led_w     : out std_logic;
			gpio_sw_c      : in std_logic := '0';
			gpio_sw_e      : in std_logic := '0';
			gpio_sw_n      : in std_logic := '0';
			gpio_sw_s      : in std_logic := '0';
			gpio_sw_w      : in std_logic := '0';
	
--			hdr1           : std_logic_vector(1 to 32):= (others => '-');
--			hdr2_diff_p    : std_logic_vector(0 to 4-1) := (others => 'Z');
--			hdr2_diff_n    : std_logic_vector(0 to 4-1) := (others => 'Z');
--			hdr2_sm_p      : std_logic_vector(4 to 16-1) := (others => 'Z');
--			hdr2_sm_n      : std_logic_vector(4 to 16-1) := (others => 'Z');
	
--			lcd_fpga_db    : std_logic_vector(8-1 downto 4);
	
			phy_reset      : out std_logic;
			phy_col        : in std_logic := 'Z';
			phy_crs        : in std_logic := 'Z';
			phy_int        : in std_logic := 'Z';		-- open drain
			phy_mdc        : out std_logic;
			phy_mdio       : inout std_logic;
	
			phy_rxclk      : in std_logic;
			phy_rxctl_rxdv : in std_logic;
			phy_rxd        : in std_logic_vector(0 to 8-1);
			phy_rxer       : in std_logic := 'Z';
	
			phy_txc_gtxclk : out std_logic;
			phy_txclk      : in std_logic;
			phy_txctl_txen : out std_logic;
			phy_txd        : out std_logic_vector(0 to 8-1);
			phy_txer       : out std_logic;

--			sram_bw        : std_logic_vector(4-1 downto 0);
--			sram_d         : std_logic_vector(32-1 downto 16);
--			sram_dqp       : std_logic_vector(4-1 downto 0);
--			sram_flash_a   : std_logic_vector(22-1 downto 0);
--			sram_flash_d   : std_logic_vector(16-1 downto 0);
--
--			sysace_mpa     : std_logic_vector(7-1 downto 0);
--			sysace_usb_d   : std_logic_vector(16-1 downto 0);
--
--			trc_ts         : std_logic_vector(6 downto 3);
--
--			vga_in_blue    : std_logic_vector(8-1 downto 0);
--			vga_in_green   : std_logic_vector(8-1 downto 0);
--			vga_in_red     : std_logic_vector(8-1 downto 0)
			user_clk       : in std_logic);

	end component;

	component ddr2_model is
		port (
			ck    : in std_logic;
			ck_n  : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits-1 downto 0);
			dm_rdqs : in std_logic_vector(2-1 downto 0);
			dq    : inout std_logic_vector(16-1 downto 0);
			dqs   : inout std_logic_vector(2-1 downto 0);
			dqs_n : inout std_logic_vector(2-1 downto 0);
			rdqs_n : inout std_logic_vector(2-1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;

	signal xtal   : std_logic := '0';
	signal xtal_n : std_logic := '0';
	signal xtal_p : std_logic := '0';

	signal clk_fpga   : std_logic := '0';
	signal clk_fpga_n : std_logic := '0';
	signal clk_fpga_p : std_logic := '0';

	signal datarx_null :  std_logic_vector(mii_rxd'range);
	signal sw : std_logic;
begin

	rst   <= '1', '0' after 1.1 us;
	sw <= '0', '1' after 10 us, '0' after 15 us, '1' after 20 us;
	reset_n <= not rst;

	xtal   <= not xtal after 5 ns;
	xtal_p <= not xtal after 5 ns;
	xtal_n <=     xtal after 5 ns;

	clk_fpga <= not clk_fpga after 2.5 ns;
	clk_fpga_p <= clk_fpga;
	clk_fpga_n <= not clk_fpga;

	mii_rxc <= mii_refclk;
	mii_txc <= mii_refclk;

	process
		variable x : natural := 0;
	begin
		mii_req <= '0';
		wait for 10 us;
		loop
			if mii_req='1' then
				wait on mii_rxdv;
				if falling_edge(mii_rxdv) then
					mii_req <= '0';
					x := x + 1;
					wait for 30 us;
				end if;
			else
				if x > 1 then
					wait;
				end if;
				mii_req <= '1';
				wait on mii_req;
			end if;
		end loop;
	end process;

	htb_e : entity hdl4fpga.eth_tb
	generic map (
		debug =>false)
	port map (
		mii_data4 =>
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
		x"18ff" &
		x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
		x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
		x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
		x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
		x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
		x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
		x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
		x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
		x"18ff" &
		x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
		x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
		x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
		x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
		x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
		x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
		x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
		x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
		x"18ff" &
		x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
		x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
		x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
		x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
		x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
		x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
		x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
		x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
		x"1702_0003ff_1603_0007_3000",
		mii_data5 => x"010000_1702_0003ff_1603_8007_3000",
--		mii_data4 => x"01007e_1702_000030_1603_8000_07d0",
		mii_frm1 => mii_req,
		mii_frm2 => '0',
		mii_frm3 => '0',
		mii_frm4 => '0',
		mii_frm5 => '0',

		mii_txc  => mii_rxc,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : ml509
	generic map (
		debug => false)
	port map (
		clk_fpga_p     => clk_fpga_p,
		clk_fpga_n     => clk_fpga_n,
		ddr2_clk_p     => clk_p,
		ddr2_clk_n     => clk_n,
		ddr2_cke       => cke,
		ddr2_cs        => cs_n,
		ddr2_ras       => ras_n,
		ddr2_cas       => cas_n,
		ddr2_we        => we_n,
		ddr2_ba        => ba,
		ddr2_a         => addr,
		ddr2_dm        => dm,
		ddr2_d         => dq,
		ddr2_dqs_p     => dqs,
		ddr2_dqs_n     => dqs_n,
		ddr2_odt       => odt,

		gpio_sw_c      => sw,
		phy_rxclk      => mii_rxc,
		phy_rxctl_rxdv => mii_rxdv,
		phy_rxd        => mii_rxd,

		phy_txc_gtxclk => mii_refclk,
		phy_txclk      => mii_rxc,
		phy_txctl_txen => mii_txen,
		phy_txd        => mii_txd,

		user_clk       => xtal);

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data   => datarx_null,
		mii_clk    => mii_txc,
		mii_frm    => mii_txen,
		mii_irdy   => mii_txen,
		mii_data   => mii_txd);

end;

configuration ml509_miiipoedebug_structure_md of testbench is
	for ml509_miiipoe_debug
		for all: ml509
			use entity work.ml509(structure);
		end for;
	end for;
end;

configuration ml509_miiipoedebug_md of testbench is
	for ml509_miiipoe_debug
		for all: ml509
			use entity work.ml509(miiipoe_debug);
		end for;
	end for;
end;