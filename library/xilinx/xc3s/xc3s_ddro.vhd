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

entity ddro is
	port (
		clk : in std_logic;
		dr  : in std_logic;
		df  : in std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture spartan3 of ddro is
	signal fclk : std_logic;
begin
	fclk <= not clk;
	oddr_i : oddr2
	port map (
		c0 => clk,
		c1 => fclk,
		ce => '1',
		r  => '0',
		s  => '0',
		d0 => dr,
		d1 => df,
		q  => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity ddrto is
	port (
		clk : in std_logic;
		d : in std_logic;
		q : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture spartan3 of ddrto is
begin
	ffd_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clk,
		ce => '1',
		d  => d,
		q  => q);
end;
