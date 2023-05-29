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

entity tx_manchester is
	port (
		txc  : in  std_logic;
		txen : in  std_logic;
		txd  : in  std_logic;
		tx   : out std_logic);
end;

architecture def of tx_manchester is
	signal clk_n : std_logic;
begin
	clk_n <= not txc;
	tx    <= txd xor clk_n when txen='1' else '0';
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_manchester is
	generic (
		oversampling : natural);
	port (
		rx   : in  std_logic;
		rxc  : in  std_logic;
		rxdv : out std_logic;
		rxd  : buffer std_logic);
end;

architecture def of rx_manchester is
begin
	process (rxc)
		variable cntr : natural range 0 to oversampling-1;
	begin
		if rising_edge(rxc) then
			if cntr > 0 then
				if cntr=1 then
					rxd <= rx;
				end if;
				cntr := cntr - 1;
			elsif (to_bit(rx) xor to_bit(rxd))='1' then
				cntr := oversampling-1;
			end if;
		end if;
	end process;
end;