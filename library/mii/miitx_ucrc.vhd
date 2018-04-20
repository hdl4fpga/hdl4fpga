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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity main is
end;

architecture def of main is
	constant p : std_logic_vector := b"111001"; --x"04c11db7";
	signal crc : std_logic_vector(p'range) := (others => '0');

	signal mii_txd  : std_logic;
    signal mii_txc  : std_logic := '0';
	signal mii_txi  : unsigned(0 to 13) := b"10110010011011";
begin

	mii_txc <= not mii_txc after 1 ns;

	process (mii_txc)
		variable r : unsigned(crc'range);
	begin
		if rising_edge(mii_txc) then
			r    := unsigned(crc);
			r(0) := mii_txi(0);
			r    := (r rol 1) xor ((r'range => crc(0)) and unsigned(p));
			crc     <= std_logic_vector(r);
			mii_txi <= mii_txi sll 1;

		end if;
	end process;

end;

