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

architecture ulx3s_graphics of testbench is

	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst   : std_logic;
	signal xtal  : std_logic := '0';

	signal sdram_dq    : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal sdram_addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal sdram_ba    : std_logic_vector (1 downto 0);
	signal sdram_clk   : std_logic := '0';
	signal sdram_cke   : std_logic := '1';
	signal sdram_cs_n  : std_logic := '1';
	signal sdram_ras_n : std_logic;
	signal sdram_cas_n : std_logic;
	signal sdram_we_n  : std_logic;
	signal sdram_dqm   : std_logic_vector(1 downto 0);

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

	component mt48lc32m16a2 is
		port (
			clk   : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dqm   : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0));
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

	constant baudrate : natural := 3_000_000;
	constant data  : std_logic_vector := reverse (
		x"010001" &
		x"18ff" & 
		gen_natural(start => 0, stop => 127, size => 16) &
--		x"123456789abcdef123456789abcdef12" &
--		x"23456789abcdef123456789abcdef123" &
--		x"3456789abcdef123456789abcdef1234" &
--		x"456789abcdef123456789abcdef12345" &
--		x"56789abcdef123456789abcdef123456" &
--		x"6789abcdef123456789abcdef1234567" &
--		x"789abcdef123456789abcdef12345678" &
--		x"89abcdef123456789abcdef123456789" &
--		x"9abcdef123456789abcdef123456789a" &
--		x"abcdef123456789abcdef123456789ab" &
--		x"bcdef123456789abcdef123456789abc" &
--		x"cdef123456789abcdef123456789abcd" &
--		x"def123456789abcdef123456789abcde" &
--		x"ef123456789abcdef123456789abcdef" &
--		x"f123456789abcdef123456789abcdef1" &
--		x"123456789abcdef123456789abcdef12" &
--		x"18ff" & 
--		gen_natural(start => 128, stop => 255, size => 16) &
--		x"123456789abcdef123456789abcdef12" &
--		x"23456789abcdef123456789abcdef123" &
--		x"3456789abcdef123456789abcdef1234" &
--		x"456789abcdef123456789abcdef12345" &
--		x"56789abcdef123456789abcdef123456" &
--		x"6789abcdef123456789abcdef1234567" &
--		x"789abcdef123456789abcdef12345678" &
--		x"89abcdef123456789abcdef123456789" &
--		x"9abcdef123456789abcdef123456789a" &
--		x"abcdef123456789abcdef123456789ab" &
--		x"bcdef123456789abcdef123456789abc" &
--		x"cdef123456789abcdef123456789abcd" &
--		x"def123456789abcdef123456789abcde" &
--		x"ef123456789abcdef123456789abcdef" &
--		x"f123456789abcdef123456789abcdef1" &
--		x"123456789abcdef123456789abcdef12" &
		x"160300000000" &
		x"170200007f"  
--		x"1602000080" &
--		x"170200007f"

--		x"1801" & 
--		x"1234" &
--		x"160301234567" &
--		x"1702000000" --&
--		x"1602000000" &
--		x"1702000000"  &
--		x"1803" & 
--		x"5678" &
--		x"9abc" &
--		x"1602000000" &
--		x"1702000000"

		,8);

	signal hdlctx_frm  : std_logic;
	signal hdlctx_trdy : std_logic;
	signal hdlctx_data : std_logic_vector(0 to 8-1);

	signal uart_clk   : std_logic := '0';
	signal uart_sin   : std_logic;
	signal uart_idle  : std_logic;
	signal uart_txen  : std_logic;
	signal uart_txd   : std_logic_vector(0 to 8-1);

	constant uart_xtal : natural := 25 sec / 1 us;

	signal gp : std_logic_vector(28-1 downto 0);
	signal gn : std_logic_vector(28-1 downto 0);

	signal btn   : std_logic_vector(7-1 downto 0);

begin

	rst <= '1', '0' after 100 us; --, '1' after 30 us, '0' after 31 us;
	xtal <= not xtal after 20 ns;

