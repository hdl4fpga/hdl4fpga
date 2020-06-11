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

entity ddrpll is
	generic (
		ddr_clki    : natural := 1;
		ddr_clkfb   : natural := 4;
		ddr_clkop   : natural := 2;
		ddr_clkok   : natural := 2;
		sys_per     : real := 10.0);
	port (
		sys_rst     : in  std_logic;
		sys_clk     : in  std_logic;
		phy_clk     : in  std_logic;

		gtx_clk     : out std_logic;

		ddr_sclk2x  : out std_logic;
		ddr_eclk    : buffer std_logic;
		ddr_sclk    : out std_logic;
		ddr_pha     : buffer std_logic_vector(4-1 downto 0);

		ddr_rst     : out std_logic;
		gtx_rst     : out std_logic);
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of dcms is

	attribute frequency_pin_clki  : string; 
	attribute frequency_pin_clkop : string; 
	attribute frequency_pin_clkos : string; 
	attribute frequency_pin_clkok : string; 

	attribute frequency_pin_clki  of pll_i : label is "100.000000";
	attribute frequency_pin_clkop of pll_i : label is "500.000000";
	attribute frequency_pin_clkos of pll_i : label is "500.000000";
	attribute frequency_pin_clkok of pll_i : label is "250.000000";

	signal clkfb      : std_logic;
	signal lock       : std_logic;
	signal dfpa3      : std_logic;
	signal adjdll_rst : std_logic;
	signal adjdll_rdy : std_logic;

	signal ddr_lock   : std_logic;

begin

	process (sys_rst, sys_clk)
		variable q : std_logic_vector(0 to 6-1) := (others => '0');
	begin
		if sys_rst='1' then
			q := (others => '0');
		elsif rising_edge(sys_clk) then
			if q(0)='0' then
				q := inc(gray(q));
			end if;
		end if;
		pll_rst <= not q(0);
	end process;

	dfpa3 <= not ddr_pha(3);
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
		CLKOK_DIV        => ddr_clkok,
		CLKOP_DIV        => ddr_clkop,
		CLKFB_DIV        => ddr_clkfb,
		CLKI_DIV         => ddr_clki,
		FEEDBK_PATH      => "INTERNAL",
		FIN              => "100.000000")
	port map (
		rst              => pll_rst, 
		rstk             => '0',
		clki             => sys_clk,
		drpai3 => pha(3),  drpai2 => pha(2), drpai1 => pha(1), drpai0 => pha(0), 
		dfpai3 => dfpa(3), dfpai2 => pha(2), dfpai1 => pha(1), dfpai0 => pha(0), 
		fda3             => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
		wrdel            => '0',
		clkintfb         => clkfb,
		clkfb            => clkfb,
		clkop            => ddr_sclk2x, 
		clkos            => ddr_eclk,
		clkok            => ddr_sclk,
		clkok2           => open,
		lock             => pll_lock);

	adjdll_rst <= not pll_lock;
	adjdll_e : entity hdl4fpga.adjdll
	port map (
		rst  => adjdll_rst,
		rdy  => adjdll_rdy,
		sclk => ddr_sclk,
		eclk => ddr_eclk,
		pha  => ddr_pha);

	process(ddr_sclk, pll_lock)
		variable q : std_logic_vector(0 to 6-1) := (others => '0');
	begin
		if lock_='0' then
			q := (others => '0');
		elsif rising_edge(ddr_sclk) then
			if adjdll_rdy='1' then
				if q(0)='0' then
					q := inc(gray(q));
				end if;
			end if;
		end if;
		ddr_lock <= q(0);
	end process;

	process (ddr_clk, sys_rst)
		variable sync1 : std_logic;
		variable sync2 : std_logic;
	begin
		if sys_rst='1' then
			ddr_rst <= '1';
			sync1   := '1';
			sync2   := '1';
		elsif rising_edge(ddr_clk) then
			ddr_rst <= sync2;
			sync2   := sync1;
			sync1   := not ddr_lock;
		end if;
	end process;

end;
