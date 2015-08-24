--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity dbram is
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		we  : in  std_logic;
		wa  : in  std_logic_vector(4-1 downto 0);
		di  : in  std_logic_vector(n-1 downto 0);
		ra  : in  std_logic_vector(4-1 downto 0);
		do  : out  std_logic_vector(n-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of dbram is
begin
	ram_g : for i in n-1 downto 0 generate
		ram_i : ram16x1d
		port map (
			wclk => clk,
			we  => we,
			a0 => wa(0),
			a1 => wa(1),
			a2 => wa(2),
			a3 => wa(3),
			d  => di(i),
			dpra0 => ra(0),
			dpra1 => ra(1),
			dpra2 => ra(2),
			dpra3 => ra(3),
			dpo => do(i),
			spo => open);
	end generate;
end;
