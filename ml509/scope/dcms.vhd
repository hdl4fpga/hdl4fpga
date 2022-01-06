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

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dcms is
	generic (
		ddr_mul : natural := 10;
		ddr_div : natural := 3;
		sys_per : real := 10.0);
	port (
		sys_rst     : in     std_logic;
		sys_clk     : in     std_logic;
		input_clk   : buffer std_logic;
		ddr_clk0    : buffer std_logic;
		ddr_clk90   : out    std_logic;
		gtx_clk     : buffer std_logic;
		ddr_rst     : out    std_logic;
		input_rst   : out    std_logic;
		gtx_rst     : out    std_logic);
end;

architecture def of dcms is

	---------------------------------------
	-- Frequency   -- 166 Mhz -- 450 Mhz --
	-- Multiply by --   5     --   9     --
	-- Divide by   --   3     --   2     --
	---------------------------------------

	signal dcm_rst : std_logic;

	signal ddr_lckd : std_logic;
	signal input_lckd : std_logic;
	signal iodctlr_lckd : std_logic;
	signal gtx_lckd : std_logic;
begin

	dcm_rst <= sys_rst;

	gmii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dfs_mode => "LOW",
		dcm_per => sys_per,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => sys_clk,
		dfs_clk => gtx_clk,
		dcm_lck => gtx_lckd);

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst => dcm_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => ddr_clk0,
		dfsdcm_clk90 => ddr_clk90,
		dfsdcm_lckd => ddr_lckd);

	inputdcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_mode => "LOW",
		dcm_per => sys_per,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => sys_clk,
		dfs_clk => input_clk,
		dcm_lck => input_lckd);

	rsts_b : block
		signal clks : std_logic_vector(0 to 2);
		signal rsts : std_logic_vector(clks'range);
		signal lcks : std_logic_vector(clks'range);
		signal grst : std_logic;
	begin
		process (sys_rst, sys_clk)
			variable sync1 : std_logic;
			variable sync2 : std_logic;
		begin
			if sys_rst='1' then
				grst  <= '1';
				sync1 := '1';
				sync2 := '1';
			elsif rising_edge(sys_clk) then
				grst  <= sync2;
				sync2 := sync1;
				sync1 := not (ddr_lckd and input_lckd and gtx_lckd);
			end if;
		end process;

		clks(0) <= input_clk;
		clks(1) <= gtx_clk;
		clks(2) <= ddr_clk0;

		lcks(0) <= input_lckd;
		lcks(1) <= gtx_lckd;
		lcks(2) <= ddr_lckd;

		input_rst <= rsts(0);
		gtx_rst   <= rsts(1);
		ddr_rst   <= rsts(2);

		rsts_g: for i in clks'range generate
		begin
			process (clks(i), grst)
				variable sync1 : std_logic;
				variable sync2 : std_logic;
			begin
				if grst='1' then
					rsts(i) <= '1';
					sync1   := '1';
					sync2   := '1';
				elsif rising_edge(clks(i)) then
					rsts(i) <= sync2;
					sync2   := sync1;
					sync1   := not lcks(i);
				end if;
			end process;
		end generate;
	end block;
end;
