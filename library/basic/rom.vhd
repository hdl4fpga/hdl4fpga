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
		latency : natural := 0;
		bitrom : std_logic_vector);
	port (
		clk  : in  std_logic := '-';
		addr : in  std_logic_vector;
		data : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of rom is

	subtype word is std_logic_vector(data'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	impure function init_rom (
		constant bitdata : std_logic_vector;
		constant memsize : natural)
		return word_vector is

		variable retval : word_vector(0 to memsize-1) := (others => (others => '-'));
		variable aux    : std_logic_vector(0 to memsize*word'length-1) := (others => '-');

	begin
		aux(0 to bitdata'length-1) := bitdata;
		for i in retval'range loop
			retval(i) := aux(word'length*i to word'length*(i+1)-1);
		end loop;

		return retval;
	end;

	constant rom : word_vector(0 to 2**addr'length-1) := init_rom(bitrom, 2**addr'length);

begin


	synchronous1_g : if latency>0 generate
		process (clk)
			variable saddr : std_logic_vector(addr'range);
		begin
			if rising_edge(clk) then
				if latency=1 then
					data <= rom(to_integer(unsigned(addr)));
				else
					data <= rom(to_integer(unsigned(saddr)));
				end if;
				saddr := addr;
			end if;
		end process;
	end generate;

	synchronous0_g : if latency=0 generate
		data <= rom(to_integer(unsigned(addr)));
	end generate;

end;
