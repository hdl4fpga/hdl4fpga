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

architecture ulx3s_miidebug of testbench is

	component ulx3s is
		port (
			clk_25mhz      : in    std_logic;

			ftdi_rxd       : out   std_logic;
			ftdi_txd       : in    std_logic := '-';
			ftdi_nrts      : inout std_logic := '-';
			ftdi_ndtr      : inout std_logic := '-';
			ftdi_txden     : inout std_logic := '-';

			led            : out   std_logic_vector(8-1 downto 0);
			btn            : in    std_logic_vector(7-1 downto 0) := (others => '-');
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

			gpdi_dp        : out   std_logic_vector(4-1 downto 0);
			gpdi_dn        : out   std_logic_vector(4-1 downto 0);
			--gpdi_ethp      : out   std_logic;  
			--gpdi_ethn      : out   std_logic;
			gpdi_cec       : inout std_logic := '-';
			gpdi_sda       : inout std_logic := '-';
			gpdi_scl       : inout std_logic := '-';

			gp             : inout std_logic_vector(28-1 downto 0) := (others => '-');
			gn             : inout std_logic_vector(28-1 downto 0) := (others => '-');
			gp_i           : in    std_logic_vector(12 downto 9) := (others => '-');

			user_programn  : out   std_logic := '1'; -- '0' loads next bitstream from SPI FLASH (e.g. bootloader)
			shutdown       : out   std_logic := '0'); -- '1' power off the board, 10uA sleep
	end component;

	constant udppkt : std_logic_vector :=
			x"5555_5555_5555_55d5"  &
			x"00_40_00_01_02_03"    &
			x"00_00_00_00_00_00"    &
			x"0800"                 &
			x"4500"                 &    -- IP Version, TOS
			x"0000"                 &    -- IP Length
			x"0000"                 &    -- IP Identification
			x"0000"                 &    -- IP Fragmentation
			x"0511"                 &    -- IP TTL, protocol
			x"00000000"             &    -- IP Source IP address
			x"00000000"             &    -- IP Destiantion IP Address
			x"0000" &

			udp_checksummed (
				x"00000000",
				x"ffffffff",
				x"00430044"         &    -- UDP Source port, Destination port
				x"000f"             & -- UDP Length,
				x"0000"             & -- UPD checksum
				x"02010600" &
				x"3903F326" &
				x"00000000" &
				x"00000000" &
				x"C0A80164" &
				x"C0A80101" &
				x"00000000" &
				x"00400001" &
				x"02030000" &
				x"00000000" &
				x"00000000" &
				(1 to 192*8 => '0') &
				x"63825363" &
				x"53010200"

			)   &
			x"00000000";
		
	constant arppkt : std_logic_vector :=
		x"5555_5555_5555_55d5"  &
		x"ff_ff_ff_ff_ff_ff"    &
		x"00_00_00_00_00_00"    &
		x"0806"                 &
		x"0000"                 & -- arp_htype
		x"0000"                 & -- arp_ptype
        x"00"                   & -- arp_hlen 
        x"00"                   & -- arp_plen 
        x"0000"                 & -- arp_oper 
        x"00_00_00_00_00_00"    & -- arp_sha  
        x"00_00_00_00"          & -- arp_spa  
        x"00_00_00_00_00_00"    & -- arp_tha  
        x"c0_a8_00_0e"          & -- arp_tpa  
        x"00_00_00_00";           -- crc

	constant pingpkt : std_logic_vector :=
		x"5555_5555_5555_55d5"  &
		x"00_40_00_01_02_03"    &
		x"ff_ff_ff_ff_ff_ff"    &
		x"0800"                 &
		x"4500"                 &    -- IP Version, TOS
		x"0054"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0501"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP checksum
        x"c0_a8_00_0e"          &    -- IP destination address  
        x"00_00_00_00"          &    -- IP destination address  
        x"0800ba60"             & 
		x"24650006" &
		x"56fc6c5f00000000_94050b0000000000" &
		x"1011121314151617_18191a1b1c1d1e1f" &
		x"2021222324252627_28292a2b2c2d2e2f" &
		x"3031323334353637_3eeb441f";

	signal rst   : std_logic;
	signal xtal  : std_logic := '0';

	signal gp : std_logic_vector(28-1 downto 0);
	signal gn : std_logic_vector(28-1 downto 0);

	signal arp_req  : std_logic := '0';
	signal mii_clk  : std_logic := '0';
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to 2-1);

	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 2-1);
	signal btn   : std_logic_vector(7-1 downto 0);

begin

	rst <= '1', '0' after (1 us+82.5 us);
	xtal <= not xtal after 20 ns;
	mii_clk <= not mii_clk after 10 ns;
	btn(1)  <= '0', '1' after 1 us;
	arp_req <= '0', '0' after 8 us;

	gn(12) <= mii_clk;
	gp(12) <= mii_rxdv;
	gn(11) <= mii_rxd(0);
	gp(11) <= mii_rxd(1);

	mii_txen   <= gn(10);
	mii_txd(0) <= gp(10);
	mii_txd(1) <= gn(9);

	eth_e: entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(arppkt,8))
	port map (
		mii_txc  => mii_clk,
		mii_txen => arp_req,
		mii_txdv => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : ulx3s
	port map (
		clk_25mhz => xtal,
		btn => btn,
		gp => gp,
		gn => gn);

end;