--	uart_clk <= not uart_clk after (1 sec / baudrate / 2);
	uart_clk <= xtal;

	process (rst, uart_clk)
		variable addr : natural;
		variable n : natural;
	begin
		if rst='1' then
			hdlctx_frm <= '0';
			addr      := 0;
			n := 0;
		elsif rising_edge(uart_clk) then
			if addr < data'length then
				hdlctx_data <= data(addr to addr+8-1);
				if hdlctx_trdy='1' then
					addr := addr + 8;
				end if;
			else
				if n <0 then
				if uart_idle='1' then
					addr := 0;
					n := n + 1;
				end if;
				end if;
				hdlctx_data <= (others => '-');
			end if;
			if addr < data'length then
				hdlctx_frm  <= '1';
			else
				hdlctx_frm  <= '0';
			end if;
		end if;
	end process;

	hdlcdll_tx_e : entity hdl4fpga.hdlcdll_tx
	port map (
		uart_clk    => uart_clk,
		uart_idle   => uart_idle,
		uart_txen   => uart_txen,
		uart_txd    => uart_txd,

		hdlctx_frm  => hdlctx_frm,
		hdlctx_irdy => '1',
		hdlctx_trdy => hdlctx_trdy,
		hdlctx_data => hdlctx_data);

	uarttx_e : entity hdl4fpga.uart_tx
	generic map (
		baudrate => baudrate,
		clk_rate => uart_xtal)
	port map (
		uart_txc  => uart_clk,
		uart_sout => uart_sin,
		uart_idle => uart_idle,
		uart_txen => uart_txen,
		uart_txd  => uart_txd);

	
	ipoe_b : block
		signal mii_clk  : std_logic := '0';

		signal mii_req  : std_logic;

		signal mii_txc  : std_logic;
		signal mii_txen : std_logic;
		signal mii_txd  : std_logic_vector(0 to 2-1);
		signal eth_txen : std_logic;
		signal eth_txd  : std_logic_vector(mii_txd'range);

		signal mii_rxc  : std_logic;
		signal mii_rxdv : std_logic;
		signal mii_rxd  : std_logic_vector(0 to 2-1);

		signal arp_req  : std_logic := '0';

		signal txfrm_ptr : std_logic_vector(0 to 20);

		constant payload : std_logic_vector := 
			x"0100" & x"23"
			& x"160380000000"
			& x"1702000002"
			& x"1702000002"
			& x"160380000000"
			& x"1702000002"
			& x"1702000002"
			& x"1702000003"
			& x"1702000004"
			& x"170200000f";

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

	begin

		mii_clk <= not mii_clk after 10 ns;
		mii_rxc <= mii_clk;
		mii_txc <= mii_clk;

		gn(12) <= mii_clk;

		mii_req <= '0', '1' after 8 us;
		eth_e: entity hdl4fpga.mii_rom
		generic map (
			mem_data => reverse(packet,8))
		port map (
			mii_txc  => mii_rxc,
			mii_txen => mii_req,
			mii_txdv => eth_txen,
			mii_txd  => eth_txd);

		process (mii_rxc)
		begin

			if rising_edge(mii_rxc) then
				if eth_txen='0' and mii_rxdv='0' then
					txfrm_ptr <= (others => '0');
				else
					txfrm_ptr <= std_logic_vector(unsigned(txfrm_ptr) + 1);
				end if;
			end if;
		end process;

		ethtx_e : entity hdl4fpga.eth_tx
		port map (
			mii_txc  => mii_rxc,
			eth_ptr  => txfrm_ptr,
			hwsa     => x"af_ff_ff_ff_ff_f5",
			hwda     => x"00_40_00_01_02_03",
			llc      => x"0800",
			pl_txen  => eth_txen,
			eth_rxd  => eth_txd,
			eth_txen => mii_rxdv,
			eth_txd  => mii_rxd);

		gp(12) <= mii_rxdv;
		gn(11) <= mii_rxd(0);
		gp(11) <= mii_rxd(1);

		mii_txen   <= gn(10);
		mii_txd(0) <= gp(10);
		mii_txd(1) <= gn(9);

	end block;

	du_e : ulx3s
	port map (
		clk_25mhz  => xtal,
		ftdi_txd   => uart_sin,

		sdram_clk  => sdram_clk,
		sdram_cke  => sdram_cke,
		sdram_csn  => sdram_cs_n,
		sdram_rasn => sdram_ras_n,
		sdram_casn => sdram_cas_n,
		sdram_wen  => sdram_we_n,
		sdram_ba   => sdram_ba,
		sdram_a    => sdram_addr,
		sdram_dqm  => sdram_dqm,
		sdram_d    => sdram_dq);

	sdr_model_g: mt48lc32m16a2
	port map (
		clk   => sdram_clk,
		cke   => sdram_cke,
		cs_n  => sdram_cs_n,
		ras_n => sdram_ras_n,
		cas_n => sdram_cas_n,
		we_n  => sdram_we_n,
		ba    => sdram_ba,
		addr  => sdram_addr,
		dqm   => sdram_dqm,
		dq    => sdram_dq);
end;

library micron;

configuration ulx3s_graphic_structure_md of testbench is
	for ulx3s_graphics
		for all : ulx3s
			use entity work.ulx3s(structure);
		end for;
		for all: mt48lc32m16a2
			use entity micron.mt48lc32m16a2
			port map (
				clk   => sdram_clk,
				cke   => sdram_cke,
				cs_n  => sdram_cs_n,
				ras_n => sdram_ras_n,
				cas_n => sdram_cas_n,
				we_n  => sdram_we_n,
				ba    => sdram_ba,
				addr  => sdram_addr,
				dqm   => sdram_dqm,
				dq    => sdram_dq);
		end for;
	end for;
end;

library micron;

configuration ulx3s_graphic_md of testbench is
	for ulx3s_graphics
		for all : ulx3s
			use entity work.ulx3s(graphics);
		end for;
			for all : mt48lc32m16a2
			use entity micron.mt48lc32m16a2
			port map (
				clk   => sdram_clk,
				cke   => sdram_cke,
				cs_n  => sdram_cs_n,
				ras_n => sdram_ras_n,
				cas_n => sdram_cas_n,
				we_n  => sdram_we_n,
				ba    => sdram_ba,
				addr  => sdram_addr,
				dqm   => sdram_dqm,
				dq    => sdram_dq);
		end for;
	end for;
end;
