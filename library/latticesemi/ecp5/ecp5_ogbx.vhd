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

library ecp5u;
use ecp5u.components.all;

entity ecp5_ogbx is
	generic (
		size      : natural;
		gear      : natural);
	port (
		rst  : in  std_logic := '0';
		sclk : in  std_logic;
		eclk : in std_logic := '0';
		t    : in  std_logic_vector(0 to gear*size-1) := (others => '0');
		tq   : out std_logic_vector(0 to size-1);
		d    : in  std_logic_vector(0 to gear*size-1);
		q    : out std_logic_vector(0 to size-1));
end;

architecture beh of ecp5_ogbx is
begin

	reg_g : for i in q'range generate
	begin
		gear1_g : if gear = 1 generate
			ffd_i : fd1s3ax
			port map (
				ck => sclk,
				d  => d(i),
				q  => q(i));
		end generate;

		gear2_g : if gear=2 generate
    		oddr_i : oddrx1f
    		port map (
    			rst  => rst,
    			sclk => sclk,
    			d0   => d(gear*i+0),
    			d1   => d(gear*i+1),
    			q    => q(i));
		end generate;

		gear4_g : if gear=4 generate
		end generate;

	end generate;

end;
