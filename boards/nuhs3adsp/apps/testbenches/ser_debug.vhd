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

architecture nuhs3adsp_serdebug of testbench is
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
	signal sw1  : std_logic;

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
	signal arp_req  : std_logic := '0';
	signal mii_refclk : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 4-1);
	signal mii_rxc  : std_logic;
	signal mii_txc  : std_logic;
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to 4-1);

	signal ddr_lp_dqs : std_logic;

	signal uart_clk : std_logic := '0';
	signal uart_sin : std_logic;

	constant delay : time := 1 ns;

	component nuhs3adsp is
		generic (
			debug : boolean := true);
		port (
			clk : in std_logic;
			sw1 : in std_logic;

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
			mii_txen : buffer std_logic := 'Z';
			mii_txd  : buffer std_logic_vector(0 to 4-1) := (others => 'Z');

			mii_rxc  : in std_logic := 'Z';
			mii_rxdv : in std_logic := 'Z';
			mii_rxer : in std_logic := 'Z';
			mii_rxd  : in std_logic_vector(0 to 4-1) := (others => 'Z');

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

	constant arppkt : std_logic_vector :=
		x"0000"                 & -- arp_htype
		x"0000"                 & -- arp_ptype
		x"00"                   & -- arp_hlen 
		x"00"                   & -- arp_plen 
		x"0000"                 & -- arp_oper 
		x"00_00_00_00_00_00"    & -- arp_sha  
		x"00_00_00_00"          & -- arp_spa  
		x"00_00_00_00_00_00"    & -- arp_tha  
		x"c0_a8_00_0e";           -- arp_tpa  

	constant icmppkt : std_logic_vector :=
		x"4500"                 &    -- IP Version, TOS
		x"0000"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0501"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP Header Checksum
		x"ffffffff"             &    -- IP Source IP address
		x"c0a8000e"             &    -- IP Destiantion IP Address
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"aaaaaaaa",8) &
		reverse(x"ffffffff",8) ;


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

	constant payload : std_logic_vector := 
		x"0100" & x"23";
--		& x"18ff" & gen_natural(start => 0,     stop => 1*128-1, size => 16)
--		& x"18ff" & gen_natural(start => 1*128, stop => 2*128-1, size => 16)
--		& x"18ff" & gen_natural(start => 2*128, stop => 3*128-1, size => 16)
--		& x"18ff" & gen_natural(start => 3*128, stop => 4*128-1, size => 16)
--		& x"18ff" & gen_natural(start => 4*128, stop => 5*128-1, size => 16)
--		& x"1602800000"
--		& x"170200003f";

	constant packet : std_logic_vector := 
		x"4500"                 &    -- IP Version, TOS
		x"0000"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0511"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP Header Checksum
		x"ffffffff"             &    -- IP Source IP address
		x"c0a8000e"             &    -- IP Destiantion IP Address

		udp_checksummed (
			x"00000000",
			x"ffffffff",
			x"0044dea9"         & -- UDP Source port, Destination port
			std_logic_vector(to_unsigned(payload'length/8+8,16))    & -- UDP Length,
			x"0000" &              -- UPD checksum
			payload);

	signal eth_txen : std_logic;
	signal eth_txd  : std_logic_vector(0 to 4-1);
	signal txfrm_ptr     : std_logic_vector(0 to 20);

begin

	mii_rxc <= mii_refclk after 5 ps;
	mii_txc <= not mii_refclk after 5 ps;

	clk <= not clk after 25 ns;

	arp_req <= '0', '1' after 8 us;

	sw1 <= '1', '0' after 1 us;

--	eth_e: entity hdl4fpga.mii_rom
--	generic map (
--		mem_data => reverse(icmppkt,8))
--	port map (
--		mii_txc  => mii_rxc,
--		mii_txen => arp_req,
--		mii_txdv => eth_txen,
--		mii_txd  => eth_txd);
--
--	process (mii_rxc)
--	begin
--
--		if rising_edge(mii_rxc) then
--			if eth_txen='0' and mii_rxdv='0' then
--				txfrm_ptr <= (others => '0');
--			else
--				txfrm_ptr <= std_logic_vector(unsigned(txfrm_ptr) + 1);
--			end if;
--		end if;
--	end process;
--
--	ethtx_e : entity hdl4fpga.eth_tx
--	port map (
--		mii_txc  => mii_rxc,
--		eth_ptr  => txfrm_ptr,
--		hwsa     => x"ff_ff_ff_ff_ff_ff",
--		hwda     => x"00_40_00_01_02_03",
--		llc      => x"0800",
--		pl_txen  => eth_txen,
--		eth_rxd  => eth_txd,
--		eth_txen => mii_rxdv,
--		eth_txd  => mii_rxd);

--	mii_rxdv <= mii_txen;
--	mii_rxd  <= mii_txd;
	rst <= '0', '1' after 300 ns;
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

		adc_clkab  => x,
		adc_clkout => x,

		hd_t_clock => rst,

		rs232_rd => uart_sin,
		mii_refclk => mii_refclk,
		mii_rxc => mii_rxc,
		mii_txc => mii_txc,
		mii_rxdv => mii_rxdv,
		mii_rxd => mii_rxd,
		mii_txen => mii_txen,
		mii_txd => mii_txd,
		-------------
		-- DDR RAM --

		ddr_ckp => clk_p,
		ddr_ckn => clk_n,
		ddr_lp_ckp => clk_p,
		ddr_lp_ckn => clk_n,
		ddr_st_lp_dqs => ddr_lp_dqs,
		ddr_st_dqs => ddr_lp_dqs,
		ddr_cke => cke,
		ddr_cs  => cs_n,
		ddr_ras => ras_n,
		ddr_cas => cas_n,
		ddr_we  => we_n,
		ddr_ba  => ba,
		ddr_a   => addr,
		ddr_dm  => dm,
		ddr_dqs => dqs,
		ddr_dq  => dq);

end;
