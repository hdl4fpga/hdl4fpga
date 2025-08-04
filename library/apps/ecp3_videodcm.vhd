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

library ecp3;
use ecp3.components.all;

entity ecp3_videodcm is
	generic (
		settings     : string);
	port (
		rst          : in std_logic := '0';
		clk          : in std_logic;
		video_clk    : out std_logic;
		video_shift_clk : out std_logic;
		video_lck    : buffer std_logic);

    constant freq_in    : real    := settings**".dcm.freq_in=1.0";
    constant clki_div   : natural := settings**".dcm.clki_div=1";
    constant clkfb_div  : natural := settings**".dcm.clkfb_div=1";
    constant clkop_div  : natural := settings**".dcm.clkop_div=1";
    constant clkok_div  : natural := settings**".dcm.clkok_div=1";

end;

architecture def of ecp3_videodcm is
	
		constant video_freq       : real := (real(clkfb_div*clkop_div)*freq_in)/(real(clki_div*clkok_div*1e6));
		constant video_shift_freq : real := (real(clkfb_div*clkop_div)*freq_in)/(real(clki_div*clkok_div*1e6));

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOK  : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(freq_in/1.0e6,   10);
		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(video_shift_freq, 10);
		attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa(video_freq,       10);
		attribute FREQUENCY_PIN_CLKOK of pll_i : label is ftoa(video_freq,       10);

		signal clkfb : std_logic;

	begin

	pll_i : ehxpllf
       generic map (
		CLKOS_TRIM_DELAY => 0,
		CLKOS_TRIM_POL   => "RISING", 
		CLKOS_BYPASS     => "DISABLED", 
		CLKOP_TRIM_DELAY => 0,
		CLKOP_TRIM_POL   => "RISING", 
		CLKOP_BYPASS     => "DISABLED", 
		CLKOK_INPUT      => "CLKOP",
		CLKOK_BYPASS     => "DISABLED", 
		DELAY_PWD        => "DISABLED",
		DELAY_VAL        => 0, 
		DUTY             => 8,
		PHASE_DELAY_CNTL => "DYNAMIC",
		PHASEADJ         => "0.0", 

		CLKOK_DIV        => clkok_div,
		CLKOP_DIV        => clkop_div,
		CLKFB_DIV        => clkfb_div,
		CLKI_DIV         => clki_div)
       port map (
		rst      => '0',
		rstk     => '0',
		drpai3   => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
		dfpai3   => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
		fda3     => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
		wrdel    => '0',
		clki     => clk,
		CLKFB    => clkfb,
		CLKOP    => video_shift_clk,
		CLKOK    => video_clk,
		LOCK     => video_lck,
		clkintfb => clkfb);

end;
