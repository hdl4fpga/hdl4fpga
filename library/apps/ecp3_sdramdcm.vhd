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

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ecp5_profiles.all;

library ecp3;
use ecp3.components.all;

entity ecp3_sdramdcm is
	generic (
		settings : string);
	port (
		clk   : in  std_logic;
        clkop : out std_logic; 
        clkos : out std_logic;
        clkok : out std_logic;
		phase : buffer std_logic_vector(4-1 downto 0);
		lock  : out std_logic);

    constant freq_in   : real    := settings**".dcm.freq_in";
	constant clkok_div : natural := hdo(settings)**".dcm.clkok_div=1";
	constant clkop_div : natural := hdo(settings)**".dcm.clkop_div=1";
	constant clkfb_div : natural := hdo(settings)**".dcm.clkfb_div=0";
	constant clki_div  : natural := hdo(settings)**".dcm.clki_div=1";

end;

architecture def of ecp3_sdramdcm is

	constant sdram_freq : real := hdl4fpga.ecp3_profiles.sdram_freq(settings**".dcm"); -- GHDL annoyance

	attribute FREQUENCY_PIN_CLKI  : string;
	attribute FREQUENCY_PIN_FIN   : string;
	attribute FREQUENCY_PIN_CLKOS : string;
	attribute FREQUENCY_PIN_CLKOP : string;
	attribute FREQUENCY_PIN_CLKOK : string; 

	attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(freq_in/1.0e6, 10);
	attribute FREQUENCY_PIN_FIN   of pll_i : label is ftoa((sdram_freq/1.0e6), 10);
	attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa((sdram_freq/1.0e6), 10);
	attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa((sdram_freq/1.0e6), 10);
	attribute FREQUENCY_PIN_CLKOK of pll_i : label is ftoa((sdram_freq/1.0e6)/2.0, 10);

	signal clkfb      : std_logic;
	signal dfpa3      : std_logic;

begin

	assert false
	report "SDRAM clock : " & real'image(sdram_freq)
	severity NOTE;

	dfpa3 <= not phase(3);
	pll_i : ehxpllf
	generic map (
		CLKOK_BYPASS     => "DISABLED", 
		CLKOS_BYPASS     => "DISABLED", 
		CLKOP_BYPASS     => "DISABLED", 
		CLKOK_INPUT      => "CLKOP",
		DELAY_PWD        => "DISABLED",
		DELAY_VAL        => 0, 
		CLKOS_TRIM_DELAY => 0,
		CLKOS_TRIM_POL   => "RISING", 
		CLKOP_TRIM_DELAY => 0,
		CLKOP_TRIM_POL   => "RISING", 
		PHASE_DELAY_CNTL => "DYNAMIC",
		DUTY             => 8,
		PHASEADJ         => "0.0", 
		CLKOK_DIV        => clkok_div,
		CLKOP_DIV        => clkop_div,
		CLKFB_DIV        => clkfb_div,
		CLKI_DIV         => clki_div,
		FEEDBK_PATH      => "INTERNAL")
	port map (
		rstk             => '0',
		clki             => clk,
		clkfb            => clkfb,
		rst              => '0', 
		drpai3           => phase(3),
		drpai2           => phase(2), 
		drpai1           => phase(1), 
		drpai0           => phase(0), 
		dfpai3           => dfpa3,
		dfpai2           => phase(2), 
		dfpai1           => phase(1), 
		dfpai0           => phase(0), 
		fda3             => '0',
		fda2             => '0',
		fda1             => '0',
		fda0             => '0', 
		wrdel            => '0',
		clkintfb         => clkfb,
		clkop            => clkop, 
		clkos            => clkos,
		clkok            => clkok,
		clkok2           => open,
		lock             => lock);

end;
