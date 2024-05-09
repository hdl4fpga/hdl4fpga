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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

entity ecp5_sdrampll is
	generic (
		gear         : natural;
		clkref_freq  : real;
		sdram_params : sdramparams_record);
	port (
		clk_ref      : in  std_logic;
		ctlr_rst     : out std_logic;
		sclk         : buffer std_logic;
		eclk         : buffer std_logic;
		phy_rst      : buffer std_logic;
		phy_mspause  : out std_logic;
		phy_ddrdel   : out std_logic;
		sdrampll_lck : buffer std_logic);
end;

architecture def of ecp5_sdrampll is

	attribute FREQUENCY_PIN_CLKOS  : string;
	attribute FREQUENCY_PIN_CLKOS2 : string;
	attribute FREQUENCY_PIN_CLKOS3 : string;
	attribute FREQUENCY_PIN_CLKI   : string;
	attribute FREQUENCY_PIN_CLKOP  : string;

	constant clkos_freq  : real :=
		real(sdram_params.pll.clkfb_div)*clkref_freq/
		real(sdram_params.pll.clki_div);

	constant sdram_freq  : real := sdram_freq(sdram_params,clkref_freq);

	attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa(clkos_freq/1.0e6, 10);
	attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(setif(sdram_freq < 400.0e6, sdram_freq/1.0e6, 400.0), 10);
	attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(clkref_freq/1.0e6, 10);

	signal clkfb       : std_logic;
	signal clkop       : std_logic;
	signal memsync_rst : std_logic;

begin

	assert false
	report CR &
		"SDRAM CLK FREQUENCY : " & ftoa(sdram_freq/1.0e6, 6) & " MHz" & CR & 
		"CLKOP  : " & pll_i'FREQUENCY_PIN_CLKOP  & " MHz "  & CR &
		"CLKOS  : " & pll_i'FREQUENCY_PIN_CLKOS  & " MHz "
	severity NOTE;

	pll_i : EHXPLLL
	generic map (
		PLLRST_ENA       => "DISABLED",
		INTFB_WAKE       => "DISABLED",
		STDBY_ENABLE     => "DISABLED",
		DPHASE_SOURCE    => "DISABLED",
		PLL_LOCK_MODE    =>  0,
		FEEDBK_PATH      => "CLKOS",
		CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => sdram_params.pll.clkos_div-1,
		CLKOS2_ENABLE    => "DISABLED", CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
		CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
		CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => 0,
		CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
		CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
		OUTDIVIDER_MUXD  => "DIVD",
		OUTDIVIDER_MUXC  => "DIVC",
		OUTDIVIDER_MUXB  => "DIVB",
		OUTDIVIDER_MUXA  => "DIVA",

		CLKOS_DIV        => sdram_params.pll.clkos_div,
		CLKOP_DIV        => sdram_params.pll.clkop_div,
		CLKFB_DIV        => sdram_params.pll.clkfb_div,
		CLKI_DIV         => sdram_params.pll.clki_div)
	port map (
		rst       => '0',
		clki      => clk_ref,
		CLKFB     => clkfb,
		PHASESEL0 => '0', PHASESEL1 => '0',
		PHASEDIR  => '0',
		PHASESTEP => '0', PHASELOADREG => '0',
		STDBY     => '0', PLLWAKESYNC  => '0',
		ENCLKOP   => '0',
		ENCLKOS   => '0',
		ENCLKOS2  => '0',
		ENCLKOS3  => '0',
		CLKOP     => clkop,
		CLKOS     => clkfb,
		CLKOS2    => open,
		CLKOS3    => open,
		LOCK      => sdrampll_lck,
		INTLOCK   => open,
		REFCLK    => open,
		CLKINTFB  => open);

	gear1_g : if gear=1 generate
		sclk     <= clkop;
		ctlr_rst <= not sdrampll_lck;
	end generate;

	gear4_g : if gear=4 generate

		component mem_sync
			port (
				start_clk : in  std_logic;
				rst       : in  std_logic;
				dll_lock  : in  std_logic;
				pll_lock  : in  std_logic;
				update    : in  std_logic;
				pause     : out std_logic;
				stop      : out std_logic;
				freeze    : out std_logic;
				uddcntln  : out std_logic;
				dll_rst   : out std_logic;
				ddr_rst   : out std_logic;
				ready     : out std_logic);
		end component;

		signal uddcntln : std_logic;
		signal freeze   : std_logic;
		signal stop     : std_logic;
		signal dll_rst  : std_logic;
		signal dll_lock : std_logic;
		signal pll_lock : std_logic;
		signal update   : std_logic;
		signal ready    : std_logic;
		alias ddr_rst is phy_rst;
		-- signal eclko    : std_logic;
		-- signal cdivx    : std_logic;
		alias eclko is eclk;
		alias cdivx is sclk;

		attribute FREQUENCY_PIN_ECLKO : string;
		attribute FREQUENCY_PIN_ECLKO of  eclksyncb_i : label is ftoa(sdram_freq/1.0e6, 10);

		attribute FREQUENCY_PIN_CDIVX : string;
		attribute FREQUENCY_PIN_CDIVX of clkdivf_i : label is ftoa(sdram_freq/1.0e6/2.0, 10);

	begin

		assert false
		report CR &
			"ECLKO : " & eclksyncb_i'FREQUENCY_PIN_ECLKO  & " MHz "  & CR &
			"CDIVX : " &   clkdivf_i'FREQUENCY_PIN_CDIVX  & " MHz "
		severity NOTE;

		memsync_rst <= not sdrampll_lck;
		pll_lock <= '1';
		update   <= '0';

		mem_sync_i : mem_sync
		port map (
			start_clk => clk_ref,
			rst       => memsync_rst,
			dll_lock  => dll_lock,
			pll_lock  => pll_lock,
			update    => update,
			pause     => phy_mspause,
			stop      => stop,
			freeze    => freeze,
			uddcntln  => uddcntln,
			dll_rst   => dll_rst,
			ddr_rst   => ddr_rst,
			ready     => ready);

		eclksyncb_i : eclksyncb
		port map (
			stop  => stop,
			eclki => clkop,
			eclko => eclko);
	
		clkdivf_i : clkdivf
		generic map (
			div => "2.0")
		port map (
			rst     => ddr_rst,
			alignwd => '0',
			clki    => eclko,
			cdivx   => cdivx);
		-- eclk <= eclko;
		-- sclk <= transport cdivx after natural(1.0e12*(1.0/4.0)/sdram_freq)*1 ps;


		ddrdll_i : ddrdlla
		port map (
			rst      => dll_rst,
			clk      => eclk,
			freeze   => freeze,
			uddcntln => uddcntln,
			ddrdel   => phy_ddrdel,
			lock     => dll_lock);

		process (memsync_rst, ready, sclk)
		begin
			if memsync_rst='1' then
				ctlr_rst <= '1';
			elsif ready='0' then
				ctlr_rst <= '1';
			elsif rising_edge(sclk) then
				ctlr_rst <= memsync_rst;
			end if;
		end process;

	end generate;

end;