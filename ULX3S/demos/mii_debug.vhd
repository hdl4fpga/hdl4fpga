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

library ecp5u;
use ecp5u.components.all;

architecture mii_debug of ulx3s is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	constant sys_per      : real    := 1000.0 / 25.0;

	signal video_clk      : std_logic;
	signal video_shift_clk : std_logic;
	signal video_hzsync   : std_logic;
    signal video_vtsync   : std_logic;
    signal video_on     : std_logic;
	signal video_dot      : std_logic;
	signal dvid_crgb      : std_logic_vector(7 downto 0);

	constant modedebug : natural := 0;
	constant mode600p  : natural := 1;

	type video_params is record
		clkos_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
		clkos3_div : natural;
		timing_id  : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug  => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos3_div => 2, timing_id => pclk_debug),
		mode600p   => (clkos_div => 2, clkop_div => 16, clkfb_div => 1, clki_div => 1, clkos3_div => 2, timing_id => pclk40_00m800x600at60));
	constant video_mode : natural := mode600p;


	signal dhcp_req : std_logic := '0';

	signal tp : std_logic_vector(1 to 4);

	-- RMII pins as labeled on the board and connected to ULX3S with pins down and flat cable
	alias rmii_tx_en : std_logic is gn(10);
	alias rmii_tx0   : std_logic is gp(10);
	alias rmii_tx1   : std_logic is gn(9);

	alias rmii_rx0   : std_logic is gn(11);
	alias rmii_rx1   : std_logic is gp(11);

	alias rmii_crs   : std_logic is gp(12);

	alias rmii_nint  : std_logic is gn(12);
	alias rmii_mdio  : std_logic is gn(13);
	alias rmii_mdc   : std_logic is gp(13);

	signal mii_txc : std_logic;
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(0 to 2-1);

	signal mii_rxc : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 2-1);

begin

    mii_txc    <= rmii_nint;
	rmii_tx_en <= mii_txen;
	(0 => rmii_tx0, 1 => rmii_tx1) <= mii_txd;

    mii_rxc   <= rmii_nint;
	mii_rxdv  <= rmii_crs;
	mii_rxd   <= rmii_rx0 & rmii_rx1;

	rmii_mdc  <= 'Z';
	rmii_mdio <= 'Z';

	sys_rst <= '0';
	videopll_b : block

		signal clkfb : std_logic;

		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKOS : string; 
		attribute FREQUENCY_PIN_CLKOS2 : string; 
		attribute FREQUENCY_PIN_CLKOS3 : string; 

		attribute FREQUENCY_PIN_CLKI   of pll_i : label is  "25.000000";
		attribute FREQUENCY_PIN_CLKOP  of pll_i : label is  "25.000000";

		attribute FREQUENCY_PIN_CLKOS  of pll_i : label is "200.000000";
		attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is  "40.000000";

	begin
		pll_i : EHXPLLL
        generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED", 
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED", 
			PLL_LOCK_MODE    =>  0, 
			FEEDBK_PATH      => "CLKOP",
			CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => 15,
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => 0, 
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING", 
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING", 
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKOS3_DIV       => video_tab(video_mode).clkos3_div, 
			CLKOS2_DIV       =>  10, 
			CLKOS_DIV        => video_tab(video_mode).clkos_div,
			CLKOP_DIV        => video_tab(video_mode).clkop_div,
			CLKFB_DIV        => video_tab(video_mode).clkfb_div,
			CLKI_DIV         => video_tab(video_mode).clki_div)
        port map (
			rst       => '0', 
			clki      => clk_25mhz,
			CLKFB     => clkfb, 
            PHASESEL0 => '0', PHASESEL1 => '0', 
			PHASEDIR  => '0', 
            PHASESTEP => '0', PHASELOADREG => '0', 
            STDBY     => '0', PLLWAKESYNC  => '0',
            ENCLKOP   => '0', 
			ENCLKOS   => '0',
			ENCLKOS2  => '0', 
            ENCLKOS3  => '0', 
			CLKOP     => clkfb,
			CLKOS     => video_shift_clk,
            CLKOS2    => video_clk,
			LOCK      => open, 
            INTLOCK   => open, 
			REFCLK    => open, --REFCLK, 
			CLKINTFB  => open);

	end block;

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if btn(1)='0' then
				led(7) <= '0';
				led(0) <= '0';
			elsif mii_rxdv='1' then
				led(7) <= '1';
			elsif tp(1)='1' then
				led(0) <= '1';
			end if;
		end if;
	end process;

	mii_debug_e : entity hdl4fpga.mii_debug
	generic map (
		cga_bitrom => to_ascii("Ready Steady GO!"),
		timing_id  => video_tab(video_mode).timing_id)
	port map (
		mii_rxc   => mii_rxc,
		mii_rxd   => mii_rxd,
		mii_rxdv  => mii_rxdv,

		mii_txc   => mii_txc,
		dhcp_req  => dhcp_req,
		mii_txd   => mii_txd,
		mii_txen  => mii_txen,
		tp => tp,

		video_clk => video_clk, 
		video_dot => video_dot,
		video_on  => video_on,
		video_hs  => video_hzsync,
		video_vs  => video_vtsync);

	-- VGA --
	---------

	dvi_b : block
		signal video_blank : std_logic;
		signal in_dots    : std_logic_vector(5-1 downto 0);
	begin

		video_blank <= not video_on;
		in_dots <= (others => video_dot);

		vga2dvid_e : entity hdl4fpga.vga2dvid
		generic map (
			C_shift_clock_synchronizer => '0',
			C_ddr   => '1',
			C_depth => 5)
		port map (
			clk_pixel => video_clk,
			clk_shift => video_shift_clk,
			in_red    => in_dots,
			in_green  => in_dots,
			in_blue   => in_dots,
			in_hsync  => video_hzsync,
			in_vsync  => video_vtsync,
			in_blank  => video_blank,
			out_clock => dvid_crgb(7 downto 6),
			out_red   => dvid_crgb(5 downto 4),
			out_green => dvid_crgb(3 downto 2),
			out_blue  => dvid_crgb(1 downto 0));

		ddr_g : for i in gpdi_dp'range generate
			signal q : std_logic;
		begin
			oddr_i : oddrx1f
			port map(
				sclk => video_shift_clk,
				rst  => '0',
				d0   => dvid_crgb(2*i),
				d1   => dvid_crgb(2*i+1),
				q    => q);
			olvds_i : olvds 
			port map(
				a  => q,
				z  => gpdi_dp(i),
				zn => gpdi_dn(i));
		end generate;
	end block;

end;
