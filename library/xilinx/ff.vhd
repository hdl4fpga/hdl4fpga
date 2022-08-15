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

entity sff is
	port (
		clk : in  std_logic;
		sr  : in  std_logic;
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of sff is
begin
	ffd_i : fdrse
	port map (
		c  => clk,
		ce => '1',
		s  => '0',
		r  => sr,
		d  => d,
		q  => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity aff is
	port (
		ar  : in  std_logic;
		clk : in  std_logic;
		ena : in  std_logic := '1';
		d   : in  std_logic;
		q   : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of aff is
begin
	ffd_i : fdcpe
	port map (
		pre => '0',
		clr => ar,
		c   => clk,
		ce  => ena,
		d   => d,
		q   => q);
end;
