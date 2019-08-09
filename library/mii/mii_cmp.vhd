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

entity mii_cmp is
    port (
        mii_rxc    : in  std_logic;
		mii_req    : in  std_logic;
		mii_rdy    : in  std_logic;
		mii_ena    : in  std_logic := '1';
        mii_rxd1   : in  std_logic_vector;
        mii_rxd2   : in  std_logic_vector;
		mii_equ    : out std_logic;
		mii_equrdy : out std_logic);
end;

architecture def of mii_cmp is
	signal eq : std_logic;
begin

	process (mii_rxc)
		variable cy : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if mii_req='0' then
				cy := '1';
				eq <= '0';
			elsif mii_rdy='0' then
				if mii_ena='1' then
					cy := cy and setif(mii_rxd1=mii_rxd2);
					eq <= cy;
				end if;
			end if;
		end if;
	end process;
	mii_equ    <= eq;
	mii_equrdy <= eq and mii_rdy;
end;
