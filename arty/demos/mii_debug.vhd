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

architecture mii_debug of arty is
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
	signal video_dot      : std_logic;
	signal video_vs       : std_logic;
	signal video_hs       : std_logic;
	signal video_clk      : std_logic;

	signal rxc  : std_logic;
	signal rxd  : std_logic_vector(eth_rxd'range);
	signal rxdv : std_logic;

	signal txc  : std_logic;
	signal txd  : std_logic_vector(eth_txd'range);
	signal txen : std_logic;
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

	dcm_e : block
		signal video_clkfb : std_logic;
	begin
		video_dcm_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0,
			clkfbout_mult_f  => real(video_tab(video_mode).dcm_mul), --6.0, --12.0,		-- 200 MHz
			clkout0_divide_f => real(video_tab(video_mode).dcm_div), --15.0, --8.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => sys_clk,
			clkfbin  => video_clkfb,
			clkfbout => video_clkfb,
			clkout0  => video_clk);
	end block;

	rxc <= eth_rxclk_bufg;
	process (rxc)
	begin
		if rising_edge(rxc) then
			rxd  <= eth_rxd;
			rxdv <= eth_rx_dv;
		end if;
	end process;

	txc <= not eth_txclk_bufg;
	mii_debug_e : entity hdl4fpga.mii_debug
	generic map (
		default_ipv4a => x"c0_a8_00_0e",
		cga_bitrom => to_ascii("Ready Steady GO!"),
		timing_id  => video_tab(video_mode).timing_id)
	port map (
		mii_rxc   => rxc,
		mii_rxd   => rxd,
		mii_rxdv  => rxdv,

		mii_txc   => txc,
		mii_txd   => txd,
		mii_txen  => txen,

		dhcp_req  => dhcp_req,

		video_clk => video_clk, 
		video_dot => video_dot,
		video_hs  => video_hs,
		video_vs  => video_vs);

	process (txc)
	begin
		if rising_edge(txc) then
			eth_txd   <= txd;
			eth_tx_en <= txen;
		end if;
	end process;

	process (txc)
	begin
		if rising_edge(txc) then
			if btn(0)='1' then
				if txen='0' then
					dhcp_req <= '1';
				end if;
			elsif txen='0' then
				dhcp_req <= '0';
			end if;
		end if;
	end process;
	led(0) <= dhcp_req;

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			ja(1)  <= video_dot;
			ja(2)  <= video_dot;
			ja(3)  <= video_dot;
			ja(4)  <= video_hs;
			ja(10) <= video_vs;
		end if;
	end process;

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';
end;
