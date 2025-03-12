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
use hdl4fpga.profiles.all;

entity xc_dqsdelay is
	generic (
		device : fpga_devices;
		gear   : natural);
	port (
		clk    : in  std_logic;
		rst    : in  std_logic;
		delay  : in  std_logic_vector;
		dqsi   : in  std_logic;
		dqso   : out std_logic_vector(0 to gear-1));
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of xc_dqsdelay is
begin
	xc3s_g : if device=xc3s generate
		signal dqso_p : std_logic;
		signal dqso_n : std_logic;
	begin
		idelay_i : entity hdl4fpga.xc3s_dqsdelay
		port map (
			rst    => rst,
			clk    => clk,
			delay  => delay,
			dqsi   => dqsi,
			dqso_p => dqso_p,
			dqso_n => dqso_n);
		dqso <= (dqso_p, dqso_n);
	end generate;

	xc5v_g : if device=xc5v generate
		signal dataout : std_logic;
	begin
		idelay_i : entity hdl4fpga.xc5v_idelay
		generic map (
			delay_src      => string'("I"),
			signal_pattern => "CLOCK")
		port map (
			rst     => rst,
			clk     => clk,
			delay   => delay,
			idatain => dqsi,
			dataout => dataout);
		dqso <= (others => dataout);
	end generate;

	xc7a_g : if device=xc7a generate
		signal dataout : std_logic;
	begin
		idelay_i : entity hdl4fpga.xc7a_idelay
		generic map (
			delay_src      => "IDATAIN",
			signal_pattern => "CLOCK")
		port map (
			rst     => rst,
			clk     => clk,
			delay   => delay,
			idatain => dqsi,
			dataout => dataout);
		dqso <= (others => dataout);
	end generate;
end;