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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ipoepkg.all;

architecture ulx3s_miiipoedebug of testbench is

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

	signal rst      : std_logic := '1';
	signal clk      : std_logic := '1';

	signal xtal     : std_logic := '0';

	signal gp       : std_logic_vector(28-1 downto 0);
	signal gn       : std_logic_vector(28-1 downto 0);
	alias mii_clk   : std_logic is gn(12);

	signal fire1    : std_logic;
	signal fire2    : std_logic;

	signal mii_req  : std_logic := '0';


	signal pl_frm : std_logic;
begin

	rst     <= '0', '1' after 300 ns;
	clk     <= not clk after 25 ns;
	mii_clk <= not to_stdulogic(to_bit(mii_clk)) after 10 ns;

	pl_frm <= '0', '1' after 1 us;
	ipoe_b : block
		generic (
			baudrate  : natural := 3_000_000;
			uart_xtal : natural := 25 sec / 1 us;
			payload   : std_logic_vector);
		generic map (
			payload   => x"0100ff");

		port (
			rst       : in  std_logic;
			pl_frm    : in  std_logic;
			mii_clk   : in  std_logic;
			mii_rxdv  : in  std_logic;
			mii_rxd   : in  std_logic_vector(0 to 2-1);

			mii_txen  : buffer std_logic;
			mii_txd   : buffer std_logic_vector(0 to 2-1));
		port map (
			rst        => rst,
			pl_frm     => pl_frm,
			mii_clk    => mii_clk,
			mii_txen   => gp(12),
			mii_txd(0) => gn(11),
			mii_txd(1) => gp(11),

			mii_rxdv   => gn(10),
			mii_rxd(0) => gp(10),
			mii_rxd(1) => gn(9));

		constant myip : std_logic_vector := aton("192.168.1.1");

		constant arppkt : std_logic_vector :=
			x"0000"                 & -- arp_htype
			x"0000"                 & -- arp_ptype
			x"00"                   & -- arp_hlen
			x"00"                   & -- arp_plen
			x"0000"                 & -- arp_oper
			x"00_00_00_00_00_00"    & -- arp_sha
			x"00_00_00_00"          & -- arp_spa
			x"00_00_00_00_00_00"    & -- arp_tha
			myip;                     -- arp_tpa

		constant packet : std_logic_vector :=
			x"4500"                 &    -- IP Version, TOS
			x"0000"                 &    -- IP Length
			x"0000"                 &    -- IP Identification
			x"0000"                 &    -- IP Fragmentation
			x"0511"                 &    -- IP TTL, protocol
			x"0000"                 &    -- IP Header Checksum
			x"ffffffff"             &    -- IP Source IP address
			myip                    &    -- IP Destiantion IP Address

			udp_checksummed (
				x"ffffffff",
				myip,
				x"4444dea9"         & -- UDP Source port, Destination port
				std_logic_vector(to_unsigned(payload'length/8+8,16))    & -- UDP Length,
				x"0000" &              -- UPD checksum
				payload);

		signal eth_txen  : std_logic;
		signal eth_txd   : std_logic_vector(mii_txd'range);

		signal pl_trdy    : std_logic;
		signal pl_end     : std_logic;
		signal pl_data    : std_logic_vector(mii_txd'range);

		signal miirx_frm  : std_logic;
		signal miirx_end  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(pl_data'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(pl_data'range);

		signal llc_data   : std_logic_vector(0 to 2*48+16-1);
		signal hwllc_irdy : std_logic;
		signal hwllc_trdy : std_logic;
		signal hwllc_end  : std_logic;
		signal hwllc_data : std_logic_vector(pl_data'range);

		signal datatx_null :  std_logic_vector(mii_txd'range);
		signal datarx_null :  std_logic_vector(mii_rxd'range);

	begin

		eth4_e: entity hdl4fpga.sio_mux
		port map (
			mux_data => reverse(arppkt,8),
			sio_clk  => mii_clk,
			sio_frm  => pl_frm,
			sio_irdy => pl_trdy,
			so_end   => pl_end,
			so_data  => pl_data);

		llc_data <= reverse(x"00_40_00_01_02_03" & x"00_27_0e_0f_f5_95" & x"0806",8);
		hwsa_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => llc_data,
			sio_clk  => mii_clk,
			sio_frm  => pl_frm,
			sio_irdy => hwllc_irdy,
			sio_trdy => hwllc_trdy,
			so_end   => hwllc_end,
			so_data  => hwllc_data);

		ethtx_e : entity hdl4fpga.eth_tx
		port map (
			mii_clk  => mii_clk,

			pl_frm   => pl_frm,
			pl_trdy  => pl_trdy,
			pl_end   => pl_end,
			pl_data  => pl_data,

			hwllc_irdy => hwllc_irdy,
			hwllc_trdy => open,
			hwllc_end  => hwllc_end,
			hwllc_data => hwllc_data,

			mii_frm  => miirx_frm,
			mii_irdy => miirx_irdy,
			mii_trdy => '1', --miirx_trdy,
			mii_end  => miirx_end,
			mii_data => miirx_data);

		mii_txen <= miirx_frm and not miirx_end;
		mii_txd  <= miirx_data;

		ethphy_e : entity hdl4fpga.eth_rx
		port map (
			dll_data   => datarx_null,
			mii_clk    => mii_clk,
			mii_frm    => mii_rxdv,
			mii_irdy   => mii_rxdv,
			mii_data   => mii_rxd);

		ethrx_e : entity hdl4fpga.eth_rx
		port map (
			mii_clk    => mii_clk,
			mii_frm    => mii_txen,
			mii_irdy   => mii_txen,
			mii_data   => mii_txd,
			dll_data   => datatx_null);

	end block;

	fire1 <= '0';
	fire2 <= '0';
	du_e : ulx3s
	generic map (
		debug => true)
	port map (
		clk_25mhz  => xtal,
		fire1      => fire1,
		fire2      => fire2,
		up         => '0',
		down       => '0',
		left       => '0',
		right      => '0',
		btn_pwr_n  => '1',
		gp         => gp,
		gn         => gn);

end;

configuration ulx3s_miiipoedebug_structure_md of testbench is
	for ulx3s_miiipoedebug
		for all : ulx3s
			use entity work.ulx3s(structure);
		end for;
	end for;
end;

configuration ulx3s_miiipoedebug_md of testbench is
	for ulx3s_miiipoedebug
		for all : ulx3s
			use entity work.ulx3s(miiipoe_debug);
		end for;
	end for;
end;
