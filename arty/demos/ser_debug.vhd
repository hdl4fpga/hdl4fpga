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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.cgafonts.all;

library unisim;
use unisim.vcomponents.all;

architecture ser_debug of arty is

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
		mode480p  => (timing_id => pclk25_00m640x480at60,    dcm_mul =>  6, dcm_div => 24),
		mode600p  => (timing_id => pclk40_00m800x600at60,    dcm_mul =>  6, dcm_div => 15),
		mode1080p => (timing_id => pclk140_00m1920x1080at60, dcm_mul => 12, dcm_div => 8));

	constant video_mode : video_modes := mode600p;

	signal sys_clk        : std_logic;
	signal dhcp_req       : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal eth_rxclk_bufg : std_logic;
	signal video_clk      : std_logic;
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
	signal video_pixel    : std_logic_vector(3-1 downto 0);

	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(8-1 downto 0);
	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(8-1 downto 0);

	signal tp  : std_logic_vector(1 to 32);
	alias data : std_logic_vector(0 to 4-1) is tp(3 to 3+4-1);

begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	eth_rx_clk_ibufg : ibufg
	port map (
		I => eth_rx_clk,
		O => eth_rxclk_bufg);

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);

	dcm_b : block
		signal video_clkfb : std_logic;
	begin
		video_dcm_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0,
			clkfbout_mult_f  => real(video_tab(video_mode).dcm_mul),
			clkout0_divide_f => real(video_tab(video_mode).dcm_div),
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => sys_clk,
			clkfbin  => video_clkfb,
			clkfbout => video_clkfb,
			clkout0  => video_clk);
	end block;

	udpdaisy_e : entity hdl4fpga.sio_dayudp
	generic map (
		default_ipv4a => x"c0_a8_00_0e")
	port map (
		ipv4acfg_req => dhcp_req,

		phy_rxc   => eth_rxclk_bufg,
		phy_rx_dv => eth_rx_dv,
		phy_rx_d  => eth_rxd,

		phy_txc   => eth_txclk_bufg,
		phy_tx_en => eth_tx_en ,
		phy_tx_d  => eth_txd,

		phy_crs   => eth_crs,
		phy_col   => eth_col,

		sio_clk   => eth_txclk_bufg,
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
		red_length   => 1,
		green_length => 1,
		blue_length  => 1)
	port map (
		ser_clk      => eth_txclk_bufg,
		ser_frm      => eth_tx_en,
		ser_irdy     => '1',
		ser_data     => eth_txd,
				
		video_clk    => video_clk,
		video_hzsync => video_hs,
		video_vtsync => video_vs,
		video_pixel  => video_pixel);

	process (eth_txclk_bufg)
	begin
		if rising_edge(eth_txclk_bufg) then
			if btn(0)='1' then
				if eth_tx_en='0' then
					dhcp_req <= '1';
				end if;
			elsif eth_tx_en='0' then
				dhcp_req <= '0';
			end if;
		end if;
	end process;
	led(0) <= tp(3);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			ja(1)  <= video_pixel(2);
			ja(2)  <= video_pixel(1);
			ja(3)  <= video_pixel(0);
			ja(4)  <= video_hs;
			ja(10) <= video_vs;
		end if;
	end process;

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';

end;
