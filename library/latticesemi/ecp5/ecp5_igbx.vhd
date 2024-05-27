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

entity ecp5_igbx is
	generic (
		size : natural := 1;
		gear : natural);
	port (
		rst  : in std_logic := '0';
		sclk : in std_logic := '0';
		d    : in  std_logic_vector(0 to size-1);
		q    : out std_logic_vector(0 to size*gear-1));
end;

library ecp5u;
use ecp5u.components.all;

architecture beh of ecp5_igbx is
begin

	reg_g : for i in d'range generate
		gear1_g : if gear=1 generate
        	ff_i : fd1s3ax
        	port map (
        		ck => sclk,
        		d  => d(0),
        		q  => q(0));
		end generate;

		gear2_g : if gear=2 generate
			assert false
			report "No gear2 core yet"
			severity failure;
		end generate;

		gear4_g : if gear=4 generate
			assert false
			report "No gear4 core yet"
			severity failure;
		end generate;

	end generate;

end;
