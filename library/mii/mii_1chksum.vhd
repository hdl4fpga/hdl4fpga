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
	port (
		chksumi  : in  std_logic_vector;
		mii_txc  : in  std_logic;
		mii_rena : in  std_logic := '1';
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_txdv : out  std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture beh of mii_1chksum is
	signal chksum : unsigned(0 to chksumi'length-1);
begin
	process (mii_txc)
		variable aux  : unsigned(0 to mii_txd'length+1);
		variable sum  : unsigned(chksum'range);
		variable cntr : unsigned(0 to chksumi'length/mii_txd'length-1);
	begin
		if rising_edge(mii_txc) then
			if mii_rxdv='0' then
				aux    := (others => '0');
				sum    := unsigned(chksumi);
				cntr   := cntr sll 1;
				chksum <= chksum rol mii_txd'length;
			elsif mii_rena='1' then
				sum := sum ror mii_txd'length;
				aux := aux rol 1;
				aux(mii_txd'range) := sum(mii_txd'range);
				aux := aux srl 1;
				aux := aux + ("0" & unsigned(reverse(mii_rxd)) & "1");
				aux := aux rol 1;
				sum(mii_txd'range) := aux(mii_txd'range);
				chksum <= unsigned(reverse(std_logic_vector(sum + aux(aux'right to aux'right))));
				cntr := cntr sll 1;
				cntr(cntr'right) := '1';
			end if;
			mii_txdv <= cntr(0);
		end if;
	end process;
	mii_txd <= std_logic_vector(chksum(mii_txd'range));
end;
