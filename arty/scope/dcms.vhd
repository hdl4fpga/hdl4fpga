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
		SYS_PER       : real;
		DDR_MUL       : real;
		DDR_DIV       : natural;
		DDR_GEAR      : natural);
	port (
		sys_rst       : in  std_logic;
		sys_clk       : in  std_logic;
		ioctrl_clk    : out std_logic;
		input_clk     : out std_logic;
		ddr_clk0      : out std_logic;
		ddr_clk0div   : out std_logic;
		ddr_clk90     : out std_logic;
		ddr_clk90div  : out std_logic;
		ioctrl_rst    : out std_logic;
		input_rst     : out std_logic;
		ddr0div_rst   : out std_logic;
		ddr90div_rst  : out std_logic);
end;

architecture def of dcms is

	constant input             : natural := 0; 
    constant ddr0div           : natural := 1;
    constant ddr90div          : natural := 2;
    constant ioctrl            : natural := 3;

	signal ddr_clkfb           : std_logic;
	signal ddr_clk0_mmce2      : std_logic;
	signal ddr_clk0div_mmce2   : std_logic;
	signal ddr_clk90_mmce2     : std_logic;
	signal ddr_clk90div_mmce2  : std_logic;
	signal ddr_clk270div_mmce2 : std_logic;

	signal ioctrl_clkfb : std_logic;
	signal clks : std_logic_vector(0 to ioctrl);
	signal lcks : std_logic_vector(clks'range);
begin

	ioctrl_i :  mmcme2_base
	generic map (
		clkfbout_mult_f => 8.0,		-- 200 MHz
		clkin1_period => sys_per,
		clkout0_divide_f => 4.0,
		bandwidth => "LOW")
	port map (
		pwrdwn   => '0',
		rst      => sys_rst,
		clkin1   => sys_clk,
		clkfbin  => ioctrl_clkfb,
		clkfbout => ioctrl_clkfb,
		clkout0  => clks(ioctrl),
		locked   => lcks(ioctrl));
   
	ddr_i :  mmcme2_base
	generic map (
		divclk_divide => ddr_div,
		clkfbout_mult_f => 2.0*ddr_mul,
		clkin1_period => sys_per,
		clkout1_phase => 90.0+180.0,
		clkout3_phase => 90.0/real((DDR_GEAR/2))+270.0,
		clkout0_divide_f => real(DDR_GEAR/2),
		clkout1_divide => DDR_GEAR/2,
		clkout2_divide => DDR_GEAR,
		clkout3_divide => DDR_GEAR)
	port map (
		pwrdwn   => '0',
		rst      => sys_rst,
		clkin1   => sys_clk,
		clkfbin  => ddr_clkfb,
		clkfbout => ddr_clkfb,
		clkout0  => ddr_clk0_mmce2,
		clkout1  => ddr_clk90_mmce2,
		clkout2  => ddr_clk0div_mmce2,
		clkout3  => ddr_clk90div_mmce2,
		locked   => lcks(ddr0div));
	lcks(ddr90div) <= lcks(ddr0div);
    
	ddr_clk0_bufg : bufio
	port map (
		i => ddr_clk0_mmce2,
		o => ddr_clk0);

	ddr_clk90_bufg : bufio
	port map (
		i => ddr_clk90_mmce2,
		o => ddr_clk90);

	ddr_clk0div_bufg : bufg
	port map (
		i => ddr_clk0div_mmce2,
		o => clks(ddr0div));

	ddr_clk90div_bufg : bufg
	port map (
		i => ddr_clk90div_mmce2,
		o => clks(ddr90div));

	clks(input) <= sys_clk;
	lcks(input) <= not sys_rst;

	rsts_b : block
		signal rsts : std_logic_vector(clks'range);
	begin

		input_rst    <= rsts(input);
		ddr0div_rst  <= rsts(ddr0div);
		ddr90div_rst <= rsts(ddr90div);
		ioctrl_rst   <= rsts(ioctrl);

		rsts_g: for i in clks'range generate
			signal q : std_logic_vector(0 to 1);
		begin
			process (clks(i), sys_rst)
			begin
				if sys_rst='1' then
					q <= (others => '1');
				elsif rising_edge(clks(i)) then
					q <= q(1 to q'right) & not lcks(i);
				end if;
			end process;
			rsts(i) <= q(0);
		end generate;
	end block;

	input_clk    <= clks(input);
	ddr_clk0div  <= clks(ddr0div);
	ddr_clk90div <= clks(ddr90div);
	ioctrl_clk   <= clks(ioctrl);

end;
