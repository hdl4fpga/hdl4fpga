--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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
use ieee.std_logic_textio.all;

use std.textio.all;

entity main is
end;

architecture ip_checksum of main is

	function oneschecksum (
		constant data : std_logic_vector;
		constant size : natural)
		return std_logic_vector is
		constant n : natural := (data'length+size-1)/size;
		variable aux : unsigned(0 to data'length-1);
		variable checksum : unsigned(0 to size);
	begin
		aux := unsigned(data);
		checksum := (others => '0');
		for i in 0 to n-1 loop
			checksum := checksum + resize(unsigned(aux(0 to checksum'right-1)), checksum'length);
			if checksum(0)='1' then
				checksum := checksum + 1;
			end if;
			aux := aux sll checksum'right;
		end loop;
		return std_logic_vector(checksum(1 to size));	
	end;

	function ipheader_checksum(
		constant ipheader : std_logic_vector)
		return std_logic_vector is
		variable aux : std_logic_vector(0 to ipheader'length-1);
	begin
		aux := ipheader;
		aux(80 to 96-1) := not checksum(ipheader, 16);
		return aux;
	end;
begin

	process
		variable msg : line;
	begin
		hwrite (msg, ipheader_checksum (
			x"4500"     & 
			x"021c"     & 
			x"0000"     & 
			x"0000"     & 
			x"0511"     & 
			x"0000"     & 
			x"c0a802c8" & 
			x"ffffffff"));
		writeline (output, msg);
		wait;
	end process;
end;
