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
use hdl4fpga.ipoepkg.all;

architecture ulx4mld_graphics of testbench is

	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 15;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst         : std_logic;
	signal xtal        : std_logic := '0';

	component ulx4m_ld is
		generic (
			debug          : boolean := true);
		port (
			clk_25mhz      : in    std_logic;
			btn            : in    std_logic_vector(1 to 3) := (others => '-');
			led            : out   std_logic_vector(0 to 8-1) := (others => 'Z');

			sd_clk         : in    std_logic := '-';
			sd_cmd         : out   std_logic; 
			sd_d           : inout std_logic_vector(4-1 downto 0) := (others => '-');
			sd_wp          : in    std_logic := '-';
			sd_cdn         : in    std_logic := '-';

			usb_fpga_dp    : inout std_logic := '-';
			usb_fpga_dn    : inout std_logic := '-';
			usb_fpga_bd_dp : inout std_logic := '-';
			usb_fpga_bd_dn : inout std_logic := '-';
			usb_fpga_pu_dp : inout std_logic := '-';
			usb_fpga_pu_dn : inout std_logic := '-';

			eth_reset      : out   std_logic;
			rgmii_ref_clk    : out   std_logic;
			eth_mdio       : inout std_logic := '-';
			eth_mdc        : out   std_logic;
	
			rgmii_tx_clk   : in    std_logic := '-';
			rgmii_tx_en    : buffer std_logic;
			rgmii_txd      : buffer std_logic_vector(0 to 4-1);
			rgmii_rx_clk   : in    std_logic := '-';
			rgmii_rx_dv    : in    std_logic := '-';
			rgmii_rxd      : in    std_logic_vector(0 to 4-1) := (others => '-');

			ddram_clk      : inout std_logic;
			ddram_reset_n  : out   std_logic;
			ddram_cke      : out   std_logic;
			ddram_cs_n     : out   std_logic;
			ddram_ras_n    : out   std_logic;
			ddram_cas_n    : out   std_logic;
			ddram_we_n     : out   std_logic;
			ddram_odt      : out   std_logic;
			ddram_a        : out   std_logic_vector(15-1 downto 0);
			ddram_ba       : out   std_logic_vector( 3-1 downto 0);
			ddram_dm       : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
			ddram_dq       : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddram_dqs      : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');

			fpdi_clk       :  out std_logic; 
			fpdi_d0        :  out std_logic;
			fpdi_d1        :  out std_logic;
			fpdi_d2        :  out std_logic;

			user_programn  : out   std_logic := '1';
			shutdown       : out   std_logic := '0');
	end component;

	signal rst_n : std_logic;
	signal cke   : std_logic;
	signal ddr_clk : std_logic;
	signal ddr_clk_p : std_logic;
	signal ddr_clk_n : std_logic;
	signal cs_n  : std_logic;
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal ba    : std_logic_vector(bank_bits-1 downto 0);
	signal addr  : std_logic_vector(addr_bits-1 downto 0) := (others => '0');
	signal dq    : std_logic_vector(data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector(data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n : std_logic_vector(dqs'range) := (others => 'Z');
	signal dm    : std_logic_vector(data_bytes-1 downto 0);
	signal odt   : std_logic;
	signal scl   : std_logic;
	signal sda   : std_logic;
	signal tdqs_n : std_logic_vector(dqs'range);

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
			addr    : in std_logic_vector(13-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq      : inout std_logic_vector(16-1 downto 0);
			dqs     : inout std_logic_vector(2-1 downto 0);
			dqs_n   : inout std_logic_vector(2-1 downto 0);
			tdqs_n  : inout std_logic_vector(2-1 downto 0);
			odt     : in std_logic);
	end component;

	function gen_natural(
		constant start : natural := 0;
		constant stop  : natural;
		constant step  : natural := 1;
		constant size  : natural)
		return std_logic_vector is
		variable retval : std_logic_vector(start*size to size*(stop+1)-1);
	begin
		if start < stop then
			for i in start to stop loop
				retval(size*i to size*(i+1)-1) := std_logic_vector(to_unsigned(i, size));
			end loop;
		else
			for i in start downto stop loop
				retval(size*i to size*(i+1)-1) := std_logic_vector(to_unsigned(i, size));
			end loop;
		end if;
		return retval;
	end;

	signal mii_refclk : std_logic;
	signal mii_req    : std_logic := '0';
	signal mii_req1   : std_logic := '0';
	signal ping_req   : std_logic := '0';
	signal rep_req    : std_logic := '0';
	signal mii_rxdv   : std_logic;
	signal mii_rxd    : std_logic_vector(0 to 4-1);
	signal mii_txd    : std_logic_vector(0 to 4-1);
	signal mii_txc    : std_logic;
	signal mii_rxc    : std_logic;
	signal mii_txen   : std_logic;

	signal datarx_null :  std_logic_vector(mii_rxd'range);

begin

	rst  <= '1', '0' after 110 us; --, '1' after 30 us, '0' after 31 us;
	xtal <= not xtal after 20 ns;

	mii_rxc <= mii_refclk;
	mii_txc <= mii_refclk;

	mii_req  <= '0', '1' after 15 us, '0' after 20 us; --, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
--	mii_req1 <= '0', '1' after 14.5 us, '0' after 55 us, '1' after 55.02 us; --, '0' after 219 us, '1' after 220 us;
	process
	begin
		wait for 23 us;
		loop
			if rep_req='1' then
				wait;
				rep_req <= '0' after 5.8 us;
			else
				rep_req <= '1' after 250 ns;
			end if;
			wait on rep_req;
		end loop;
	end process;
	mii_req1 <= rep_req;

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
		x"1702_0003ff_1603_0007_3000",
		mii_data5 => x"010000_1702_00000f_1603_8007_3000",
		mii_frm1 => '0',
		mii_frm2 => '0', --ping_req,
		mii_frm3 => '0',
		mii_frm4 => mii_req,
		mii_frm5 => mii_req1,

		mii_txc  => mii_rxc,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : ulx4m_ld
	generic map (
		debug => true)
	port map (
		clk_25mhz    => xtal,
		btn(1)       => '0',
		btn(2 to 3)  => (others => '-'),

		eth_reset    => open,
		rgmii_ref_clk  => mii_refclk,
		eth_mdc      => open,
		rgmii_tx_clk => mii_rxc,
		rgmii_tx_en  => mii_txen,
		rgmii_txd    => mii_txd,
		rgmii_rx_clk => mii_rxc,
		rgmii_rx_dv  => mii_rxdv,
		rgmii_rxd    => mii_rxd,

		ddram_reset_n => rst_n,
		ddram_clk   => ddr_clk,
		ddram_cke   => cke,
		ddram_cs_n  => cs_n,
		ddram_ras_n => ras_n,
		ddram_cas_n => cas_n,
		ddram_we_n  => we_n,
		ddram_ba    => ba,
		ddram_a     => addr,
		ddram_dqs   => dqs,
		ddram_dq    => dq,
		ddram_dm    => dm,
		ddram_odt   => odt);

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data => datarx_null,
		mii_clk  => mii_txc,
		mii_frm  => mii_txen,
		mii_irdy => mii_txen,
		mii_data => mii_txd);

	ddr_clk_p <= ddr_clk;
	ddr_clk_n <= not ddr_clk;
	dqs_n <= not dqs;

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
		Dm_tdqs => dm,
		Dq    => dq,
		Dqs   => dqs,
		Dqs_n => dqs_n,
		tdqs_n => tdqs_n,
		Odt   => odt);

end;

library micron;

configuration ulx4mld_graphic_structure_md of testbench is
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

configuration ulx4mld_graphic_md of testbench is
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
