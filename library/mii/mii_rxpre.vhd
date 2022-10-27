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
use hdl4fpga.base.all;

entity mii_rxpre is
    port (
		mii_clk  : in  std_logic;
		mii_frm  : in  std_logic;
		mii_irdy : in  std_logic;
		mii_trdy : out std_logic := '1';
        mii_data : in std_logic_vector;
		mii_pre  : buffer std_logic);
end;

architecture def of mii_rxpre is
begin
	process(mii_frm, mii_clk)
		variable vld  : std_logic;
		variable data : unsigned(0 to mii_data'length);
		variable cy   : std_logic;
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				vld  := '0';
				cy   := '0';
				data := (others => '0');
			elsif mii_irdy='1' then
				if vld ='0' then
					data := data(0) & unsigned(mii_data);

					for i in mii_data'range loop
						if (data(0) xnor data(1))='1' then
							if cy='1' then
								if data(0)='1' then
									vld := '1';
								end if;
							end if;
							cy := '0';
						else
							cy := '1';
						end if;
						data := data sll 1;
					end loop;
				end if;
			end if;
		end if;
		mii_pre <= mii_frm and vld;
	end process;
end;
