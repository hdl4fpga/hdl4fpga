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

entity xc7a_idelay is
	generic (
		delay_src      : string := "I";
		signal_pattern : string := "DATA");
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of xc7a_idelay is
begin
	idelay_i : idelaye2
	generic map (
		idelay_type    => "VAR_LOAD",
		delay_src      => delay_src,
		signal_pattern => signal_pattern)
	port map (
		regrst     => rst,
		c          => clk,
		ld         => '1',
		cntvaluein => delay,
		idatain    => idatain,
		dataout    => dataout,
		cinvctrl   => '0',
		ce         => '0',
		inc        => '0',
		ldpipeen   => '0',
		datain     => '0');
end;