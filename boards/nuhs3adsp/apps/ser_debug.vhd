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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.cgafonts.all;
use hdl4fpga.xc3s_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture ser_debug of nuhs3adsp is

	constant settings : string := "{"                                                         &
		"io_link: io_ipoe,"                                                                   &
		"video:{"                                                                             &
			"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'20mhz'.'40mhz'"))       & ',' &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'") & ',' &
			"pixel:"   & "{R:8,G:8,B:8}}}";

	signal sys_rst  : std_logic;
	alias sys_clk is clk;

	signal mii_clk  : std_logic;
	signal mii_req  : std_logic;

	signal so_frm   : std_logic;
	signal so_irdy  : std_logic := '1';
	signal so_trdy  : std_logic := '1';
	signal so_data  : std_logic_vector(0 to 8-1);
	signal si_frm   : std_logic;
	signal si_irdy  : std_logic := '1';
	signal si_trdy  : std_logic := '1';
	signal si_end   : std_logic;
	signal si_data  : std_logic_vector(0 to 8-1);
	signal dhcp_btn : std_logic;

	signal ser_clk  : std_logic;
	signal ser_frm  : std_logic;
	signal ser_irdy : std_logic;
	signal ser_data : std_logic_vector(0 to mii_rxd'length-1);
	signal dll_data : std_logic_vector(0 to mii_rxd'length-1);

	signal video_on     : std_logic;
	signal video_clk    : std_logic;
	signal video_hzsync : std_logic;
	signal video_vtsync : std_logic;
	signal video_blank  : std_logic;
	signal video_pixel  : std_logic_vector(hdo(settings)**".video.pixel.R=8"+hdo(settings)**".video.pixel.G=8"+hdo(settings)**".video.pixel.B=8"-1 downto 0);

	signal tp : std_logic_vector(1 to 32);

	signal hwda_frm   : std_logic;
	signal dhcpcd_req : std_logic := '0';
	signal dhcpcd_rdy : std_logic := '0';

	signal udppylrx_frm  : std_logic;
	signal udppylrx_irdy : std_logic;
	signal udppylrx_trdy : std_logic;
	signal udppylrx_data : std_logic_vector(0 to mii_rxd'length-1);

	signal udppyltx_frm  : std_logic := '0';
	signal udppyltx_irdy : std_logic := '0';
	signal udppyltx_trdy : std_logic := '0';
	signal udppyltx_data : std_logic_vector(0 to mii_rxd'length-1);

begin

	videodcm_i : entity hdl4fpga.xc3s_videodcm
	generic map(
		settings => hdo(settings)**".video.dcm")
	port map(
		rst       => sys_rst,
		clk       => sys_clk,
		video_clk => video_clk);

	miidcm_i : entity hdl4fpga.xc3s_dcm
	generic map (
		settings => compact("{"         &
			"freq_in        : 20.0e6,"  & 
			"clkfx_multiply : 5,"       & 
			"clkfx_divide   : 4}"))
	port map (
		clkin => sys_clk,
		clkfx => mii_clk);
	mii_refclk <= not mii_clk;

	dhcp_btn <= not sw1;
	dhcp_p : process(mii_txc)
		type states is (s_request, s_wait);
		variable state : states;
	begin
		if rising_edge(mii_txc) then
			case state is
			when s_request =>
				if dhcp_btn='1' then
					dhcpcd_req <= not dhcpcd_rdy;
					state := s_wait;
				end if;
			when s_wait =>
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					if dhcp_btn='0' then
						state := s_request;
					end if;
				end if;
			end case;
		end if;
	end process;

	pyl_b : block
		constant bitrom : std_logic_vector := std_logic_vector'(
		hdo(string'("{udp:0x"               &
			"0f_27_0e_0f_f5_95" & -- mac source address
			"00fa"              & -- packet length
			"c0a80002"          & -- IP Source IP address
			"0043"              &
			"0044"              &
			"aaaa"              &
			"ffff"              &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"dddddddd"          &
			"12345678}"))**".udp");
		signal addr : unsigned(0 to unsigned_num_bits(bitrom'length/mii_rxd'length-1)-1);

	begin
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if (udppyltx_frm or udppyltx_irdy)='1' then
					if addr < (bitrom'length/mii_rxd'length-2) then
						udppyltx_frm <= '1';
					else
						udppyltx_frm <= '0';
					end if;
					if (not udppyltx_frm and udppyltx_irdy and udppyltx_trdy)='1' then
						dhcpcd_rdy <= dhcpcd_req;
						udppyltx_irdy <= '0';
					else
						udppyltx_irdy <= '1';
					end if;
					if (udppyltx_irdy and udppyltx_trdy)='1' then
						addr <= addr + 1;
					end if;
				elsif (dhcpcd_rdy xor dhcpcd_req)='1' then
					udppyltx_frm  <= '1';
					udppyltx_irdy <= '1';
					if udppyltx_trdy='1' then
						addr <= addr + 1;
					end if;
				else
					udppyltx_frm <= '0';
					addr <= (others => '0');
				end if;
			end if;
		end process;

		rom_i: entity hdl4fpga.rom
		generic map (
			bitdata => reverse(bitrom,8))
		port map (
			addr => std_logic_vector(addr),
			data => udppyltx_data);

	end block;

	sioupd_i : entity hdl4fpga.sio_udp
	generic (
		hwaddr        : std_logic_vector(0 to 48-1);
		ipv4addr      : std_logic_vector(0 to 32-1));
	port (
		tp       => tp,
		dhcpcd_req => '0', --dhcpcd_req,
		-- dhcpcd_rdy => dhcpcd_rdy,

		miirx_clk  => mii_rxc,
		miirx_frm  => mii_rxdv,
		miirx_irdy => mii_rxdv,
		miirx_data => mii_rxd,

		miitx_clk  => mii_txc,
		miitx_frm  => mii_txen,
		miitx_data => mii_txd,

		so_clk     => mii_rxc,
		so_frm     => udppylrx_frm,
		so_irdy    => udppylrx_irdy,
		so_data    => udppylrx_data,

		si_clk     => mii_txc,
		si_frm     => udppylrx_frm,
		si_irdy    => udppylrx_irdy,
		si_data    => udppylrx_data);

	-- miiipoe_i : entity hdl4fpga.mii_ipoe
	-- port map (
	-- 	tp       => tp,
	-- 	dhcpcd_req => '0', --dhcpcd_req,
	-- 	-- dhcpcd_rdy => dhcpcd_rdy,
	-- 	miirx_clk  => mii_rxc,
	-- 	miirx_frm  => mii_rxdv,
	-- 	miirx_irdy => mii_rxdv,
	-- 	miirx_data => mii_rxd,
	--
	--
	-- 	miitx_clk  => mii_txc,
	-- 	miitx_frm  => mii_txen,
	-- 	miitx_data => mii_txd,
	--
	-- 	udppyltx_frm  => udppyltx_frm,
	-- 	udppyltx_irdy => udppyltx_irdy,
	-- 	udppyltx_trdy => udppyltx_trdy,
	-- 	udppyltx_data => udppyltx_data);

	-- ser_clk <= mii_rxc;
	-- process (ser_clk)
	-- begin
	-- 	if rising_edge(ser_clk) then
	-- 		ser_frm  <= udppylrx_frm;
	-- 		ser_irdy <= udppylrx_irdy;
	-- 		ser_data <= udppylrx_data;
	-- 	end if;
	-- end process;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		settings => hdo(settings)**".video")
	port map (
		ser_clk      => ser_clk, 
		ser_frm      => ser_frm, 
		ser_irdy     => ser_irdy, 
		ser_data     => ser_data, 
		
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel);

	psave <= '1';
	sync  <= 'Z';
	hsync <= video_hzsync;
	vsync <= video_vtsync;
	red   <= multiplex(video_pixel, 0, red'length);
	green <= multiplex(video_pixel, 1, green'length);
	blue  <= multiplex(video_pixel, 2, blue'length);
	sync  <= not video_hzsync and not video_vtsync;
	blankn  <= not video_blank;

	videodac_b : block
		signal clk_n : std_logic;
	begin
		clk_n <= not video_clk;
		clk_videodac_e : oddr2
		port map (
			c0 => video_clk,
			c1 => clk_n,
			d0 => '1',
			d1 => '0',
			q  => clk_videodac);
	end block;

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
--	led18 <= tp(9);
--	led16 <= tp(8);
--	led15 <= tp(7);
--	led13 <= tp(6);
--	led11 <= tp(5);
--	led9  <= tp(4);
--	led8  <= tp(3);
--	led7  <= tp(2);

	led18 <= 'Z';
	led16 <= 'Z';
	led15 <= 'Z';
	led13 <= 'Z';
	led11 <= 'Z';
	led9  <= 'Z';
	led8  <= 'Z';
	led7  <= 'Z';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= 'Z';
	rs232_td  <= 'Z';
	rs232_dtr <= 'Z';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= '1';
	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => ddr_ckp,
		ob => ddr_ckn);

	ddr_st_dqs <= 'Z';
	ddr_cke    <= 'Z';
	ddr_cs     <= 'Z';
	ddr_ras    <= 'Z';
	ddr_cas    <= 'Z';
	ddr_we     <= 'Z';
	ddr_ba     <= (others => 'Z');
	ddr_a      <= (others => 'Z');
	ddr_dm     <= (others => 'Z');
	ddr_dqs    <= (others => 'Z');
	ddr_dq     <= (others => 'Z');

	adc_clkab <= 'Z';
end;
