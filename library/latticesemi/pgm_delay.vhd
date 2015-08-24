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

entity pgm_delay is
	generic (
		n : natural := 1;
		x : natural := 0;
		y : natural := 0);
	port (
		xi  : in  std_logic;
		ena : in  std_logic_vector(n-1 downto 0) := (others => '1');
		x_p : out std_logic;
		x_n : out std_logic);
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of pgm_delay is
	signal d : std_logic_vector(0 to n-1);
begin
	d(n-1) <= '-';
	chain_g: for i in n-1 downto 1 generate
	begin
		lut : lut4 
		generic map (
			init => x"00ca")
		port map (
			a => d(i),
			b => xi,
			c => ena(i),
			d => '0',
			z => d(i-1));
	end generate;
	lutp : lut4 
	generic map (
		init => x"00ca")
	port map (
		a => d(0),
		b => xi,
		c => ena(0),
		d => '0',
		z => x_p);
	lutn : lut4 
	generic map (
		init => x"0035")
	port map (
		a => d(0),
		b => xi,
		c => ena(0),
		d => '0',
		z => x_n);
end;
