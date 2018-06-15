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
		n : natural);
	port (
		mii_txc  : in  std_logic;
		mii_rena : in  std_logic := '1';
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_txdv : out  std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture beh of mii_1chksum is
	signal chksum : std_logic_vector(n-1 downto 0);
	signal txdv   : std_logic;
begin
	process (mii_txc)
		variable cntr : unsigned(0 to n/mii_txd'length-1);

		variable ci   : std_logic;
		variable arg1 : unsigned(mii_txd'length+1 downto 0);
		variable arg2 : unsigned(mii_txd'length+1 downto 0);
		variable sum  : unsigned(mii_txd'length+1 downto 0);
		variable aux  : unsigned(chksum'range) := (others => '0');
	begin
		if rising_edge(mii_txc) then
			if mii_rena='1' then
				aux  := unsigned(chksum);
				aux  := aux rol mii_txd'length;
				arg1 := '0' & aux(mii_rxd'length-1 downto 0) & ci;
				arg2 := (0 => '1', others => '0');
				cntr := cntr sll 1;
				if mii_rxdv='1' then
					arg2(mii_txd'length downto 1) := unsigned(reverse(mii_rxd));
					cntr(cntr'right) := '1';
				end if;
				sum  := arg1 + arg2;
				ci   := sum(sum'left);
				aux(mii_rxd'length-1 downto 0) := sum(mii_txd'length downto 1);
				if mii_rxdv='0' then
					if cntr(0)='0' then
						ci  := '0';
						aux := (others => '0');
					end if;
				end if;
				chksum <= std_logic_vector(aux);
			end if;
			txdv <= cntr(0);
		end if;
	end process;
	mii_txdv <= txdv and not mii_rxdv;
	mii_txd  <= chksum(mii_txd'reverse_range);
end;
