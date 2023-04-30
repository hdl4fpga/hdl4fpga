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
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

entity ecp5_videopll is
	generic (
		clkref_freq  : real;
		default_gear : natural := 0;
		video_record : video_params);
	port (
		clk_ref      : in std_logic;
		videoio_clk  : out std_logic;
		video_clk    : out std_logic;
		video_shift_clk : out std_logic;
		video_eclk   : out std_logic;
		video_phyrst : buffer std_logic;
		video_lck    : buffer std_logic);

	constant gear  : natural := setif(default_gear=0,video_record.gear, default_gear);

end;

architecture def of ecp5_videopll is

	attribute FREQUENCY_PIN_CLKOS  : string;
	attribute FREQUENCY_PIN_CLKOS2 : string;
	attribute FREQUENCY_PIN_CLKOS3 : string;
	attribute FREQUENCY_PIN_CLKI   : string;
	attribute FREQUENCY_PIN_CLKOP  : string;

	constant video_freq : real :=
		(real(video_record.pll.clkfb_div*video_record.pll.clkos_div)*clkref_freq)/
		(real(video_record.pll.clki_div*video_record.pll.clkos2_div));

	constant video_clkop_freq : real := 
		real(video_record.pll.clkfb_div*video_record.pll.clkos_div)*clkref_freq/
		real(video_record.pll.clki_div*video_record.pll.clkop_div);
	constant video_clkop_clampfreq : real := 
		setif(video_clkop_freq > 400.0e6, 400.0e6, video_clkop_freq);

	constant videoio_freq : real :=
		(real(video_record.pll.clkfb_div*video_record.pll.clkos_div)*clkref_freq)/
		(real(video_record.pll.clki_div*video_record.pll.clkos3_div));

	attribute FREQUENCY_PIN_CLKOP  of pll_i : label is ftoa(video_clkop_clampfreq/1.0e6, 10);
	attribute FREQUENCY_PIN_CLKOS2 of pll_i : label is ftoa(           video_freq/1.0e6, 10);
	attribute FREQUENCY_PIN_CLKOS3 of pll_i : label is ftoa(         videoio_freq/1.0e6, 10);
	attribute FREQUENCY_PIN_CLKI   of pll_i : label is ftoa(          clkref_freq/1.0e6, 10);
	attribute FREQUENCY_PIN_CLKOS  of pll_i : label is ftoa(          clkref_freq/1.0e6, 10);

	signal clkop  : std_logic;
	signal clkos  : std_logic;
	signal clkos2 : std_logic;

begin
	assert false
	report 
		"VIDEO CLK FREQUENCY : " & ftoa(video_freq/1.0e6, 6) & " MHz " &
		pll_i'FREQUENCY_PIN_CLKOP  & " " &
		pll_i'FREQUENCY_PIN_CLKOS  & " " &
		pll_i'FREQUENCY_PIN_CLKOS2 & " " &
		pll_i'FREQUENCY_PIN_CLKOS3
	severity NOTE;

	pll_i : EHXPLLL
	generic map (
		PLLRST_ENA       => "DISABLED",
		INTFB_WAKE       => "DISABLED",
		STDBY_ENABLE     => "DISABLED",
		DPHASE_SOURCE    => "DISABLED",
		PLL_LOCK_MODE    =>  0,
		FEEDBK_PATH      => "CLKOS",
		CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => video_record.pll.clkos_div-1,
		CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
		CLKOS3_ENABLE    => "ENABLED",  CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
		CLKOP_ENABLE     => "ENABLED",  CLKOP_FPHASE   => 0, CLKOP_CPHASE  => 0,
		CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
		CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
		OUTDIVIDER_MUXD  => "DIVD",
		OUTDIVIDER_MUXC  => "DIVC",
		OUTDIVIDER_MUXB  => "DIVB",
		OUTDIVIDER_MUXA  => "DIVA",

		CLKOS_DIV        => video_record.pll.clkos_div,
		CLKOS2_DIV       => video_record.pll.clkos2_div,
		CLKOS3_DIV       => video_record.pll.clkos3_div,
		CLKOP_DIV        => video_record.pll.clkop_div,
		CLKFB_DIV        => video_record.pll.clkfb_div,
		CLKI_DIV         => video_record.pll.clki_div)
	port map (
		rst       => '0',
		clki      => clk_ref,
		CLKFB     => clkos,
		PHASESEL0 => '0', PHASESEL1 => '0',
		PHASEDIR  => '0',
		PHASESTEP => '0', PHASELOADREG => '0',
		STDBY     => '0', PLLWAKESYNC  => '0',
		ENCLKOP   => '0',
		ENCLKOS   => '0',
		ENCLKOS2  => '0',
		ENCLKOS3  => '0',
		CLKOP     => clkop,
		CLKOS     => clkos,
		CLKOS2    => video_clk,
		CLKOS3    => videoio_clk,
		LOCK      => video_lck,
		INTLOCK   => open,
		REFCLK    => open,
		CLKINTFB  => open);

	gbx21_g : if gear=2 generate
		video_phyrst    <= not video_lck;
		video_eclk      <= clkop;
		video_shift_clk <= clkop;
	end generate;

	gbx71_g : if gear=4 or gear=7 generate
		component gddr_sync
		port (
			rst       : in  std_logic;
			sync_clk  : in  std_logic;
			start     : in  std_logic;
			stop      : out std_logic;
			ddr_reset : out std_logic;
			ready     : out std_logic);
		end component;

		signal gddr_rst : std_logic;
		signal stop     : std_logic;
		signal eclko    : std_logic;
		signal cdivx    : std_logic;

		attribute FREQUENCY_PIN_ECLKO : string;
		attribute FREQUENCY_PIN_ECLKO of eclksyncb_i : label is ftoa(video_clkop_clampfreq/1.0e6, 10);

		attribute FREQUENCY_PIN_CDIVX : string;
		attribute FREQUENCY_PIN_CDIVX of clkdivf_i   : label is ftoa((video_clkop_clampfreq/setif(gear=4,2.0,3.5))/1.0e6, 10);

	begin
		gddr_rst <= not video_lck;
		gddr_sync_i : gddr_sync 
		port map (
		  rst       => gddr_rst,
		  sync_clk  => clk_ref,
		  start     => gddr_rst,
		  stop      => stop,
		  ddr_reset => video_phyrst,
		  ready     => open);

		eclksyncb_i : eclksyncb
		port map (
			stop  => stop,
			eclki => clkop,
			eclko => eclko);
	
		clkdivf_i : clkdivf
		generic map (
			div => setif(gear=7, "3.5", "2.0"))
		port map (
			rst     => video_phyrst,
			alignwd => '0',
			clki    => eclko,
			cdivx   => cdivx);
		video_eclk      <= eclko;
		video_shift_clk <= transport cdivx after natural((3.0/4.0)/(video_clkop_freq*1.0e12))*1 ps;
	end generate;

end;
