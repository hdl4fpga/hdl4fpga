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

entity xc5v_sdramdcm is
	generic (
		settings  : string);
	port (
		rst          : in  std_logic := '0';
		clk          : in  std_logic;
		ctlr_clk     : buffer std_logic;
		ctlr_clkx2   : out std_logic;
		ctlr_clk90   : buffer std_logic;
		ctlr_clk90x2 : out std_logic;
		ctlr_rst     : out std_logic;
		ctlr_rst90   : out std_logic;
		locked       : buffer std_logic);

    constant freq_in       : real    := settings**".freq_in";
	constant clkfbout_mult : natural := settings**".clkfbout_mult=1";
	constant divclk_divide : natural := settings**".divclk_divide=1";
	constant gear : natural := 4;

end;


library hdl4fpga;
use hdl4fpga.xc5v_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture def of xc5v_sdramdcm is

	constant sdram_freq     : real := hdl4fpga.xc5v_profiles.sdram_freq(settings**".dcm"); -- GHDL annoyance

	signal ctlr_clk0_mmce2    : std_logic;
	signal ctlr_clk90_mmce2   : std_logic;
	signal ctlr_clk0x2_mmce2  : std_logic;
	signal ctlr_clk90x2_mmce2 : std_logic;
	signal ctlr_clkfb         : std_logic;
	signal tmr_rdy            : std_logic;

begin

	pll_i : pll_base
	generic map (
		divclk_divide  => divclk_divide,
		clkfbout_mult  => 2*clkfbout_mult,
		clkin_period   => 1.0e9/freq_in,
		clkout0_divide => gear/2,
		clkout1_divide => gear/2,
		clkout1_phase  => 90.0+180.0,
		clkout2_divide => gear,
		clkout3_divide => gear,
		clkout3_phase  => 90.0/real((gear/2))+270.0)
	port map (
		rst      => rst,
		clkin    => clk,
		clkfbin  => ctlr_clkfb,
		clkfbout => ctlr_clkfb,
		clkout0  => ctlr_clk0x2_mmce2,
		clkout1  => ctlr_clk90x2_mmce2,
		clkout2  => ctlr_clk0_mmce2,
		clkout3  => ctlr_clk90_mmce2,
		locked   => locked);

	ctlr_clk0_bufg: bufg
	port map (
		i => ctlr_clk0_mmce2,
		o => ctlr_clk);

	ctlr_clk0x2_bufg: bufg
	port map (
		i => ctlr_clk0x2_mmce2,
		o => ctlr_clkx2);

	ctlr_clk90_bufg : bufg
	port map (
		i => ctlr_clk90_mmce2,
		o => ctlr_clk90);

	ctlr_clk90x2_bufg: bufg
	port map (
		i => ctlr_clk90x2_mmce2,
		o => ctlr_clk90x2);

   	process (clk)
   		variable tmr : unsigned(0 to 8-1) := (others => '0');
   	begin
   		if rising_edge(clk) then
   			if (rst or not locked)='1' then
   				tmr := (others => '0');
   			elsif tmr(0)='0' then
   				tmr := tmr + 1;
   			end if;
   		end if;
   		tmr_rdy <= not tmr(0);
   	end process;

	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if tmr_rdy='1' then
				ctlr_rst <= '1';
			else
				ctlr_rst <= rst;
			end if;
		end if;
	end process;

	process (ctlr_clk90)
	begin
		if rising_edge(ctlr_clk90) then
			if tmr_rdy='1' then
				ctlr_rst90 <= '1';
			else
				ctlr_rst90 <= rst;
			end if;
		end if;
	end process;
end;
