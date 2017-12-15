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

architecture scope of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 14;
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
	signal dqs_p : std_logic_vector (1 downto 0) := "00";
	signal dqs_n : std_logic_vector (1 downto 0) := "00";
	signal addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal ba    : std_logic_vector (bank_bits -1 downto 0);
	signal clk_p : std_logic := '0';
	signal clk_n : std_logic := '0';
	signal cke   : std_logic := '1';
	signal cs_n  : std_logic := '1';
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(1 downto 0);
	signal rst_n : std_logic;

	signal x : std_logic;
	signal mii_refclk : std_logic;
	signal mii_treq : std_logic := '0';
	signal mii_trdy : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : nibble;
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;
	signal mii_strt : std_logic;

	signal ddr3_rst : std_logic;
	signal ddr_lp_dqs : std_logic;

	component arty is
		port (
			btn : in std_logic_vector(4-1 downto 0) := (others => '-');
			sw  : in std_logic_vector(4-1 downto 0) := (others => '-');
			led : out std_logic_vector(8-1 downto 4);
			RGBled : out std_logic_vector(4*3-1 downto 0);
			ja  : inout std_logic_vector(1 to 10);
			vaux_p : in std_logic_vector(0 to 16-1);
			vaux_n : in std_logic_vector(0 to 16-1);
			v_p : in std_logic_vector(0 to 1-1); 
			v_n : in std_logic_vector(0 to 1-1); 
			
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

	signal reset_n : std_logic;
	signal xtal   : std_logic := '0';
	signal xtal_n : std_logic := '0';
	signal xtal_p : std_logic := '0';
	signal mii_freq : std_logic := '0';
begin

	rst   <= '1', '0' after 1.1 us;
	reset_n <= not rst;

	xtal   <= not xtal after 5 ns;
	xtal_p <= not xtal after 5 ns;
	xtal_n <=     xtal after 5 ns;

	mii_freq <= not mii_freq after 20 ns;
	mii_rxc <= mii_freq;

	clk <= not clk after 25 ns;
	process (clk)
		variable vrst : unsigned(1 to 16) := (others => '1');
	begin
		if rising_edge(clk) then
			vrst := vrst sll 1;
			rst <= not vrst(1) after 5 ns;
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

	eth_e: entity hdl4fpga.mii_mem
	generic map (
		mem_data => x"5555_5555_5555_55d5_00_00_00_01_02_03_00000000_000000ff")
	port map (
		mii_txc  => mii_rxc,
		mii_treq => mii_treq,
		mii_trdy => mii_trdy,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	mii_rxc <= mii_refclk after 5 ps;
	arty_e : arty
	port map (
		btn(0) => rst,
		btn(4-1 downto 1) => (1 to 3 => '-'),

		vaux_p => (others => '0'),
		vaux_n => (others => '0'),
		v_p => (others => '0'),
		v_n => (others => '0'),
		gclk100     => xtal,
		eth_rstn    => open,
		eth_ref_clk => open,
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
		ddr3_clk_p => clk_p,
		ddr3_clk_n => clk_n,
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
		ddr3_odt   => open);

end;
