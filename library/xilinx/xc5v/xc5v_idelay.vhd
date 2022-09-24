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

entity xc5v_idelay is
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library hdl4fpga;

library unisim;
use unisim.vcomponents.all;

architecture def of xc5v_idelay is

	signal ce    : std_logic;
	signal inc   : std_logic;
	signal del   : std_logic_vector(delay'range);
	
begin

	del <= to_stdlogicvector(to_bitvector(delay));
	adjser_i : entity hdl4fpga.adjser
	generic map (
		tap_value => 0)
	port map (
		clk   => clk,
		rst   => rst,
		delay => del,
		ce    => ce,
		inc   => inc);

	idelay_i : idelay
	generic map (
		IOBDELAY_VALUE => 0,
		IOBDELAY_TYPE => "VARIABLE")
	port map (
		c    => clk,
		rst  => rst,
		ce   => ce,
		inc  => inc,
		i    => idatain,
		o    => dataout);
end;