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

entity iofifo is
	port (
		in_clk   : in  std_logic;
		in_dv    : in  std_logic;
		in_data  : in  std_logic_vector;

		out_clk  : in  std_logic;
		out_ena  : in  std_logic;
		out_data : out std_logic_vector);
end;

architecture mix of iofifo is

	type ram is array(natural range <>) of std_logic_vector(in_data'range);
	signal mem : ram(2**4-1 downto 0);

begin

	process (in_clk)
		variable cntr : std_logic_vector(4-1 downto 0);
	begin
		if rising_edge(in_clk) then
			if in_dv='1' then
				cntr := std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(cntr))) + 1);
			end if;
			mem(to_integer(unsigned(cntr))) <= in_data;
		end if;
	end process;

	process (out_clk)
		variable cntr : std_logic_vector(4-1 downto 0);
	begin
		if rising_edge(out_clk) then
			if out_ena='1' then
				cntr := std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(cntr))) + 1);
			end if;
			out_data <= mem(to_integer(unsigned(cntr)));
		end if;
	end process;


end;
