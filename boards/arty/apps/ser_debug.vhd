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

architecture ser_debug of arty is

	constant settings : string := '{'  &
		"video:{"                      &
			"dcm:{"                    & 
				"clkfbout_mult: 12,"   &
				"clkout0_divide: 8,"   &
				"freq_in: 100.0e6},"   &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'1920x1080'.'@60'.'150mhz'") & ',' &
			"pixel:"   & "{R:1,G:1,B:1}}}";

	alias sys_clk is gclk100;

	signal so_frm          : std_logic;
	signal so_irdy         : std_logic;
	signal so_trdy         : std_logic;
	signal so_data         : std_logic_vector(0 to 8-1);
	signal si_frm          : std_logic;
	signal si_irdy         : std_logic;
	signal si_trdy         : std_logic;
	signal si_end          : std_logic;
	signal si_data         : std_logic_vector(0 to 8-1);

	signal videoio_clk     : std_logic;
	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
	signal video_vtsync    : std_logic;
	signal video_pixel     : std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);
	signal dvid_crgb       : std_logic_vector(4*hdo(settings)**".video.gear=1" downto 0);

	signal ser_clk         : std_logic;
	signal ser_frm         : std_logic;
	signal ser_irdy        : std_logic;
	signal ser_data        : std_logic_vector(0 to eth_rxd'length-1);

	signal tp  : std_logic_vector(1 to 32);

begin

	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	videodcm_i : entity hdl4fpga.xc7a_videodcm
	generic map(
		settings => hdo(settings)**".video.dcm")
	port map(
		clk       => sys_clk,
		video_clk => video_clk);

	mii_e : entity hdl4fpga.link_mii
	generic map (
		rmii          => false,
		default_mac   => x"00_40_00_01_02_03",
		default_ipv4a => aton("192.168.0.14"),
		n             => eth_rxd'length)
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
		dhcp_btn   => btn0,
		mii_txc    => eth_tx_clk,
		mii_txen   => eth_tx_en,
		mii_txd    => eth_txd,

		mii_rxc    => eth_rx_clk,
		mii_rxdv   => eth_rx_dv, 
		mii_rxd    => eth_rxd);   

	ser_clk  <= eth_tx_clk;
	ser_frm  <= tp(2);
	ser_irdy <= eth_tx_en;
	ser_data <= eth_txd;

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

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			ja(1)  <= video_pixel(2);
			ja(2)  <= video_pixel(1);
			ja(3)  <= video_pixel(0);
			ja(4)  <= video_hzsync;
			ja(10) <= video_vtsync;
		end if;
	end process;

	ddrck_obufds : obufds
	generic map (
		iostandard => "DIFF_SSTL135")
	port map (
		i  => '0',
		o  => ddr3_clk_p,
		ob => ddr3_clk_n);

	ddrdqs_g : for i in ddr3_dqs_p'range generate
		iobuf_i : obufds
		generic map (
			iostandard => "DIFF_SSTL135")
		port map (
			i   => 'Z',
			o  => ddr3_dqs_p(i),
			ob => ddr3_dqs_n(i));
	end generate;


	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';
end;
