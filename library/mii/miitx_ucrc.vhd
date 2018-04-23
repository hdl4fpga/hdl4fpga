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
use ieee.numeric_std.all;

entity miitx is
end;

architecture def of main is
	constant p : std_logic_vector := x"04c11db7";
	constant d : std_logic_vector := x"0101"; --b"10110010011011";
	signal crc : unsigned(p'range) := (others => '1');
	signal crc1: std_logic_vector(p'range) := (others => '1');

	signal mii_txd  : std_logic;
    signal mii_txc  : std_logic := '0';
	signal mii_txi  : unsigned(d'range) := unsigned(d);

	function galois_crc(
		constant m : std_logic_vector;
		constant r : std_logic_vector;
		constant g : std_logic_vector)
		return std_logic_vector is
		variable aux_m : unsigned(0 to m'length-1) := unsigned(m);
		variable aux_r : unsigned(0 to r'length-1) := unsigned(r);
	begin
		for i in aux_m'range loop
			aux_r := (aux_r sll 1) xor ((aux_r'range => aux_r(0) xor aux_m(0)) and unsigned(g));
			aux_m := aux_m sll 1;
		end loop;
		return std_logic_vector(aux_r);
	end;

begin


	process (mii_txc)
		variable pp : std_logic_vector(d'range) := d;
	begin
		if rising_edge(mii_txc) then
			crc1 <= galois_crc(pp(0 to 8-1), crc1, p);
			pp   := std_logic_vector(unsigned(pp) sll 8);
		end if;
	end process;

end;

