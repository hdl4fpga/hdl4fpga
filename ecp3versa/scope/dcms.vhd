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


entity dcms is
	generic (
		ddr_mul : natural := 5;
		ddr_div : natural := 1;
		ddr_fbdiv : natural := 1;
		sys_per : real := 10.0);
	port (
		sys_rst  : in  std_logic;
		sys_clk  : in  std_logic;

		ddr_sclk2x : out std_logic;
		ddr_eclk : out std_logic;
		ddr_sclk : out std_logic;
		ddr_pha  : out std_logic_vector(4-1 downto 0);

		video_clk0  : out std_logic;
		video_clk90 : out std_logic;

		ddr_rst   : out std_logic;
		video_rst : out std_logic);
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of dcms is

	---------------------------------------
	-- Frequency   -- 166 Mhz -- 450 Mhz --
	-- Multiply by --   5     --   9     --
	-- Divide by   --   3     --   2     --
	---------------------------------------
	signal pll_rst : std_logic;

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

	video_b : block
		attribute frequency_pin_clkop : string; 
		attribute frequency_pin_clkos : string; 
		attribute frequency_pin_clki  : string; 
		attribute frequency_pin_clkok : string; 
		attribute frequency_pin_clkop of pll_i : label is "125.000000";
		attribute frequency_pin_clkos of pll_i : label is "125.000000";
		attribute frequency_pin_clki  of pll_i : label is "100.000000";

		signal clkfb : std_logic;
		signal lock : std_logic;
	begin
		pll_i : ehxpllf
		generic map (
			feedbk_path => "INTERNAL",
			clkos_trim_delay => 0, clkos_trim_pol => "RISING", 
			clkop_trim_delay => 0, clkop_trim_pol => "RISING", 
			delay_pwd => "DISABLED",
			delay_val => 0, 
			duty => 8,
			phase_delay_cntl => "STATIC",
			phaseadj => "90.0", 
			clkok_div => 2,
			clkop_div => 8,
			clkfb_div => 5,
			clki_div  => 4,
			fin => "100.000000")
		port map (
			rst   => pll_rst, 
			rstk  => '0',
			clki  => sys_clk,
			wrdel => '0',
			drpai3 => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3 => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3   => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb => clkfb,
			clkfb => clkfb,
			clkop => video_clk0, 
			clkos => video_clk90,
			clkok => open,
			clkok2 => open,

			lock  => lock);
			video_rst <= not lock;
	end block;

	ddr_b : block
		attribute frequency_pin_clkop : string; 
		attribute frequency_pin_clkos : string; 
		attribute frequency_pin_clki  : string; 
		attribute frequency_pin_clkok : string; 

		attribute frequency_pin_clki  of pll_i : label is "100.000000";

--		attribute frequency_pin_clkop of pll_i : label is "400.000000";
--		attribute frequency_pin_clkos of pll_i : label is "400.000000";
--		attribute frequency_pin_clkok of pll_i : label is "200.000000";
		attribute frequency_pin_clkop of pll_i : label is "500.000000";
		attribute frequency_pin_clkos of pll_i : label is "500.000000";
		attribute frequency_pin_clkok of pll_i : label is "250.000000";

--		attribute frequency_pin_clki  of pll_i : label is to_string(1000/natural(sys_per));
--		attribute frequency_pin_clkop of pll_i : label is to_string(ddr_mul*1000/(natural(sys_per)*ddr_fbdiv));
--		attribute frequency_pin_clkos of pll_i : label is to_string(ddr_mul*1000/(natural(sys_per)*ddr_fbdiv));
--		attribute frequency_pin_clkok of pll_i : label is to_string(ddr_mul*1000/(natural(sys_per)*ddr_fbdiv*ddr_div));

		signal sclk : std_logic;
		signal eclk : std_logic;
		signal clkfb : std_logic;
		signal lock : std_logic;
		signal drpa : std_logic_vector(3 downto 0);
		signal dfpa : std_logic_vector(3 downto 0);
		signal pha  : std_logic_vector(3 downto 0);
		signal adjdll_rst  : std_logic;
		signal adjdll_rdy  : std_logic;
	begin
		drpa <= pha;
		dfpa <= not pha(3) & pha(2 downto 0);
		pll_i : ehxpllf
		generic map (
			CLKOS_TRIM_DELAY => 0,
			CLKOS_TRIM_POL => "RISING", 
			CLKOS_BYPASS => "DISABLED", 
			CLKOP_TRIM_DELAY => 0,
			CLKOP_TRIM_POL => "RISING", 
			CLKOP_BYPASS => "DISABLED", 
			CLKOK_INPUT => "CLKOP",
			CLKOK_BYPASS => "DISABLED", 
			DELAY_PWD => "DISABLED",
			DELAY_VAL => 0, 
			DUTY => 8,
			PHASE_DELAY_CNTL => "DYNAMIC",
			PHASEADJ => "0.0", 
			CLKOK_DIV => ddr_div,
			CLKOP_DIV => ddr_div,
			CLKFB_DIV => ddr_mul,
			CLKI_DIV  => ddr_fbdiv,
			FEEDBK_PATH => "INTERNAL",
			FIN => "100.000000")
		port map (
			rst   => pll_rst, 
			rstk  => '0',
			clki  => sys_clk,
			drpai3 => drpa(3), drpai2 => drpa(2), drpai1 => drpa(1), drpai0 => drpa(0), 
			dfpai3 => dfpa(3), dfpai2 => dfpa(2), dfpai1 => dfpa(1), dfpai0 => dfpa(0), 
			fda3   => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			wrdel => '0',
			clkintfb => clkfb,
			clkfb => clkfb,
			clkop => ddr_sclk2x, 
			clkos => eclk,
			clkok => sclk,
			clkok2 => open,

			lock  => lock);

		ddr_eclk <= eclk;
		ddr_sclk <= sclk;

		adjdll_rst <= not lock;
		adjdll_e : entity hdl4fpga.adjdll
		port map (
			rst => adjdll_rst,
			rdy => adjdll_rdy,
			sclk => sclk,
			eclk => eclk,
			pha => pha);
		ddr_pha <= pha;

		process(sclk, lock)
			variable q : std_logic_vector(0 to 6-1) := (others => '0');
		begin
			if lock='0' then
				q := (others => '0');
			elsif rising_edge(sclk) then
				if adjdll_rdy='1' then
					if q(0)='0' then
						q := inc(gray(q));
					end if;
				end if;
			end if;
			ddr_rst <= not q(0);
		end process;


	end block;

end;
