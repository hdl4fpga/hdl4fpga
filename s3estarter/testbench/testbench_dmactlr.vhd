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

architecture dmactlr of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst   : std_logic;
	signal clk   : std_logic := '0';
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector (1 downto 0) := "00";
	signal addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal ba    : std_logic_vector (1 downto 0);
	signal clk_p : std_logic := '0';
	signal clk_n : std_logic := '0';
	signal cke   : std_logic := '1';
	signal cs_n  : std_logic := '1';
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(1 downto 0);

	signal x : std_logic;
	signal mii_refclk : std_logic;
	signal mii_treq : std_logic := '0';
	signal mii_trdy : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(4-1 downto 0);
	signal mii_rxc  : std_logic := '0';
	signal mii_txen : std_logic;
	signal mii_strt : std_logic;

	signal ddr3_rst : std_logic;
	signal ddr_lp_dqs : std_logic;

	component s3estarter is
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
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm_rdqs : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0);
			dqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			rdqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			odt   : in std_logic);
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
			ba    : in std_logic_vector(2 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm_tdqs : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0);
			dqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			tdqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;
begin

	clk <= not clk after 10 ns;
	process (clk)
		variable vrst : unsigned(1 to 16) := (others => '1');
	begin
		if rising_edge(clk) then
			vrst := vrst sll 1;
			rst <= vrst(1) after 5 ns;
		end if;
	end process;

	mii_strt <= '0', '1' after 8 us;

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

	eth_e: entity hdl4fpga.mii_rom
	generic map (
		mem_data => x"5555_5555_5555_55d5_00_00_00_01_02_03_00000000_000000ff")
	port map (
		mii_txc  => mii_rxc,
		mii_treq => mii_treq,
		mii_trdy => mii_trdy,
		mii_txdv => mii_rxdv,
		mii_txd  => mii_rxd);

	mii_rxc <= not mii_rxc after 10 ns;
	mii_refclk <= mii_rxc;
	s3estarter_e : s3estarter
	port map (
		xtal => clk,
		btn_west  => rst,

		spi_miso => '-',
		amp_dout => '-',
		e_tx_clk => mii_refclk,
		e_rx_clk => mii_rxc,
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
	for dmactlr 
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

configuration s3estarter_dmactlr_md of testbench is
	for dmactlr
		for all : s3estarter 
			use entity work.s3estarter(dmactlr);
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
