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

architecture ulx3s_siodebug of testbench is

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

	signal rst   : std_logic;
	signal xtal  : std_logic := '0';

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
	constant data  : std_logic_vector := reverse( -- x"0002_000004";
--		x"0002000080" &
--		x"18ff" & 
--		gen_natural(start => 0, stop => 127, size => 16) &
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
--		x"1602000080" &
--		x"170200007f" &
--		x"1602000080" &
--		x"170200007f"
		x"010000" &
		x"1801" & 
		x"1234" &
		x"1602000000" &
		x"17020000ff" --&
--		x"1602000000" &
--		x"1702000000"  &
--		x"1803" & 
--		x"5678" &
--		x"9abc" &
--		x"1602000000" &
--		x"1702000000"
		, 8);

	constant uart_xtal : natural := 25 sec / 1 us;

	signal uart_clk   : std_logic := '0';
	signal uart_sin   : std_logic;
	signal uart_trdy  : std_logic;
	signal uart_irdy  : std_logic;
	signal uart_txd   : std_logic_vector(0 to 8-1);

	signal ahdlc_frm  : std_logic;
	signal ahdlc_irdy : std_logic;
	signal ahdlc_trdy : std_logic;
	signal ahdlc_data : std_logic_vector(0 to 8-1);


	for all: ulx3s use entity work.ulx3s(sio_debug);
begin

	rst <= '1', '0' after 1 us; --, '1' after 30 us, '0' after 31 us;
	xtal <= not xtal after 20 ns;

--	uart_clk <= not uart_clk after (1 sec / baudrate / 2);
	uart_clk <= xtal;

	process (rst, uart_clk)
		variable addr : natural;
		variable n : natural;
	begin
		if rst='1' then
			ahdlc_frm <= '0';
			addr      := 0;
			n := 0;
		elsif rising_edge(uart_clk) then
			if addr < data'length then
				ahdlc_data <= data(addr to addr+8-1);
				if ahdlc_trdy='1' then
					addr := addr + 8;
				end if;
			else
				if n <0 then
				if uart_trdy='1' then
					addr := 0;
					n := n + 1;
				end if;
				end if;
				ahdlc_data <= (others => '-');
			end if;
			if addr < data'length then
				ahdlc_frm  <= '1';
			else
				ahdlc_frm  <= '0';
			end if;
		end if;
	end process;

	ahdlcfcs_e : block

		signal fcs_frm  : std_logic;
		signal fcs_data : std_logic_vector(ahdlc_data'range);
		signal fcs_trdy : std_logic;
		signal fcs      : std_logic;

		signal crc_init : std_logic;
		signal crc_ena  : std_logic;
		signal crc      : std_logic_vector(0 to 16-1);
		signal cy       : std_logic;

	begin

		fcs_p : process (ahdlc_frm, cy, uart_clk)
			variable q : std_logic;
		begin
			if rising_edge(uart_clk) then
				if uart_trdy='1' then
					if ahdlc_frm='1' then
						if cy='1' then
							q := '0';
						end if;
					else
						q := '1';
					end if;
				end if;
			end if;
			crc_init <= cy and q;
			fcs <= setif(ahdlc_frm='1', q and not cy, not cy);
		end process;

		cntr_p : process (uart_clk)
			variable cntr : unsigned(0 to unsigned_num_bits(crc'length/fcs_data'length-1));
		begin
			if rising_edge(uart_clk) then
				if fcs_trdy='1' then
					if fcs='0' then
						if ahdlc_frm='1' then
							cntr := to_unsigned(crc'length/ahdlc_data'length-1, cntr'length);
						end if;
					elsif cy='0' then
						cntr := cntr - 1;
					end if;
				end if;
				cy <= setif(cntr(0)/='0');
			end if;
		end process;

		crc_ena <= (ahdlc_irdy and ahdlc_trdy and ahdlc_frm) or (fcs_trdy and fcs);
		crc_ccitt_e : entity hdl4fpga.crc
		port map (
			g    => x"1021",
			clk  => uart_clk,
			init => crc_init,
			ena  => crc_ena,
			sero => fcs,
			data => ahdlc_data,
			crc  => crc);

		fcs_frm  <= (ahdlc_frm or fcs) and not crc_init;
		fcs_data <= wirebus(ahdlc_data & crc(0 to fcs_data'length-1), not fcs & fcs);

		ahdlc_irdy <= '1';
		ahdlc_trdy <= ahdlc_frm and not (fcs or crc_init)and fcs_trdy;
		ahdlctx_e : entity hdl4fpga.ahdlc_tx
		port map (
			clk        => uart_clk,
			uart_irdy  => uart_irdy,
			uart_trdy  => uart_trdy,
			uart_txd   => uart_txd,

			ahdlc_frm  => fcs_frm,
			ahdlc_irdy => ahdlc_irdy,
			ahdlc_trdy => fcs_trdy,
			ahdlc_data => fcs_data);

	end block;

	uarttx_e : entity hdl4fpga.uart_tx
	generic map (
		baudrate => baudrate,
		clk_rate => uart_xtal)
	port map (
		uart_txc  => uart_clk,
		uart_sout => uart_sin,
		uart_idle => uart_trdy,
		uart_txen => uart_irdy,
		uart_txd  => uart_txd);

	du_e : ulx3s
	port map (
		clk_25mhz => xtal,
		ftdi_txd  => uart_sin);

end;
