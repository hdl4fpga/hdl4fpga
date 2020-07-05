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

entity eth_crc32 is
    port (
        mii_txc  : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rxdv : in  std_logic;
		mii_txdv : out std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture def of eth_crc32 is
	signal crc  : std_logic_vector(0 to 32-1);
	signal cntr : unsigned(0 to unsigned_num_bits(32/mii_txd'length-1));
	signal edge : std_logic;
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_rxdv='1' then
				crc  <= not galois_crc(mii_rxd, word2byte((crc'range => '1') & not crc, edge), x"04c11db7");
				cntr <= to_unsigned(32/mii_txd'length-1, cntr'length);
			elsif cntr(0)='0' then
				crc <= std_logic_vector(unsigned(crc) rol mii_txd'length);
				cntr <= cntr - 1;
			end if;
			edge <= mii_rxdv;
		end if;
	end process;

	mii_txd  <= crc(mii_txd'range);
	mii_txdv <= not mii_rxdv and setif(cntr(0)='0');
end;

