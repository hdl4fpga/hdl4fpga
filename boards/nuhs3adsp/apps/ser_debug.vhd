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

library unisim;
use unisim.vcomponents.all;

architecture ser_debug of nuhs3adsp is

	constant settings : string := "{"                                                         &
		"io_link: io_ipoe,"                                                                   &
		"video:{"                                                                             &
			"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'20mhz'.'150mhz'"))       & ',' &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'1920x1080'.'@60'.'150mhz'") & ',' &
			"pixel:"   & "{R:8,G:8,B:8}}}";

	signal sys_rst       : std_logic;
	alias sys_clk is clk;

	signal video_on     : std_logic;
	signal video_clk    : std_logic;
	signal video_hzsync : std_logic;
	signal video_vtsync : std_logic;
	signal video_pixel  : std_logic_vector(hdo(settings)**".video.pixel.R=8"+hdo(settings)**".video.pixel.G=8"+hdo(settings)**".video.pixel.B=8"-1 downto 0);
	signal dvid_crgb    : std_logic_vector(4*hdo(settings)**".video.gear=1" downto 0);

	signal mii_clk  : std_logic;
	signal mii_req  : std_logic;

	signal so_frm   : std_logic;
	signal so_irdy  : std_logic;
	signal so_trdy  : std_logic;
	signal so_data  : std_logic_vector(0 to 8-1);
	signal si_frm   : std_logic;
	signal si_irdy  : std_logic;
	signal si_trdy  : std_logic;
	signal si_end   : std_logic;
	signal si_data  : std_logic_vector(0 to 8-1);

	signal ser_clk  : std_logic;
	signal ser_frm  : std_logic;
	signal ser_irdy : std_logic;
	signal ser_data : std_logic_vector(0 to mii_rxd'length-1);

	signal dhcp_btn : std_logic;
	signal tp : std_logic_vector(1 to 32);

begin

	videodcm_i : entity hdl4fpga.xc3s_videodcm
	generic map(
		settings => hdo(settings)**".dcm")
	port map(
		rst       => sys_rst,
		clk       => sys_clk,
		video_clk => video_clk);

	miidcm_i : entity hdl4fpga.xc3s_dcm
	generic map (
		settings => "{"                 &
			"freq_in        : 20.0e6,"  & 
			"clkfx_multiply : 5,"       & 
			"clkfx_divide   : 4}")
	port map (
		clkin => sys_clk,
		clkfx => mii_clk);
	mii_refclk <= not mii_clk;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			dhcp_btn <= not sw1;
		end if;
	end process;

	mii_e : entity hdl4fpga.link_mii
	generic map (
		rmii          => false,
		default_mac   => x"00_40_00_01_02_03",
		default_ipv4a => aton("192.168.0.14"),
		n             => mii_rxd'length)
	port map (
		tp         => tp,
		si_frm     => si_frm,
		si_irdy    => si_irdy,
		si_trdy    => si_trdy,
		si_end     => si_end,
		si_data    => si_data,
	
		so_frm     => so_frm,
		so_irdy    => so_irdy,
		so_trdy    => so_trdy,
		so_data    => so_data,
		dhcp_btn   => dhcp_btn,
		mii_txc    => mii_txc,
		mii_txen   => mii_txen,
		mii_txd    => mii_txd,

		mii_rxc    => mii_rxc,
		mii_rxdv   => mii_rxdv,
		mii_rxd    => mii_rxd);   

	ser_clk  <= mii_txc;
	ser_frm  <= tp(2);
	ser_irdy <= mii_txen;
	ser_data <= mii_txd;

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
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb);

	psave <= '1';
	sync  <= 'Z';
	red   <= multiplex(video_pixel, std_logic_vector(to_unsigned(0,2)), 8);
	green <= multiplex(video_pixel, std_logic_vector(to_unsigned(1,2)), 8);
	blue  <= multiplex(video_pixel, std_logic_vector(to_unsigned(2,2)), 8);

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

	process (mii_txc)
		variable q1 : bit;
		variable q2 : bit;
	begin
		if rising_edge(mii_txc) then
			if q1='1' and tp(1)='0' then
				q2 := not q2;
			end if;
			led7 <= to_stdulogic(q2);
			led8 <= not to_stdulogic(q2);
			q1 := to_bit(tp(1));
		end if;
	end process;

	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
--	led8  <= '0';
--	led7  <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

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
