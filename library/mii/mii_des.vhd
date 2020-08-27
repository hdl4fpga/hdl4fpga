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
use hdl4fpga.std.all;

entity mii_des is
    port (
        mii_rxc  : in  std_logic;
        mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		des_data : out  std_logic_vector);
end;

architecture def of mii_des is
begin

	process (mii_rxc)
		variable data : unsigned(0 to des_data'length-1);
	begin
		if rising_edge(mii_rxc) then
			if mii_rxdv='1' then
				data(0 to mii_rxd'length-1) := unsigned(mii_rxd);
				data := data rol mii_rxd'length;
			end if;
			des_data <= reverse(std_logic_vector(data),8);
		end if;
	end process;

end;
