-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.cgafonts.all;

library unisim;
use unisim.vcomponents.all;

architecture ser_debug of nuhs3adsp is

	signal clk_bufg   : std_logic;
	signal mii_req   : std_logic;
	signal vga_dot   : std_logic;
	signal vga_on    : std_logic;
	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;

	type video_params is record
		timing_id : videotiming_ids;
		dcm_mul   : natural;
		dcm_div   : natural;
	end record;

	type video_modes is (
		mode480p,
		mode600p, 
		mode1080p);

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		mode480p  => (timing_id => pclk25_00m640x480at60,    dcm_mul =>  3, dcm_div => 2),
		mode600p  => (timing_id => pclk40_00m800x600at60,    dcm_mul =>  2, dcm_div => 1),
		mode1080p => (timing_id => pclk140_00m1920x1080at60, dcm_mul => 15, dcm_div => 2));

	constant video_mode : video_modes := mode600p;
    signal vga_pixel    : std_logic_vector(0 to 32-1);
    signal vga_blank    : std_logic;

	signal mii_clk  : std_logic;

	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(8-1 downto 0);
	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(8-1 downto 0);

	signal txc_rxdv : std_logic;
	signal ipv4acfg_req  : std_logic;
	alias sio_clk : std_logic is mii_txc;
	signal tp : std_logic_vector(1 to 32);
	alias data : std_logic_vector(0 to 4-1) is tp(3 to 3+4-1);
begin

	clkin_ibufg : ibufg
	port map (
		I => clk,
		O => clk_bufg);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => video_tab(video_mode).dcm_mul,
		dfs_div => video_tab(video_mode).dcm_div)
	port map(
		dcm_rst => '0',
		dcm_clk => clk_bufg,
		dfs_clk => vga_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => clk_bufg,
		dfs_clk => mii_clk);
	mii_refclk <= not mii_clk;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			ipv4acfg_req <= not sw1;
		end if;
	end process;

	udpdaisy_e : entity hdl4fpga.sio_dayudp
	generic map (
		default_ipv4a => x"c0_a8_00_0e")
	port map (
		ipv4acfg_req => ipv4acfg_req,

		phy_rxc   => mii_rxc,
		phy_rx_dv => mii_rxdv,
		phy_rx_d  => mii_rxd,

		phy_txc   => mii_txc,
		phy_col   => mii_col,
		phy_crs   => mii_crs,
		phy_tx_en => mii_txen,
		phy_tx_d  => mii_txd,
		txc_rxdv  => txc_rxdv,
	
		sio_clk   => sio_clk,
		si_frm    => sout_frm,
		si_irdy   => sout_irdy,
		si_trdy   => sout_trdy,
		si_data   => sout_data,

		so_frm    => sin_frm,
		so_irdy   => sin_irdy,
		so_trdy   => '1',
		so_data   => sin_data,
		tp        => tp);
	
	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		timing_id    => video_tab(video_mode).timing_id,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8)
	port map (
		ser_clk      => mii_txc, 
		ser_frm      => tp(1),
		ser_irdy     => tp(2),
		ser_data     => data,
		
		video_clk    => vga_clk,
		video_hzsync => vga_hsync,
		video_vtsync => vga_vsync,
		video_blank  => vga_blank,
		video_pixel  => vga_pixel);

	psave <= '1';
	sync  <= 'Z';
	red   <= multiplex(vga_pixel, std_logic_vector(to_unsigned(0,2)), 8);
	green <= multiplex(vga_pixel, std_logic_vector(to_unsigned(1,2)), 8);
	blue  <= multiplex(vga_pixel, std_logic_vector(to_unsigned(2,2)), 8);

	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => vga_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

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
