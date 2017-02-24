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

entity cntrtab is
	generic (
		tab : natural_vector);
	port (
		clk : in  std_logic;
		ld  : in  std_logic;
		val : in  std_logic;
		cnt : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of cntrtab is
	subtype word is unsigned(cnt'range);
	type word_vector is array (natural range <>) of word;

	function to_wordvector (
		constant tab : natural_vector)
		return word_vector is
		variable retval : word_vector(tab'range);
	begin
		for i in tab'range loop
			retval(i) := to_unsigned(tab(i),retval(i)'length);
		end loop;
		return retval;
	end;

	constant wtab : word_vector(tab'range) := to_wordvector(tab);
	signal   cntr : word;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if ld='1' then
				cntr <= wtab(to_integer(val));
			else
				cntr <= cntr - 1;
			end if;
		end if;
	end process;

	cnt <= cntr;
end;
