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

entity miitx_crc is
    port (
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_tcrc : in  std_logic;
		mii_txi  : in  std_logic_vector;
		mii_txen : out std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture def of miitx_crc is
	constant p  : std_logic_vector := x"04c11db7";

	signal crc  : std_logic_vector(p'range);
	signal cntr : unsigned(0 to unsigned_num_bits(p'length/mii_txd'length-1));
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				crc  <= (others => '0');
				cntr <= to_unsigned(p'length/mii_txd'length-1, cntr'length);
			elsif mii_tcrc='0' then
				crc  <= not galois_crc(mii_txi, not crc, p);
				cntr <= to_unsigned(p'length/mii_txd'length-1, cntr'length);
			elsif cntr(0)='0' then
				crc <= std_logic_vector(unsigned(crc) sll mii_txd'length);
				cntr <= cntr - 1;
			end if;
		end if;
	end process;
	mii_txd  <= crc(mii_txd'range);
	mii_txen <= mii_treq and mii_tcrc and not cntr(0);
end;

