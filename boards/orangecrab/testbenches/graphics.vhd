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

architecture orangecrab_graphics of testbench is

	constant debug          : boolean := true;

	constant bank_bits      : natural := 3;
	constant addr_bits      : natural := 16;
	constant cols_bits      : natural := 9;
	constant data_bytes     : natural := 2;
	constant byte_bits      : natural := 8;
	constant data_bits      : natural := byte_bits*data_bytes;

	component orangecrab is
    	generic (
    		debug           : boolean := false);
    	port (
    		clk_48MHz       : in  std_logic := 'Z';
    		rst_n           : in  std_logic := 'Z';
    		usr_btn         : in  std_logic := 'Z';
            rgb_led         : out std_logic_vector(3-1 downto 0);
            gpio            : inout std_logic_vector(14-1 downto 0);
            gpio_a          : inout std_logic_vector( 6-1 downto 0);

    		usb_d_p         : inout std_logic := 'Z';
    		usb_d_n         : inout std_logic := 'Z';
    		usb_pullup      : inout std_logic := 'Z';

    		ddram_clk       : out std_logic;
    		ddram_reset_n   : out std_logic;
    		ddram_cke       : out std_logic;
    		ddram_cs_n      : out std_logic;
    		ddram_ras_n     : out std_logic;
    		ddram_cas_n     : out std_logic;
    		ddram_we_n      : out std_logic;
    		ddram_odt       : out std_logic;
    		ddram_a         : out std_logic_vector(16-1 downto 0);
    		ddram_ba        : out std_logic_vector( 3-1 downto 0);
    		ddram_dm        : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
    		ddram_dq        : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
    		ddram_dqs       : inout std_logic_vector( 2-1 downto 0) := (others => 'Z'));
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
		x"1702_00001f_1603_0000_0000";
	constant req_data : std_logic_vector := x"010000_1702_00001f_1603_8000_0000";

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

	signal uart_clk   : std_logic := '0';

	signal rst        : std_logic;
	signal clk_48MHz  : std_logic := '0';
	signal gpio       : std_logic_vector(14-1 downto 0);

begin

	rst        <= '1', '0' after 40 us when debug else '1', '0' after 100 us;
	clk_48MHz  <= not clk_48MHz after (1 sec/ 48e6)/2;
	uart_clk   <= not uart_clk after 0.1 ns /2 when debug else not uart_clk after 1 sec/48.0e6/2.0;

	hdlctb_e : entity work.hdlc_tb
	generic map (
		debug     => debug,
		baudrate  =>    3e6,
		uart_freq => 48.0e6,
		payload_segments => (0 => snd_data'length, 1 => req_data'length),
		payload   => snd_data & req_data)
	port map (
		rst       => rst,
		uart_clk  => uart_clk,
		uart_sin  => gpio(1),
		uart_sout => gpio(0));

	du_e : orangecrab
	generic map (
		debug => debug)
		-- debug => true)
	port map (
		clk_48MHz    => clk_48MHz,
		ddram_reset_n => rst_n,
		gpio         => gpio,
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

configuration orangecrab_graphics_structure_md of testbench is
	for orangecrab_graphics
		for all : orangecrab
			use entity work.orangecrab(structure);
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

configuration orangecrab_graphics_md of testbench is
	for orangecrab_graphics
		for all : orangecrab
			use entity work.orangecrab(graphics);
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