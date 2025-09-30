-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

architecture nuhs3adsp_serdebug of testbench is
	signal rst   : std_logic;
	signal clk   : std_logic := '0';
	signal led7  : std_logic;
	signal sw1  : std_logic;

	signal arp_req  : std_logic := '0';
	signal mii_refclk : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 4-1);
	signal mii_rxc  : std_logic;
	signal mii_txc  : std_logic;
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to 4-1);


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
			hd_t_clock : in std_logic := 'Z';

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

	constant data : string := "{"           &
		"mac:0x"                   &
		    "55555555555555d5"     &
			"00_40_00_01_02_03"    & -- mac source address
			"0f_27_0e_0f_f5_95,"   & -- mac source address
		"arp:0x"                   &
			"0806"                 & -- mac type
			"0000"                 & -- arp_htype
			"0000"                 & -- arp_ptype
			"00"                   & -- arp_hlen 
			"00"                   & -- arp_plen 
			"0000"                 & -- arp_oper 
			"00_00_00_00_00_00"    & -- arp_sha  
			"00_00_00_00"          & -- arp_spa  
			"00_00_00_00_00_00"    & -- arp_tha  
			"c0_a8_00_0e,"         & -- arp_tpa  
		"dhcp:0x"                  &
			"0800"                 & -- mac type
			"4500"                 & -- IP Version, TOS
			"0054"                 & -- IP Length
			"0000"                 & -- IP Identification
			"0000"                 & -- IP Fragmentation
			"0511"                 & -- IP TTL, protocol
			"0000"                 & -- IP Header Checksum
			"c0a80002"             & -- IP Source IP address
			"c0a80002"             & -- IP Destiantion IP Address
			"0043"                 &
			"0044"                 &
			"aaaa"                 &
			"ffff"                 &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
			"dddddddd"             &
		"icmp:0x"                  &
			"0800"                 & -- mac type
			"4500"                 & -- IP Version, TOS
			"0054"                 & -- IP Length
			"0000"                 & -- IP Identification
			"0000"                 & -- IP Fragmentation
			"0501"                 & -- IP TTL, protocol
			"0000"                 & -- IP Header Checksum
			"c0a80002"             & -- IP Source IP address
			"c0a8000e"             & -- IP Destiantion IP Address
			"12341f2b"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"ffffffff"             &
			"9999995a}";
begin

	mii_rxc <= mii_refclk after 5 ps;
	mii_txc <= mii_refclk after 5 ps;

	clk <= not clk after 25 ns;

	arp_req <= '0', '1' after 8 us;

	sw1 <= '1', '1' after 1 us;

	tb_b : block
		constant bitrom : std_logic_vector := std_logic_vector'(hdo(data)**".mac") & std_logic_vector'(hdo(data)**".dhcp");
		signal addr : unsigned(0 to unsigned_num_bits(bitrom'length/mii_rxd'length-1)-1);
	begin
		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if rst='1' then
					mii_rxdv <= '0';
					addr <= (others => '0');
				elsif addr < (bitrom'length/mii_rxd'length-1) then
					mii_rxdv <= '1';
					addr <= (addr + 1);
				else
					mii_rxdv <= '0';
				end if;
			end if;
		end process;
	
		eth_e: entity hdl4fpga.rom
		generic map (
			bitdata => reverse(bitrom,8))
		port map (
			addr => std_logic_vector(addr),
			data => mii_rxd);

	end block;

	rst <= '1', '0' after 1 us;

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

		rs232_rd => uart_sin,
		mii_refclk => mii_refclk,
		mii_rxc => mii_rxc,
		mii_txc => mii_txc,
		mii_rxdv => mii_rxdv,
		mii_rxd => mii_rxd,
		mii_txen => mii_txen,
		mii_txd => open);

end;
