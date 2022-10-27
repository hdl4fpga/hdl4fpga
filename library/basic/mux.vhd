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

entity mux is
	generic (
		m : natural);
	port (
		sel : in  std_logic_vector(m-1 downto 0);
		di  : in  std_logic_vector(0 to 2**m-1);
		do  : out std_logic);
end;

architecture arch of mux is
begin
	do <= di(to_integer(unsigned(sel)));
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity muxw is
	generic (
		addr_size : natural;
		data_size : natural);
	port (
		sel : in  std_logic_vector(addr_size-1 downto 0);
		di  : in  std_logic_vector(0 to 2**addr_size*data_size-1);
		do  : out std_logic_vector(0 to data_size-1));
end;

architecture arch of muxw is
begin
	mux_g : for i in 0 to data_size-1 generate
		signal d : std_logic_vector(0 to 2**addr_size-1);
	begin
		process (di)
		begin
			for j in 0 to 2**addr_size-1 loop
				d(j) <= di(data_size*j+i);
			end loop;
		end process;

		do(i) <= d(to_integer(unsigned(sel)));
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demux is
	generic (
		n : natural);
	port (
		s : in  std_logic_vector(n-1 downto 0);
		e : in  std_logic := '1';
		o : out std_logic_vector(2**n-1 downto 0));
end;

architecture arch of demux is
begin
	process (e,s)
	begin
		o <= (others => '0');
		o(to_integer(unsigned(s))) <= e;
	end process;
end;
