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

entity mii_1chksum is
	generic (
		size     : natural);
	port (
		mii_txc  : in  std_logic;
		mii_rena : in  std_logic := '1';
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_txdv : out  std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture beh of mii_1chksum is
begin

	process (mii_rxc)
		variable cy  : std_logic;
		variable add : unsigned(0 to mii_rxdv'lentgh+1);
		variable acc : unsigned(0 to mii_rxdv'lentgh+1);
	begin
		if rising_edge(mii_rxc) then
			if mii_rxdv='0' then
				acc := (others => '0');
				cy  := '0';
			else
				add := unsigned'('0' & rxd) + unsigned'('0' & acc(rxd'reverse_range);
				cy  := add(0);
				acc(rxd'range) <= std_logic_vector(add(1 to rxd'length);
				acc := acc ror rxd'length;
				acc := acc(rxd'reverse_range) + cy;
			end if;
		end if;
end;
