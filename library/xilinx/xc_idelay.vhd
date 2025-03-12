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

entity xc_idelay is
	generic (
		device         : fpga_devices;
		signal_pattern : string);
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of xc_idelay is
begin
	xc5v_g : if device=xc5v generate
		idelay_i : entity hdl4fpga.xc5v_idelay
		generic map (
			delay_src      => string'("I"),
			signal_pattern => signal_pattern)
		port map (
			rst     => rst,
			clk     => clk,
			delay   => delay,
			idatain => idatain,
			dataout => dataout);
	end generate;

	xc7a_g : if device=xc7a generate
		idelay_i : entity hdl4fpga.xc7a_idelay
		generic map (
			delay_src      => "IDATAIN",
			signal_pattern => signal_pattern)
		port map (
			rst     => rst,
			clk     => clk,
			delay   => delay,
			idatain => idatain,
			dataout => dataout);
	end generate;
end;