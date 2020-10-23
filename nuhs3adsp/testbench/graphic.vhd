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

architecture nuhs3adsp_graphics of testbench is
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
	signal mii_refclk : std_logic;
	signal mii_treq : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 4-1);
	signal mii_txc  : std_logic;
	signal eth_txen : std_logic;
	signal eth_txd  : std_logic_vector(0 to 4-1);
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;
	signal txfrm_ptr     : std_logic_vector(0 to 17);

	signal ddr_lp_dqs : std_logic;

	component nuhs3adsp is
		generic (
			debug : boolean := true);
		port (
			xtal : in std_logic;
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
			mii_txen : out std_logic := 'Z';
			mii_txd  : out std_logic_vector(4-1 downto 0) := (others => 'Z');

			mii_rxc  : in std_logic := 'Z';
			mii_rxdv : in std_logic := 'Z';
			mii_rxer : in std_logic := 'Z';
			mii_rxd  : in std_logic_vector(4-1 downto 0) := (others => 'Z');

			mii_crs  : in std_logic := 'Z';
			mii_col  : in std_logic := 'Z';

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

	constant baudrate : natural := 1000000;
	constant uart_data  : std_logic_vector := 
		x"000000" & 
		x"1602_5c00_0180" &
		x"0000" & 
		x"18ff" & 
		x"123456789abcdef123456789abcdef12" &
		x"23456789abcdef123456789abcdef123" &
		x"3456789abcdef123456789abcdef1234" &
		x"456789abcdef123456789abcdef12345" &
		x"56789abcdef123456789abcdef123456" &
		x"6789abcdef123456789abcdef1234567" &
		x"789abcdef123456789abcdef12345678" &
		x"89abcdef123456789abcdef123456789" &
		x"9abcdef123456789abcdef123456789a" &
		x"abcdef123456789abcdef123456789ab" &
		x"bcdef123456789abcdef123456789abc" &
		x"cdef123456789abcdef123456789abcd" &
		x"def123456789abcdef123456789abcde" &
		x"ef123456789abcdef123456789abcdef" &
		x"f123456789abcdef123456789abcdef1" &
		x"123456789abcdef123456789abcdef12" &
		x"0000" &
		x"1702_5c00_5c00_7f" &
		x"0000" &
		x"18ff"& 
		x"1234ffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffaabb" &
		x"ccddffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffffffff" &
		x"ffffffffffffffffffffffffffff6789" &
		x"0000" &
		x"1602_5c00_5c00_5c00" & 
		x"0000" & 
		x"1702_5c00_5c00_7f" &
		x"0000";

	signal uart_clk : std_logic := '0';
	signal uart_sin : std_logic;
	constant pp_pl : std_logic_vector := 
		  x"18ff"
		& x"123456789abcdef123456789abcdef1223456789abcdef123456789abcdef123"
		& x"3456789abcdef123456789abcdef1234456789abcdef123456789abcdef12345"
		& x"56789abcdef123456789abcdef1234566789abcdef123456789abcdef1234567"
		& x"789abcdef123456789abcdef1234567889abcdef123456789abcdef123456789"
		& x"9abcdef123456789abcdef123456789aabcdef123456789abcdef123456789ab"
		& x"bcdef123456789abcdef123456789abccdef123456789abcdef123456789abcd"
		& x"def123456789abcdef123456789abcdeef123456789abcdef123456789abcdef"
		& x"f123456789abcdef123456789abcdef1123456789abcdef123456789abcdef12"
		& x"18ff"
		& x"123456789abcdef123456789abcdef1223456789abcdef123456789abcdef123"
		& x"3456789abcdef123456789abcdef1234456789abcdef123456789abcdef12345"
		& x"56789abcdef123456789abcdef1234566789abcdef123456789abcdef1234567"
		& x"789abcdef123456789abcdef1234567889abcdef123456789abcdef123456789"
		& x"9abcdef123456789abcdef123456789aabcdef123456789abcdef123456789ab"
		& x"bcdef123456789abcdef123456789abccdef123456789abcdef123456789abcd"
		& x"def123456789abcdef123456789abcdeef123456789abcdef123456789abcdef"
		& x"f123456789abcdef123456789abcdef1123456789abcdef123456789abcdef12"
		& x"1602000060"
		& x"170200001f";

	constant pp1_pl : std_logic_vector := 
		  x"18ff"
		& x"eeee77779abcdef123456789abcdef1223456789abcdef123456789abcdef123"
		& x"3456789abcdef123456789abcdef1234456789abcdef123456789abcdef12345"
		& x"56789abcdef123456789abcdef1234566789abcdef123456789abcdef1234567"
		& x"789abcdef123456789abcdef1234567889abcdef123456789abcdef123456789"
		& x"9abcdef123456789abcdef123456789aabcdef123456789abcdef123456789ab"
		& x"bcdef123456789abcdef123456789abccdef123456789abcdef123456789abcd"
		& x"def123456789abcdef123456789abcdeef123456789abcdef123456789abcdef"
		& x"f123456789abcdef123456789abcdef1123456789abcdef123456789abcdef12"
		& x"18ff"
		& x"eeee77779abcdef123456789abcdef1223456789abcdef123456789abcdef123"
		& x"3456789abcdef123456789abcdef1234456789abcdef123456789abcdef12345"
		& x"56789abcdef123456789abcdef1234566789abcdef123456789abcdef1234567"
		& x"789abcdef123456789abcdef1234567889abcdef123456789abcdef123456789"
		& x"9abcdef123456789abcdef123456789aabcdef123456789abcdef123456789ab"
		& x"bcdef123456789abcdef123456789abccdef123456789abcdef123456789abcd"
		& x"def123456789abcdef123456789abcdeef123456789abcdef123456789abcdef"
		& x"f123456789abcdef123456789abcdef1123456789abcdef123456789abcdef12"
		& x"16020000a0"
		& x"170200001f";

	constant pp : std_logic_vector := 
			x"4500"                 &    -- IP Version, TOS
			x"0000"                 &    -- IP Length
			x"0000"                 &    -- IP Identification
			x"0000"                 &    -- IP Fragmentation
			x"0511"                 &    -- IP TTL, protocol
			x"0000"                 &    -- IP Header Checksum
			x"00000000"             &    -- IP Source IP address
			x"c0a8000e"             &    -- IP Destiantion IP Address

			udp_checksummed (
				x"00000000",
				x"ffffffff",
				x"0044dea9"         & -- UDP Source port, Destination port
				std_logic_vector(to_unsigned(pp_pl'length/8+8,16))    & -- UDP Length,
				x"0000" &              -- UPD checksum
				pp_pl);

	constant pp1 : std_logic_vector := 
			x"4500"                 &    -- IP Version, TOS
			x"0000"                 &    -- IP Length
			x"0000"                 &    -- IP Identification
			x"0000"                 &    -- IP Fragmentation
			x"0511"                 &    -- IP TTL, protocol
			x"0000"                 &    -- IP Header Checksum
			x"00000000"             &    -- IP Source IP address
			x"c0a8000e"             &    -- IP Destiantion IP Address

			udp_checksummed (
				x"00000000",
				x"ffffffff",
				x"0044dea9"         & -- UDP Source port, Destination port
				std_logic_vector(to_unsigned(pp1_pl'length/8+8,16))    & -- UDP Length,
				x"0000" &              -- UPD checksum
				pp1_pl);

	constant delay : time := 1 ns;
	signal n : std_logic := '0';
		function xxx (
			constant n : natural;
			constant size : natural)
			return std_logic_vector is
			variable retval : unsigned(0 to n-1);
		begin
			for i in 0 to n/size-1 loop
				retval (i*size to (i+1)*size-1) := to_unsigned(2*(i/2)+(i+1) mod 2, size);
			end loop;
			return std_logic_vector(retval);
		end;
begin

	mii_rxc <= mii_refclk;
	mii_txc <= mii_refclk;

	clk <= not clk after 25 ns;


	uart_clk <= not uart_clk after (1 sec / baudrate / 2);
	process (rst, uart_clk)
		variable data : unsigned((uart_data'length/8)*10-1 downto 0);
	begin
		if rst='0' then
			for i in 0 to data'length/10-1 loop
				data(10-1 downto 0) := unsigned(uart_data(i*8 to (i+1)*8-1)) & b"01";
				data := data ror 10;
			end loop;
			data := not data;
			uart_sin <= '1';
		elsif rising_edge(uart_clk) then
			data := data srl 1;
--			data := data ror 1;
			uart_sin <= not data(0);
		end if;
	end process;

	rst <= '0', '1' after 300 ns;
	mii_treq <= '0', '1' after 210 us + 1 us, '0' after  210 us + 50 us, '0' after 210 us +60 us;
--	mii_treq <= '0', '1' after  1 us, '0' after   30 us, '1' after 40 us;


	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if mii_treq='0' then
				txfrm_ptr <= (others => '0');
			elsif unsigned(txfrm_ptr(1 to txfrm_ptr'right))< pp'length/mii_rxd'length then
				txfrm_ptr <= std_logic_vector(unsigned(txfrm_ptr) + 1);
			end if;
		end if;
	end process;
	process (mii_treq)
	begin
		if rising_edge(mii_treq) then
			n <= not n;
		end if;
	end process;
	eth_txen <= mii_treq and setif(unsigned(txfrm_ptr(1 to txfrm_ptr'right))< pp'length/mii_rxd'length);
	eth_txd  <= word2byte(
		word2byte(reverse(pp,8),txfrm_ptr(1 to txfrm_ptr'right), eth_txd'length) &
		word2byte(reverse(pp1,8),txfrm_ptr(1 to txfrm_ptr'right), eth_txd'length),
		n);

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_rxc,
		eth_ptr  => txfrm_ptr,
		hwsa     => x"00_00_00_00_00_00",
		hwda     => x"00_40_00_01_02_03",
		llc      => x"0800",
		pl_txen  => eth_txen,
		pl_txd   => eth_txd,
		eth_txen => mii_rxdv,
		eth_txd  => mii_rxd);

	du_e : nuhs3adsp
	port map (
		xtal => clk,
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
		mii_txc => mii_txc,
		mii_rxc => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd => mii_rxd,
		mii_txen => mii_txen,
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
