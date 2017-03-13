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

entity miirx_pre is
    port (
		mii_rxc  : in std_logic;
        mii_rxdv : in std_logic;
        mii_rxd  : in std_logic_vector;
		mii_prdy : out std_logic);

end;

architecture def of miirx_pre is
	signal prdy : std_logic;
begin

	process(mii_rxc)
		variable data : unsigned(0 to mii_txd'length);
		variable carr : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if mii_rxdv='0' then
				prdy <= '0';
				carr := '0';
				data := (others => '0');
			elsif mii_rxdv='1' then
				if prdy='0' the 
					data := data(0) & mii_rxd;
					for i in mii_rxd'range loop
						if (data(0) xnor data(1))='1' then
							if carr='1' then
								if data(0)='1' then
									prdy <= '1';
								end if;
							end if;
							carr := '0'
						else
							carr := '1'
						end if;
						data := data sll 1;
					end loop;
				end if;
			end if;
		end if;
	end process;
	mii_prdy <= prdy;

end;
