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

entity rom is
	generic (
		synchronous : natural := 1;
		bitrom : std_logic_vector);
	port (
		clk  : in  std_logic := '-';
		addr : in  std_logic_vector;
		data : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of rom is

	subtype word is std_logic_vector(data'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	impure function init_rom (
		constant arg : std_logic_vector)
		return word_vector is

		variable aux : std_logic_vector(0 to data'length*2**addr'length-1) := (others => '-');
		variable val : word_vector(0 to 2**addr'length-1) := (others => (others => '-'));

	begin
		aux(0 to arg'length-1) := arg;
		for i in val'range loop
			val(i) := aux(word'length*i to word'length*(i+1)-1);
		end loop;

		return val;
	end;

	constant rom : word_vector(0 to 2**addr'length-1) := init_rom(bitrom);

begin

	synchronous1_g : if synchronous>0 generate
		process (clk)
			variable saddr : std_logic_vector(addr'range);
		begin
			if rising_edge(clk) then
				if synchronous=1 then
					data <= rom(to_integer(unsigned(addr)));
				else
					data <= rom(to_integer(unsigned(saddr)));
				end if;
				saddr := addr;
			end if;
		end process;
	end generate;

	synchronous0_g : if synchronous=0 generate
		data <= rom(to_integer(unsigned(addr)));
	end generate;

end;
